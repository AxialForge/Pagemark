import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/crypto_backup.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/lock.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Future<int> addBook(AppDb db, String title, {String author = '', String isbn = '', bool locked = false}) =>
    db.into(db.books).insert(BooksCompanion.insert(title: title, author: Value(author), isbn: Value(isbn), locked: Value(locked)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('database', () {
    late AppDb db;
    setUp(() => db = AppDb.memory());
    tearDown(() => db.close());

    test('foreign keys are on: deleting a book removes its reads', () async {
      final id = await addBook(db, 'Dune');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id));
      await db.purgeBook(id);
      expect(await db.select(db.reads).get(), isEmpty);
    });

    test('soft delete hides from library, restore brings back, purge removes', () async {
      final id = await addBook(db, 'Dune');
      await db.softDelete(id);
      expect(await db.watchLibrary(locked: false).first, isEmpty);
      expect((await db.watchTrash().first).single.id, id);
      await db.restoreBook(id);
      expect((await db.watchLibrary(locked: false).first).single.book.id, id);
    });

    test('expired trash is purged, recent trash is kept', () async {
      final old = await addBook(db, 'Old');
      final fresh = await addBook(db, 'Fresh');
      await (db.update(db.books)..where((b) => b.id.equals(old))).write(
          BooksCompanion(deletedAt: Value(DateTime.now().subtract(const Duration(days: 40)))));
      await db.softDelete(fresh);
      expect(await db.purgeExpiredTrash(), 1);
      expect((await db.select(db.books).get()).map((b) => b.title), ['Fresh']);
    });

    test('duplicate check matches ISBN or title+author and never crosses libraries', () async {
      await addBook(db, 'Dune', author: 'Frank Herbert', isbn: '123');
      await addBook(db, 'Secret', author: 'X', locked: true);
      expect(await db.findDuplicate(title: 'dune', author: 'FRANK HERBERT', locked: false), isNotNull);
      expect(await db.findDuplicate(title: 'Other', isbn: '123', locked: false), isNotNull);
      expect(await db.findDuplicate(title: 'Secret', author: 'X', locked: false), isNull,
          reason: 'main library must not reveal a locked title');
      expect(await db.findDuplicate(title: 'Secret', author: 'X', locked: true), isNotNull);
    });

    test('book status/rating come from the right reads', () async {
      final id = await addBook(db, 'Dune');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('finished'), rating: const Value(4.0)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('reading')));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('dnf'), rating: const Value(1.0)));
      final row = (await db.watchLibrary(locked: false).first).single;
      expect(row.status, 'reading', reason: 'an active read represents the book');
      expect(row.avgRating, 4.0, reason: 'only finished reads count towards the average');
    });
  });

  group('migration', () {
    test('v1 database upgrades to v2 keeping data and gaining trash column + indexes', () async {
      final dir = Directory.systemTemp.createTempSync('pgm');
      final f = File('${dir.path}/v1.sqlite');
      final raw = sql.sqlite3.open(f.path);
      raw.execute('''
        CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '',
          isbn TEXT NOT NULL DEFAULT '', cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '',
          series TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', year INTEGER NULL, pages INTEGER NULL,
          description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', notes TEXT NOT NULL DEFAULT '',
          locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0, 1)), added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)));
        CREATE TABLE reads (id INTEGER PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id) ON DELETE CASCADE,
          format TEXT NOT NULL DEFAULT 'print', status TEXT NOT NULL DEFAULT 'want', started INTEGER NULL, finished INTEGER NULL,
          rating REAL NULL, thoughts TEXT NOT NULL DEFAULT '', narrator TEXT NOT NULL DEFAULT '', minutes INTEGER NULL);
        INSERT INTO books (title, author) VALUES ('Dune', 'Frank Herbert');
        INSERT INTO reads (book_id, status, rating) VALUES (1, 'finished', 5.0);
        PRAGMA user_version = 1;
      ''');
      raw.dispose();

      final db = AppDb.forFile(f);
      final lib = await db.watchLibrary(locked: false).first;
      expect(lib.single.book.title, 'Dune');
      expect(lib.single.book.deletedAt, isNull);
      expect(lib.single.reads.single.rating, 5.0);
      final idx = await db.customSelect("SELECT name FROM sqlite_master WHERE type='index'").get();
      expect(idx.map((r) => r.read<String>('name')), containsAll(['reads_book', 'books_locked', 'books_title']));
      await db.close();
      dir.deleteSync(recursive: true);
    });
  });

  group('restore validation', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pgm'));
    tearDown(() => dir.deleteSync(recursive: true));

    File makeDb(String name, {int version = AppDb.currentSchema, List<String> tables = const ['books', 'reads']}) {
      final f = File('${dir.path}/$name');
      final d = sql.sqlite3.open(f.path);
      for (final t in tables) {
        d.execute('CREATE TABLE $t (id INTEGER PRIMARY KEY)');
      }
      d.execute('PRAGMA user_version = $version');
      d.dispose();
      return f;
    }

    test('accepts a healthy Pagemark database', () {
      expect(Exporter.inspect(makeDb('ok.sqlite')).ok, isTrue);
    });

    test('rejects garbage, foreign databases and newer schemas', () {
      final junk = File('${dir.path}/junk.sqlite')..writeAsBytesSync(List.filled(4096, 7));
      expect(Exporter.inspect(junk).ok, isFalse);
      expect(Exporter.inspect(makeDb('other.sqlite', tables: ['notes'])).ok, isFalse);
      final r = Exporter.inspect(makeDb('new.sqlite', version: AppDb.currentSchema + 1));
      expect(r.ok, isFalse);
      expect(r.message, contains('newer'));
    });
  });

  group('export', () {
    test('formula-looking cells are neutralised and CSV starts with a BOM', () {
      expect(Exporter.safeCell('=SUM(A1)'), "'=SUM(A1)");
      expect(Exporter.safeCell('+1'), "'+1");
      expect(Exporter.safeCell('@x'), "'@x");
      expect(Exporter.safeCell('Dune'), 'Dune');
      expect(Exporter.safeCell(42), 42);
      expect(Exporter.toCsv([{'title': '=1+1'}]).startsWith('﻿'), isTrue);
    });

    test('rows exclude locked and trashed books', () async {
      final db = AppDb.memory();
      await addBook(db, 'Public');
      await addBook(db, 'Private', locked: true);
      final gone = await addBook(db, 'Gone');
      await db.softDelete(gone);
      expect((await Exporter.rows(db)).map((r) => r['title']), ['Public']);
      expect((await Exporter.rows(db, includeLocked: true)).length, 2);
      await db.close();
    });
  });

  group('backup encryption', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('pgm'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('round trip, wrong passphrase and tamper detection', () async {
      final plain = File('${dir.path}/p.sqlite')..writeAsBytesSync(List.generate(5000, (i) => i % 251));
      final enc = await BackupCrypto.encrypt(plain, File('${dir.path}/p.pgbak'), 'correct horse');
      expect(await BackupCrypto.isEncrypted(enc), isTrue);
      expect(await BackupCrypto.isEncrypted(plain), isFalse);
      final back = await BackupCrypto.decrypt(enc, File('${dir.path}/back.sqlite'), 'correct horse');
      expect(back.readAsBytesSync(), plain.readAsBytesSync());
      expect(() => BackupCrypto.decrypt(enc, File('${dir.path}/x'), 'wrong'), throwsA(isA<WrongPassphrase>()));
      final bytes = enc.readAsBytesSync()..[100] ^= 0xFF;
      enc.writeAsBytesSync(bytes);
      expect(() => BackupCrypto.decrypt(enc, File('${dir.path}/y'), 'correct horse'), throwsA(isA<WrongPassphrase>()));
    });
  });

  group('lock', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('PIN set / verify / wrong, and nothing configured by default', () async {
      expect(await LockService.mode(), isNull);
      await LockService.setPin('4821');
      expect(await LockService.mode(), 'pin');
      expect(await LockService.checkPin('4821'), PinResult.ok);
      expect(await LockService.checkPin('0000'), PinResult.wrong);
    });

    test('five misses lock out, even the right PIN is refused during lockout', () async {
      await LockService.setPin('4821');
      for (var i = 0; i < LockService.freeAttempts - 1; i++) {
        expect(await LockService.checkPin('0000'), PinResult.wrong);
      }
      expect(await LockService.checkPin('0000'), PinResult.lockedOut);
      expect(await LockService.checkPin('4821'), PinResult.lockedOut);
      expect((await LockService.lockoutRemaining()).inSeconds, greaterThan(20));
    });

    test('recovery code resets the PIN once and issues a new code', () async {
      final code = await LockService.setPin('4821');
      expect(await LockService.resetWithRecovery('wrong-code', '1111'), isNull);
      final fresh = await LockService.resetWithRecovery(code.toLowerCase(), '1111');
      expect(fresh, isNotNull);
      expect(fresh, isNot(code));
      expect(await LockService.checkPin('1111'), PinResult.ok);
      expect(await LockService.resetWithRecovery(code, '2222'), isNull, reason: 'old code is dead');
    });

    test('legacy v0.1.0 PIN still works and is upgraded to PBKDF2', () async {
      // sha256("salt:4821") using the old scheme
      FlutterSecureStorage.setMockInitialValues({
        'salt': '123',
        'pin': _legacyHash('123', '4821'),
      });
      expect(await LockService.mode(), 'pin');
      expect(await LockService.checkPin('4821'), PinResult.ok);
      expect(await LockService.checkPin('4821'), PinResult.ok, reason: 'still ok after upgrade');
      expect(await const FlutterSecureStorage().read(key: 'pin_hash'), isNotNull);
      expect(await const FlutterSecureStorage().read(key: 'pin'), isNull);
    });

    test('clear() removes the lock entirely', () async {
      await LockService.setPin('4821');
      await LockService.clear();
      expect(await LockService.mode(), isNull);
    });
  });
}

String _legacyHash(String salt, String pin) => sha256.convert(utf8.encode('$salt:$pin')).toString();
