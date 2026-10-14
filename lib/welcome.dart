import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'backup_reminder.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'firstrun.dart';
import 'folder_backup.dart';
import 'main.dart';
import 'restore_ui.dart';
import 'ui.dart';

/// Shown once, on the very first start with an empty library: three short screens, then a choice of how to begin.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _ctl = PageController();
  int _page = 0;

  static const _pages = [
    (Icons.menu_book_rounded, 'Your private reading log', 'Keep track of every book you read or listen to: what you thought, how far you are, and what you want to read next. Everything stays on this phone.'),
    (Icons.qr_code_scanner, 'Adding a book is easy', 'Scan the barcode on the back of a book, or type its title. Pagemark finds the cover and the details for you.'),
    (Icons.lock_outline, 'Private and safe', 'Keep some books behind a PIN in the Locked tab. Save a backup copy now and then, so you never lose your library. Pagemark will remind you.'),
  ];

  Future<void> _finish(Widget? then) async {
    await prefs.setBool('welcome_seen', true);
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pop();
    if (then != null) nav.push(MaterialPageRoute(builder: (_) => then));
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => _finish(null), child: const Text('Skip')),
          ),
          Expanded(
            child: PageView(
              controller: _ctl,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                for (final p in _pages)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                        child: Icon(p.$1, size: 60, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(height: 32),
                      Text(p.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      Text(p.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                    ]),
                  ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages.length; i++)
              Container(margin: const EdgeInsets.all(4), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: i == _page ? cs.primary : cs.outlineVariant)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: last
                ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    FilledButton.icon(onPressed: () => _finish(const AddBook(locked: false)), icon: const Icon(Icons.add), label: const Text('Add my first book')),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Samples.add(db);
                        await _finish(null);
                      },
                      icon: const Icon(Icons.auto_stories_outlined),
                      label: const Text('Try it with 5 sample books'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final r = await FilePicker.pickFile();
                        final path = r?.path;
                        if (path == null || !context.mounted) return;
                        await restoreFlow(context, File(path));
                      },
                      child: const Text('I already use Pagemark: restore my library'),
                    ),
                    TextButton(onPressed: () => _finish(null), child: const Text('Just look around')),
                  ])
                : Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(onPressed: () => _ctl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut), child: const Text('Next')),
                  ),
          ),
        ]),
      ),
    );
  }
}

/// Cards at the top of the main Library: "you are looking at sample books" and "set up a backup".
class LibraryBanners extends StatefulWidget {
  const LibraryBanners({super.key});
  @override
  State<LibraryBanners> createState() => _LibraryBannersState();
}

class _LibraryBannersState extends State<LibraryBanners> {
  bool samples = false, nudge = false;
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _check();
    BackupReminder.changes.addListener(_check);
    Samples.changed.addListener(_check);
    _sub = db.watchLibrary(locked: false).listen((_) => _check()); // books added or removed: look again
  }

  @override
  void dispose() {
    _sub?.cancel();
    BackupReminder.changes.removeListener(_check);
    Samples.changed.removeListener(_check);
    super.dispose();
  }

  Future<void> _check() async {
    final s = await Samples.present(db);
    final all = await (db.select(db.books)..where((b) => b.deletedAt.isNull() & b.locked.equals(false))).get();
    final real = all.length - (s ? Samples.ids().length : 0);
    final n = BackupNudge.shouldShow(DateTime.now(),
        realBooks: real, folderSet: FolderBackup.isSet, lastBackup: BackupReminder.lastBackup, snoozedUntil: BackupNudge.snoozedUntil);
    if (mounted && (s != samples || n != nudge)) setState(() { samples = s; nudge = n; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      if (samples)
        Card(
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          color: cs.secondaryContainer,
          child: ListTile(
            leading: Icon(Icons.auto_stories_outlined, color: cs.onSecondaryContainer),
            title: Text('You are looking at 5 sample books', style: TextStyle(color: cs.onSecondaryContainer, fontWeight: FontWeight.w600)),
            subtitle: Text('Have a look around, then remove them when you are ready to add your own.', style: TextStyle(color: cs.onSecondaryContainer)),
            trailing: TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Remove the sample books?'),
                    content: const Text('This removes the 5 sample books for good. Books you added yourself are not touched.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove them'))],
                  ),
                );
                if (ok != true) return;
                await Samples.remove(db);
                _check();
              },
              child: const Text('Remove'),
            ),
          ),
        ),
      if (nudge)
        Card(
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          color: cs.tertiaryContainer,
          child: ListTile(
            leading: Icon(Icons.shield_outlined, color: cs.onTertiaryContainer),
            title: Text('Protect your books', style: TextStyle(color: cs.onTertiaryContainer, fontWeight: FontWeight.w600)),
            subtitle: Text('Your library is only on this phone. Set up a backup in one minute.', style: TextStyle(color: cs.onTertiaryContainer)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(onPressed: () async { await BackupNudge.snooze(); _check(); }, child: const Text('Not now')),
              FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsPage())), child: const Text('Set up')),
            ]),
          ),
        ),
    ]);
  }
}
