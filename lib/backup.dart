import 'dart:io';
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
    final db = AppDb();
    try {
      await DriveBackup.run(db, interactive: false);
      return true;
    } catch (_) {
      return false; // retried with backoff; error is stored in prefs
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

class DriveBackup {
  static bool _init = false;

  static Future<void> _ensureInit() async {
    if (_init) return;
    final p = await SharedPreferences.getInstance();
    final cid = p.getString('bk_cid') ?? '';
    if (cid.isEmpty) throw 'Enter your Google Web client ID first.';
    await GoogleSignIn.instance.initialize(serverClientId: cid);
    _init = true;
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
    if (acct == null) throw 'Signed out of Google — open Pagemark > Backup and sign in again.';
    var auth = await acct.authorizationClient.authorizationForScopes([_scope]);
    if (auth == null && interactive) auth = await acct.authorizationClient.authorizeScopes([_scope]);
    if (auth == null) throw 'Drive permission missing — open Pagemark > Backup and sign in again.';
    return drive.DriveApi(_Auth(auth.accessToken));
  }

  /// Upload a fresh database snapshot, then prune to the newest [keepBackups].
  static Future<void> run(AppDb db, {required bool interactive}) async {
    final p = await SharedPreferences.getInstance();
    try {
      final api = await _api(interactive: interactive);
      final snap = await Exporter.snapshotDb(db);
      final name = 'pagemark-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}.sqlite';
      final media = drive.Media(snap.openRead(), await snap.length());
      await api.files.create(
        drive.File(name: name, parents: ['appDataFolder']),
        uploadMedia: media,
      );
      final old = await list(api: api);
      for (final f in old.skip(keepBackups)) {
        await api.files.delete(f.id!);
      }
      await p.setString('bk_ok', DateTime.now().toIso8601String());
      await p.remove('bk_err');
    } catch (e) {
      await p.setString('bk_err', '${DateTime.now().toIso8601String()}  $e');
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
      return;
    }
    await Workmanager().registerPeriodicTask(
      _task, _task,
      frequency: s.frequency == 'weekly' ? const Duration(days: 7) : const Duration(days: 1),
      constraints: Constraints(networkType: s.wifiOnly ? NetworkType.unmetered : NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
    );
  }
}
