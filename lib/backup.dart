import 'dart:io';
import 'package:crypto/crypto.dart' as hash;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'backup_errors.dart';
import 'covers.dart';
import 'crypto_backup.dart';
import 'log.dart';
import 'notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'db.dart';
import 'export.dart';

const _scope = 'https://www.googleapis.com/auth/drive.appdata';
const _task = 'pagemark-drive-backup';
const keepBackups = 5;

class _Auth extends http.BaseClient {
  final String token;
  final http.Client _c = http.Client();
  _Auth(this.token);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) {
    r.headers['Authorization'] = 'Bearer $token';
    return _c.send(r);
  }
}

/// Runs in a background isolate, so it opens its own database connection.
@pragma('vm:entry-point')
void backupDispatcher() {
  Workmanager().executeTask((task, input) async {
    Log.i('backup', 'scheduled backup started');
    final db = AppDb();
    try {
      final r = await DriveBackup.run(db, interactive: false);
      Log.i('backup', 'scheduled backup finished: $r');
      return true;
    } catch (e, st) {
      Log.e('backup', e, st);
      // Count consecutive failures; tell the user when it needs their attention (sign-in expired) or keeps failing.
      final p = await SharedPreferences.getInstance();
      final streak = (p.getInt('bk_fail') ?? 0) + 1;
      await p.setInt('bk_fail', streak);
      if (shouldNotifyBackupFailure(streak, authProblem: isAuthProblem(e))) await Notifier.backupProblem(friendlyBackupError(e));
      return false; // retried with backoff; the error is also stored in prefs for the Settings row
    } finally {
      await db.close();
    }
  });
}

class BackupSettings {
  bool enabled = false;
  String frequency = 'daily'; // daily | weekly
  bool wifiOnly = true;
  String serverClientId = '';
  String? account, lastOk, lastError;

  static Future<BackupSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return BackupSettings()
      ..enabled = p.getBool('bk_on') ?? false
      ..frequency = p.getString('bk_freq') ?? 'daily'
      ..wifiOnly = p.getBool('bk_wifi') ?? true
      ..serverClientId = p.getString('bk_cid') ?? ''
      ..account = p.getString('bk_acct')
      ..lastOk = p.getString('bk_ok')
      ..lastError = p.getString('bk_err');
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('bk_on', enabled);
    await p.setString('bk_freq', frequency);
    await p.setBool('bk_wifi', wifiOnly);
    await p.setString('bk_cid', serverClientId.trim());
  }
}

/// What a backup run did.
class BackupResult {
  final bool uploaded;
  final int bytes;
  const BackupResult(this.uploaded, this.bytes);
  @override
  String toString() => uploaded ? 'uploaded $bytes bytes' : 'unchanged';
}

class DriveBackup {
  static bool _init = false;
  static String? _initId;

  static Future<void> _ensureInit() async {
    final p = await SharedPreferences.getInstance();
    final cid = p.getString('bk_cid') ?? '';
    if (cid.isEmpty) throw const BackupAuthException('Enter your Google Web client ID first.');
    if (_init) {
      if (_initId != cid) throw 'The client ID changed. Close and reopen Pagemark to apply it.';
      return;
    }
    await GoogleSignIn.instance.initialize(serverClientId: cid);
    _init = true;
    _initId = cid;
  }

  /// Interactive sign-in + one-time Drive permission grant.
  static Future<String> signIn() async {
    await _ensureInit();
    final acct = await GoogleSignIn.instance.authenticate();
    await acct.authorizationClient.authorizeScopes([_scope]);
    final p = await SharedPreferences.getInstance();
    await p.setString('bk_acct', acct.email);
    return acct.email;
  }

  static Future<void> signOut() async {
    await _ensureInit();
    await GoogleSignIn.instance.signOut();
    final p = await SharedPreferences.getInstance();
    await p.remove('bk_acct');
  }

  static Future<drive.DriveApi> _api({required bool interactive}) async {
    await _ensureInit();
    // Lightweight (silent) auth works from the background isolate after the first grant.
    var acct = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (acct == null && interactive) acct = await GoogleSignIn.instance.authenticate();
    if (acct == null) throw const BackupAuthException('Signed out of Google. Open Pagemark, go to Settings, Google Drive backup, and sign in again.');
    var auth = await acct.authorizationClient.authorizationForScopes([_scope]);
    if (auth == null && interactive) auth = await acct.authorizationClient.authorizeScopes([_scope]);
    if (auth == null) throw const BackupAuthException('Drive permission is missing or was revoked. Open Pagemark, go to Settings, Google Drive backup, and sign in again.');
    return drive.DriveApi(_Auth(auth.accessToken));
  }

  static const _store = FlutterSecureStorage();

  static Future<String?> passphrase() => _store.read(key: 'bk_pass');

  /// Remembers that a passphrase was chosen (plain pref), so a lost secure-storage copy is noticed instead of
  /// silently producing unencrypted uploads.
  static Future<void> setPassphrase(String? p) async {
    final prefs = await SharedPreferences.getInstance();
    if (p == null || p.isEmpty) {
      await prefs.setBool('bk_enc', false);
      await _store.delete(key: 'bk_pass');
    } else {
      await _store.write(key: 'bk_pass', value: p);
      await prefs.setBool('bk_enc', true);
    }
    await prefs.remove('bk_hash'); // a new passphrase means the next run must upload again
  }

  /// Upload a fresh database snapshot (encrypted when a passphrase is set), skipping the upload
  /// when nothing changed. Old copies are pruned only after the new one is verified on Drive.
  static Future<BackupResult> run(AppDb db, {required bool interactive, bool force = false}) async {
    final p = await SharedPreferences.getInstance();
    try {
      final api = await _api(interactive: interactive);
      final snap = await Exporter.snapshotDb(db);
      final pass = await passphrase();
      if ((pass == null || pass.isEmpty) && (p.getBool('bk_enc') ?? false)) {
        throw const BackupAuthException('Your backup passphrase is no longer stored on this phone, so nothing was uploaded. Open Pagemark, go to Settings, Google Drive backup, and set the passphrase again.');
      }
      final digest = hash.sha256.convert(await snap.readAsBytes()).toString();
      final coversSig = hash.sha256.convert((await CoverStore.signature()).codeUnits).toString();
      final sig = '$digest|$coversSig|${pass == null || pass.isEmpty ? 'plain' : 'enc:${hash.sha256.convert(pass.codeUnits).toString().substring(0, 8)}'}';
      if (!force && p.getString('bk_hash') == sig) {
        await snap.delete();
        await p.setString('bk_ok', DateTime.now().toIso8601String());
        await p.remove('bk_err');
        await p.setInt('bk_fail', 0);
        return const BackupResult(false, 0);
      }
      // covers saved on the phone travel inside the backup (a zip), so a restore on a new phone shows them offline
      var upload = await Exporter.bundle(snap, baseName: 'pagemark-upload');
      var ext = upload.path.endsWith('.zip') ? 'zip' : 'sqlite';
      if (pass != null && pass.isNotEmpty) {
        final tmp = await getTemporaryDirectory();
        final plain = upload;
        upload = await BackupCrypto.encrypt(plain, File('${tmp.path}/pagemark-upload.pgbak'), pass);
        if (plain.path != upload.path && await plain.exists()) await plain.delete();
        ext = 'pgbak';
      }
      final name = 'pagemark-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.$ext';
      final size = await upload.length();
      final made = await api.files.create(
        drive.File(name: name, parents: ['appDataFolder']),
        uploadMedia: drive.Media(upload.openRead(), size),
        uploadOptions: drive.ResumableUploadOptions(), // survives a flaky connection instead of restarting from zero
        $fields: 'id,size',
      );
      if (int.tryParse(made.size ?? '') != size) {
        if (made.id != null) await api.files.delete(made.id!);
        throw 'Drive did not store the whole backup (it reports ${made.size} bytes, expected $size). Nothing was removed; try Back up now again.';
      }
      for (final f in (await list(api: api)).skip(keepBackups)) {
        await api.files.delete(f.id!);
      }
      for (final f in {snap, upload}) { // (snap is already gone when it was bundled)
        if (await f.exists()) await f.delete();
      }
      await p.setString('bk_hash', sig);
      await p.setString('bk_ok', DateTime.now().toIso8601String());
      await p.remove('bk_err');
      await p.setInt('bk_fail', 0);
      await Notifier.clearBackupProblem();
      return BackupResult(true, size);
    } catch (e) {
      Log.w('backup', 'run failed: $e');
      await p.setString('bk_err', '${DateTime.now().toIso8601String()}  ${friendlyBackupError(e)}');
      rethrow;
    }
  }

  /// Newest first.
  static Future<List<drive.File>> list({drive.DriveApi? api}) async {
    api ??= await _api(interactive: true);
    final r = await api.files.list(
      spaces: 'appDataFolder', orderBy: 'createdTime desc',
      $fields: 'files(id,name,size,createdTime)', pageSize: 50,
    );
    return r.files ?? [];
  }

  static Future<File> download(drive.File f, File dest) async {
    final api = await _api(interactive: true);
    final media = await api.files.get(f.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final sink = dest.openWrite();
    await media.stream.pipe(sink);
    return dest;
  }

  /// (Re)schedule or cancel the periodic job from the saved settings.
  static Future<void> applySchedule(BackupSettings s) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await Workmanager().initialize(backupDispatcher);
    if (!s.enabled) {
      await Workmanager().cancelByUniqueName(_task);
      (await SharedPreferences.getInstance()).remove('bk_sched');
      return;
    }
    final p = await SharedPreferences.getInstance();
    final sig = '${s.frequency}|${s.wifiOnly}';
    if (p.getString('bk_sched') == sig) return; // unchanged: don't reset the running period
    await p.setString('bk_sched', sig);
    await Workmanager().registerPeriodicTask(
      _task, _task,
      frequency: s.frequency == 'weekly' ? const Duration(days: 7) : const Duration(days: 1),
      constraints: Constraints(networkType: s.wifiOnly ? NetworkType.unmetered : NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }
}
