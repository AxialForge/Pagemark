part of '../ui.dart';

// ───────────────────────── Settings ─────────────────────────
/// Settings: a short home list in plain words. Each row opens one small page, so nothing is buried in one long scroll.
class SettingsPage extends StatelessWidget {
  final VoidCallback onLockNow;
  const SettingsPage({super.key, required this.onLockNow});

  Widget _row(BuildContext context, IconData icon, String title, String subtitle, Widget Function() page) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page())),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(children: [
          const AppHeader(),
          const UpdateTile(),
          const Divider(),
          _row(context, Icons.menu_book_outlined, 'How to use Pagemark', 'Short, simple steps for everything the app does', () => const GuidePage()),
          _row(context, Icons.verified_user_outlined, 'Our promise to you', 'No tracking, no ads, no AI. Your books stay yours.', () => const PromisePage()),
          const Divider(),
          _row(context, Icons.palette_outlined, SettingsTitles.appearance, 'Choose your colours', () => const _AppearancePage()),
          _row(context, Icons.notifications_active_outlined, SettingsTitles.notifications, 'Reading and backup reminders', () => const _NotificationsPage()),
          _row(context, Icons.widgets_outlined, SettingsTitles.widget, 'Home-screen widget and icon shortcuts', () => const _WidgetPage()),
          _row(context, Icons.lock_outline, SettingsTitles.privacy, 'PIN, fingerprint and your private library', () => _PrivacyPage(onLockNow: onLockNow)),
          _row(context, Icons.cloud_upload_outlined, SettingsTitles.backup, 'Keep your library safe, or bring it back', () => const BackupSettingsPage()),
          _row(context, Icons.swap_horiz, SettingsTitles.importExport, 'Bring books in from another app, or take your list out', () => const _ImportExportPage()),
          _row(context, Icons.collections_bookmark_outlined, SettingsTitles.library, 'Deleted books, cover pictures and extra notes', () => const _LibraryExtrasPage()),
          _row(context, Icons.help_outline, SettingsTitles.help, 'What is new, and fixing problems', () => const _HelpPage()),
          const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 24), child: Text('Everything stays on this phone unless you back it up or share it.')),
        ]),
      );
}

/// One settings page: a title and a list of rows.
class _SettingsSub extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSub(this.title, this.children);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: NarrowColumn(child: ListView(children: children)));
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 12), child: Text(text, style: Theme.of(context).textTheme.bodySmall));
}

class _AppearancePage extends StatelessWidget {
  const _AppearancePage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.appearance, [
        const _Hint('Pick the colours you like. You can change this any time.'),
        ValueListenableBuilder<String>(
          valueListenable: themeId,
          builder: (_, id, _) => Column(children: [
            for (final t in themes)
              ListTile(
                leading: CircleAvatar(backgroundColor: t.seed, radius: 14),
                title: Text(t.name),
                subtitle: Text(t.mode),
                trailing: id == t.id ? const Icon(Icons.check) : null,
                onTap: () => themeId.value = t.id,
              ),
          ]),
        ),
      ]);
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();
  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> with WidgetsBindingObserver {
  bool? allowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(); // back from the phone's settings
  }

  Future<void> _check() async {
    final v = await Notifier.areEnabled();
    if (mounted) setState(() => allowed = v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _SettingsSub(SettingsTitles.notifications, [
      if (allowed == false)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Card(
            color: cs.errorContainer,
            child: ListTile(
              leading: Icon(Icons.notifications_off_outlined, color: cs.onErrorContainer),
              title: Text('Notifications are off for Pagemark', style: TextStyle(color: cs.onErrorContainer, fontWeight: FontWeight.w600)),
              subtitle: Text('Your reminders below cannot appear until you allow them.', style: TextStyle(color: cs.onErrorContainer)),
              // iOS has no page to open from here; asking shows its own question the first time.
              // iOS refuses to schedule while notifications are off, so rebuild the schedules once allowed.
              trailing: TextButton(
                onPressed: defaultTargetPlatform == TargetPlatform.iOS
                    ? () async {
                        if (await Notifier.requestPermission()) await Future.wait([Reminders.apply(), BackupReminder.apply()]);
                        await _check();
                      }
                    : openNotificationSettings,
                child: const Text('Turn on'),
              ),
            ),
          ),
        )
      else if (allowed == true)
        const _Hint('Notifications are on. Pagemark only sends the reminders you choose below, never anything about your books.'),
      const ListTile(title: Text('Reading', style: TextStyle(fontWeight: FontWeight.bold)), dense: true),
      const _ReminderTiles(),
      const Divider(),
      const ListTile(title: Text('Backup', style: TextStyle(fontWeight: FontWeight.bold)), dense: true),
      const _BackupReminderTiles(),
    ]);
  }
}

/// The "Remind me to back up" switch and how often, shared by the Notifications page and the Backup page.
class _BackupReminderTiles extends StatefulWidget {
  const _BackupReminderTiles();
  @override
  State<_BackupReminderTiles> createState() => _BackupReminderTilesState();
}

class _BackupReminderTilesState extends State<_BackupReminderTiles> {
  @override
  Widget build(BuildContext context) => Column(children: [
        SwitchListTile(
          secondary: const Icon(Icons.save_outlined),
          title: const Text('Remind me to back up'),
          subtitle: const Text('A notification now and then. It restarts each time you save a copy.'),
          value: BackupReminder.enabled,
          onChanged: (v) async {
            final ok = await BackupReminder.setEnabled(v);
            if (!ok && context.mounted) snack(context, 'Allow notifications for Pagemark in your phone settings to get reminders.');
            if (mounted) setState(() {});
          },
        ),
        if (BackupReminder.enabled)
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('How often'),
            trailing: DropdownButton<int>(
              value: BackupReminder.everyDays,
              items: [for (final e in BackupReminder.everyChoices.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) async {
                if (v != null) await BackupReminder.setEvery(v);
                if (mounted) setState(() {});
              },
            ),
          ),
      ]);
}

class _WidgetPage extends StatelessWidget {
  const _WidgetPage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.widget, [
        ValueListenableBuilder<bool>(
          valueListenable: WidgetSync.showTitles,
          builder: (_, on, _) => SwitchListTile(
            secondary: const Icon(Icons.widgets_outlined),
            title: const Text('Show book titles on the widget'),
            subtitle: const Text('Off shows only how many books you are reading.'),
            value: on,
            onChanged: (v) => WidgetSync.showTitles.value = v,
          ),
        ),
        const _Hint('To add the widget: press and hold an empty spot on your home screen, tap Widgets, then find Pagemark. '
            'It shows what you are reading and your yearly goal, and never shows your locked books. If you ask for your PIN every time Pagemark opens, the widget shows only numbers.'),
        const Divider(),
        const ListTile(leading: Icon(Icons.touch_app_outlined), title: Text('Shortcuts'), subtitle: Text('Press and hold the Pagemark icon on your home screen for two shortcuts: Add book, and Reading now (only the books you are reading).')),
      ]);
}

class _PrivacyPage extends StatelessWidget {
  final VoidCallback onLockNow;
  const _PrivacyPage({required this.onLockNow});
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.privacy, [
        const _Hint('Books you move to the Locked tab are hidden behind a PIN or your fingerprint.'),
        ListTile(leading: const Icon(Icons.lock_clock), title: const Text('Lock now'), subtitle: const Text('Close your private library right away'), onTap: () { onLockNow(); Navigator.pop(context); }),
        ValueListenableBuilder<int>(
          valueListenable: lockDelay,
          builder: (context, secs, _) => ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Lock when I leave Pagemark'),
            subtitle: const Text('How long before it asks for your PIN again'),
            trailing: DropdownButton<int>(
              value: lockDelayChoices.containsKey(secs) ? secs : 0,
              items: [for (final e in lockDelayChoices.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => lockDelay.value = v ?? 0,
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: appLockEnabled,
          builder: (context, on, _) => SwitchListTile(
            secondary: const Icon(Icons.phonelink_lock_outlined),
            title: const Text('Ask for my PIN to open Pagemark'),
            subtitle: const Text('Protects the whole app, not just the Locked tab. Uses the same PIN.'),
            value: on,
            onChanged: (v) async {
              if (v && !await enableAppLock(context)) return;
              appLockEnabled.value = v;
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: hideLockedTab,
          builder: (context, hidden, _) => SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text('Hide the Locked tab'),
            subtitle: const Text('Nothing shows that you have a private library. To open it, press and hold the word "Library" at the top of the Library screen.'),
            value: hidden,
            onChanged: (v) {
              hideLockedTab.value = v;
              if (v) snack(context, 'Locked tab hidden. Press and hold "Library" at the top to open it.');
            },
          ),
        ),
        const _UnlockMethodTile(),
        ListTile(leading: const Icon(Icons.pin_outlined), title: const Text('Change my PIN'), onTap: () async {
          if (!await confirmCurrent(context) || !context.mounted) return;
          if (await setupPin(context) && context.mounted) snack(context, 'PIN updated');
        }),
        ListTile(
          leading: const Icon(Icons.no_encryption_outlined), title: const Text('Turn off the lock'),
          subtitle: const Text('Your private books stay where they are, but anyone holding your phone could then set a new PIN.'),
          onTap: () async {
            if (!await confirmCurrent(context) || !context.mounted) return;
            await LockService.clear();
            appLockEnabled.value = false; // the whole-app lock needs a PIN; without one it would leave the app open to anyone
            if (context.mounted) snack(context, 'Lock turned off');
          },
        ),
      ]);
}

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});
  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  @override
  void initState() {
    super.initState();
    BackupReminder.changes.addListener(_refresh);
  }

  @override
  void dispose() {
    BackupReminder.changes.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _saveCopy() async {
    final pass = await ask(context, 'Password to protect the file (leave empty for none)', '', false, true);
    if (pass == null || !mounted) return;
    if (pass.isEmpty) {
      final go = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
        title: const Text('Save without a password?'), content: const Text('This file contains your locked books and private notes. Anyone who gets it can read them.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save anyway'))]));
      if (go != true) return;
    } else if (pass.length < 8) {
      if (mounted) snack(context, 'Use at least 8 characters');
      return;
    }
    await Exporter.shareDb(db, passphrase: pass);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final last = BackupReminder.lastBackup;
    final days = BackupReminder.daysSince(DateTime.now());
    final overdue = days == null || days > BackupReminder.everyDays;
    final cs = Theme.of(context).colorScheme;
    return _SettingsSub(SettingsTitles.backup, [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Card(
          color: overdue ? cs.errorContainer : cs.primaryContainer,
          child: ListTile(
            leading: Icon(overdue ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: overdue ? cs.onErrorContainer : cs.onPrimaryContainer),
            title: Text(last == null ? 'You have not saved a backup yet' : 'Last backup: ${_date.format(last)}', style: TextStyle(color: overdue ? cs.onErrorContainer : cs.onPrimaryContainer, fontWeight: FontWeight.w600)),
            subtitle: Text(
              last == null
                  ? 'Your books are only on this phone. Save a copy somewhere safe, like your email, Google Drive or a computer.'
                  : days == 0 ? 'Saved today.' : days == 1 ? 'Saved yesterday.' : 'Saved $days days ago.',
              style: TextStyle(color: overdue ? cs.onErrorContainer : cs.onPrimaryContainer),
            ),
          ),
        ),
      ),
      const _Hint('A backup is a safe copy of your whole library, including your locked books. If you lose or break your phone, it brings everything back.'),
      ListTile(leading: const Icon(Icons.save_alt), title: const Text('Save a copy as a file'), subtitle: const Text('The best backup. Choose where to keep it, and protect it with a password.'), onTap: _saveCopy),
      ListTile(leading: const Icon(Icons.table_chart_outlined), title: const Text('Save my list as a spreadsheet'), subtitle: const Text('Easy to read in Excel or Google Sheets. Your locked books are not included.'), onTap: () async {
        await Exporter.shareCsv(db, includePrivateFields: adultFieldsOn());
        if (mounted) setState(() {});
      }),
      const Divider(),
      const _FolderBackupTiles(),
      const Divider(),
      ListTile(leading: const Icon(Icons.restore), title: const Text('Restore from a file'), subtitle: const Text('Replace your library with a saved copy'), onTap: () async {
        final r = await FilePicker.pickFile();
        final path = r?.path;
        if (path == null || !context.mounted) return;
        await restoreFlow(context, File(path));
      }),
      ListTile(leading: const Icon(Icons.history), title: const Text('Go back to an earlier copy'), subtitle: const Text('Pagemark saves one before every restore and import'), trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestorePointsPage()))),
      const Divider(),
      const _BackupReminderTiles(),
    ]);
  }
}

/// Automatic backups into a folder you pick once (see folder_backup.dart).
class _FolderBackupTiles extends StatefulWidget {
  const _FolderBackupTiles();
  @override
  State<_FolderBackupTiles> createState() => _FolderBackupTilesState();
}

class _FolderBackupTilesState extends State<_FolderBackupTiles> {
  bool busy = false;

  Future<String?> _newPassword() async {
    final a = await ask(context, 'Choose a password for your backups', '', false, true);
    if (a == null || a.isEmpty || !mounted) return null;
    if (a.length < 8) {
      snack(context, 'Use at least 8 characters');
      return null;
    }
    final b = await ask(context, 'Type the password again', '', false, true);
    if (b == null || !mounted) return null;
    if (a != b) {
      snack(context, 'The passwords did not match');
      return null;
    }
    return a;
  }

  Future<void> _choose() async {
    final picked = await FolderBackup.choose();
    if (picked == null || !mounted) return;
    if (!FolderBackup.passwordWanted && mounted) {
      final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Protect your backups with a password?'),
          content: const Text('Your backups include your locked books. A password keeps them private if someone finds the file. Write it down: without it, nobody can open a backup, not even Pagemark.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No password')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Set a password')),
          ],
        ),
      );
      if (yes == true) {
        final p = await _newPassword();
        if (p != null) await FolderBackup.setPassword(p);
      }
    }
    await FolderBackup.commit(picked); // only now, so no backup can start before the password question is answered
    await _backupNow();
  }

  Future<void> _backupNow() async {
    setState(() => busy = true);
    final ok = await FolderBackup.runIfDue(force: true);
    if (!mounted) return;
    setState(() => busy = false);
    snack(context, ok ? 'Backup saved to ${FolderBackup.folderName}' : (FolderBackup.lastError ?? 'The backup did not work.'));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!FolderBackup.isSet) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          leading: const Icon(Icons.folder_special_outlined),
          title: const Text('Save backups to a folder automatically'),
          subtitle: const Text('Pick a folder once. Pagemark then saves a fresh backup there by itself. Tip: choose a folder in Google Drive, OneDrive or Dropbox and Android copies it to the cloud for you.'),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(72, 0, 16, 8), child: Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: _choose, icon: const Icon(Icons.create_new_folder_outlined), label: const Text('Choose a folder')))),
      ]);
    }
    final last = FolderBackup.lastOk;
    final err = FolderBackup.lastError;
    return Column(children: [
      ListTile(
        leading: Icon(err == null ? Icons.folder_special : Icons.error_outline, color: err == null ? null : cs.error),
        title: Text('Saving to: ${FolderBackup.folderName}'),
        subtitle: Text(err ?? (last == null ? 'No automatic backup yet.' : 'Last automatic backup: ${_date.format(last)}')),
        isThreeLine: err != null,
      ),
      if (busy) const LinearProgressIndicator(),
      Padding(
        padding: const EdgeInsets.fromLTRB(72, 0, 16, 4),
        child: Wrap(spacing: 8, children: [
          FilledButton.tonal(onPressed: busy ? null : _backupNow, child: const Text('Back up now')),
          OutlinedButton(onPressed: busy ? null : _choose, child: const Text('Change folder')),
          TextButton(onPressed: busy ? null : () async { await FolderBackup.turnOff(); if (mounted) setState(() {}); }, child: const Text('Turn off')),
        ]),
      ),
      ListTile(
        leading: const Icon(Icons.event_repeat),
        title: const Text('How often'),
        trailing: DropdownButton<int>(
          value: FolderBackup.everyDays,
          items: [for (final e in FolderBackup.everyChoices.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
          onChanged: (v) async {
            if (v != null) await prefs.setInt('fb_every', v);
            if (mounted) setState(() {});
          },
        ),
      ),
      SwitchListTile(
        secondary: const Icon(Icons.password),
        title: const Text('Protect backups with a password'),
        subtitle: const Text('Recommended: your locked books are in every backup.'),
        value: FolderBackup.passwordWanted,
        onChanged: (v) async {
          if (v) {
            final p = await _newPassword();
            if (p != null) await FolderBackup.setPassword(p);
          } else {
            await FolderBackup.setPassword(null);
          }
          if (mounted) setState(() {});
        },
      ),
      const _Hint('Pagemark keeps the newest 5 backups in that folder and checks when you open the app. The folder may need to be on Wi-Fi or a signed-in cloud app to upload.'),
    ]);
  }
}

class _ImportExportPage extends StatelessWidget {
  const _ImportExportPage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.importExport, [
        ListTile(leading: const Icon(Icons.upload_file), title: const Text('Bring in books from another app'), subtitle: const Text('Goodreads, StoryGraph, or a Pagemark file'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportPage()))),
        const Divider(),
        const _Hint('Your list of books, to keep or use elsewhere. Your locked books are not included.'),
        ListTile(leading: const Icon(Icons.table_chart_outlined), title: const Text('Save my list as a spreadsheet'), subtitle: const Text('Opens in Excel or Google Sheets, with your notes and thoughts'), onTap: () => Exporter.shareCsv(db, includePrivateFields: adultFieldsOn())),
        ListTile(leading: const Icon(Icons.data_object), title: const Text('Save my list for other apps'), subtitle: const Text('A JSON file, for apps and developers'), onTap: () => Exporter.shareJson(db, includePrivateFields: adultFieldsOn())),
      ]);
}

class _LibraryExtrasPage extends StatelessWidget {
  const _LibraryExtrasPage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.library, [
        ListTile(leading: const Icon(Icons.delete_sweep_outlined), title: const Text('Deleted books'), subtitle: const Text('Kept for 30 days, then removed for good'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrashPage()))),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Cover pictures'), subtitle: const Text('Keep covers on this phone so they work without internet and are included in backups'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoversPage()))),
        const _DefaultsTiles(),
        ListTile(
          leading: const Icon(Icons.auto_fix_high_outlined),
          title: const Text('Tidy genres'),
          subtitle: const Text('Remove repeats and catalogue labels from the genres of books you added earlier. You see the changes first.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => tidyGenresFlow(context),
        ),
        const Divider(),
        _GoogleSwitch(),
        ValueListenableBuilder<bool>(
          valueListenable: detailedRatings,
          builder: (context, on, _) => SwitchListTile(
            secondary: const Icon(Icons.star_half_rounded),
            title: const Text('Rate books in more detail'),
            subtitle: const Text('Adds optional stars for story, characters, writing, pace and how it made you feel (and the narrator for audiobooks) to each read, and a chart in Stats.'),
            value: on,
            onChanged: (v) => detailedRatings.value = v,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: adultFields,
          builder: (context, on, _) => SwitchListTile(
            secondary: const Icon(Icons.local_fire_department_outlined),
            title: const Text('Heat level and content notes'),
            subtitle: const Text('Adds private fields to each read (a heat level from 0 to 5, and content notes) and a chart in Stats. Left out of saved lists unless this is on.'),
            value: on,
            onChanged: (v) => adultFields.value = v,
          ),
        ),
      ]);
}

/// Settings > Privacy and lock: how the locked library opens (a PIN, or the fingerprint / device lock only) and a way to switch.
class _UnlockMethodTile extends StatefulWidget {
  const _UnlockMethodTile();
  @override
  State<_UnlockMethodTile> createState() => _UnlockMethodTileState();
}

class _UnlockMethodTileState extends State<_UnlockMethodTile> {
  String? mode;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await LockService.mode();
    if (mounted) setState(() { mode = m; loaded = true; });
  }

  static String label(String? m) => switch (m) {
        'pin' => 'A PIN (the fingerprint button works as a shortcut)',
        'device' => 'Fingerprint or device lock only',
        'lost' || 'unavailable' => 'Needs confirming (open the Locked tab)',
        _ => 'Not set up yet (open the Locked tab)',
      };

  Future<void> _choose() async {
    final pick = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(title: Text('How do you want to unlock?', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: const Text('A PIN'),
            subtitle: const Text('You can still use your fingerprint as a shortcut. You get a recovery code.'),
            trailing: mode == 'pin' ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(c, 'pin'),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Fingerprint or device lock only'),
            subtitle: const Text('Uses the screen lock of your phone. No PIN to remember.'),
            trailing: mode == 'device' ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(c, 'device'),
          ),
        ]),
      ),
    );
    if (pick == null || pick == mode || !mounted) return;
    if (mode != 'pin' && mode != 'device') {
      snack(context, 'Open the Locked tab once to set up the lock first.');
      return;
    }
    if (!await confirmCurrent(context) || !mounted) return;
    if (pick == 'pin') {
      if (await setupPin(context) && mounted) snack(context, 'Now unlocking with a PIN');
    } else {
      if (appLockEnabled.value) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Switch to the device lock?'),
            content: const Text('Asking for a PIN to open the whole app needs a PIN, so that setting will be switched off.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Switch')),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
      if (await chooseDeviceLock(context)) {
        appLockEnabled.value = false;
        if (mounted) snack(context, 'Now unlocking with your fingerprint or device lock');
      }
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.fingerprint),
        title: const Text('How you unlock'),
        subtitle: Text(loaded ? label(mode) : ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: loaded ? _choose : null,
      );
}

/// Settings > Your library: whether book searches also ask Google Books.
class _GoogleSwitch extends StatefulWidget {
  @override
  State<_GoogleSwitch> createState() => _GoogleSwitchState();
}

class _GoogleSwitchState extends State<_GoogleSwitch> {
  @override
  Widget build(BuildContext context) => SwitchListTile(
        secondary: const Icon(Icons.travel_explore),
        title: const Text('Also search Google Books'),
        subtitle: const Text('Finds more books and fills in missing details. What you type is sent to Google Books as well as Open Library. Turn off to use Open Library only.'),
        value: googleOn(),
        onChanged: (v) async {
          await prefs.setBool('src_google', v);
          if (mounted) setState(() {});
        },
      );
}

/// Date style, the format a new read starts with, and removing the sample books.
class _DefaultsTiles extends StatefulWidget {
  const _DefaultsTiles();
  @override
  State<_DefaultsTiles> createState() => _DefaultsTilesState();
}

class _DefaultsTilesState extends State<_DefaultsTiles> {
  bool samples = false;

  @override
  void initState() {
    super.initState();
    Samples.present(db).then((v) { if (mounted) setState(() => samples = v); });
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
          leading: const Icon(Icons.event_outlined),
          title: const Text('How dates look'),
          trailing: DropdownButton<String>(
            value: dateStyles.containsKey(prefs.getString('date_style')) ? prefs.getString('date_style') : 'mdy',
            items: [for (final e in dateStyles.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) async {
              if (v != null) await prefs.setString('date_style', v);
              if (mounted) setState(() {});
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('New reads start as'),
          subtitle: const Text('Print, e-book or audiobook: the one you use most.'),
          trailing: DropdownButton<String>(
            value: defaultFormat(),
            items: [for (final e in formats.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) async {
              if (v != null) await prefs.setString('default_format', v);
              if (mounted) setState(() {});
            },
          ),
        ),
        if (samples)
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined),
            title: const Text('Remove the sample books'),
            subtitle: const Text('The 5 example books from the welcome screen.'),
            onTap: () async {
              final n = await Samples.remove(db);
              if (!context.mounted) return;
              setState(() => samples = false);
              snack(context, n == 0 ? 'The sample books were already gone' : 'Removed $n sample books');
            },
          ),
      ]);
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.help, [
        ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Our promise to you'), subtitle: const Text('No tracking, no ads, no AI. Your books stay yours.'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromisePage()))),
        ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('How to use Pagemark'), subtitle: const Text('Short, simple steps for everything the app does'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage()))),
        ListTile(leading: const Icon(Icons.new_releases_outlined), title: const Text("What's new"), subtitle: const Text('Every change in every version'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogPage()))),
        ListTile(leading: const Icon(Icons.bug_report_outlined), title: const Text('Problem report'), subtitle: const Text('Only needed if someone is helping you fix a problem. It contains no book titles.'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsPage()))),
      ]);
}
