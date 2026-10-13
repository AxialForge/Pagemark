import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/backup.dart';
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

  group('PGM-102/202 backup passphrase', () {
    test('setting a passphrase records it and forces the next backup to upload', () async {
      SharedPreferences.setMockInitialValues({'bk_hash': 'old'});
      FlutterSecureStorage.setMockInitialValues({});
      await DriveBackup.setPassphrase('correct horse');
      final p = await SharedPreferences.getInstance();
      expect(p.getBool('bk_enc'), isTrue);
      expect(p.getString('bk_hash'), isNull);
      await DriveBackup.setPassphrase('');
      expect(p.getBool('bk_enc'), isFalse);
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
}
