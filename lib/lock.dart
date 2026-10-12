import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Locked library: app PIN (salted hash, in secure storage) and/or device biometrics/screen lock.
class LockService {
  static const _s = FlutterSecureStorage();
  static final _auth = LocalAuthentication();

  static String _hash(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin')).toString();

  static Future<bool> hasPin() async => (await _s.read(key: 'pin')) != null;

  static Future<void> setPin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    await _s.write(key: 'salt', value: salt);
    await _s.write(key: 'pin', value: _hash(pin, salt));
  }

  static Future<bool> checkPin(String pin) async {
    final salt = await _s.read(key: 'salt') ?? '';
    return _hash(pin, salt) == await _s.read(key: 'pin');
  }

  static Future<void> clearPin() async {
    await _s.delete(key: 'pin');
    await _s.delete(key: 'salt');
  }

  static Future<bool> deviceAuth() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.authenticate(localizedReason: 'Unlock your private library');
    } catch (_) {
      return false;
    }
  }
}
