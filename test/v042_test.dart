import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/lookup.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Future<int> addBook(AppDb db, String title, {bool locked = false}) =>
    db.into(db.books).insert(BooksCompanion.insert(title: title, locked: Value(locked)));

BookMeta meta(String title, {String author = '', String cover = ''}) => BookMeta(title: title, author: author, coverUrl: cover);

void main() {
  group('vault trash', () {
    test('each library sees only its own trashed books, and restore brings them back', () async {
      final db = AppDb.memory();
      final pub = await addBook(db, 'Public');
      final vault = await addBook(db, 'Hidden', locked: true);
      await db.softDelete(pub);
      await db.softDelete(vault);
      expect((await db.watchTrash(locked: false).first).map((b) => b.title), ['Public']);
      expect((await db.watchTrash(locked: true).first).map((b) => b.title), ['Hidden']);
      await db.restoreBook(vault);
      expect(await db.watchTrash(locked: true).first, isEmpty);
      expect((await db.watchLibrary(locked: true).first).single.book.title, 'Hidden');
      await db.close();
    });
  });

  group('restore check reports locked books', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pgm042'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('lockedBooks counts vault rows so the UI can mention the PIN', () {
      final f = File('${dir.path}/b.sqlite');
      final d = sql.sqlite3.open(f.path);
      d.execute('CREATE TABLE books (id INTEGER PRIMARY KEY, locked INTEGER NOT NULL DEFAULT 0); CREATE TABLE reads (id INTEGER PRIMARY KEY);'
          'INSERT INTO books (locked) VALUES (0),(1),(1); PRAGMA user_version = ${AppDb.currentSchema};');
      d.close();
      final r = Exporter.inspect(f);
      expect(r.ok, isTrue);
      expect(r.books, 3);
      expect(r.lockedBooks, 2);
    });
  });

  group('search ranking', () {
    test('real editions first, summaries and study guides sink, order otherwise stable', () {
      final ranked = Lookup.rank([
        meta('Summary of Circe by Madeline Miller', author: 'BookHabits'),
        meta('Study Guide The Personal Librarian', author: 'SuperSummary', cover: 'x'),
        meta('Galatea', author: 'Madeline Miller', cover: 'x'),
        meta('Circe', author: 'Madeline Miller', cover: 'x'),
        meta('Circe (large print)', author: 'Madeline Miller'),
        meta('Workbook for Circe', author: 'Someone'),
      ], 'circe madeline miller');
      expect(ranked.map((m) => m.title), ['Galatea', 'Circe', 'Circe (large print)', 'Study Guide The Personal Librarian', 'Summary of Circe by Madeline Miller', 'Workbook for Circe']);
    });

    test('isJunk flags third-party companions but not real titles', () {
      expect(Lookup.isJunk(meta('Summary of Circe by Madeline Miller')), isTrue);
      expect(Lookup.isJunk(meta('Study Guide The Lucifer Effect')), isTrue);
      expect(Lookup.isJunk(meta('Workbook for Circe')), isTrue);
      expect(Lookup.isJunk(meta('Circe')), isFalse);
      expect(Lookup.isJunk(meta('The Executive Summary')), isFalse);
      expect(Lookup.isJunk(meta('A Study in Scarlet')), isFalse);
    });

    test('a legitimately titled book containing "summary" is not buried unless it matches the junk patterns', () {
      final r = Lookup.rank([meta('Executive Summary', author: 'A', cover: 'x'), meta('The Hobbit', author: 'Tolkien', cover: 'x')], 'hobbit');
      expect(r.first.title, 'Executive Summary', reason: 'order is stable when scores tie');
    });
  });
}
