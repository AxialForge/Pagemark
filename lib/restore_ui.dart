import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
    final pass = await ask(context, 'Backup password', '', false, true);
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

/// Lists the restore points Pagemark kept before a restore or an import, and lets the user go back to one.
class RestorePointsPage extends StatefulWidget {
  const RestorePointsPage({super.key});
  @override
  State<RestorePointsPage> createState() => _RestorePointsPageState();
}

class _RestorePointsPageState extends State<RestorePointsPage> {
  List<File>? files;

  @override
  void initState() {
    super.initState();
    Exporter.restorePoints().then((v) {
      if (mounted) setState(() => files = v);
    });
  }

  String _label(File f) {
    final n = f.uri.pathSegments.last;
    final kind = n.startsWith('pre-import-') ? 'Before an import' : 'Before a restore';
    final m = RegExp(r'(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})?').firstMatch(n);
    if (m == null) return kind;
    final t = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!), int.parse(m[4]!), int.parse(m[5]!));
    return '$kind - ${DateFormat.yMMMd().add_jm().format(t)}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Restore points')),
        body: files == null
            ? const Center(child: CircularProgressIndicator())
            : files!.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No restore points yet. Pagemark saves one before every restore and import (newest 3 of each kind).', textAlign: TextAlign.center)))
                : ListView(children: [
                    for (final f in files!)
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(_label(f)),
                        subtitle: Text('${(f.lengthSync() / 1024).round()} KB'),
                        onTap: () => restoreFlow(context, f),
                      ),
                  ]),
      );
}
