part of '../ui.dart';

// ───────────────────────── Home ─────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

enum _Tab { library, manga, locked, stats, settings }

class _HomeState extends State<Home> with WidgetsBindingObserver {
  _Tab cur = _Tab.library;
  final _navKey = GlobalKey<ScaffoldState>();
  /// The pages' own message area: message bars then sit above each page's Add book button instead of on the outer
  /// (menu) Scaffold, which knows nothing about it.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  bool unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cleanTempExports();
    db.purgeExpiredTrash().then((_) async {
      // covers of books deleted for good are no longer needed
      if (CoverStore.ready) await CoverStore.removeUnused({for (final b in await db.select(db.books).get()) b.coverUrl});
    });
    autoCheckUpdates();
    Reminders.apply(); // tops up the next 3 weeks of reminders (no-op when they are off)
    BackupReminder.apply(); // tops up the next backup reminders
    FolderBackup.runIfDue(); // the automatic folder backup, if one is due
    _askNotificationsOnce();
    WidgetSync.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Incoming.start(); // a Share or shortcut that started the app
      _maybeWelcome();
      if (mounted) announceNewVersion(context, messenger: _messengerKey.currentState);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _unlock() {
    Secure.set(true); // block screenshots / blank the recents thumbnail while locked content is visible
    setState(() => unlocked = true);
  }

  /// Close the locked library: pop its screens, wipe its cached covers and temp exports.
  void _lock() {
    if (unlocked) {
      setState(() => unlocked = false);
      wipeLockedTraces();
    }
  }

  DateTime? _leftAt;

  /// First start with an empty library: the welcome screens, once. Anyone who already has books never sees them.
  Future<void> _maybeWelcome() async {
    if (prefs.getBool('welcome_seen') ?? false) return;
    final n = (await db.select(db.books).get()).length;
    if (n > 0) {
      await prefs.setBool('welcome_seen', true);
      return;
    }
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => const WelcomePage()));
    await prefs.setBool('welcome_seen', true);
  }

  /// After a few books are in, ask once for permission to send reminders (Android 13+ shows its own question).
  Future<void> _askNotificationsOnce() async {
    if (prefs.getBool('notif_asked') ?? false) return;
    final n = (await db.select(db.books).get()).where((b) => !Samples.ids().contains(b.id)).length; // sample books do not count
    if (n < 3 || !mounted) return;
    await prefs.setBool('notif_asked', true);
    await Notifier.requestPermission();
    await BackupReminder.apply();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leftAt ??= DateTime.now();
      if (lockDelay.value == 0) _lock(); // leave FLAG_SECURE on so the recents card stays blank
    } else if (state == AppLifecycleState.resumed) {
      final away = _leftAt == null ? Duration.zero : DateTime.now().difference(_leftAt!);
      _leftAt = null;
      if (unlocked && shouldRelock(away, lockDelay.value)) _lock(); // the delay has run out while you were away
      if (!unlocked && !appLocked.value) Secure.set(false);
      FolderBackup.runIfDue(); // back after a while: the automatic folder backup may be due
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: hideLockedTab,
        builder: (context, hidden, _) {
          final visible = [_Tab.library, _Tab.manga, if (!hidden) _Tab.locked, _Tab.stats, _Tab.settings];
          final shown = visible.contains(cur) ? cur : _Tab.library; // the Locked tab may have just been hidden
          if (shown != cur) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) { _lock(); setState(() => cur = _Tab.library); } });
          final page = switch (shown) {
            _Tab.library => const Library(locked: false, volumes: false),
            _Tab.manga => const Library(locked: false, volumes: true),
            _Tab.locked => unlocked ? const Library(locked: true) : LockGate(onUnlock: _unlock),
            _Tab.stats => const Stats(),
            _Tab.settings => SettingsPage(onLockNow: () => setState(() { _lock(); cur = _Tab.library; })),
          };
          final wide = useRail(context);
          final twoPane = useTwoPane(context);
          void select(int i) => setState(() {
                final next = visible[i];
                if (shown == _Tab.locked && next != _Tab.locked) _lock(); // re-lock when leaving the locked tab
                cur = next;
              });
          final content = ScaffoldMessenger(key: _messengerKey, child: PopScope(
            canPop: shown == _Tab.library, // Back on Stats, Locked or Settings goes to Library first; Back on Library leaves the app
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) select(visible.indexOf(_Tab.library));
            },
            child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
            ),
            child: KeyedSubtree(
              key: ValueKey(shown),
              // wide screens: the main Library sits beside the open book (the locked library never uses the pane, so nothing private lingers on screen)
              child: twoPane && (shown == _Tab.library || shown == _Tab.manga)
                  ? Row(children: [
                      Expanded(flex: 5, child: DetailPane(child: page)),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 6,
                        child: ValueListenableBuilder<int?>(
                          valueListenable: selectedBook,
                          builder: (_, id, _) => id == null
                              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Choose a book to see it here.', textAlign: TextAlign.center)))
                              : DetailPane(child: BookPage(key: ValueKey(id), bookId: id)),
                        ),
                      ),
                    ])
                  : page,
            ),
          )));
          final destinations = [
            for (final t in visible)
              switch (t) {
                _Tab.library => (const Icon(Icons.menu_book_outlined), 'Library'),
                _Tab.manga => (const Icon(Icons.auto_stories_outlined), 'Manga & comics'),
                _Tab.locked => (const Icon(Icons.lock_outline), 'Locked'),
                _Tab.stats => (const Icon(Icons.bar_chart), 'Stats'),
                _Tab.settings => (ValueListenableBuilder<UpdateInfo?>(valueListenable: updateAvailable, builder: (_, u, _) => Badge(isLabelVisible: u != null, child: const Icon(Icons.settings_outlined))), 'Settings'),
              },
          ];
          if (wide) {
            return Scaffold(
              body: SafeArea(
                child: Row(children: [
                  NavigationRail(
                    selectedIndex: visible.indexOf(shown),
                    onDestinationSelected: select,
                    labelType: NavigationRailLabelType.all,
                    destinations: [for (final d in destinations) NavigationRailDestination(icon: d.$1, label: Text(d.$2))],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ]),
              ),
            );
          }
          return Scaffold(
            key: _navKey,
            drawer: _NavDrawer(
              items: [for (final (i, t) in visible.indexed) (destinations[i].$1, destinations[i].$2, t == shown)],
              onSelect: (i) {
                Navigator.pop(context);
                select(i);
              },
            ),
            body: HomeNav(open: () => _navKey.currentState?.openDrawer(), child: content),
          );
        },
      );
}

/// The locked library as its own screen: used when the Locked tab is hidden (long-press the Library title).
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> with WidgetsBindingObserver {
  bool unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (unlocked) {
      lockedCache.emptyCache(); // leaving the vault: its covers and temp exports go with it
      cleanTempExports();
      Secure.hold = false;
      // when leaving because the app went to the background, keep the screen protected until it is back in front
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) Secure.set(false);
    }
    super.dispose();
  }

  DateTime? _leftAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!unlocked) return;
    if (state == AppLifecycleState.paused) {
      _leftAt ??= DateTime.now();
      if (lockDelay.value == 0) wipeLockedTraces(); // pops back to the main library
    } else if (state == AppLifecycleState.resumed) {
      final away = _leftAt == null ? Duration.zero : DateTime.now().difference(_leftAt!);
      _leftAt = null;
      if (shouldRelock(away, lockDelay.value)) wipeLockedTraces();
    }
  }

  @override
  Widget build(BuildContext context) => unlocked
      ? const Library(locked: true)
      : LockGate(onUnlock: () {
          Secure.hold = true;
          Secure.set(true);
          setState(() => unlocked = true);
        });
}

void openVault(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultPage()));

/// The side menu: a coloured header with the logo, then one row per section.
class _NavDrawer extends StatelessWidget {
  final List<(Widget, String, bool)> items;
  final ValueChanged<int> onSelect;
  const _NavDrawer({required this.items, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final header = Container(
      width: double.infinity,
      color: cs.inverseSurface, // the charcoal band
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 18),
      child: Row(children: [
        const AppLogo(size: 44, animate: false),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pagemark', style: tt.titleLarge?.copyWith(color: cs.onInverseSurface, fontWeight: FontWeight.w600)),
            Text('Your private reading log', style: tt.bodySmall?.copyWith(color: cs.onInverseSurface.withValues(alpha: 0.75))),
          ]),
        ),
      ]),
    );
    // status bar icons that read on the header colour
    final overlay = ThemeData.estimateBrightnessForColor(cs.inverseSurface) == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Drawer(
        shape: const RoundedRectangleBorder(),
        child: ListView(
          padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 8),
          children: [
            header,
            const SizedBox(height: 8),
            for (final (i, (icon, label, selected)) in items.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                child: ListTile(
                  selected: selected,
                  selectedTileColor: cs.secondaryContainer,
                  selectedColor: cs.onSecondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: icon,
                  title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
