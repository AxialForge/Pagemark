import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/covers.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Future<int> addBook(AppDb db, String t, {String author = '', bool locked = false, String isbn = ''}) =>
    db.into(db.books).insert(BooksCompanion.insert(title: t, author: Value(author), locked: Value(locked), isbn: Value(isbn)));

void main() {
  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('pgm060');
    CoverStore.useDir(Directory('${tmp.path}/covers'));
    Exporter.debugTmp = Directory('${tmp.path}/out')..createSync();
  });
  tearDown(() {
    Exporter.debugTmp = null;
    tmp.deleteSync(recursive: true);
  });

  group('quotes', () {
    test('add, order by page, edit, delete with undo, cascade on purge, search text', () async {
      final db = AppDb.memory();
      final b = await addBook(db, 'Dune');
      await db.addQuote(b, 'Fear is the mind-killer.', page: 12, note: 'litany');
      await db.addQuote(b, 'The spice must flow.', page: 3);
      await db.addQuote(b, 'No page given.');
      final list = await db.watchQuotes(b).first;
      expect(list.map((q) => q.page), [null, 3, 12], reason: 'unpaged first (nulls sort first), then by page');
      expect((await db.watchQuoteText().first)[b], allOf(contains('mind-killer'), contains('litany'), contains('spice')));
      await db.updateQuote(list[1].id, '  The spice must flow!  ', page: 4);
      expect((await db.watchQuotes(b).first).map((q) => q.body), contains('The spice must flow!'));
      final gone = (await db.watchQuotes(b).first).first;
      await db.deleteQuote(gone.id);
      expect((await db.watchQuotes(b).first).length, 2);
      await db.restoreQuote(gone);
      expect((await db.watchQuotes(b).first).length, 3);
      await db.purgeBook(b);
      expect(await db.select(db.quotes).get(), isEmpty, reason: 'quotes go with the book');
      await db.close();
    });
  });

  group('schema 4 migration', () {
    test('a v3 database upgrades keeping data and gains quotes, series total, heat and content notes', () async {
      final f = File('${tmp.path}/v3.sqlite');
      final raw = sql.sqlite3.open(f.path);
      raw.execute('''
        CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '', isbn TEXT NOT NULL DEFAULT '',
          cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '', series TEXT NOT NULL DEFAULT '', series_number REAL NULL, publisher TEXT NOT NULL DEFAULT '',
          year INTEGER NULL, pages INTEGER NULL, description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', notes TEXT NOT NULL DEFAULT '',
          locked INTEGER NOT NULL DEFAULT 0, added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)), deleted_at INTEGER NULL);
        CREATE TABLE reads (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE, format TEXT NOT NULL DEFAULT 'print',
          status TEXT NOT NULL DEFAULT 'want', started INTEGER NULL, finished INTEGER NULL, rating REAL NULL, thoughts TEXT NOT NULL DEFAULT '', narrator TEXT NOT NULL DEFAULT '',
          minutes INTEGER NULL, current_page INTEGER NULL);
        CREATE TABLE shelves (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE);
        CREATE TABLE book_shelves (book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE, shelf_id INTEGER NOT NULL REFERENCES shelves (id) ON DELETE CASCADE, PRIMARY KEY (book_id, shelf_id));
        INSERT INTO books (title, author) VALUES ('Dune', 'Frank Herbert');
        INSERT INTO reads (book_id, status, rating) VALUES (1, 'finished', 5.0);
        PRAGMA user_version = 3;
      ''');
      raw.close();
      final db = AppDb.forFile(f);
      final row = (await db.watchLibrary(locked: false).first).single;
      expect(row.book.title, 'Dune');
      expect(row.book.seriesTotal, isNull);
      expect(row.reads.single.rating, 5.0);
      expect(row.reads.single.heat, isNull);
      expect(row.reads.single.contentNotes, '');
      await db.addQuote(1, 'works after upgrade');
      expect((await db.watchQuotes(1).first).single.body, 'works after upgrade');
      await db.close();
    });
  });

  group('cover store', () {
    test('only plain file names are accepted', () {
      expect(CoverStore.safeName('b12-345.jpg'), isTrue);
      for (final bad in ['../x.jpg', 'a/b.jpg', r'a\b.jpg', '', 'x' * 90, '..', 'a b.jpg']) {
        expect(CoverStore.safeName(bad), isFalse, reason: bad);
      }
      expect(CoverStore.fileFor('local:../../etc/passwd'), isNull);
      expect(CoverStore.fileFor('https://x/y.jpg'), isNull);
      expect(CoverStore.fileFor('local:b1-2.jpg')!.path, contains('covers'));
    });

    test('download: accepts a real image, refuses placeholders, errors and non-images', () async {
      final img = List<int>.filled(4000, 7);
      CoverStore.client = MockClient((req) async {
        if (req.url.path.endsWith('ok.jpg')) return http.Response.bytes(img, 200, headers: {'content-type': 'image/jpeg'});
        if (req.url.path.endsWith('tiny.gif')) return http.Response.bytes(List.filled(43, 1), 200, headers: {'content-type': 'image/gif'});
        if (req.url.path.endsWith('html')) return http.Response.bytes(img, 200, headers: {'content-type': 'text/html'});
        if (req.url.path.endsWith('boom')) throw const SocketException('x');
        return http.Response('no', 404);
      });
      final ok = await CoverStore.saveFromUrl(5, 'https://covers/ok.jpg');
      expect(ok, startsWith('local:b5-'));
      expect(CoverStore.fileFor(ok!)!.lengthSync(), 4000);
      expect(await CoverStore.saveFromUrl(5, 'https://covers/tiny.gif'), isNull, reason: 'Open Library placeholder pixel');
      expect(await CoverStore.saveFromUrl(5, 'https://covers/html'), isNull);
      expect(await CoverStore.saveFromUrl(5, 'https://covers/boom'), isNull);
      expect(await CoverStore.saveFromUrl(5, 'https://covers/missing'), isNull);
    });

    test('unused files are cleaned, referenced ones stay; fallback url comes from the ISBN', () async {
      final a = await CoverStore.saveFile(1, File('${tmp.path}/a')..writeAsBytesSync([1, 2, 3]));
      final b = await CoverStore.saveFile(2, File('${tmp.path}/b')..writeAsBytesSync([4, 5, 6]));
      expect((await CoverStore.allFiles()).length, 2);
      expect(await CoverStore.removeUnused({a}), 1);
      expect(CoverStore.fileFor(a)!.existsSync(), isTrue);
      expect(CoverStore.fileFor(b)!.existsSync(), isFalse);
      expect(CoverStore.webFallback('9780441172719'), contains('9780441172719'));
      expect(CoverStore.webFallback(''), '');
      expect(await CoverStore.signature(), contains('b1-'));
    });
  });

  group('backup bundles', () {
    Future<(AppDb, String)> libraryWithCover() async {
      final db = AppDb.memory();
      final id = await addBook(db, 'Covered', author: 'A');
      final local = await CoverStore.saveFile(id, File('${tmp.path}/pic')..writeAsBytesSync(List.filled(2000, 9)));
      await (db.update(db.books)..where((b) => b.id.equals(id))).write(BooksCompanion(coverUrl: Value(local)));
      await addBook(db, 'Secret', locked: true);
      return (db, local);
    }

    test('without covers a backup stays a plain sqlite file', () async {
      final db = AppDb.memory();
      await addBook(db, 'X');
      final snap = await Exporter.snapshotDb(db, name: 'plain-test.sqlite');
      final out = await Exporter.bundle(snap, baseName: 'plain-test');
      expect(out.path, snap.path);
      expect(await Exporter.isZip(out), isFalse);
      await db.close();
    });

    test('with covers it is a zip holding the database and the covers; unpack returns both', () async {
      final (db, local) = await libraryWithCover();
      final out = await Exporter.bundle(await Exporter.snapshotDb(db, name: 'bundle-test.sqlite'), baseName: 'bundle-test');
      expect(await Exporter.isZip(out), isTrue);
      final zin = InputFileStream(out.path);
      final names = ZipDecoder().decodeStream(zin).map((e) => e.name).toList();
      await zin.close();
      expect(names, containsAll(['pagemark.sqlite', 'covers/${local.substring(6)}']));
      final u = await Exporter.unpack(out);
      expect(Exporter.inspect(u.db).ok, isTrue);
      expect(u.covers!.listSync().length, 1);
      final check = await Exporter.inspectBackup(out);
      expect(check.ok, isTrue);
      expect(check.covers, 1);
      expect(check.books, 2);
      await u.cleanup();
      await db.close();
    });

    test('a hostile zip cannot write outside the covers folder, and a zip without a database is refused', () async {
      final evil = Archive()
        ..add(ArchiveFile.bytes('pagemark.sqlite', File('${tmp.path}/dummy').existsSync() ? [] : (await _tinyDb(tmp)).readAsBytesSync()))
        ..add(ArchiveFile.bytes('covers/../../escape.txt', [1, 2, 3]))
        ..add(ArchiveFile.bytes('covers/ok-1.jpg', List.filled(10, 1)))
        ..add(ArchiveFile.bytes('other/thing.txt', [1]));
      final f = File('${tmp.path}/evil.zip')..writeAsBytesSync(ZipEncoder().encode(evil));
      final u = await Exporter.unpack(f);
      expect(u.covers!.listSync().map((e) => e.uri.pathSegments.last), ['ok-1.jpg']);
      expect(File('${tmp.path}/escape.txt').existsSync(), isFalse);
      expect(File('${u.dir!.path}/../escape.txt').existsSync(), isFalse);
      await u.cleanup();

      final empty = File('${tmp.path}/empty.zip')..writeAsBytesSync(ZipEncoder().encode(Archive()..add(ArchiveFile.bytes('readme.txt', [1]))));
      await expectLater(Exporter.unpack(empty), throwsA(isA<String>()));
      final check = await Exporter.inspectBackup(empty);
      expect(check.ok, isFalse);
    });
  });

  group('export / import of quotes and private fields', () {
    test('JSON v2 carries quotes; import re-attaches them to the right book; vault quotes are excluded', () async {
      final src = AppDb.memory();
      final a = await addBook(src, 'Dune', author: 'Frank Herbert', isbn: '9780441172719');
      final v = await addBook(src, 'Secret', locked: true);
      await src.addQuote(a, 'Fear is the mind-killer.', page: 12, note: 'litany');
      await src.addQuote(v, 'vault quote');
      await src.into(src.reads).insert(ReadsCompanion.insert(bookId: a, status: const Value('finished'), heat: const Value(3), contentNotes: const Value('violence')));
      final text = const JsonEncoder().convert({
        'pagemark_export': Exporter.formatVersion,
        'books': await Exporter.rows(src, includePrivateFields: true),
        'quotes': await Exporter.quoteRows(src),
      });
      await src.close();
      expect(text, isNot(contains('vault quote')));

      final p = Importer.parse(text);
      expect(p.books.single.quotes.single.text, 'Fear is the mind-killer.');
      expect(p.books.single.quotes.single.page, 12);
      expect(p.books.single.reads.single.heat, 3);
      expect(p.books.single.reads.single.contentNotes, 'violence');

      final dst = AppDb.memory();
      await ImportRunner.run(dst, await ImportRunner.plan(dst, p), DuplicatePolicy.skip);
      expect((await dst.select(dst.quotes).get()).single.note, 'litany');
      expect((await dst.select(dst.reads).get()).single.heat, 3);
      await dst.close();
    });

    test('private fields are left out of exports unless asked for', () async {
      final db = AppDb.memory();
      final a = await addBook(db, 'X');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: a, heat: const Value(4), contentNotes: const Value('secret')));
      expect((await Exporter.rows(db)).single.containsKey('heat'), isFalse);
      expect((await Exporter.rows(db, includePrivateFields: true)).single['heat'], 4);
      await db.close();
    });

    test('exports from a newer format than this app understands are refused', () {
      expect(() => Importer.parse('{"pagemark_export":3,"books":[]}'), throwsA(isA<ImportException>()));
      expect(Importer.parse('{"pagemark_export":2,"books":[]}').books, isEmpty);
    });
  });
}

Future<File> _tinyDb(Directory tmp) async {
  final f = File('${tmp.path}/tiny.sqlite');
  final d = AppDb.forFile(f);
  await d.into(d.books).insert(BooksCompanion.insert(title: 't'));
  await d.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  await d.close();
  return f;
}
