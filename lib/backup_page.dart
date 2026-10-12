import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'backup.dart';
import 'export.dart';
import 'main.dart';
import 'ui.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  BackupSettings? s;
  final cid = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    BackupSettings.load().then((v) => setState(() { s = v; cid.text = v.serverClientId; }));
  }

  Future<void> guard(Future<void> Function() f) async {
    setState(() => busy = true);
    try {
      await f();
    } catch (e) {
      if (mounted) snack(context, '$e');
    }
    s = await BackupSettings.load();
    if (mounted) setState(() => busy = false);
  }

  Future<void> persist() async {
    s!.serverClientId = cid.text;
    await s!.save();
    await DriveBackup.applySchedule(s!);
  }

  String fmt(String? iso) => iso == null ? 'never' : DateFormat.yMMMd().add_jm().format(DateTime.parse(iso));

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
                  'app-data folder on your Drive — they don\'t show in your normal Drive files. The newest 5 are kept.'),
              const SizedBox(height: 16),
              TextField(
                controller: cid,
                decoration: const InputDecoration(labelText: 'Google Web client ID', helperText: 'From your Google Cloud project (see setup guide)', border: OutlineInputBorder()),
                onChanged: (_) => st.serverClientId = cid.text,
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
                title: const Text('Automatic backup'),
                value: st.enabled,
                onChanged: st.account == null ? null : (v) => guard(() async { st.enabled = v; await persist(); }),
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
              ListTile(title: const Text('Last successful backup'), subtitle: Text(fmt(st.lastOk))),
              if (st.lastError != null) ListTile(title: const Text('Last error'), subtitle: Text(st.lastError!), textColor: Theme.of(context).colorScheme.error),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Back up now'),
                onPressed: busy || st.account == null ? null : () => guard(() async {
                  await persist();
                  await DriveBackup.run(db, interactive: true);
                  if (mounted) snack(context, 'Backup uploaded');
                }),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.cloud_download),
                label: const Text('Restore from Drive…'),
                onPressed: busy || st.account == null ? null : () => guard(() async {
                  final files = await DriveBackup.list();
                  if (!mounted) return;
                  if (files.isEmpty) { snack(context, 'No backups found'); return; }
                  final pick = await showDialog(
                    context: context,
                    builder: (c) => SimpleDialog(title: const Text('Choose a backup'), children: [
                      for (final f in files)
                        SimpleDialogOption(
                          onPressed: () => Navigator.pop(c, f),
                          child: Text('${f.name}\n${((int.tryParse(f.size ?? '0') ?? 0) / 1024).toStringAsFixed(0)} KB'),
                        ),
                    ]),
                  );
                  if (pick == null || !mounted) return;
                  final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                    title: const Text('Replace everything?'),
                    content: const Text('Your current library is replaced by this backup, then the app closes.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore'))],
                  ));
                  if (ok != true) return;
                  final tmp = File('${(await getTemporaryDirectory()).path}/restore.sqlite');
                  await DriveBackup.download(pick, tmp);
                  await Exporter.restoreDb(db, tmp);
                  exit(0);
                }),
              ),
            ]),
    );
  }
}
