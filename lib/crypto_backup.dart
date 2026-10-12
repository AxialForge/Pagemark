import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class WrongPassphrase implements Exception {
  @override
  String toString() => 'Wrong passphrase, or the file is damaged.';
}

/// Passphrase-encrypted backup container:
///   "PGMKENC1" (8) | salt (16) | nonce (12) | AES-256-GCM ciphertext | tag (16)
/// Key = PBKDF2-HMAC-SHA256(passphrase, salt, 150k iterations).
class BackupCrypto {
  static final _magic = 'PGMKENC1'.codeUnits;
  static final _aes = AesGcm.with256bits();
  static final _kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 150000, bits: 256);

  static Future<bool> isEncrypted(File f) async {
    final raf = await f.open();
    try {
      final head = await raf.read(_magic.length);
      if (head.length != _magic.length) return false;
      for (var i = 0; i < _magic.length; i++) {
        if (head[i] != _magic[i]) return false;
      }
      return true;
    } finally {
      await raf.close();
    }
  }

  static Future<SecretKey> _key(String pass, List<int> salt) => _kdf.deriveKeyFromPassword(password: pass, nonce: salt);

  static Future<File> encrypt(File plain, File out, String pass) async {
    final r = Random.secure();
    final s = List<int>.generate(16, (_) => r.nextInt(256));
    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(await plain.readAsBytes(), secretKey: await _key(pass, s), nonce: nonce);
    final bytes = BytesBuilder()
      ..add(_magic)
      ..add(s)
      ..add(nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    await out.writeAsBytes(bytes.takeBytes(), flush: true);
    return out;
  }

  static Future<File> decrypt(File enc, File out, String pass) async {
    final all = await enc.readAsBytes();
    const head = 8 + 16 + 12, tag = 16;
    if (all.length < head + tag) throw WrongPassphrase();
    final salt = all.sublist(8, 24), nonce = all.sublist(24, 36);
    final cipher = all.sublist(head, all.length - tag), mac = all.sublist(all.length - tag);
    try {
      final clear = await _aes.decrypt(SecretBox(cipher, nonce: nonce, mac: Mac(mac)), secretKey: await _key(pass, salt));
      await out.writeAsBytes(clear, flush: true);
      return out;
    } on SecretBoxAuthenticationError {
      throw WrongPassphrase();
    }
  }
}
