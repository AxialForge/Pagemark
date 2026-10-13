// AUDIT SCRIPT - findings PGM-103 PGM-104 PGM-105 PGM-106 PGM-107 PGM-114 PGM-125 PGM-133 (restore / unpack / backup crypto / migrations)
// Rerun: copy into <repo>/test/ and run `flutter test test/pgm_restore_audit_test.dart`.
// Each probe prints `AUDIT|<case>|PASS/FAIL|<detail>`; FAIL lines are findings (the test run itself stays green).
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/covers.dart';
import 'package:pagemark/crypto_backup.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void chk(String id, bool ok, String detail) => print('AUDIT|$id|${ok ? 'PASS' : 'FAIL'}|$detail');

List<int> zipOf(List<MapEntry<String, List<int>>> entries) {
  final a = Archive();
  for (final e in entries) {
    a.addFile(ArchiveFile.bytes(e.key, e.value));
  }
  final List<int>? o = ZipEncoder().encode(a);
  return o!;
}

const v1ddl = '''
  CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '',
    isbn TEXT NOT NULL DEFAULT '', cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '',
    series TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', year INTEGER NULL, pages INTEGER NULL,
    description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', notes TEXT NOT NULL DEFAULT '',
    locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0, 1)), added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)));
  CREATE TABLE reads (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE,
    format TEXT NOT NULL DEFAULT 'print', status TEXT NOT NULL DEFAULT 'want', started INTEGER NULL, finished INTEGER NULL,
    rating REAL NULL, thoughts TEXT NOT NULL DEFAULT '', narrator TEXT NOT NULL DEFAULT '', minutes INTEGER NULL);
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root, docs, tmp;

  setUp(() {
    root = Directory.systemTemp.createTempSync('pgmaud');
    docs = Directory('${root.path}/docs')..createSync();
    tmp = Directory('${root.path}/tmp')..createSync();
    Exporter.debugTmp = tmp;
    CoverStore.useDir(Directory('${docs.path}/covers'));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => call.method.contains('Documents') || call.method.contains('Temporary') || call.method.contains('Support') ? docs.path : docs.path,
    );
  });
  tearDown(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<File> makeV4(String name, List<String> titles) async {
    final f = File('${root.path}/$name');
    final d = AppDb.forFile(f);
    for (final t in titles) {
      final id = await d.into(d.books).insert(BooksCompanion.insert(title: t));
      await d.into(d.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('finished')));
    }
    await d.close();
    return f;
  }

  group('unpack / inspectBackup hostile files', () {
    test('truncated / zero / garbage / empty-zip / no-db zips', () async {
      final good = await makeV4('good.sqlite', ['A']);
      final bytes = good.readAsBytesSync();
      final trunc = File('${root.path}/trunc.sqlite')..writeAsBytesSync(bytes.sublist(0, 2048));
      var r = await Exporter.inspectBackup(trunc);
      chk('D-trunc-sqlite', !r.ok, 'truncated sqlite (2048 of ${bytes.length} bytes) -> ok=${r.ok} "${r.message}"');
      final zero = File('${root.path}/zero.sqlite')..writeAsBytesSync([]);
      r = await Exporter.inspectBackup(zero);
      chk('D-zero-byte', !r.ok, 'zero-byte file -> ok=${r.ok}');
      final flip = Uint8List.fromList(bytes)..[bytes.length ~/ 2] ^= 0xFF;
      final corrupt = File('${root.path}/corrupt.sqlite')..writeAsBytesSync(flip);
      r = await Exporter.inspectBackup(corrupt);
      print('INFO single mid-file bit flip -> ok=${r.ok} "${r.message}" (a small DB may not hit used pages)');
      final emptyZip = File('${root.path}/empty.zip')..writeAsBytesSync(zipOf([]));
      r = await Exporter.inspectBackup(emptyZip);
      chk('D-empty-zip', !r.ok, 'zip with zero entries -> ok=${r.ok} "${r.message}"');
      final nodb = File('${root.path}/nodb.zip')..writeAsBytesSync(zipOf([MapEntry('covers/a.jpg', List.filled(10, 1))]));
      r = await Exporter.inspectBackup(nodb);
      chk('D-zip-no-db', !r.ok, 'zip with covers but no db -> ok=${r.ok} "${r.message}"');
      final trz = File('${root.path}/trz.zip')..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', bytes)]).sublist(0, 900));
      r = await Exporter.inspectBackup(trz);
      chk('D-truncated-zip', !r.ok, 'truncated zip -> ok=${r.ok} "${r.message}"');
    });

    test('zip-slip and odd names are never written outside the temp dir', () async {
      final good = await makeV4('good2.sqlite', ['A']);
      final dbBytes = good.readAsBytesSync();
      final names = [
        '../evil.txt', '..\\evil.txt', '/abs/evil.txt', 'covers/../../evil.jpg', 'covers/..\\evil.jpg', 'covers/a/b.jpg',
        'covers/${'x' * 81}', 'covers/a b.jpg', 'covers/a\u0000b.jpg', 'covers//x.jpg', 'covers/x.jpg\n', 'C:\\evil.txt', 'pagemark.sqlite/../x',
      ];
      final entries = [MapEntry('pagemark.sqlite', dbBytes), for (final n in names) MapEntry(n, List.filled(20, 7)), MapEntry('covers/good.jpg', List.filled(20, 9))];
      final z = File('${root.path}/slip.zip')..writeAsBytesSync(zipOf(entries));
      final before = Directory.systemTemp.listSync().length;
      final u = await Exporter.unpack(z);
      final got = u.covers!.listSync().map((e) => e.uri.pathSegments.last).toList()..sort();
      chk('D-zip-slip-covers', got.length == 1 && got.first == 'good.jpg', 'only good.jpg extracted; got $got');
      final outside = [File('${root.path}/evil.txt'), File('${Directory.systemTemp.path}/evil.txt'), File('${Directory.systemTemp.path}/evil.jpg')];
      chk('D-zip-slip-outside', !outside.any((f) => f.existsSync()), 'no file created outside the temp dir');
      await u.cleanup();
      chk('D-unpack-cleanup', Directory.systemTemp.listSync().length <= before, 'temp dir removed after cleanup');
    });

    test('cover entry named "." / ".." / "..." (passes safeName regex)', () async {
      final good = await makeV4('good3.sqlite', ['A']);
      final dbBytes = good.readAsBytesSync();
      for (final n in ['covers/.', 'covers/...', 'covers/-', 'covers/.hidden']) {
        final z = File('${root.path}/dot.zip')..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', dbBytes), MapEntry(n, List.filled(20, 1))]));
        final tmpsBefore = Directory.systemTemp.listSync().where((e) => e.path.contains('pgm-unpack')).length;
        Object? err;
        try {
          final u = await Exporter.unpack(z);
          await u.cleanup();
        } catch (e) {
          err = e;
        }
        final tmpsAfter = Directory.systemTemp.listSync().where((e) => e.path.contains('pgm-unpack')).length;
        final leaked = tmpsAfter - tmpsBefore;
        chk('D-odd-cover-name[$n]', err == null && leaked == 0, 'threw=${err?.runtimeType} ${err is String ? '' : (err ?? '')}; leaked temp dirs=$leaked');
        final r = await Exporter.inspectBackup(z);
        print('INFO inspectBackup for "$n": ok=${r.ok} "${r.message}"');
      }
      for (final d in Directory.systemTemp.listSync().where((e) => e.path.contains('pgm-unpack'))) {
        try {
          d.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('zip bomb: no size cap, ignored entries are still decompressed in memory', () async {
      final good = await makeV4('good4.sqlite', ['A']);
      final big = List<int>.filled(120 * 1024 * 1024, 0); // 120 MB of zeros compresses to ~120 KB
      final z = File('${root.path}/bomb.zip')..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', good.readAsBytesSync()), MapEntry('junk/ignored.bin', big)]));
      final zsize = z.lengthSync();
      final sw = Stopwatch()..start();
      final r = await Exporter.inspectBackup(z);
      sw.stop();
      chk('D-zip-bomb-ignored-entry', sw.elapsedMilliseconds < 3000, 'zip file ${zsize ~/ 1024} KB expanded to 120 MB in memory for an IGNORED entry; inspect took ${sw.elapsedMilliseconds} ms, ok=${r.ok}');
      final z2 = File('${root.path}/bomb2.zip')..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', good.readAsBytesSync()), MapEntry('covers/huge.jpg', big)]));
      final u = await Exporter.unpack(z2);
      final written = u.covers!.listSync().whereType<File>().fold<int>(0, (a, f) => a + f.lengthSync());
      chk('D-zip-bomb-cover-written', written < 10 * 1024 * 1024, 'a ${z2.lengthSync() ~/ 1024} KB zip wrote ${written ~/ (1024 * 1024)} MB to disk as a "cover" (no cap on entry size / count)');
      await u.cleanup();
    });

    test('duplicate pagemark.sqlite entries: last one wins', () async {
      final good = await makeV4('good5.sqlite', ['A']);
      final z = File('${root.path}/dup.zip')
        ..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', good.readAsBytesSync()), MapEntry('pagemark.sqlite', List.filled(5000, 3))]));
      final r = await Exporter.inspectBackup(z);
      print('INFO duplicate pagemark.sqlite entries (good first, garbage second): ok=${r.ok} (fails closed if false)');
      chk('D-dup-db-entries', !r.ok || r.books == 1, 'ambiguous duplicate entry resolved without crash, ok=${r.ok}');
    });
  });

  group('inspect() depth', () {
    test('id-only tables at current schema pass inspect (no column check)', () async {
      final f = File('${root.path}/idonly.sqlite');
      final d = sql.sqlite3.open(f.path);
      d.execute('CREATE TABLE books (id INTEGER PRIMARY KEY); CREATE TABLE reads (id INTEGER PRIMARY KEY); PRAGMA user_version = ${AppDb.currentSchema};');
      d.close();
      final r = Exporter.inspect(f);
      Object? err;
      try {
        final db = AppDb.forFile(f);
        await db.watchLibrary(locked: false).first;
        await db.close();
      } catch (e) {
        err = e;
      }
      chk('D-inspect-no-column-check', !r.ok || err == null, 'inspect.ok=${r.ok} but opening the same file and listing the library throws: ${err.runtimeType}');
    });

    test('real tables but user_version 0 passes inspect and then fails to open', () async {
      final f = File('${root.path}/v0.sqlite');
      final d = sql.sqlite3.open(f.path);
      d.execute(v1ddl); // user_version stays 0
      d.close();
      final r = Exporter.inspect(f);
      Object? err;
      try {
        final db = AppDb.forFile(f);
        await db.watchLibrary(locked: false).first;
        await db.close();
      } catch (e) {
        err = e;
      }
      chk('D-inspect-user-version-0', !r.ok || err == null, 'inspect.ok=${r.ok}; opening it throws ${err.runtimeType}');
    });

    test('FK-orphan rows and duplicate rows do not make inspect fail (integrity_check only)', () async {
      final f = await makeV4('orph.sqlite', ['A']);
      final d = sql.sqlite3.open(f.path);
      d.execute('PRAGMA foreign_keys=OFF; INSERT INTO reads (book_id, status) VALUES (999, \'finished\'); PRAGMA foreign_keys=ON;');
      d.close();
      final r = Exporter.inspect(f);
      print('INFO orphan read row (book_id 999) -> inspect ok=${r.ok} reads=${r.reads}');
    });
  });

  group('migrations v1/v2/v3 -> v4 with real DDL', () {
    String v2extra = 'ALTER TABLE books ADD COLUMN deleted_at INTEGER NULL; CREATE INDEX reads_book ON reads (book_id); CREATE INDEX books_locked ON books (locked); CREATE INDEX books_title ON books (title);';
    String v3extra = 'ALTER TABLE books ADD COLUMN series_number REAL NULL; ALTER TABLE reads ADD COLUMN current_page INTEGER NULL; '
        'CREATE TABLE shelves (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE); '
        'CREATE TABLE book_shelves (book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE, shelf_id INTEGER NOT NULL REFERENCES shelves (id) ON DELETE CASCADE, PRIMARY KEY (book_id, shelf_id));';
    for (final ver in [1, 2, 3]) {
      test('v$ver database migrates to 4, rows survive, second open is a no-op', () async {
        final f = File('${root.path}/v$ver.sqlite');
        final raw = sql.sqlite3.open(f.path);
        raw.execute(v1ddl);
        if (ver >= 2) raw.execute(v2extra);
        if (ver >= 3) raw.execute(v3extra);
        raw.execute("INSERT INTO books (title, author, locked) VALUES ('Dune','Herbert',0),('Secret','X',1),('Third','Y',0);"
            "INSERT INTO reads (book_id, status, rating, thoughts) VALUES (1,'finished',4.5,'good'),(1,'reading',NULL,''),(2,'want',NULL,'hid');");
        if (ver >= 2) raw.execute('UPDATE books SET deleted_at = strftime(\'%s\',\'now\') WHERE id = 3;');
        if (ver >= 3) raw.execute("INSERT INTO shelves (name) VALUES ('S'); INSERT INTO book_shelves VALUES (1,1);");
        raw.execute('PRAGMA user_version = $ver;');
        raw.close();
        chk('M-v$ver-inspect', Exporter.inspect(f).ok, 'v$ver file accepted by inspect');
        for (var pass = 1; pass <= 2; pass++) {
          final db = AppDb.forFile(f);
          final books = await db.select(db.books).get();
          final reads = await db.select(db.reads).get();
          final uv = (await db.customSelect('PRAGMA user_version').getSingle()).data.values.first;
          final fk = await db.customSelect('PRAGMA foreign_key_check').get();
          final ic = (await db.customSelect('PRAGMA integrity_check').getSingle()).data.values.first;
          final q = await db.select(db.quotes).get();
          await db.close();
          chk('M-v$ver-pass$pass', books.length == 3 && reads.length == 3 && uv == 4 && fk.isEmpty && ic == 'ok' && books.where((b) => b.locked).length == 1 && q.isEmpty,
              'books=${books.length} reads=${reads.length} user_version=$uv fk_violations=${fk.length} integrity=$ic locked=${books.where((b) => b.locked).length}');
        }
      });
    }
  });

  group('restoreDb end to end', () {
    test('happy path: safety copy first, sidecars removed, covers imported, junk cover names ignored', () async {
      final liveFile = File('${docs.path}/pagemark.sqlite');
      final live = AppDb.forFile(liveFile);
      await live.into(live.books).insert(BooksCompanion.insert(title: 'LIVE-BOOK'));
      final cand = await makeV4('cand.sqlite', ['BACKUP-BOOK']);
      final zip = File('${root.path}/cand.zip')
        ..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', cand.readAsBytesSync()), MapEntry('covers/ok.jpg', List.filled(30, 5)), MapEntry('covers/../bad.jpg', List.filled(30, 5))]));
      final kept = await Exporter.restoreDb(live, zip);
      final safety = AppDb.forFile(kept);
      final sTitles = (await safety.select(safety.books).get()).map((b) => b.title).toList();
      await safety.close();
      final dest = AppDb.forFile(liveFile);
      final dTitles = (await dest.select(dest.books).get()).map((b) => b.title).toList();
      await dest.close();
      chk('R-safety-copy-has-old', sTitles.contains('LIVE-BOOK'), 'pre-restore copy holds $sTitles');
      chk('R-dest-has-new', dTitles.contains('BACKUP-BOOK') && !dTitles.contains('LIVE-BOOK'), 'live file now holds $dTitles');
      chk('R-covers', File('${docs.path}/covers/ok.jpg').existsSync() && !File('${docs.path}/bad.jpg').existsSync(), 'cover imported, traversal name ignored');
      chk('R-no-incoming-left', !File('${liveFile.path}.incoming').existsSync(), 'staged .incoming file renamed away');
    });

    test('invalid candidate leaves live DB untouched and usable, makes no safety copy', () async {
      final liveFile = File('${docs.path}/pagemark.sqlite');
      final live = AppDb.forFile(liveFile);
      await live.into(live.books).insert(BooksCompanion.insert(title: 'LIVE-BOOK'));
      final junk = File('${root.path}/junk.sqlite')..writeAsBytesSync(List.filled(9000, 4));
      Object? err;
      try {
        await Exporter.restoreDb(live, junk);
      } catch (e) {
        err = e;
      }
      final still = await live.select(live.books).get();
      chk('R-invalid-candidate', err is String && still.length == 1 && docs.listSync().whereType<File>().every((f) => !f.path.contains('pre-restore')), 'threw "$err"; live rows=${still.length}; no pre-restore file');
      await live.close();
    });

    test('failure AFTER the swap (cover import fails): error shown but DB already replaced and connection closed', () async {
      final liveFile = File('${docs.path}/pagemark.sqlite');
      final live = AppDb.forFile(liveFile);
      await live.into(live.books).insert(BooksCompanion.insert(title: 'LIVE-BOOK'));
      final cand = await makeV4('cand2.sqlite', ['BACKUP-BOOK']);
      final zip = File('${root.path}/cand2.zip')..writeAsBytesSync(zipOf([MapEntry('pagemark.sqlite', cand.readAsBytesSync()), MapEntry('covers/ok.jpg', List.filled(30, 5))]));
      Directory('${docs.path}/covers').deleteSync(recursive: true); // simulate the covers folder being unwritable / gone
      Object? err;
      try {
        await Exporter.restoreDb(live, zip);
      } catch (e) {
        err = e;
      }
      final d = AppDb.forFile(liveFile);
      final titles = (await d.select(d.books).get()).map((b) => b.title).toList();
      await d.close();
      Object? useErr;
      try {
        await live.select(live.books).get();
      } catch (e) {
        useErr = e;
      }
      chk('R-fail-after-swap', err == null || !titles.contains('BACKUP-BOOK'),
          'restoreDb threw ${err.runtimeType} (UI shows it as a failed restore) yet the live file now holds $titles; old connection usable afterwards: ${useErr == null}');
    });

    test('two restores inside one minute: the first safety copy is overwritten', () async {
      final liveFile = File('${docs.path}/pagemark.sqlite');
      var live = AppDb.forFile(liveFile);
      await live.into(live.books).insert(BooksCompanion.insert(title: 'ORIGINAL-LIBRARY'));
      final a = await makeV4('a.sqlite', ['A-BOOK']);
      final b = await makeV4('b.sqlite', ['B-BOOK']);
      await Exporter.restoreDb(live, a);
      live = AppDb.forFile(liveFile);
      await Exporter.restoreDb(live, b);
      final kept = docs.listSync().whereType<File>().where((f) => f.path.contains('pre-restore-')).toList();
      final titles = <String>[];
      for (final k in kept) {
        final d = AppDb.forFile(k);
        titles.addAll((await d.select(d.books).get()).map((x) => x.title));
        await d.close();
      }
      chk('R-safety-copy-collision', titles.contains('ORIGINAL-LIBRARY'), 'safety copies kept: ${kept.length}, together holding $titles (stamp has minute resolution)');
    });

    test('safetyCopy twice in a minute (pre-import restore point) overwrites the first', () async {
      final liveFile = File('${docs.path}/pagemark.sqlite');
      final live = AppDb.forFile(liveFile);
      await live.into(live.books).insert(BooksCompanion.insert(title: 'STATE-1'));
      await Exporter.safetyCopy(live, 'pre-import');
      await live.into(live.books).insert(BooksCompanion.insert(title: 'STATE-2'));
      await Exporter.safetyCopy(live, 'pre-import');
      final kept = docs.listSync().whereType<File>().where((f) => f.path.contains('pre-import-')).toList();
      var minOnly = true;
      for (final k in kept) {
        final d = AppDb.forFile(k);
        if ((await d.select(d.books).get()).length == 1) minOnly = false;
        await d.close();
      }
      chk('R-pre-import-collision', kept.length >= 2 || !minOnly, '${kept.length} pre-import file(s) after two imports within the same minute; the 1-book (original) state ${minOnly ? 'is gone' : 'survives'}');
      await live.close();
    });

    test('restore of v1 backup end to end', () async {
      final f = File('${root.path}/old.sqlite');
      final raw = sql.sqlite3.open(f.path);
      raw.execute(v1ddl);
      raw.execute("INSERT INTO books (title) VALUES ('Old'); PRAGMA user_version = 1;");
      raw.close();
      final liveFile = File('${docs.path}/pagemark.sqlite');
      final live = AppDb.forFile(liveFile);
      await live.select(live.books).get();
      await Exporter.restoreDb(live, f);
      final d = AppDb.forFile(liveFile);
      final t = (await d.select(d.books).get()).map((b) => b.title).toList();
      await d.close();
      chk('R-restore-v1', t.length == 1 && t.first == 'Old', 'v1 backup restored and migrated: $t');
    });
  });

  group('BackupCrypto', () {
    test('wrong pass, tamper at every region, truncation, unicode normalisation', () async {
      final plain = File('${root.path}/p.bin')..writeAsBytesSync(List.generate(3000, (i) => i % 251));
      final enc = await BackupCrypto.encrypt(plain, File('${root.path}/p.pgbak'), 'pässword');
      final orig = enc.readAsBytesSync();
      Future<String> tryDec(List<int> bytes, String pass) async {
        final f = File('${root.path}/t.pgbak')..writeAsBytesSync(bytes);
        try {
          await BackupCrypto.decrypt(f, File('${root.path}/t.out'), pass);
          return 'DECRYPTED';
        } on WrongPassphrase {
          return 'WrongPassphrase';
        } catch (e) {
          return 'OTHER:${e.runtimeType}';
        }
      }

      for (final off in [0, 7, 8, 23, 24, 35, 36, 100, orig.length - 17, orig.length - 1]) {
        final b = Uint8List.fromList(orig)..[off] ^= 1;
        final res = off < 8 ? (await BackupCrypto.isEncrypted(File('${root.path}/t.pgbak')..writeAsBytesSync(b)) ? 'magic-still-ok' : 'not-detected-as-encrypted') : await tryDec(b, 'pässword');
        chk('C-tamper@$off', res != 'DECRYPTED' && !res.startsWith('OTHER'), 'bit flip at byte $off -> $res');
      }
      for (final len in [0, 7, 8, 20, 35, 36, 51, 52, orig.length - 1]) {
        final res = await tryDec(orig.sublist(0, len), 'pässword');
        chk('C-trunc@$len', res == 'WrongPassphrase', 'truncated to $len bytes -> $res');
      }
      chk('C-wrong-pass', await tryDec(orig, 'wrong') == 'WrongPassphrase', 'wrong passphrase');
      chk('C-empty-pass-vs-real', await tryDec(orig, '') == 'WrongPassphrase', 'empty passphrase on an encrypted file');
      final nfd = 'pa\u0308ssword'; // same text, decomposed
      final nfc = 'p\u00e4ssword';
      final enc2 = await BackupCrypto.encrypt(plain, File('${root.path}/p2.pgbak'), nfc);
      final r = await tryDec(enc2.readAsBytesSync(), nfd);
      chk('C-unicode-normalisation', r == 'DECRYPTED', 'passphrase typed as NFD ("a"+combining) vs NFC ("a-umlaut") -> $r (no Unicode normalisation)');
      final e1 = await BackupCrypto.encrypt(plain, File('${root.path}/e1'), 'x');
      final e2 = await BackupCrypto.encrypt(plain, File('${root.path}/e2'), 'x');
      chk('C-unique-salt-nonce', e1.readAsBytesSync().sublist(8, 36).toString() != e2.readAsBytesSync().sublist(8, 36).toString(), 'two encryptions have different salt+nonce');
      final plainDb = await makeV4('encsrc.sqlite', ['A']);
      final encDb = await BackupCrypto.encrypt(plainDb, File('${root.path}/db.pgbak'), 'x');
      chk('C-encrypted-not-sqlite', !await Exporter.isZip(encDb) && (await Exporter.inspectBackup(encDb)).ok == false, 'an encrypted file passed to inspectBackup is rejected, not misread');
    });
  });
}
