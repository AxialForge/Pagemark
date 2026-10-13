import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'backup.dart';
import 'backup_errors.dart';
import 'log.dart';
import 'notifier.dart';
import 'text_utils.dart';
import 'widgets.dart';
import 'crypto_backup.dart';
import 'export.dart';
import 'main.dart';
import 'ui.dart';

/// Decrypt (asking for the passphrase if needed) and validate a backup file, then offer to restore it.
/// Shared by "Restore from file" and "Restore from Drive". Exits the app after a successful swap.
Future<void> restoreFlow(BuildContext context, File picked) async {
  var file = picked;
  if (await BackupCrypto.isEncrypted(picked)) {
    if (!context.mounted) return;
    final pass = await ask(context, 'Backup passphrase', '', false, true);
    if (pass == null || pass.isEmpty) return;
    try {
      final tmp = await getTemporaryDirectory();
      file = await BackupCrypto.decrypt(picked, File('${tmp.path}/pagemark-restore.sqlite'), pass);
    } on WrongPassphrase catch (e) {
      if (context.mounted) snack(context, '$e');
      return;
    }
  }
  final check = await Exporter.inspectBackup(file);
  if (!context.mounted) return;
  if (!check.ok) {
    snack(context, check.message);
    return;
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Replace your library?'),
      content: Text('This backup holds ${check.books} books and ${check.reads} reads${check.covers > 0 ? ' and ${check.covers} saved covers' : ''}. '
          'Your current library is replaced; a safety copy of it is kept in the app (newest 3). The app will close afterwards.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await Exporter.restoreDb(db, file);
  } catch (e) {
    if (context.mounted) snack(context, '$e');
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (c) => AlertDialog(
      title: const Text('Restored'),
      content: Text('Pagemark will now close. Open it again to see your restored library.'
          '${check.lockedBooks > 0 ? '\n\nYour ${check.lockedBooks} locked book${check.lockedBooks == 1 ? '' : 's'} came back too, but your PIN is not part of backups. '
              'Open the Locked tab and set a new PIN to reach ${check.lockedBooks == 1 ? 'it' : 'them'}.' : ''}'),
      actions: [FilledButton(onPressed: () => SystemNavigator.pop(), child: const Text('Close Pagemark'))], // a graceful exit, not exit(0)
    ),
  );
}

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  BackupSettings? s;
  bool encrypted = false;
  final cid = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final v = await BackupSettings.load();
    final pass = await DriveBackup.passphrase();
    if (!context.mounted) return;
    setState(() {
      s = v;
      encrypted = pass != null && pass.isNotEmpty;
      if (cid.text.isEmpty) cid.text = v.serverClientId;
    });
  }

  @override
  void dispose() {
    cid.dispose();
    super.dispose();
  }

  Future<void> guard(Future<void> Function() f) async {
    setState(() => busy = true);
    try {
      await f();
    } catch (e) {
      Log.w('backup-ui', 'action failed: $e');
      if (mounted) snack(context, friendlyBackupError(e));
    }
    await _reload();
    if (mounted) setState(() => busy = false);
  }

  Future<void> persist() async {
    if (cid.text.trim().isNotEmpty && !looksLikeGoogleClientId(cid.text)) {
      throw 'The Web client ID does not look right. It should end with .apps.googleusercontent.com (copy it from Google Cloud, Credentials, Web application).';
    }
    s!.serverClientId = cid.text.trim();
    await s!.save();
    await DriveBackup.applySchedule(s!);
  }

  String fmt(String? iso) => iso == null ? 'never' : DateFormat.yMMMd().add_jm().format(DateTime.parse(iso));

  Future<void> _toggleEncryption(bool on) async {
    if (!on) {
      await DriveBackup.setPassphrase(null);
      return;
    }
    final a = await ask(context, 'Choose a backup passphrase', '', false, true);
    if (a == null || a.length < 8 || !mounted) {
      if (a != null && mounted) snack(context, 'Use at least 8 characters');
      return;
    }
    final b = await ask(context, 'Re-enter the passphrase', '', false, true);
    if (b != a) {
      if (mounted) snack(context, 'Passphrases did not match');
      return;
    }
    await DriveBackup.setPassphrase(a);
    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Remember this passphrase'),
          content: const Text('Backups are now encrypted. If you lose both this phone and the passphrase, the backups cannot be opened — not even by Pagemark.'),
          actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = s;
    return Scaffold(
      appBar: AppBar(title: const Text('Google Drive backup')),
      body: st == null
          ? const SizedBox()
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (busy) const LinearProgressIndicator(),
              const Text('Backups are full database copies (including locked books) stored in Pagemark\'s private '
                  'app-data folder on your Drive — they don\'t show in your normal Drive files. The newest 5 are kept, '
                  'and an unchanged library isn\'t uploaded again.'),
              const SizedBox(height: 16),
              TextField(
                controller: cid,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Google Web client ID',
                  helperText: 'From your Google Cloud project (see setup guide)',
                  errorText: cid.text.trim().isNotEmpty && !looksLikeGoogleClientId(cid.text) ? 'Should end with .apps.googleusercontent.com' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => st.serverClientId = cid.text),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_circle),
                title: Text(st.account ?? 'Not signed in'),
                trailing: st.account == null
                    ? FilledButton(onPressed: busy ? null : () => guard(() async { await persist(); await DriveBackup.signIn(); }), child: const Text('Sign in'))
                    : TextButton(onPressed: busy ? null : () => guard(() async { await DriveBackup.signOut(); st.enabled = false; await persist(); }), child: const Text('Sign out')),
              ),
              SwitchListTile(
                title: const Text('Encrypt backups with a passphrase'),
                subtitle: const Text('Recommended — your locked books are in every backup.'),
                value: encrypted,
                onChanged: busy ? null : (v) => guard(() => _toggleEncryption(v)),
              ),
              SwitchListTile(
                title: const Text('Automatic backup'),
                value: st.enabled,
                onChanged: st.account == null ? null : (v) => guard(() async {
                  if (v) await Notifier.requestPermission(); // so a failing backup can tell you (Android 13+ asks once)
                  st.enabled = v;
                  await persist();
                }),
              ),
              ListTile(
                title: const Text('Frequency'),
                trailing: DropdownButton<String>(
                  value: st.frequency,
                  items: const [DropdownMenuItem(value: 'daily', child: Text('Daily')), DropdownMenuItem(value: 'weekly', child: Text('Weekly'))],
                  onChanged: (v) => guard(() async { st.frequency = v!; await persist(); }),
                ),
              ),
              SwitchListTile(
                title: const Text('Wi-Fi only'),
                value: st.wifiOnly,
                onChanged: (v) => guard(() async { st.wifiOnly = v; await persist(); }),
              ),
              const Divider(),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Backups not running on schedule?', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    const Text('Some phones (Xiaomi, Huawei, Samsung, OnePlus and others) stop background apps to save battery. '
                        'Allow Pagemark to run in the background and set its battery use to "Unrestricted" so the daily or weekly backup can happen.'),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      OutlinedButton(onPressed: openAppSettings, child: const Text('App settings')),
                      OutlinedButton(onPressed: openBatterySettings, child: const Text('Battery optimisation')),
                    ]),
                  ]),
                ),
              ),
              ListTile(title: const Text('Last successful backup'), subtitle: Text(fmt(st.lastOk))),
              if (st.lastError != null) ListTile(title: const Text('Last error'), subtitle: Text(st.lastError!), textColor: Theme.of(context).colorScheme.error),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Back up now'),
                onPressed: busy || st.account == null ? null : () => guard(() async {
                  await persist();
                  final r = await DriveBackup.run(db, interactive: true, force: true);
                  if (context.mounted) snack(context, r.uploaded ? 'Backup uploaded and verified (${humanBytes(r.bytes)})' : 'Nothing changed since the last backup');
                }),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: const Text('Restore from Drive…'),
                onPressed: busy || st.account == null ? null : () => guard(() async {
                  final files = await DriveBackup.list();
                  if (!context.mounted) return;
                  if (files.isEmpty) { snack(context, 'No backups found'); return; }
                  final pick = await showDialog<drive.File>(
                    context: context,
                    builder: (c) => SimpleDialog(title: const Text('Choose a backup'), children: [
                      for (final f in files)
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(c, f),
                          child: Text('${f.name}\n${f.createdTime == null ? '' : DateFormat.yMMMd().add_jm().format(f.createdTime!.toLocal())} · '
                              '${((int.tryParse(f.size ?? '0') ?? 0) / 1024).toStringAsFixed(0)} KB'),
                        ),
                    ]),
                  );
                  if (pick == null || !context.mounted) return;
                  final tmp = File('${(await getTemporaryDirectory()).path}/pagemark-restore.download');
                  await DriveBackup.download(pick, tmp);
                  if (!context.mounted) return;
                  await restoreFlow(context, tmp);
                }),
              ),
            ]),
    );
  }
}
