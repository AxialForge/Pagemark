import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'backup_reminder.dart';
import 'crypto_backup.dart';
import 'export.dart';
import 'log.dart';
import 'main.dart';
import 'privacy.dart';

/// Automatic backups into a folder the user picked once with Android's own file picker. The folder can be on the phone, a USB drive, or
/// in Google Drive, OneDrive or Dropbox (Android then does the cloud part), so there is no sign-in and no developer account involved.
/// When Pagemark opens and a backup is due, it quietly writes a fresh file there and keeps the newest few.
class FolderBackup {
  static const _ch = MethodChannel('pagemark/folder');
  static const _store = FlutterSecureStorage(aOptions: AndroidOptions(resetOnError: false));
  static const keep = 5;
  static const prefix = 'Pagemark-backup-';
  static const everyChoices = <int, String>{1: 'Every day', 7: 'Every week', 14: 'Every 2 weeks', 30: 'Every month'};

  static bool _running = false;

  static String? get folderUri => prefs.getString('fb_uri');
  static String get folderName => prefs.getString('fb_name') ?? 'your folder';
  static bool get isSet => folderUri != null;
  static bool get passwordWanted => prefs.getBool('fb_enc') ?? false;
  static int get everyDays {
    final v = prefs.getInt('fb_every') ?? 7;
    return everyChoices.containsKey(v) ? v : 7;
  }

  static DateTime? get lastOk => DateTime.tryParse(prefs.getString('fb_last') ?? '');
  static String? get lastError => prefs.getString('fb_err');

  /// Pure: is a backup due at [now]? Never ran, or [everyDays] have passed since the last good one.
  static bool isDue(DateTime now, DateTime? last, int everyDays) =>
      last == null || DateTime(now.year, now.month, now.day).difference(DateTime(last.year, last.month, last.day)).inDays >= everyDays;

  /// Pure: which of [names] (file names found in the folder) to delete so only the newest [keep] of our own files remain. The date is
  /// in each name, so sorting the names sorts by age. Files that are not ours are never touched.
  static List<String> toDelete(Iterable<String> names, {int keep = FolderBackup.keep}) {
    final ours = names.where((n) => n.startsWith(prefix)).toList()..sort((a, b) => b.compareTo(a));
    return ours.skip(keep).toList();
  }

  static String fileName(DateTime t, String ext) => '$prefix${DateFormat('yyyyMMdd-HHmm').format(t)}.$ext';

  /// Opens Android's folder picker. Returns the folder, or null if the user cancelled. Nothing is saved yet: Pagemark comes back to the
  /// front when the picker closes and must not start a backup before the password question has been answered (see [commit]).
  static Future<({String uri, String name})?> choose() async {
    final r = await _ch.invokeMapMethod<String, String>('pick');
    if (r == null) return null;
    return (uri: r['uri']!, name: r['name'] ?? 'your folder');
  }

  /// Remembers the folder. From now on automatic backups go there.
  static Future<void> commit(({String uri, String name}) folder) async {
    await prefs.setString('fb_uri', folder.uri);
    await prefs.setString('fb_name', folder.name);
    await prefs.remove('fb_err');
  }

  static Future<void> turnOff() async {
    for (final k in ['fb_uri', 'fb_name', 'fb_err', 'fb_last']) {
      await prefs.remove(k);
    }
  }

  static Future<String?> password() => _store.read(key: 'fb_pass');

  /// Sets (or, with an empty text, removes) the password used for folder backups.
  static Future<void> setPassword(String? p) async {
    if (p == null || p.isEmpty) {
      await _store.delete(key: 'fb_pass');
      await prefs.setBool('fb_enc', false);
    } else {
      await _store.write(key: 'fb_pass', value: p);
      await prefs.setBool('fb_enc', true);
    }
  }

  /// Writes a backup now when one is due (or [force]). Never throws; the outcome is kept for the Backup page. Returns true if a file was written.
  static Future<bool> runIfDue({bool force = false}) async {
    if (!isSet || _running || defaultTargetPlatform != TargetPlatform.android) return false;
    if (!force && !isDue(DateTime.now(), lastOk, everyDays)) return false;
    _running = true;
    File? plain, out;
    try {
      final tree = folderUri!;
      if (!await _ch.invokeMethod<bool>('check', {'tree': tree}).then((v) => v ?? false)) {
        throw 'Pagemark can no longer use the folder you chose. Pick it again.';
      }
      final pass = await password();
      if (passwordWanted && (pass == null || pass.isEmpty)) {
        throw 'Your backup password is no longer saved on this phone. Set it again, or turn the password off.';
      }
      final snap = await Exporter.snapshotDb(db, name: 'pagemark-folder.sqlite');
      plain = await Exporter.bundle(snap, baseName: 'pagemark-folder');
      out = plain;
      var ext = plain.path.endsWith('.zip') ? 'zip' : 'sqlite';
      if (passwordWanted) {
        final tmp = await getTemporaryDirectory();
        out = await BackupCrypto.encrypt(plain, File('${tmp.path}/pagemark-folder.pgbak'), pass!);
        ext = 'pgbak';
      }
      final now = DateTime.now();
      await _ch.invokeMethod<String>('write', {'tree': tree, 'name': fileName(now, ext), 'path': out.path, 'mime': 'application/octet-stream'});
      try {
        final files = (await _ch.invokeListMethod<Map<Object?, Object?>>('list', {'tree': tree})) ?? const [];
        final byName = {for (final f in files) '${f['name']}': '${f['uri']}'};
        for (final n in toDelete(byName.keys)) {
          await _ch.invokeMethod<void>('delete', {'uri': byName[n]});
        }
      } catch (e) {
        Log.w('folder-backup', 'could not tidy old copies: $e'); // the new copy is safe; old ones just stay
      }
      await prefs.setString('fb_last', now.toIso8601String());
      await prefs.remove('fb_err');
      await BackupReminder.recordBackup();
      return true;
    } catch (e) {
      Log.w('folder-backup', 'backup failed: $e');
      await prefs.setString('fb_err', e is String ? e : (e is PlatformException ? (e.message ?? 'The folder did not accept the file.') : 'The backup did not work. Try again.'));
      return false;
    } finally {
      _running = false;
      await cleanTempExports();
    }
  }
}
