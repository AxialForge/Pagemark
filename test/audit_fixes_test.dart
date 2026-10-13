import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/backup.dart';
import 'package:pagemark/lock.dart';
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
}
