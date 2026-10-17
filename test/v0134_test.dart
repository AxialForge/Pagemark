import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/finding.dart';
import 'package:pagemark/lookup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/privacy.dart';

void main() {
  group('PGM-100 and PGM-105: restore points', () {
    late Directory tmp;
    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('pgm100');
      AppDb.debugDir = Directory('${tmp.path}/app')..createSync();
      Exporter.debugTmp = Directory('${tmp.path}/tmp')..createSync();
    });
    tearDown(() async {
      AppDb.debugDir = null;
      Exporter.debugTmp = null;
      await tmp.delete(recursive: true);
    });

    Future<File> makeDb(Directory d, String name, String title) async {
      final f = File('${d.path}/$name');
      final db = AppDb.forFile(f);
      await db.into(db.books).insert(BooksCompanion.insert(title: title));
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      await db.close();
      return f;
    }

    Future<String> liveTitle() async {
      final db = AppDb.forFile(await AppDb.file());
      final t = (await db.select(db.books).get()).single.title;
      await db.close();
      return t;
    }

    test('restoring from the OLDEST of three restore points works and does not delete its own source', () async {
      await makeDb(AppDb.debugDir!, 'pagemark.sqlite', 'Live');
      for (final t in ['A', 'B', 'C', 'D']) {
        final backup = await makeDb(tmp, '$t.sqlite', t);
        final db = AppDb.forFile(await AppDb.file());
        await Exporter.restoreDb(db, backup); // no waiting between restores: names never collide
      }
      var points = await Exporter.restorePoints();
      expect(points.length, 3, reason: 'newest three kept');
      final oldest = points.last; // holds the library as it was before the third restore
      final db = AppDb.forFile(await AppDb.file());
      await Exporter.restoreDb(db, oldest); // making a 4th point would have pruned `oldest` before it was copied
      expect(await liveTitle(), isNotEmpty);
      points = await Exporter.restorePoints();
      expect(points.length, 3);
      expect(await File('${AppDb.debugDir!.path}/pagemark.sqlite.incoming').exists(), isFalse);
    });

    test('two copies made in the same second get different names', () async {
      await makeDb(AppDb.debugDir!, 'pagemark.sqlite', 'Live');
      final db = AppDb.forFile(await AppDb.file());
      final a = await Exporter.safetyCopy(db, 'pre-import');
      final b = await Exporter.safetyCopy(db, 'pre-import');
      await db.close();
      expect(a.path == b.path, isFalse);
      expect(await a.exists() && await b.exists(), isTrue);
    });
  });

  group('PGM-127: Undo of Mark finished', () {
    test('a read that was created is removed by Undo, but kept once the user has edited anything on it', () async {
      final db = AppDb.memory();
      final a = await db.into(db.books).insert(BooksCompanion.insert(title: 'A'));
      final b = await db.into(db.books).insert(BooksCompanion.insert(title: 'B'));
      final u = await db.markFinishedToday([a, b]);
      expect(u.created.length, 2);
      final rb = await (db.select(db.reads)..where((r) => r.bookId.equals(b))).getSingle();
      await (db.update(db.reads)..where((r) => r.id.equals(rb.id))).write(const ReadsCompanion(minutes: Value(45)));
      await db.undoMarkFinished(u);
      final left = await db.select(db.reads).get();
      expect(left.map((r) => r.bookId).toList(), [b], reason: 'the edited read stays, the untouched one goes');
      await db.close();
    });
  });

  group('PGM-203: leftover exports in the cache are really deleted', () {
    test('the share sheet and file picker folders, export files and the restore copy go; other files stay', () async {
      final dir = Directory.systemTemp.createTempSync('pgm203');
      addTearDown(() => dir.deleteSync(recursive: true));
      File('${dir.path}/share_plus/one/locked.csv').createSync(recursive: true);
      File('${dir.path}/file_picker/backup.pgbak').createSync(recursive: true);
      File('${dir.path}/pagemark-export-1.csv').createSync();
      File('${dir.path}/restore.sqlite').createSync();
      File('${dir.path}/keep.txt').createSync();
      Directory('${dir.path}/other_plugin').createSync();
      await cleanTempExports(dir: dir);
      final left = dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last).toList()..sort();
      expect(left, ['keep.txt', 'other_plugin']);
    });
  });

  group('PGM-113: imported dates', () {
    test('a date that does not exist is refused in every written form', () {
      for (final bad in ['2023-02-29', '02/29/2023', '2/30/2024', '2023/02/30', '2023.02.31', '2023-04-31T10:00:00Z', '2023-13-01']) {
        expect(Importer.parseDate(bad), isNull, reason: bad);
      }
    });

    test('real dates still parse, and a timestamp keeps the day written in it', () {
      expect(Importer.parseDate('2024-02-29'), DateTime(2024, 2, 29));
      expect(Importer.parseDate('2/29/2024'), DateTime(2024, 2, 29));
      expect(Importer.parseDate('2023/05/14'), DateTime(2023, 5, 14));
      expect(Importer.parseDate('2023-05-14T23:30:00-08:00'), DateTime(2023, 5, 14), reason: 'UTC conversion must not move it to the 15th');
      expect(Importer.parseDate('2023-05-14T00:30:00+09:00'), DateTime(2023, 5, 14), reason: 'nor to the 13th');
      expect(Importer.parseDate('2023-05-14 10:00:00'), DateTime(2023, 5, 14));
    });
  });

  group('Tidy genres (0.13.4)', () {
    test('repeats, catalogue labels and places or characters go; the rest, the order and the capitals stay', () {
      expect(Lookup.tidyGenre('Fantasy, fantasy, Fiction, general, Dune (Imaginary place)'), 'Fantasy');
      expect(Lookup.tidyGenre('Science fiction, Science-fiction, American literature'), 'Science fiction, American literature');
      expect(Lookup.tidyGenre('cozy mystery, Humour, Thriller, Crime'), 'cozy mystery, Humour, Thriller, Crime', reason: 'no limit of three, no change of capitals');
      expect(Lookup.tidyGenre('General'), 'General', reason: 'never blanks out what the owner typed');
      expect(Lookup.tidyGenre('Romance'), 'Romance');
    });

    test('only unlocked, live books with something to tidy are offered; applying and undoing restore every genre exactly', () async {
      final db = AppDb.memory();
      Future<int> add(String t, String g, {bool locked = false}) =>
          db.into(db.books).insert(BooksCompanion.insert(title: t, genre: Value(g), locked: Value(locked)));
      final a = await add('A', 'Fantasy, fantasy, General');
      await add('B', 'Crime');
      await add('C', '');
      await add('Secret', 'Romance, romance', locked: true);
      final gone = await add('Trashed', 'SF, sf');
      await db.softDelete(gone);
      final fixes = await genreFixes(db);
      expect(fixes.map((f) => f.id), [a]);
      expect(fixes.single.after, 'Fantasy');
      await applyGenreFixes(db, fixes);
      expect((await (db.select(db.books)..where((b) => b.id.equals(a))).getSingle()).genre, 'Fantasy');
      await applyGenreFixes(db, fixes, undo: true);
      expect((await (db.select(db.books)..where((b) => b.id.equals(a))).getSingle()).genre, 'Fantasy, fantasy, General');
      expect(await genreFixes(db), hasLength(1));
      await db.close();
    });
  });
}
