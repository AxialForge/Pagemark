import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/volume.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  group('volume parser', () {
    void ok(String title, String series, double n, {bool sure = true, String edition = ''}) {
      final g = parseVolume(title);
      expect(g, isNotNull, reason: title);
      expect([g!.series, g.number, g.sure], [series, n, sure], reason: title);
      if (edition.isNotEmpty) expect(g.edition.toLowerCase(), contains(edition.toLowerCase()), reason: title);
    }

    test('the table in the design', () {
      ok('One Piece, Vol. 12', 'One Piece', 12);
      ok('Berserk Volume 2', 'Berserk', 2);
      ok('Naruto, Vol. 05', 'Naruto', 5);
      ok('Fullmetal Alchemist (3-in-1 Edition), Vol. 4', 'Fullmetal Alchemist', 4, sure: false, edition: '3-in-1');
      ok('Attack on Titan #7', 'Attack on Titan', 7);
      ok('Berserk Deluxe Edition Volume 2', 'Berserk', 2, edition: 'Deluxe Edition');
      ok('Dragon Ball Z Omnibus 3', 'Dragon Ball Z', 3, sure: false);
    });

    test('other spellings', () {
      ok('Bleach - Vol. 7', 'Bleach', 7);
      ok('Harry Potter and the Goblet of Fire: Book 4', 'Harry Potter and the Goblet of Fire', 4);
      ok('Akira, Volume IV', 'Akira', 4);
      ok('Vinland Saga Vol. 2.5', 'Vinland Saga', 2.5);
      ok('Monster, Vols. 1-3', 'Monster', 1, sure: false);
      ok('Spy x Family, No. 9', 'Spy x Family', 9);
    });

    test('plain titles are never volumes', () {
      for (final t in ['Fahrenheit 451', 'Catch-22', 'Apollo 13', 'The Hobbit', 'Vol. 5', '#7', 'Book 3', 'Dune', '', '   ', '1984', 'Ocean #', 'Volume']) {
        expect(parseVolume(t), isNull, reason: t);
      }
    });

    test('a roman numeral needs a volume word; absurd numbers are refused', () {
      expect(parseVolume('Rocky #IV'), isNull);
      expect(parseVolume('Series Vol. 99999'), isNull);
      expect(parseVolume('Series Vol. 0'), isNull);
      expect(parseVolume('X' * 400 + ' Vol. 2'), isNull);
    });

    test('fuzz: never throws, and a guess always has a name and a sensible number', () {
      final words = ['One', 'Piece', 'Vol.', 'Volume', '#', '12', 'iv', ',', '-', '(', ')', 'Edition', 'Omnibus', 'Book', '0', '1-3', '2.5', 'No.', ' '];
      var seed = 7;
      int next() => seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      for (var i = 0; i < 3000; i++) {
        final t = [for (var j = 0; j < 1 + next() % 7; j++) words[next() % words.length]].join(next() % 2 == 0 ? ' ' : '');
        final g = parseVolume(t);
        if (g != null) {
          expect(g.series.trim(), isNotEmpty, reason: t);
          expect(g.number, inExclusiveRange(0, 10000), reason: t);
        }
      }
    });
  });

  group('schema 7', () {
    test('a schema 6 database gains kind, owned and series info, keeping its rows', () async {
      final dir = Directory.systemTemp.createTempSync('pgm110');
      final f = File('${dir.path}/v6.sqlite');
      final raw = sql.sqlite3.open(f.path);
      raw.execute('''
        CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '', isbn TEXT NOT NULL DEFAULT '',
          cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '', series TEXT NOT NULL DEFAULT '', series_number REAL NULL, series_total INTEGER NULL,
          publisher TEXT NOT NULL DEFAULT '', year INTEGER NULL, pages INTEGER NULL, description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '',
          notes TEXT NOT NULL DEFAULT '', locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0, 1)), added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
          deleted_at INTEGER NULL, queue_pos INTEGER NULL);
        INSERT INTO books (title, series, series_number, series_total) VALUES ('Berserk 1', 'Berserk', 1, 20), ('Berserk 2', ' berserk ', 2, 41), ('Dune', '', NULL, NULL);
        INSERT INTO books (title, series, series_total, locked) VALUES ('Secret 1', 'Berserk', 5, 1);
        PRAGMA user_version = 6;
      ''');
      raw.close();
      final db = AppDb.forFile(f);
      final books = await db.select(db.books).get();
      expect(books.map((b) => b.title), ['Berserk 1', 'Berserk 2', 'Dune', 'Secret 1']);
      expect(books.every((b) => b.kind == '' && b.owned), isTrue);
      final main = await db.seriesInfoFor('Berserk', locked: false);
      expect([main?.total, main?.status], [41, '']);
      final vault = await db.seriesInfoFor('berserk', locked: true);
      expect(vault?.total, 5, reason: 'the locked library keeps its own row');
      expect(await db.select(db.seriesInfo).get(), hasLength(2), reason: 'books with no series get no row');
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('series info is per library and updates in place', () async {
      final db = AppDb.memory();
      await db.setSeriesInfo('Naruto', locked: false, total: 72);
      await db.setSeriesInfo(' naruto', locked: false, status: 'complete');
      await db.setSeriesInfo('Naruto', locked: true, total: 3);
      final main = await db.seriesInfoFor('NARUTO', locked: false);
      expect([main!.total, main.status, main.name], [72, 'complete', 'Naruto']);
      expect((await db.seriesInfoFor('Naruto', locked: true))!.total, 3);
      await db.setSeriesInfo('Naruto', locked: false, clearTotal: true);
      expect((await db.seriesInfoFor('Naruto', locked: false))!.total, isNull);
      await db.setSeriesInfo('   ', locked: false, total: 1);
      expect(await db.select(db.seriesInfo).get(), hasLength(2));
      await db.close();
    });

    test('kind, owned and series status survive export and import', () async {
      final src = AppDb.memory();
      await src.into(src.books).insert(BooksCompanion.insert(
          title: 'Berserk, Vol. 3', series: const Value('Berserk'), seriesNumber: const Value(3), kind: const Value('manga'), owned: const Value(false), seriesTotal: const Value(41)));
      await src.into(src.books).insert(BooksCompanion.insert(title: 'Plain'));
      await src.setSeriesInfo('Berserk', locked: false, total: 41, status: 'ongoing');
      final csv = Exporter.toCsv(await Exporter.rows(src));
      expect(csv.split('\n').first, allOf(contains('kind'), contains('owned'), contains('series_status')));
      final dst = AppDb.memory();
      final plan = await ImportRunner.plan(dst, Importer.parse(csv));
      await ImportRunner.run(dst, plan, DuplicatePolicy.skip);
      final b = (await dst.select(dst.books).get()).firstWhere((b) => b.series == 'Berserk');
      expect([b.kind, b.owned, b.seriesNumber], ['manga', false, 3]);
      final p = (await dst.select(dst.books).get()).firstWhere((b) => b.title == 'Plain');
      expect([p.kind, p.owned], ['', true]);
      final info = await dst.seriesInfoFor('Berserk', locked: false);
      expect([info?.total, info?.status], [41, 'ongoing']);
      await src.close();
      await dst.close();
    });

    test('an older export with none of the new columns still imports', () async {
      final dst = AppDb.memory();
      final plan = await ImportRunner.plan(dst, Importer.parse('title,author,series,series_number,status,format\nOne Piece 1,Oda,One Piece,1,want,print\n'));
      await ImportRunner.run(dst, plan, DuplicatePolicy.skip);
      final b = (await dst.select(dst.books).get()).single;
      expect([b.kind, b.owned, b.series], ['', true, 'One Piece']);
      await dst.close();
    });

    test('hand-edited junk in kind is ignored', () async {
      final dst = AppDb.memory();
      final plan = await ImportRunner.plan(dst, Importer.parse('title,status,format,kind,owned,series_status\nA,want,print,spaceship,maybe,whenever\n'));
      await ImportRunner.run(dst, plan, DuplicatePolicy.skip);
      final b = (await dst.select(dst.books).get()).single;
      expect([b.kind, b.owned], ['', true]);
      await dst.close();
    });
  });
}
