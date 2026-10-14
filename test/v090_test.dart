import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/detailed_ratings.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Future<AppDb> seeded() async {
  final db = AppDb.memory();
  final b = await db.into(db.books).insert(BooksCompanion.insert(title: 'Dune', author: const Value('Frank Herbert')));
  await db.into(db.reads).insert(ReadsCompanion.insert(
        bookId: b, status: const Value('finished'), format: const Value('audio'), rating: const Value(4.5),
        ratingStory: const Value(5.0), ratingCharacters: const Value(4.0), ratingWriting: const Value(4.5), ratingPace: const Value(3.5),
        ratingFeeling: const Value(5.0), ratingNarrator: const Value(2.5),
      ));
  await db.addQuote(b, 'Fear is the mind-killer.', page: 12, rating: 5.0);
  await db.addQuote(b, 'A plain line.');
  return db;
}

void main() {
  test('detailed ratings and quote ratings are stored and read back', () async {
    final db = await seeded();
    final r = (await db.select(db.reads).get()).single;
    expect([r.ratingStory, r.ratingCharacters, r.ratingWriting, r.ratingPace, r.ratingFeeling, r.ratingNarrator], [5.0, 4.0, 4.5, 3.5, 5.0, 2.5]);
    final q = await db.select(db.quotes).get();
    expect(q.map((x) => x.rating), [5.0, null]);
    expect(detailText(r), 'Story 5 · Characters 4 · Writing 4.5 · Pace 3.5 · How it made me feel 5 · Narrator 2.5');
    await db.close();
  });

  test('a JSON export brings detailed ratings and quote ratings back on import', () async {
    final src = await seeded();
    final doc = jsonEncode({'pagemark_export': 2, 'books': await Exporter.rows(src), 'quotes': await Exporter.quoteRows(src)});
    await src.close();

    final dst = AppDb.memory();
    final parse = Importer.parse(doc);
    await ImportRunner.run(dst, await ImportRunner.plan(dst, parse), DuplicatePolicy.skip);
    final r = (await dst.select(dst.reads).get()).single;
    expect([r.ratingStory, r.ratingCharacters, r.ratingWriting, r.ratingPace, r.ratingFeeling, r.ratingNarrator], [5.0, 4.0, 4.5, 3.5, 5.0, 2.5]);
    expect((await dst.select(dst.quotes).get()).map((x) => x.rating).toSet(), {5.0, null});
    await dst.close();
  });

  test('a CSV export carries the detailed ratings too', () async {
    final src = await seeded();
    final csv = Exporter.toCsv(await Exporter.rows(src));
    await src.close();
    expect(csv, contains('rating_story'));
    final dst = AppDb.memory();
    await ImportRunner.run(dst, await ImportRunner.plan(dst, Importer.parse(csv)), DuplicatePolicy.skip);
    expect((await dst.select(dst.reads).get()).single.ratingPace, 3.5);
    await dst.close();
  });

  test('averages: each aspect over the reads that have it, and a series by its rated books', () async {
    final db = await seeded();
    final extra = await db.into(db.books).insert(BooksCompanion.insert(title: 'Messiah', series: const Value('Dune')));
    await db.into(db.reads).insert(ReadsCompanion.insert(bookId: extra, status: const Value('finished'), rating: const Value(3.0), ratingStory: const Value(3.0)));
    final unrated = await db.into(db.books).insert(BooksCompanion.insert(title: 'Children', series: const Value('Dune')));
    final reads = await db.select(db.reads).get();
    expect(aspectAverages(reads)['story'], 4.0);
    expect(aspectAverages(reads)['narrator'], 2.5);
    expect(aspectAverages(reads).containsKey('feeling'), isTrue);

    final rows = await db.watchLibrary(locked: false).first;
    final s = seriesAverage(rows);
    expect(s.rated, 2);
    expect(s.average, 3.75);
    expect(unrated, isNonZero);
    await db.close();
  });

  test('a database from schema 4 gains the new columns and keeps its rows', () async {
    final dir = Directory.systemTemp.createTempSync('pgm90');
    final f = File('${dir.path}/v4.sqlite');
    final raw = sql.sqlite3.open(f.path);
    raw.execute('''
      CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '', isbn TEXT NOT NULL DEFAULT '',
        cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '', series TEXT NOT NULL DEFAULT '', series_number REAL NULL, series_total INTEGER NULL,
        publisher TEXT NOT NULL DEFAULT '', year INTEGER NULL, pages INTEGER NULL, description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '', locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0, 1)), added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
        deleted_at INTEGER NULL);
      CREATE TABLE reads (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE,
        format TEXT NOT NULL DEFAULT 'print', status TEXT NOT NULL DEFAULT 'want', started INTEGER NULL, finished INTEGER NULL, rating REAL NULL,
        thoughts TEXT NOT NULL DEFAULT '', narrator TEXT NOT NULL DEFAULT '', minutes INTEGER NULL, current_page INTEGER NULL, heat INTEGER NULL,
        content_notes TEXT NOT NULL DEFAULT '');
      CREATE TABLE quotes (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE, body TEXT NOT NULL,
        page INTEGER NULL, note TEXT NOT NULL DEFAULT '', created INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)));
      CREATE TABLE shelves (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE);
      CREATE TABLE book_shelves (book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE, shelf_id INTEGER NOT NULL REFERENCES shelves (id) ON DELETE CASCADE, PRIMARY KEY (book_id, shelf_id));
      INSERT INTO books (title) VALUES ('Old'); INSERT INTO reads (book_id, status, rating) VALUES (1, 'finished', 4.0);
      INSERT INTO quotes (book_id, body) VALUES (1, 'kept');
      PRAGMA user_version = 4;
    ''');
    raw.close();
    final db = AppDb.forFile(f);
    final r = (await db.select(db.reads).get()).single;
    expect(r.rating, 4.0);
    expect(r.ratingStory, isNull);
    expect((await db.select(db.quotes).get()).single.rating, isNull);
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
