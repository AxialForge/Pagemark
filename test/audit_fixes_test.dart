import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pagemark/db.dart';
import 'package:pagemark/features.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/lock.dart';
import 'package:pagemark/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PGM-101 lockout cannot overflow', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({'mode': 'pin', 'pin_salt': 'AAAA', 'pin_hash': 'x', 'fails': '319'});
    });
    test('after hundreds of misses the lockout is still positive and at most an hour', () async {
      final r = await LockService.checkPin('0000'); // 320th miss
      expect(r, PinResult.lockedOut);
      final left = await LockService.lockoutRemaining();
      expect(left, greaterThan(Duration.zero));
      expect(left, lessThanOrEqualTo(const Duration(hours: 1)));
    });
  });

  group('PGM-200 a lost lock is never "no lock"', () {
    test('nothing configured ever: mode is null', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      expect(await LockService.mode(), isNull);
    });
    test('a lock was set but secure storage came back empty: mode is lost', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      await LockService.setPin('1234');
      FlutterSecureStorage.setMockInitialValues({}); // Android wiped the Keystore data
      expect(await LockService.mode(), 'lost');
    });
    test('removing the lock on purpose clears the marker', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      await LockService.setPin('1234');
      await LockService.clear();
      expect(await LockService.mode(), isNull);
    });
  });

  group('PGM-201 the log never keeps database values', () {
    test('a sqlite exception with bound parameters is cut off before it is written', () {
      const msg = 'SqliteException(2067): UNIQUE constraint failed, Causing statement: INSERT INTO books (title) VALUES (?), parameters: [My Secret Diary]';
      final out = Log.scrub(msg);
      expect(out, isNot(contains('Secret')));
      expect(out, contains('database details removed'));
    });
    test('long messages are capped', () {
      expect(Log.scrub('x' * 5000).length, lessThan(700));
    });
  });

  group('PGM-112/113/120 importer survives hostile cells', () {
    test('impossible dates are rejected, not rolled over', () {
      expect(Importer.parseDate('2024-02-30'), isNull);
      expect(Importer.parseDate('2024-13-01'), isNull);
      expect(Importer.parseDate('2024-02-29'), DateTime(2024, 2, 29));
      expect(Importer.parseDate('0001-01-01'), isNull);
    });
    test('NaN and Infinity in rating cells are ignored', () {
      expect(Importer.halfStars('NaN'), isNull);
      expect(Importer.halfStars('Infinity'), isNull);
      expect(Importer.halfStars('4.2'), 4.0);
    });
    test('odd JSON shapes give a clear ImportException', () {
      expect(() => Importer.parse('{"pagemark_export": "x", "books": []}'), throwsA(isA<ImportException>()));
      expect(() => Importer.parse('{"pagemark_export": 2, "books": 7}'), returnsNormally);
      expect(() => Importer.parse('{"pagemark_export": 9}'), throwsA(isA<ImportException>()));
    });
  });

  group('PGM-108 undo import takes back everything it added', () {
    test('reads on existing books, quotes and created shelves go away; new books go to Trash', () async {
      final db = AppDb.memory();
      final keep = await db.into(db.books).insert(BooksCompanion.insert(title: 'Old Book', author: const Value('A')));
      final parse = ImportParse(ImportSource.pagemarkCsv, [
        ImportBook(title: 'Old Book', author: 'A')
          ..reads.add(ImportRead(status: 'finished'))
          ..quotes.add(ImportQuote('a line'))
          ..shelves.add('Imported shelf'),
        ImportBook(title: 'New Book', author: 'B')..reads.add(ImportRead(status: 'want')),
      ], const []);
      final res = await ImportRunner.run(db, await ImportRunner.plan(db, parse), DuplicatePolicy.addReads);
      expect(res.booksAdded, 1);
      expect(res.existingReadIds, hasLength(1));
      expect(res.createdShelfIds, hasLength(1));
      await ImportRunner.undo(db, res);
      expect((await db.select(db.reads).get()).where((r) => r.bookId == keep), isEmpty, reason: 'the old book had no reads before');
      expect(await db.select(db.quotes).get(), isEmpty);
      expect(await db.select(db.shelves).get(), isEmpty);
      expect((await db.watchLibrary(locked: false).first).map((r) => r.book.id), [keep]);
      await db.close();
    });
  });

  group('PGM-126/127 bulk operations', () {
    test('40,000 ids do not exceed SQLite variable limits', () async {
      final db = AppDb.memory();
      final id = await db.into(db.books).insert(BooksCompanion.insert(title: 'One'));
      await db.softDeleteMany([id, for (var i = 1000; i < 41000; i++) i]);
      expect((await db.select(db.books).get()).single.deletedAt, isNotNull);
      await db.close();
    });
    test('undoing mark-finished keeps a created read the user has since edited', () async {
      final db = AppDb.memory();
      final id = await db.into(db.books).insert(BooksCompanion.insert(title: 'One'));
      final u = await db.markFinishedToday([id]);
      final rid = u.created.single;
      await (db.update(db.reads)..where((r) => r.id.equals(rid))).write(const ReadsCompanion(thoughts: Value('loved it')));
      await db.undoMarkFinished(u);
      expect(await db.select(db.reads).get(), hasLength(1));
      await db.close();
    });
  });

  test('PGM-123 series numbers must be finite and sensible', () {
    expect(SeriesPage.parseNum('2.5'), 2.5);
    expect(SeriesPage.parseNum('NaN'), isNull);
    expect(SeriesPage.parseNum('Infinity'), isNull);
    expect(SeriesPage.parseNum('1e20'), isNull);
    expect(SeriesPage.fmtNum(double.nan), '');
  });

  test('PGM-110 a shelf that only holds locked books is not listed in the main library', () async {
    final db = AppDb.memory();
    final secret = await db.into(db.books).insert(BooksCompanion.insert(title: 'S', locked: const Value(true)));
    final plain = await db.into(db.books).insert(BooksCompanion.insert(title: 'P'));
    final vaultShelf = await db.addShelf('Hidden shelf');
    final mainShelf = await db.addShelf('Comfort reads');
    await db.setOnShelf(secret, vaultShelf, true);
    await db.setOnShelf(plain, mainShelf, true);
    expect((await db.watchShelves(locked: false).first).map((s) => s.name), ['Comfort reads']);
    expect((await db.watchShelves(locked: true).first).map((s) => s.name), ['Hidden shelf']);
    await db.close();
  });
}
