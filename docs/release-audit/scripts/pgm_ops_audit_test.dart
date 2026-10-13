// AUDIT SCRIPT - findings PGM-108 PGM-110 PGM-115 PGM-126 PGM-127 PGM-130 PGM-131 (import atomicity/undo, bulk ops, trash/cover store, vault leakage, cascades)
// Rerun: copy into <repo>/test/ and run `flutter test test/pgm_ops_audit_test.dart`.
// Each probe prints `AUDIT|<case>|PASS/FAIL|<detail>`; FAIL lines are findings (the test run itself stays green).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/covers.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';

void chk(String id, bool ok, String detail) => print('AUDIT|$id|${ok ? 'PASS' : 'FAIL'}|$detail');

Future<int> addBook(AppDb db, String title, {String author = '', String isbn = '', bool locked = false, String cover = ''}) =>
    db.into(db.books).insert(BooksCompanion.insert(title: title, author: Value(author), isbn: Value(isbn), locked: Value(locked), coverUrl: Value(cover)));

Future<int> count(AppDb db, String table) async => (await db.customSelect('SELECT COUNT(*) c FROM $table').getSingle()).read<int>('c');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDb db;
  late Directory root;
  setUp(() {
    db = AppDb.memory();
    root = Directory.systemTemp.createTempSync('pgmops');
    CoverStore.useDir(Directory('${root.path}/covers'));
    Exporter.debugTmp = Directory('${root.path}')..createSync();
  });
  tearDown(() async {
    await db.close();
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  ImportBook ib(String title, {String author = '', String isbn = ''}) => ImportBook(title: title, author: author, isbn: isbn);

  group('ImportRunner', () {
    test('rollback leaves no orphan books/reads/shelves/quotes', () async {
      final exId = await addBook(db, 'Existing', author: 'E');
      final fresh = ib('Fresh', author: 'F')
        ..shelves.add('NewShelf')
        ..quotes.add(ImportQuote('a quote'))
        ..reads.add(ImportRead(status: 'finished'));
      final dupFile = ib('Existing', author: 'E')..reads.add(ImportRead(status: 'finished'));
      final plan = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [fresh, dupFile], []));
      await db.purgeBook(exId); // the existing book disappears between preview and import -> FK failure mid-transaction
      Object? err;
      try {
        await ImportRunner.run(db, plan, DuplicatePolicy.addReads);
      } catch (e) {
        err = e;
      }
      final counts = [await count(db, 'books'), await count(db, 'reads'), await count(db, 'shelves'), await count(db, 'quotes'), await count(db, 'book_shelves')];
      chk('I-atomic-rollback', err != null && counts.every((c) => c == 0), 'threw=${err.runtimeType}; books/reads/shelves/quotes/links after = $counts');
    });

    test('Undo only reverts new books: reads added to existing books and new shelves stay', () async {
      await addBook(db, 'Existing', author: 'E');
      final fresh = ib('Fresh', author: 'F')..shelves.add('ImportShelf');
      final dupFile = ib('Existing', author: 'E')
        ..reads.add(ImportRead(status: 'finished', thoughts: 'imported'))
        ..quotes.add(ImportQuote('imported quote'));
      final plan = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [fresh, dupFile], []));
      final res = await ImportRunner.run(db, plan, DuplicatePolicy.addReads);
      for (final id in res.newBookIds) {
        await db.softDelete(id); // exactly what import_ui.dart _undo() does
      }
      final readsOnExisting = await count(db, 'reads');
      final quotes = await count(db, 'quotes');
      final shelves = await count(db, 'shelves');
      chk('I-undo-addreads', readsOnExisting == 0 && quotes == 0, 'after "Undo import": ${readsOnExisting} imported read(s) and $quotes quote(s) still sit on the pre-existing book');
      chk('I-undo-shelves', shelves == 0, 'after Undo, $shelves shelf/shelves created by the import remain (empty)');
    });

    test('skip policy is idempotent; addReads is not (documented behaviour)', () async {
      final f = ib('Dune', author: 'FH', isbn: '9780441172719')..reads.add(ImportRead(status: 'finished'));
      var p = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [f], []));
      await ImportRunner.run(db, p, DuplicatePolicy.skip);
      p = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [f], []));
      final r2 = await ImportRunner.run(db, p, DuplicatePolicy.skip);
      chk('I-skip-idempotent', await count(db, 'books') == 1 && await count(db, 'reads') == 1 && r2.duplicatesSkipped == 1, 'second import with skip adds nothing');
      p = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [f], []));
      await ImportRunner.run(db, p, DuplicatePolicy.addReads);
      print('INFO addReads twice -> reads=${await count(db, 'reads')} (duplicate read rows by design)');
    });

    test('vault: never compared, never written', () async {
      final vid = await addBook(db, 'Secret', author: 'S', isbn: '9780441172719', locked: true);
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: vid, status: const Value('finished'), thoughts: const Value('vault thoughts')));
      final f = ib('Secret', author: 'S', isbn: '9780441172719')..reads.add(ImportRead(status: 'want'));
      final p = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [f], []));
      chk('I-vault-not-compared', p.duplicates.isEmpty && p.fresh.length == 1, 'import plan treats the vault title as new (does not reveal it exists): dups=${p.duplicates.length}');
      await ImportRunner.run(db, p, DuplicatePolicy.addReads);
      final vaultReads = await (db.select(db.reads)..where((r) => r.bookId.equals(vid))).get();
      chk('I-vault-not-written', vaultReads.length == 1, 'vault book still has exactly its own read');
      final main = await db.watchLibrary(locked: false).first;
      chk('I-vault-main-gets-copy', main.length == 1, 'import created a separate main-library copy (${main.length})');
    });

    test('same book twice in one file; trashed duplicate; shelf case', () async {
      final a = ib('Twice', author: 'T');
      final p = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [a, ib('Twice', author: 'T')], []));
      chk('I-dup-in-file', p.fresh.length == 1, 'duplicate within the file is added once');
      final tid = await addBook(db, 'Trashed', author: 'T');
      await db.softDelete(tid);
      final p2 = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [ib('Trashed', author: 'T')], []));
      print('INFO import of a title that is in Trash: fresh=${p2.fresh.length} dups=${p2.duplicates.length} (a second live copy is created beside the trashed one)');
      await db.addShelf('Fantasy');
      final b = ib('ShelfBook')..shelves.addAll(['fantasy', 'FANTASY']);
      final p3 = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [b], []));
      await ImportRunner.run(db, p3, DuplicatePolicy.skip);
      print('INFO existing shelf "Fantasy" + imported "fantasy"/"FANTASY": shelves now ${(await db.select(db.shelves).get()).map((s) => s.name).toList()}');
    });
  });

  group('bulk operations', () {
    test('empty, unknown and very large id lists', () async {
      await addBook(db, 'A');
      await db.softDeleteMany([]);
      await db.softDeleteMany([999]);
      chk('B-empty-unknown', (await db.watchLibrary(locked: false).first).length == 1, 'empty / unknown id lists are no-ops');
      Object? err;
      try {
        await db.softDeleteMany(List.generate(40000, (i) => i + 1));
      } catch (e) {
        err = e;
      }
      chk('B-40k-ids', err == null, '40000 ids in one IN(...) -> ${err == null ? 'ok' : err.runtimeType}');
    });

    test('softDeleteMany / setLockedMany round trip keeps vault separation', () async {
      final a = await addBook(db, 'A'), b = await addBook(db, 'B');
      await db.setLockedMany([a], true);
      chk('B-lock-moves', (await db.watchLibrary(locked: false).first).map((r) => r.book.id).toList().toString() == '[$b]' && (await db.watchLibrary(locked: true).first).length == 1, 'locking moves a book out of main');
      await db.softDeleteMany([a, b]);
      chk('B-trash-separate', (await db.watchTrash(locked: false).first).map((x) => x.id).toList().toString() == '[$b]' && (await db.watchTrash(locked: true).first).length == 1, 'trash lists are per library');
    });

    test('markFinishedToday / undo', () async {
      final noRead = await addBook(db, 'NoRead');
      final reading = await addBook(db, 'Reading');
      final rid = await db.into(db.reads).insert(ReadsCompanion.insert(bookId: reading, status: const Value('reading')));
      final already = await addBook(db, 'Done');
      final fin = DateTime(2020, 1, 2);
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: already, status: const Value('finished'), finished: Value(fin)));
      final u = await db.markFinishedToday([noRead, reading, already, reading]);
      chk('B-finish-counts', u.count == 2, 'created+changed = ${u.count} (already-finished untouched, duplicate id harmless)');
      await db.undoMarkFinished(u);
      final r = await (db.select(db.reads)..where((x) => x.id.equals(rid))).getSingle();
      chk('B-finish-undo', r.status == 'reading' && r.finished == null && await count(db, 'reads') == 2, 'undo restores status/finished and removes created read');

      final u2 = await db.markFinishedToday([noRead]);
      final created = u2.created.single;
      await (db.update(db.reads)..where((x) => x.id.equals(created))).write(const ReadsCompanion(rating: Value(4.5), thoughts: Value('typed after marking')));
      await db.undoMarkFinished(u2);
      final gone = await (db.select(db.reads)..where((x) => x.id.equals(created))).getSingleOrNull();
      chk('B-finish-undo-edited', gone != null, 'a read the user edited (rating+thoughts) after "mark finished" is deleted by Undo: ${gone == null ? 'edits lost' : 'kept'}');

      final u3 = await db.markFinishedToday([reading]);
      await (db.update(db.reads)..where((x) => x.id.equals(rid))).write(const ReadsCompanion(rating: Value(3.0)));
      await db.undoMarkFinished(u3);
      final r3 = await (db.select(db.reads)..where((x) => x.id.equals(rid))).getSingle();
      chk('B-finish-undo-keeps-other-edits', r3.rating == 3.0, 'undo writes only status+finished, later rating edit kept (${r3.rating})');

      final dnf = await addBook(db, 'Dnf');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: dnf, status: const Value('dnf')));
      final u4 = await db.markFinishedToday([dnf]);
      print('INFO mark-finished on a book whose latest read is DNF converts the DNF read to finished (changed=${u4.changed.length})');
    });
  });

  group('trash, covers, cascades', () {
    test('purgeExpiredTrash cascades and covers survive for restorable books only', () async {
      final live = await addBook(db, 'Live', cover: 'local:b1-1.jpg');
      final trashed = await addBook(db, 'Trashed', cover: 'local:b2-1.jpg');
      final old = await addBook(db, 'Old', cover: 'local:b3-1.jpg');
      final oldVault = await addBook(db, 'OldVault', locked: true, cover: 'local:b4-1.jpg');
      for (final n in ['b1-1.jpg', 'b2-1.jpg', 'b3-1.jpg', 'b4-1.jpg', 'orphan.jpg']) {
        File('${CoverStore.dir.path}/$n').writeAsBytesSync([1, 2, 3]);
      }
      File('${CoverStore.dir.path}/weird name.jpg').writeAsBytesSync([1]);
      Directory('${CoverStore.dir.path}/sub').createSync();
      await db.softDelete(trashed);
      for (final id in [old, oldVault]) {
        await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id));
        await db.addQuote(id, 'q');
        final sh = await db.addShelf('S$id');
        await db.setOnShelf(id, sh, true);
        await (db.update(db.books)..where((b) => b.id.equals(id))).write(BooksCompanion(deletedAt: Value(DateTime.now().subtract(const Duration(days: 31)))));
      }
      final n = await db.purgeExpiredTrash();
      final removed = await CoverStore.removeUnused({for (final b in await db.select(db.books).get()) b.coverUrl});
      final left = Directory(CoverStore.dir.path).listSync().map((e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last).toList()..sort();
      chk('T-purge-cascade', n == 2 && await count(db, 'reads') == 0 && await count(db, 'quotes') == 0 && await count(db, 'book_shelves') == 0, 'purged $n books (incl. 1 vault book), children cascaded');
      chk('T-cover-cleanup', left.toString() == '[b1-1.jpg, b2-1.jpg, sub, weird name.jpg]' && removed == 3, 'removed=$removed, left=$left (trashed-but-restorable cover kept; unsafe names and dirs untouched)');
      expect(live, 1);
    });

    test('removeUnused racing a cover that is saved after the in-use set was read', () async {
      final id = await addBook(db, 'New');
      final inUse = {for (final b in await db.select(db.books).get()) b.coverUrl}; // snapshot (as _tidy / startup do)
      final f = File('${root.path}/src.jpg')..writeAsBytesSync(List.filled(2000, 1));
      final saved = await CoverStore.saveFile(id, f); // AddBook/EditBook saves the file, THEN writes the row
      final removed = await CoverStore.removeUnused(inUse);
      chk('T-removeUnused-race', removed == 0, 'a cover file created between the snapshot and the sweep is deleted ($saved removed=$removed); window = one await');
    });

    test('safeName / fileFor table', () {
      final cases = {
        'a.jpg': true, 'b1-1700000000000.png': true, '.': true, '...': false, '..': false, 'a..b': false, '../x': false, 'a/b': false, 'a\\b': false,
        '': false, 'a\u0000b': false, 'a.jpg\n': false, 'a b': false, 'é.jpg': false, '${'x' * 80}': true, '${'x' * 81}': false, '%2e%2e': false, 'CON': true,
      };
      final bad = <String>[];
      cases.forEach((k, v) {
        if (CoverStore.safeName(k) != v) bad.add('"$k" expected $v');
      });
      chk('CS-safeName', bad.isEmpty, bad.isEmpty ? 'all ${cases.length} name cases as expected ("." and "..." are accepted: see D-odd-cover-name)' : bad.join('; '));
      chk('CS-fileFor', CoverStore.fileFor('local:../etc/passwd') == null && CoverStore.fileFor('local:a/b') == null && CoverStore.fileFor('http://x/local:a') == null && CoverStore.fileFor('local:ok.jpg') != null, 'fileFor rejects traversal / non-local');
    });

    test('saveFromUrl: huge body, odd content types, errors', () async {
      Future<String?> tryIt(http.Response Function() mk) async {
        CoverStore.client = MockClient((_) async => mk());
        return CoverStore.saveFromUrl(1, 'https://example.test/c.jpg');
      }

      final huge = Uint8List(40 * 1024 * 1024);
      final sw = Stopwatch()..start();
      final h = await tryIt(() => http.Response.bytes(huge, 200, headers: {'content-type': 'image/jpeg'}));
      chk('CS-huge-cover', h == null, '40 MB "cover" body: ${h == null ? 'rejected' : 'saved (${sw.elapsedMilliseconds} ms), no size cap'}');
      final svg = await tryIt(() => http.Response.bytes(Uint8List(5000), 200, headers: {'content-type': 'image/svg+xml'}));
      print('INFO image/svg+xml saved as ${svg} (stored with .jpg extension)');
      final gif = await tryIt(() => http.Response.bytes(Uint8List(5000), 200, headers: {'content-type': 'image/gif'}));
      print('INFO image/gif saved as $gif');
      chk('CS-html-rejected', await tryIt(() => http.Response.bytes(Uint8List(5000), 200, headers: {'content-type': 'text/html'})) == null, 'text/html rejected');
      chk('CS-tiny-rejected', await tryIt(() => http.Response.bytes(Uint8List(100), 200, headers: {'content-type': 'image/jpeg'})) == null, 'tiny placeholder rejected');
      chk('CS-404', await tryIt(() => http.Response('x', 404)) == null, '404 -> null');
      CoverStore.client = MockClient((_) async => throw const SocketException('x'));
      chk('CS-exception', await CoverStore.saveFromUrl(1, 'https://example.test/c.jpg') == null, 'network error -> null');
      chk('CS-bad-url', await CoverStore.saveFromUrl(1, 'ht!tp://[bad') == null, 'unparseable URL -> null');
      final png = await tryIt(() => http.Response.bytes(Uint8List(5000), 200, headers: {'content-type': 'image/png; charset=binary'}));
      chk('CS-png-ext', png != null && png.endsWith('.png'), 'png content-type with parameters -> $png');
      CoverStore.client = http.Client();
    });

    test('cascades and FK enforcement', () async {
      final b = await addBook(db, 'B');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: b));
      await db.addQuote(b, 'q1');
      final sh = await db.addShelf('S');
      await db.setOnShelf(b, sh, true);
      await db.deleteShelf(sh);
      chk('K-shelf-delete', await count(db, 'book_shelves') == 0 && await count(db, 'books') == 1, 'deleting a shelf removes links, keeps the book');
      await db.setOnShelf(b, await db.addShelf('S2'), true);
      await db.purgeBook(b);
      chk('K-book-cascade', await count(db, 'quotes') == 0 && await count(db, 'reads') == 0 && await count(db, 'book_shelves') == 0, 'purging a book removes reads, quotes, shelf links');
      Object? err;
      try {
        await db.into(db.quotes).insert(QuotesCompanion.insert(bookId: 12345, body: 'orphan'));
      } catch (e) {
        err = e;
      }
      chk('K-fk-enforced', err != null, 'inserting a quote for a missing book is rejected (foreign_keys=ON)');
      final id2 = await addBook(db, 'Dup', author: 'A');
      await db.softDelete(id2);
      final dupWhileTrashed = await db.findDuplicate(title: 'Dup', author: 'A', locked: false);
      await addBook(db, 'Dup', author: 'A');
      await db.restoreBook(id2);
      final live = (await db.watchLibrary(locked: false).first).where((r) => r.book.title == 'Dup').length;
      print('INFO soft-deleted book is invisible to findDuplicate (${dupWhileTrashed == null}); after re-adding and restoring Trash copy there are $live live copies, no warning');
    });
  });

  group('vault leakage', () {
    test('nothing from locked=1 books reaches main surfaces or exports', () async {
      final vid = await addBook(db, 'VAULTTITLE', author: 'VAULTAUTHOR', isbn: '9780441172719', locked: true);
      await (db.update(db.books)..where((b) => b.id.equals(vid))).write(const BooksCompanion(
          notes: Value('VAULTNOTE'), tags: Value('VAULTTAG'), series: Value('VAULTSERIES'), genre: Value('VAULTGENRE'), publisher: Value('VAULTPUB')));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: vid, status: const Value('finished'), thoughts: const Value('VAULTTHOUGHT'), finished: Value(DateTime.now())));
      await db.addQuote(vid, 'VAULTQUOTE');
      final sh = await db.addShelf('VAULTSHELF');
      await db.setOnShelf(vid, sh, true);
      await db.softDelete(await addBook(db, 'VAULTTRASH', locked: true));
      await addBook(db, 'MainBook');

      final rows = await Exporter.rows(db, includePrivateFields: true);
      final csv = Exporter.toCsv(rows);
      final json = jsonEncode({'books': rows, 'quotes': await Exporter.quoteRows(db)});
      final lib = (await db.watchLibrary(locked: false).first).map((r) => '${r.book} ${r.reads}').join();
      final trash = (await db.watchTrash(locked: false).first).map((b) => b.title).join();
      final dup = await db.findDuplicate(title: 'VAULTTITLE', author: 'VAULTAUTHOR', isbn: '9780441172719', locked: false);
      final plan = await ImportRunner.plan(db, ImportParse(ImportSource.pagemarkCsv, [ib('VAULTTITLE', author: 'VAULTAUTHOR', isbn: '9780441172719')], []));
      for (final entry in {'csv': csv, 'json': json, 'library stream': lib, 'main trash': trash}.entries) {
        chk('V-leak[${entry.key}]', !entry.value.contains('VAULT'), 'no VAULT* string in ${entry.key}');
      }
      chk('V-leak[findDuplicate]', dup == null, 'findDuplicate(locked:false) cannot see vault');
      chk('V-leak[import plan]', plan.duplicates.isEmpty, 'import plan cannot see vault');
      final shelfNames = (await db.watchShelves().first).map((s) => s.name).toList();
      chk('V-leak[shelf names]', !shelfNames.contains('VAULTSHELF'), 'shelf list shown in main library chips / Shelves page / shelf picker is global: $shelfNames');
      final qt = await db.watchQuoteText().first;
      chk('V-leak[quote text stream]', !qt.values.any((v) => v.contains('VAULT')), 'watchQuoteText() returns vault quote text (keyed by id) to the main Library screen state; filtered only by id at ui.dart:440');
      final allQuoteRows = await Exporter.quoteRows(db, includeLocked: true);
      chk('V-includeLocked-opt-in', allQuoteRows.length == 1 && (await Exporter.rows(db, includeLocked: true)).length == 2, 'includeLocked flag works (and is not used by any share* path)');
    });
  });
}
