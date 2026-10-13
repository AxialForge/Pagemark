import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';

String fx(String n) => File('test/fixtures/$n').readAsStringSync();

void main() {
  group('helpers', () {
    test('ISBNs: Goodreads quoting stripped, ISBN-10 upgraded, junk rejected', () {
      expect(Importer.cleanIsbn('="0441172717"'), '9780441172719');
      expect(Importer.cleanIsbn('="9780441172719"'), '9780441172719');
      expect(Importer.cleanIsbn('=""'), '');
      expect(Importer.cleanIsbn('B07XYZ1234'), '');
    });
    test('dates: slashes, dashes, ISO, US month/day/year; nonsense rejected', () {
      expect(Importer.parseDate('2023/05/14'), DateTime(2023, 5, 14));
      expect(Importer.parseDate('2023-5-4'), DateTime(2023, 5, 4));
      expect(Importer.parseDate('2023-05-14T10:20:00.000'), DateTime(2023, 5, 14));
      expect(Importer.parseDate('5/14/2023'), DateTime(2023, 5, 14));
      expect(Importer.parseDate('2023/13/40'), isNull);
      expect(Importer.parseDate(''), isNull);
      expect(Importer.parseDate('soon'), isNull);
    });
    test('ratings round to the nearest half star, zero means unrated', () {
      expect(Importer.halfStars('4.75'), 5.0);
      expect(Importer.halfStars('4.2'), 4.0);
      expect(Importer.halfStars('3.3'), 3.5);
      expect(Importer.halfStars('0'), isNull);
      expect(Importer.halfStars(''), isNull);
      expect(Importer.halfStars('9'), 5.0);
      expect(Importer.halfStars('0.1'), 0.5);
    });
  });

  group('detection', () {
    test('recognises each source and rejects strangers', () {
      expect(Importer.detect(fx('goodreads_sample.csv')), ImportSource.goodreads);
      expect(Importer.detect(fx('storygraph_sample.csv')), ImportSource.storygraph);
      expect(Importer.detect('title,author,format,status\nA,B,print,finished'), ImportSource.pagemarkCsv);
      expect(Importer.detect('{"pagemark_export":1,"books":[]}'), ImportSource.pagemarkJson);
      expect(Importer.detect('name,age\nx,1'), isNull);
      expect(Importer.detect(''), isNull);
      expect(() => Importer.parse('hello'), throwsA(isA<ImportException>()));
    });
  });

  group('Goodreads', () {
    final p = Importer.parse(fx('goodreads_sample.csv'));
    test('books, statuses, formats, ratings, dates, shelves, review text', () {
      expect(p.source, ImportSource.goodreads);
      expect(p.books.length, 4);
      expect(p.skipped.single, contains('no title'));
      final a = p.books[0];
      expect(a.title, 'The Glass Orchard');
      expect(a.isbn, '9780441172719');
      expect(a.year, 1965, reason: 'original publication year wins');
      expect(a.shelves, {'favorites', 'book-club'});
      expect(a.reads.single.status, 'finished');
      expect(a.reads.single.finished, DateTime(2023, 5, 14));
      expect(a.reads.single.rating, 5.0);
      expect(a.reads.single.thoughts, 'Loved it.\nRead it twice.');
      expect(a.coverUrl, contains('9780441172719'));
      final want = p.books[1];
      expect(want.reads.single.status, 'want');
      expect(want.reads.single.rating, isNull);
      expect(want.isbn, '');
      expect(want.shelves, isEmpty);
      final audio = p.books[2];
      expect(audio.reads.single.format, 'audio');
      expect(audio.reads.single.rating, 3.0);
      expect(audio.shelves, {'road-trip'});
      final reading = p.books[3];
      expect(reading.reads.single.status, 'reading');
      expect(reading.reads.single.started, DateTime(2024, 2, 20));
    });
  });

  group('StoryGraph', () {
    final p = Importer.parse(fx('storygraph_sample.csv'));
    test('statuses, formats, ratings, tags, content warnings; UID that is not an ISBN is dropped', () {
      expect(p.source, ImportSource.storygraph);
      expect(p.books.length, 4);
      expect(p.books[0].reads.single.rating, 5.0);
      expect(p.books[0].reads.single.finished, DateTime(2023, 5, 14));
      expect(p.books[0].tags, 'epic, sci-fi');
      expect(p.books[1].isbn, '', reason: 'B07XYZ1234 is an Amazon id');
      expect(p.books[1].reads.single.format, 'audio');
      expect(p.books[1].reads.single.status, 'reading');
      expect(p.books[1].notes, contains('violence'));
      expect(p.books[2].reads.single.format, 'ebook');
      expect(p.books[3].reads.single.status, 'dnf');
      expect(p.books[3].reads.single.rating, 1.0);
    });
  });

  group('Pagemark round trip', () {
    Future<AppDb> seeded() async {
      final db = AppDb.memory();
      final a = await db.into(db.books).insert(BooksCompanion.insert(
          title: '=Danger Title', author: const Value('Ann Author'), isbn: const Value('9780441172719'), tags: const Value('x, y'), notes: const Value('private note'), pages: const Value(300)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: a, status: const Value('finished'), format: const Value('audio'), rating: const Value(4.5),
          thoughts: const Value('great, "quoted" thoughts\nwith a newline'), started: Value(DateTime(2024, 1, 2)), finished: Value(DateTime(2024, 1, 9)), narrator: const Value('Nina'), minutes: const Value(600)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: a, status: const Value('reading'))); // a re-read
      final b = await db.into(db.books).insert(BooksCompanion.insert(title: 'No Reads Yet'));
      await db.setOnShelf(b, await db.addShelf('Maybe'), true);
      await db.into(db.books).insert(BooksCompanion.insert(title: 'Secret', locked: const Value(true)));
      return db;
    }

    for (final kind in ['csv', 'json']) {
      test('export to $kind then import into an empty library keeps books, reads and formulas', () async {
        final src = await seeded();
        final rows = await Exporter.rows(src);
        final text = kind == 'csv' ? Exporter.toCsv(rows) : const JsonEncoder.withIndent(' ').convert({'pagemark_export': 1, 'books': rows});
        await src.close();

        final parsed = Importer.parse(text);
        expect(parsed.source, kind == 'csv' ? ImportSource.pagemarkCsv : ImportSource.pagemarkJson);
        expect(parsed.books.map((b) => b.title), unorderedEquals(['=Danger Title', 'No Reads Yet']), reason: 'locked books are never in exports');
        final a = parsed.books.firstWhere((b) => b.title == '=Danger Title');
        expect(a.reads.length, 2);
        expect(a.reads.first.thoughts, 'great, "quoted" thoughts\nwith a newline');
        expect(a.reads.first.format, 'audio');
        expect(a.reads.first.rating, 4.5);
        expect(a.reads.first.finished, DateTime(2024, 1, 9));
        expect(a.reads.first.minutes, 600);
        expect(a.pages, 300);
        expect(a.tags, 'x, y');
        expect(a.notes, 'private note');
        expect(parsed.books.firstWhere((b) => b.title == 'No Reads Yet').reads, isEmpty);

        final dst = AppDb.memory();
        final plan = await ImportRunner.plan(dst, parsed);
        final res = await ImportRunner.run(dst, plan, DuplicatePolicy.skip);
        expect(res.booksAdded, 2);
        expect(res.readsAdded, 2);
        expect((await dst.select(dst.books).get()).map((b) => b.title), unorderedEquals(['=Danger Title', 'No Reads Yet']));
        await dst.close();
      });
    }

    test('a newer export format is refused with a clear message', () {
      expect(() => Importer.parse('{"pagemark_export":9,"books":[]}'), throwsA(isA<ImportException>().having((e) => e.message, 'm', contains('newer'))));
    });
  });

  group('running an import', () {
    Future<(AppDb, ImportParse)> world() async {
      final db = AppDb.memory();
      await db.into(db.books).insert(BooksCompanion.insert(title: 'The Glass Orchard', author: const Value('Mira Voss'), isbn: const Value('9780441172719')));
      await db.into(db.books).insert(BooksCompanion.insert(title: 'A Quiet Engine', author: const Value('R. Lindqvist'))); // matched by title+author
      await db.into(db.books).insert(BooksCompanion.insert(title: 'Salt & Lantern', author: const Value('T. Okoye'), locked: const Value(true))); // vault: must not count as a duplicate
      return (db, Importer.parse(fx('goodreads_sample.csv')));
    }

    test('plan: duplicates found by ISBN and by title+author, never against the vault', () async {
      final (db, p) = await world();
      final plan = await ImportRunner.plan(db, p);
      expect(plan.duplicates.map((d) => d.$1.title), ['The Glass Orchard', 'A Quiet Engine']);
      expect(plan.fresh.map((b) => b.title), ['Salt & Lantern', 'The Long Orbit']);
      await db.close();
    });

    test('skip leaves existing books alone', () async {
      final (db, p) = await world();
      final res = await ImportRunner.run(db, await ImportRunner.plan(db, p), DuplicatePolicy.skip);
      expect(res.booksAdded, 2);
      expect(res.duplicatesSkipped, 2);
      expect(res.readsAdded, 2);
      expect((await db.select(db.reads).get()).length, 2);
      await db.close();
    });

    test("addReads attaches the file's reads and shelves to the existing book", () async {
      final (db, p) = await world();
      final res = await ImportRunner.run(db, await ImportRunner.plan(db, p), DuplicatePolicy.addReads);
      expect(res.booksAdded, 2);
      expect(res.readsAdded, 4);
      final glass = await (db.select(db.books)..where((b) => b.isbn.equals('9780441172719'))).getSingle();
      expect((await (db.select(db.reads)..where((r) => r.bookId.equals(glass.id))).get()).single.rating, 5.0);
      expect((await db.select(db.shelves).get()).map((s) => s.name), containsAll(['favorites', 'book-club', 'road-trip']));
      expect(res.shelvesCreated, 3);
      expect((await db.select(db.books).get()).length, 5, reason: 'no duplicate rows were created');
      await db.close();
    });

    test('addAnyway creates new rows and Undo (trash) removes exactly the imported books', () async {
      final (db, p) = await world();
      final res = await ImportRunner.run(db, await ImportRunner.plan(db, p), DuplicatePolicy.addAnyway);
      expect(res.booksAdded, 4);
      for (final id in res.newBookIds) {
        await db.softDelete(id);
      }
      final live = await db.watchLibrary(locked: false).first;
      expect(live.map((r) => r.book.title).toSet(), {'The Glass Orchard', 'A Quiet Engine'});
      await db.close();
    });

    test('a file listing the same book twice adds it once; an empty file adds nothing', () async {
      final db = AppDb.memory();
      final twice = Importer.parse('Title,Author,ISBN13,Exclusive Shelf,My Rating\nDup,A,="9780441172719",read,4\nDup again,B,="9780441172719",read,5\n');
      final res = await ImportRunner.run(db, await ImportRunner.plan(db, twice), DuplicatePolicy.skip);
      expect(res.booksAdded, 1);
      final none = await ImportRunner.run(db, await ImportRunner.plan(db, ImportParse(ImportSource.goodreads, [], [])), DuplicatePolicy.skip);
      expect(none.booksAdded, 0);
      await db.close();
    });

    test('a failure mid-import rolls everything back', () async {
      final db = AppDb.memory();
      final plan = ImportPlan([ImportBook(title: 'Fine'), ImportBook(title: 'Boom')..reads.add(ImportRead(status: 'finished'))], const []);
      await db.customStatement("CREATE TRIGGER boom BEFORE INSERT ON reads BEGIN SELECT RAISE(ABORT, 'nope'); END");
      await expectLater(ImportRunner.run(db, plan, DuplicatePolicy.skip), throwsA(anything));
      expect(await db.select(db.books).get(), isEmpty, reason: 'the first book must not survive the failed import');
      await db.close();
    });
  });
}
