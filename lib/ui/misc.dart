part of '../ui.dart';

// ───────────────────────── Trash ─────────────────────────
class TrashPage extends StatelessWidget {
  final bool locked; // true = the locked library's Trash (reachable only from the unlocked vault)
  const TrashPage({super.key, this.locked = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(locked ? 'Locked deleted books' : 'Deleted books')),
        body: StreamBuilder<List<Book>>(
          stream: db.watchTrash(locked: locked),
          builder: (_, snap) {
            final list = snap.data ?? [];
            if (list.isEmpty) return const Center(child: Text('No deleted books.'));
            return ListView(children: [
              for (final b in list)
                ListTile(
                  title: Text(b.title),
                  subtitle: Text('${b.author}\nDeleted ${_date.format(b.deletedAt!)} - removed for good after ${AppDb.trashDays} days'),
                  isThreeLine: true,
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.restore_from_trash), tooltip: 'Restore', onPressed: () => db.restoreBook(b.id)),
                    IconButton(icon: const Icon(Icons.delete_forever), tooltip: 'Delete forever', onPressed: () => db.purgeBook(b.id)),
                  ]),
                ),
            ]);
          },
        ),
      );
}


// ───────────────────────── Diagnostics ─────────────────────────
class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Problem report')),
        body: FutureBuilder<String>(
          future: Log.read(),
          builder: (_, snap) {
            final text = snap.data ?? '';
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  OutlinedButton.icon(icon: const Icon(Icons.copy), label: const Text('Copy'), onPressed: text.isEmpty ? null : () { Clipboard.setData(ClipboardData(text: text)); snack(context, 'Log copied'); }),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(icon: const Icon(Icons.delete_outline), label: const Text('Clear'), onPressed: () async { await Log.clear(); if (context.mounted) Navigator.pop(context); }),
                ]),
              ),
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: SelectableText(text.isEmpty ? 'Nothing has gone wrong.' : text, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)))),
            ]);
          },
        ),
      );
}

/// Settings rows for the daily reading reminder: a switch and a time.
class _ReminderTiles extends StatefulWidget {
  const _ReminderTiles();
  @override
  State<_ReminderTiles> createState() => _ReminderTilesState();
}

class _ReminderTilesState extends State<_ReminderTiles> {
  @override
  Widget build(BuildContext context) {
    final on = Reminders.enabled;
    final (h, m) = Reminders.parseTime(Reminders.timeText);
    return Column(children: [
      SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: const Text('Daily reading reminder'),
        subtitle: const Text('A notification at the time you choose. It never names a book. It may arrive a few minutes late.'),
        value: on,
        onChanged: (v) async {
          final ok = await Reminders.setEnabled(v);
          if (!ok && context.mounted) snack(context, 'Allow notifications for Pagemark in your phone settings to use reminders.');
          if (mounted) setState(() {});
        },
      ),
      if (on)
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Reminder time'),
          subtitle: Text(TimeOfDay(hour: h, minute: m).format(context)),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: h, minute: m));
            if (t == null) return;
            await Reminders.setTime(t.hour, t.minute);
            if (mounted) setState(() {});
          },
        ),
    ]);
  }
}
