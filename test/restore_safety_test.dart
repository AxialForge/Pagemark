import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Future<File> makeDb(Directory d, String name, List<String> titles) async {
  final f = File('${d.path}/$name');
  final db = AppDb.forFile(f);
  for (final t in titles) {
    await db.into(db.books).insert(BooksCompanion.insert(title: t, author: const Value('')));
  }
  await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  await db.close();
  return f;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('pgm-restore');
    AppDb.debugDir = Directory('${tmp.path}/app')..createSync();
    Exporter.debugTmp = Directory('${tmp.path}/tmp')..createSync();
  });
  tearDown(() async {
    AppDb.debugDir = null;
    Exporter.debugTmp = null;
    await tmp.delete(recursive: true);
  });

  test('restore swaps the library, keeps a restore point, and two restores in a row keep two points', () async {
    final backupA = await makeDb(tmp, 'a.sqlite', ['From backup A']);
    final backupB = await makeDb(tmp, 'b.sqlite', ['From backup B']);
    await makeDb(AppDb.debugDir!, 'pagemark.sqlite', ['Live book']);

    var db = AppDb.forFile(await AppDb.file());
    await Exporter.restoreDb(db, backupA);
    await Future<void>.delayed(const Duration(milliseconds: 1100)); // restore points are named to the second
    db = AppDb.forFile(await AppDb.file());
    expect((await db.select(db.books).get()).single.title, 'From backup A');
    await Exporter.restoreDb(db, backupB);

    db = AppDb.forFile(await AppDb.file());
    expect((await db.select(db.books).get()).single.title, 'From backup B');
    await db.close();

    final points = await Exporter.restorePoints();
    expect(points.length, 2, reason: 'the first restore point must survive the second restore');
    final titles = <Object?>[];
    for (final f in points) {
      final c = sql.sqlite3.open(f.path, mode: sql.OpenMode.readOnly);
      titles.add(c.select('SELECT title FROM books').single['title']);
      c.close();
    }
    expect(titles, ['From backup A', 'Live book']); // newest first
  });

  test('inspect rejects files that only look like a Pagemark database', () async {
    final idOnly = File('${tmp.path}/idonly.sqlite');
    final d = sql.sqlite3.open(idOnly.path);
    d.execute('CREATE TABLE books(id INTEGER); CREATE TABLE reads(id INTEGER); PRAGMA user_version = 4;');
    d.close();
    expect(Exporter.inspect(idOnly).ok, isFalse, reason: 'missing columns');

    final v0 = File('${tmp.path}/v0.sqlite');
    final e = sql.sqlite3.open(v0.path);
    e.execute('CREATE TABLE books(id INTEGER, title TEXT); CREATE TABLE reads(id INTEGER, book_id INTEGER, status TEXT);');
    e.close();
    expect(Exporter.inspect(v0).ok, isFalse, reason: 'user_version 0');
  });
}
