import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as c;
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinResult { ok, wrong, lockedOut }

/// Locked library protection: PIN (PBKDF2, per-install random salt, attempt limiting,
/// recovery code) and/or the device's biometrics/screen lock. Secrets live in secure storage.
class LockService {
  // resetOnError: false - if Android's Keystore breaks, the plugin must NOT silently wipe the saved PIN (that would let
  // anyone open the locked library by "setting a new PIN"). A failed read is treated as "locked" instead.
  static const _s = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: false));
  static const _marker = 'lock_set'; // plain pref: a lock WAS configured, so empty secure storage means it was lost
  static final _auth = LocalAuthentication();
  static const iterations = 150000;
  static const freeAttempts = 5;

  static final _pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);

  static Future<String> _derive(String secret, List<int> salt) async {
    final k = await _pbkdf2.deriveKeyFromPassword(password: secret, nonce: salt);
    return base64.encode(await k.extractBytes());
  }

  static List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  static Future<bool> _markerSet() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_marker) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _setMarker(bool on) async {
    try {
      final p = await SharedPreferences.getInstance();
      on ? await p.setBool(_marker, true) : await p.remove(_marker);
    } catch (_) {}
  }

  /// 'pin', 'device', null (nothing configured yet), 'lost' (a lock was set but Android cleared the saved copy) or
  /// 'unavailable' (secure storage cannot be read right now). The last two are never treated as "no lock".
  static Future<String?> mode() async {
    try {
      final m = await _s.read(key: 'mode');
      if (m != null) return m;
      if (await _s.read(key: 'pin') != null) return 'pin'; // v0.1.0 install (legacy hash)
    } catch (_) {
      return 'unavailable';
    }
    return await _markerSet() ? 'lost' : null;
  }

  static Future<bool> hasPin() async => await mode() == 'pin';

  /// Sets (or replaces) the PIN. Returns a fresh one-time recovery code.
  static Future<String> setPin(String pin) async {
    final salt = _randomBytes(16);
    await _s.write(key: 'mode', value: 'pin');
    await _setMarker(true);
    await _s.write(key: 'pin_salt', value: base64.encode(salt));
    await _s.write(key: 'pin_hash', value: await _derive(pin, salt));
    await _s.delete(key: 'pin');
    await _s.delete(key: 'salt');
    await _resetFails();
    return newRecoveryCode();
  }

  static Future<String> newRecoveryCode() async {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    final raw = List.generate(16, (_) => alphabet[r.nextInt(alphabet.length)]).join();
    final salt = _randomBytes(16);
    await _s.write(key: 'rec_salt', value: base64.encode(salt));
    await _s.write(key: 'rec_hash', value: await _derive(raw, salt));
    return [for (var i = 0; i < 16; i += 4) raw.substring(i, i + 4)].join('-');
  }

  static String _normCode(String code) => code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static Future<void> setDeviceOnly() async {
    await _s.write(key: 'mode', value: 'device');
    await _setMarker(true);
    await _s.delete(key: 'pin_hash');
    await _s.delete(key: 'pin_salt');
    await _s.delete(key: 'rec_hash');
    await _s.delete(key: 'rec_salt');
    await _resetFails();
  }

  static Future<void> clear() async {
    for (final k in ['mode', 'pin_hash', 'pin_salt', 'pin', 'salt', 'rec_hash', 'rec_salt']) {
      await _s.delete(key: k);
    }
    await _setMarker(false);
    await _resetFails();
  }

  // ── attempt limiting ──
  static Future<Duration> lockoutRemaining() async {
    final until = int.tryParse(await _s.read(key: 'lock_until') ?? '') ?? 0;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    // never longer than the longest lockout (1 h): a clock set far ahead must not lock the library out for good
    return left > 0 ? Duration(milliseconds: left > 3600 * 1000 ? 3600 * 1000 : left) : Duration.zero;
  }

  static Future<void> _resetFails() async {
    await _s.delete(key: 'fails');
    await _s.delete(key: 'lock_until');
  }

  static Future<void> _recordFail() async {
    final n = (int.tryParse(await _s.read(key: 'fails') ?? '') ?? 0) + 1;
    await _s.write(key: 'fails', value: '$n');
    if (n >= freeAttempts) {
      // 30 s after the 5th miss, doubling every further 5 misses, capped at 1 h.
      final steps = min(7, (n ~/ freeAttempts) - 1); // capped so the shift can never overflow (30 << 7 = 3840 s > 1 h)
      final secs = min(3600, 30 * (1 << steps));
      await _s.write(key: 'lock_until', value: '${DateTime.now().millisecondsSinceEpoch + secs * 1000}');
    }
  }

  static Future<void> _chain = Future<void>.value();

  /// Attempts are checked one at a time, so two quick taps cannot be counted as one failure.
  static Future<PinResult> checkPin(String pin) {
    final next = _chain.then((_) => _checkPin(pin));
    _chain = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  static Future<PinResult> _checkPin(String pin) async {
    if ((await lockoutRemaining()) > Duration.zero) return PinResult.lockedOut;
    final ok = await _verifyPin(pin);
    if (ok) {
      await _resetFails();
      return PinResult.ok;
    }
    await _recordFail();
    return (await lockoutRemaining()) > Duration.zero ? PinResult.lockedOut : PinResult.wrong;
  }

  static Future<bool> _verifyPin(String pin) async {
    final hash = await _s.read(key: 'pin_hash');
    if (hash != null) {
      final salt = base64.decode(await _s.read(key: 'pin_salt') ?? '');
      return _constEq(await _derive(pin, salt), hash);
    }
    // Legacy v0.1.0 format: sha256("$salt:$pin"). Verify, then upgrade to PBKDF2.
    final legacy = await _s.read(key: 'pin');
    if (legacy == null) return false;
    final salt = await _s.read(key: 'salt') ?? '';
    final ok = _constEq(c.sha256.convert(utf8.encode('$salt:$pin')).toString(), legacy);
    if (ok) await setPin(pin);
    return ok;
  }

  /// Forgot-PIN path: a valid recovery code lets the user choose a new PIN.
  /// Returns the new recovery code, or null if the code was wrong / locked out.
  static Future<String?> resetWithRecovery(String code, String newPin) async {
    if ((await lockoutRemaining()) > Duration.zero) return null;
    final hash = await _s.read(key: 'rec_hash');
    if (hash == null) return null;
    final salt = base64.decode(await _s.read(key: 'rec_salt') ?? '');
    if (!_constEq(await _derive(_normCode(code), salt), hash)) {
      await _recordFail();
      return null;
    }
    return setPin(newPin);
  }

  static bool _constEq(String a, String b) {
    if (a.length != b.length) return false;
    var d = 0;
    for (var i = 0; i < a.length; i++) {
      d |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return d == 0;
  }

  /// Tests set this to bypass the biometric plugin (which has no implementation on the test VM).
  @visibleForTesting
  static bool? debugDeviceSupported;

  static Future<bool> deviceAvailable() async {
    if (debugDeviceSupported != null) return debugDeviceSupported!;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Does the phone offer a *strong* biometric (fingerprint)? Face unlock on many phones is only "weak".
  static Future<bool> strongBiometricAvailable() async {
    if (debugDeviceSupported != null) return debugDeviceSupported!;
    try {
      return (await _auth.getAvailableBiometrics()).contains(BiometricType.strong);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deviceAuth([String reason = 'Unlock your private library']) async {
    if (debugDeviceSupported != null) return debugDeviceSupported!;
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }
}
