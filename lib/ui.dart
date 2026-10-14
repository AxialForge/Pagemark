import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'app_lock.dart';
import 'backup_reminder.dart';
import 'restore_ui.dart';
import 'book_extras.dart';
import 'covers.dart';
import 'branding.dart';
import 'updater.dart';
import 'updater_ui.dart';
import 'features.dart';
import 'import_ui.dart';
import 'lock_ui.dart';
import 'privacy.dart';
import 'selection.dart';
import 'skins.dart';
import 'notifier.dart';
import 'text_utils.dart';
import 'widgets.dart';
import 'db.dart';
import 'export.dart';
import 'lock.dart';
import 'isbn.dart';
import 'detailed_ratings.dart';
import 'folder_backup.dart';
import 'guide.dart';
import 'incoming.dart';
import 'log.dart';
import 'lookup.dart';
import 'reminders.dart';
import 'widget_sync.dart';
import 'main.dart';
import 'themes.dart';

const formats = {'print': 'Print', 'ebook': 'E-book', 'audio': 'Audiobook'};
const statuses = {'want': 'Want to read', 'reading': 'Reading', 'finished': 'Finished', 'dnf': 'Did not finish'};
final _date = DateFormat.yMMMd();

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..clearSnackBars() // a new message replaces the old one instead of queueing
  ..showSnackBar(SnackBar(content: Text(m)));

// ───────────────────────── Home ─────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

enum _Tab { library, locked, stats, settings }

class _HomeState extends State<Home> with WidgetsBindingObserver {
  _Tab cur = _Tab.library;
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
      if (mounted) announceNewVersion(context);
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

  /// After a few books are in, ask once for permission to send reminders (Android 13+ shows its own question).
  Future<void> _askNotificationsOnce() async {
    if (prefs.getBool('notif_asked') ?? false) return;
    final n = (await db.select(db.books).get()).length;
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
          final visible = [_Tab.library, if (!hidden) _Tab.locked, _Tab.stats, _Tab.settings];
          final shown = visible.contains(cur) ? cur : _Tab.library; // the Locked tab may have just been hidden
          if (shown != cur) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) { _lock(); setState(() => cur = _Tab.library); } });
          final page = switch (shown) {
            _Tab.library => const Library(locked: false),
            _Tab.locked => unlocked ? const Library(locked: true) : LockGate(onUnlock: _unlock),
            _Tab.stats => const Stats(),
            _Tab.settings => SettingsPage(onLockNow: () => setState(() { _lock(); cur = _Tab.library; })),
          };
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
              ),
              child: KeyedSubtree(key: ValueKey(shown), child: page),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: visible.indexOf(shown),
              onDestinationSelected: (i) => setState(() {
                final next = visible[i];
                if (shown == _Tab.locked && next != _Tab.locked) _lock(); // re-lock when leaving the locked tab
                cur = next;
              }),
              destinations: [
                for (final t in visible)
                  switch (t) {
                    _Tab.library => const NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Library'),
                    _Tab.locked => const NavigationDestination(icon: Icon(Icons.lock_outline), label: 'Locked'),
                    _Tab.stats => const NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
                    _Tab.settings => NavigationDestination(
                        icon: ValueListenableBuilder<UpdateInfo?>(valueListenable: updateAvailable, builder: (_, u, _) => Badge(isLabelVisible: u != null, child: const Icon(Icons.settings_outlined))),
                        label: 'Settings',
                      ),
                  },
              ],
            ),
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

// ───────────────────────── Library ─────────────────────────
class Library extends StatefulWidget {
  final bool locked;
  const Library({super.key, required this.locked});
  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  String q = '', status = 'all', format = 'all', sort = 'added';
  int? shelf;
  LibrarySkin skin = LibrarySkin.classic;
  late final Stream<List<BookRow>> _rowsStream = db.watchLibrary(locked: widget.locked).distinct(); // one subscription; identical re-emissions are skipped
  final _searchCtl = TextEditingController();
  final Set<int> selected = {};
  Map<int, String> _quoteText = {};
  StreamSubscription<Map<int, String>>? _quoteSub;
  List<BookRow> _shown = []; // what the list currently shows (for Select all)
  bool groupShelves = false; // Bookshelf/Spines: one named wooden shelf per user shelf
  List<Shelf> shelves = [];
  Map<int, Set<int>> shelfBooks = {}; // shelf id -> book ids
  StreamSubscription<List<Shelf>>? _shelfSub;
  StreamSubscription<List<BookShelf>>? _linkSub;

  String get _pk => 'lib_${widget.locked ? 'v' : 'm'}'; // sort/filters are remembered per library

  /// The "Log progress" launcher shortcut: show only the books being read.
  void _showReading() {
    if (!mounted) return;
    setState(() => status = 'reading');
    _save();
  }

  @override
  void initState() {
    super.initState();
    sort = prefs.getString('${_pk}_sort') ?? 'added';
    status = prefs.getString('${_pk}_status') ?? 'all';
    format = prefs.getString('${_pk}_format') ?? 'all';
    shelf = prefs.getInt('${_pk}_shelf');
    skin = skinById(prefs.getString('${_pk}_skin'));
    groupShelves = prefs.getBool('${_pk}_group') ?? false;
    _quoteSub = db.watchQuoteText().listen((m) { if (mounted) setState(() => _quoteText = m); });
    if (!widget.locked) Incoming.readingShortcut.addListener(_showReading);
    _shelfSub = db.watchShelves(locked: widget.locked).listen((v) {
      if (!mounted) return;
      setState(() {
        shelves = v;
        if (shelf != null && !v.any((x) => x.id == shelf)) shelf = null; // the shelf was deleted
      });
    });
    _linkSub = db.watchShelfLinks().listen((v) {
      final m = <int, Set<int>>{};
      for (final l in v) { (m[l.shelfId] ??= {}).add(l.bookId); }
      if (mounted) setState(() => shelfBooks = m);
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _quoteSub?.cancel();
    _shelfSub?.cancel();
    _linkSub?.cancel();
    Incoming.readingShortcut.removeListener(_showReading);
    super.dispose();
  }

  void _toggle(BookRow r) {
    setState(() => selected.contains(r.book.id) ? selected.remove(r.book.id) : selected.add(r.book.id));
  }

  void _clearSel() => setState(selected.clear);

  void _undoBar(String message, Future<void> Function() undo) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 8), action: SnackBarAction(label: 'Undo', onPressed: undo)));
  }

  Future<void> _bulkTrash(Set<int> ids) async {
    await db.softDeleteMany(ids);
    _undoBar('${ids.length} ${ids.length == 1 ? 'book' : 'books'} moved to Trash', () => db.restoreMany(ids));
  }

  Future<void> _bulkFinish(Set<int> ids) async {
    final u = await db.markFinishedToday(ids);
    _undoBar(u.count == 0 ? 'Already finished' : '${u.count} marked finished today', () => db.undoMarkFinished(u));
  }

  Future<void> _bulkLock(Set<int> ids) async {
    final to = !widget.locked;
    await db.setLockedMany(ids, to);
    _undoBar(to ? '${ids.length} moved to the locked library' : '${ids.length} moved to the main library', () => db.setLockedMany(ids, !to));
  }

  Future<void> _bulkShelf(Set<int> ids) async {
    final shelves = await db.watchShelves(locked: widget.locked).first;
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const ListTile(title: Text('Add to shelf', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final s in shelves) ListTile(leading: const Icon(Icons.collections_bookmark_outlined), title: Text(s.name), onTap: () => Navigator.pop(c, s.id)),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New shelf'),
            onTap: () async {
              final n = await ask(c, 'Shelf name');
              if (n == null || n.trim().isEmpty) return;
              final id = await db.addShelf(n);
              if (c.mounted) Navigator.pop(c, id);
            },
          ),
        ]),
      ),
    );
    if (picked == null) return;
    await db.addManyToShelf(ids, picked);
    if (mounted) snack(context, 'Added ${ids.length} to the shelf');
  }

  PreferredSizeWidget _selectionBar() {
    final ids = {...selected};
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.close), tooltip: 'Cancel selection', onPressed: _clearSel),
      title: Text('${ids.length} selected'),
      actions: [
        IconButton(icon: const Icon(Icons.select_all), tooltip: 'Select all shown', onPressed: () => setState(() => selected.addAll(_shown.map((r) => r.book.id)))),
        IconButton(icon: const Icon(Icons.done_all), tooltip: 'Mark finished today', onPressed: () { _clearSel(); _bulkFinish(ids); }),
        IconButton(icon: const Icon(Icons.collections_bookmark_outlined), tooltip: 'Add to shelf', onPressed: () async { await _bulkShelf(ids); _clearSel(); }),
        IconButton(icon: Icon(widget.locked ? Icons.lock_open : Icons.lock_outline), tooltip: widget.locked ? 'Move to main library' : 'Move to locked library', onPressed: () { _clearSel(); _bulkLock(ids); }),
        IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Move to Trash', onPressed: () { _clearSel(); _bulkTrash(ids); }),
      ],
    );
  }

  void _save() {
    prefs.setString('${_pk}_sort', sort);
    prefs.setString('${_pk}_status', status);
    prefs.setString('${_pk}_format', format);
    prefs.setString('${_pk}_skin', skin.name);
    prefs.setBool('${_pk}_group', groupShelves);
    shelf == null ? prefs.remove('${_pk}_shelf') : prefs.setInt('${_pk}_shelf', shelf!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selected.isNotEmpty ? _selectionBar() : AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: !widget.locked && hideLockedTab.value ? () => openVault(context) : null, // stealth entrance when the tab is hidden
          child: Text(widget.locked ? 'Locked library' : 'Library'),
        ),
        actions: [
        IconButton(
          icon: Icon(skin.icon), tooltip: 'Library style: ${skin.label}',
          onPressed: () async {
            final picked = await showSkinPicker(context, skin,
                grouped: groupShelves, hasShelves: shelves.isNotEmpty, onGrouped: (v) { setState(() => groupShelves = v); _save(); });
            if (picked != null && picked != skin) { setState(() => skin = picked); _save(); }
          },
        ),
        PopupMenuButton<String>(
          tooltip: 'More',
          onSelected: (v) => Navigator.push(context, MaterialPageRoute(builder: (_) => switch (v) {
                'series' => SeriesPage(locked: widget.locked),
                'trash' => const TrashPage(locked: true),
                'help' => const GuidePage(),
                _ => ShelvesPage(locked: widget.locked),
              })),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'series', child: ListTile(leading: Icon(Icons.layers_outlined), title: Text('Series'))),
            const PopupMenuItem(value: 'shelves', child: ListTile(leading: Icon(Icons.collections_bookmark_outlined), title: Text('Manage shelves'))),
            if (widget.locked) const PopupMenuItem(value: 'trash', child: ListTile(leading: Icon(Icons.delete_sweep_outlined), title: Text('Deleted books'))),
            const PopupMenuItem(value: 'help', child: ListTile(leading: Icon(Icons.menu_book_outlined), title: Text('How to use Pagemark'))),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (v) { setState(() => sort = v); _save(); },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'added', child: Text('Recently added')),
            PopupMenuItem(value: 'title', child: Text('Title')),
            PopupMenuItem(value: 'author', child: Text('Author')),
            PopupMenuItem(value: 'rating', child: Text('Rating')),
          ],
        ),
      ]),
      floatingActionButton: selected.isNotEmpty ? null : FloatingActionButton.extended(
        icon: const Icon(Icons.add), label: const Text('Add book'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddBook(locked: widget.locked))),
      ),
      body: PopScope(
        canPop: selected.isEmpty, // Back first closes the selection
        onPopInvokedWithResult: (didPop, _) { if (!didPop) _clearSel(); },
        child: SelectionScope(
        selected: selected,
        onToggle: _toggle,
        onQuickFinish: (r) => _bulkFinish({r.book.id}),
        onQuickTrash: (r) => _bulkTrash({r.book.id}),
        child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: TextField(
            controller: _searchCtl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search books, notes, thoughts and quotes',
              border: const OutlineInputBorder(),
              suffixIcon: q.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), tooltip: 'Clear search', onPressed: () { _searchCtl.clear(); setState(() => q = ''); }),
            ),
            onChanged: (v) => setState(() => q = v.toLowerCase()),
          ),
        ),
        SizedBox(
          height: 20 + MediaQuery.textScalerOf(context).scale(28), // grows with the system font size so chip text is never clipped
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), children: [
            for (final e in {'all': 'All', ...statuses}.entries)
              Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(e.value), selected: status == e.key, onSelected: (_) { setState(() => status = e.key); _save(); })),
            const VerticalDivider(),
            for (final e in {'all': 'Any format', ...formats}.entries)
              Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(e.value), selected: format == e.key, onSelected: (_) { setState(() => format = e.key); _save(); })),
            if (shelves.isNotEmpty) ...[
              const VerticalDivider(),
              for (final s in shelves)
                Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(
                  avatar: const Icon(Icons.collections_bookmark_outlined, size: 16),
                  label: Text(s.name), selected: shelf == s.id,
                  onSelected: (_) { setState(() => shelf = shelf == s.id ? null : s.id); _save(); },
                )),
            ],
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<BookRow>>(
            stream: _rowsStream,
            builder: (_, snap) {
              var rows = (snap.data ?? []).where((r) {
                final b = r.book;
                if (q.isNotEmpty && !'${b.title} ${b.author} ${b.tags} ${b.genre} ${b.series} ${b.notes} ${r.reads.map((e) => e.thoughts).join(' ')} ${_quoteText[b.id] ?? ''}'.toLowerCase().contains(q)) return false;
                if (status != 'all' && !r.reads.any((e) => e.status == status)) return false;
                if (format != 'all' && !r.reads.any((e) => e.format == format)) return false;
                if (shelf != null && !(shelfBooks[shelf]?.contains(b.id) ?? false)) return false;
                return true;
              }).toList();
              rows.sort((a, b) {
                switch (sort) {
                  case 'title': return a.book.title.toLowerCase().compareTo(b.book.title.toLowerCase());
                  case 'author': return a.book.author.toLowerCase().compareTo(b.book.author.toLowerCase());
                  case 'rating':
                    final c = (b.avgRating ?? -1).compareTo(a.avgRating ?? -1);
                    return c != 0 ? c : a.book.title.toLowerCase().compareTo(b.book.title.toLowerCase()); // stable ties
                  default: return b.book.added.compareTo(a.book.added);
                }
              });
              if (rows.isEmpty) {
                final none = snap.data?.isEmpty ?? true;
                return none
                    ? EmptyState(
                        message: widget.locked ? 'Nothing in your locked library yet.\nTap Add book to start.' : 'Your shelf is empty.\nTap Add book to start your log.',
                        actionLabel: widget.locked ? null : 'See how Pagemark works',
                        onAction: widget.locked ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage())),
                      )
                    : const Center(child: Text('No matches.'));
              }
              _shown = rows;
              final list = SkinView(skin: skin, rows: rows, groupByShelf: groupShelves, shelves: shelves, shelfBooks: shelfBooks);
              final reading = (snap.data ?? []).where((r) => r.status == 'reading').toList();
              final unfiltered = q.isEmpty && status == 'all' && format == 'all' && shelf == null;
              if (!unfiltered || reading.isEmpty) return list;
              return Column(children: [
                Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Currently reading', style: Theme.of(context).textTheme.titleSmall))),
                SizedBox(
                  height: 148,
                  child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
                    for (final r in reading)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SizedBox(width: 72, child: Column(children: [
                            Cover(r.book.coverUrl, w: 72, locked: r.book.locked, title: r.book.title),
                            const SizedBox(height: 6),
                            r.progress != null ? SlimProgress(r.progress!) : Text(r.book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
                          ])),
                        ),
                      ),
                  ]),
                ),
                const Divider(height: 1),
                Expanded(child: list),
              ]);
            },
          ),
        ),
      ]),
        ),
      ),
    );
  }
}

class Cover extends StatelessWidget {
  final String url;
  final double w;
  final Object? tag; // shared-element (Hero) tag between list and detail
  final bool locked; // locked-library covers use a separate cache that is wiped on relock
  final String title; // when there is no cover image, a binding-coloured tile with the title's initial is drawn
  const Cover(this.url, {super.key, this.w = 48, this.tag, this.locked = false, this.title = ''});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trimmed = title.trim();
    final ph = trimmed.isEmpty
        ? Container(width: w, height: w * 1.5, color: cs.secondaryContainer, child: const Icon(Icons.book))
        : Builder(builder: (_) {
            final bg = bookColorFor(trimmed, cs);
            return Container(
              width: w, height: w * 1.5, alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
              child: Text(trimmed.substring(0, 1).toUpperCase(), style: TextStyle(color: onBookColor(bg), fontFamily: 'serif', fontWeight: FontWeight.w700, fontSize: w * 0.5)),
            );
          });
    final small = w <= 64 ? url.replaceFirst('-L.jpg', '-M.jpg') : url; // list thumbnails: don't download full-size covers
    final localFile = CoverStore.fileFor(url);
    final img = url.isEmpty || (CoverStore.isLocal(url) && localFile == null)
        ? ph
        : localFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(localFile, width: w, height: w * 1.5, fit: BoxFit.cover, cacheWidth: (w * 3).round(), gaplessPlayback: true, errorBuilder: (_, _, _) => ph),
              )
            : ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(imageUrl: small, cacheManager: locked ? lockedCache : null, memCacheWidth: (w * 3).round(), width: w, height: w * 1.5, fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 250), placeholder: (_, _) => ph, errorWidget: (_, _, _) => ph),
          );
    return tag == null ? img : Hero(tag: tag!, child: img);
  }
}

class BookTile extends StatelessWidget {
  final BookRow row;
  const BookTile({super.key, required this.row});
  @override
  Widget build(BuildContext context) {
    final b = row.book;
    final r = row.avgRating;
    final fmts = row.reads.map((e) => formats[e.format]).toSet().join(' · ');
    final scope = SelectionScope.maybeOf(context);
    final picked = SelectionScope.isSelected(context, b.id);
    return ListTile(
      selected: picked,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
      leading: Stack(clipBehavior: Clip.none, children: [
        Cover(b.coverUrl, tag: 'cover-${b.id}', locked: b.locked, title: b.title),
        if (picked) const Positioned(right: -6, top: -6, child: SelectedBadge()),
      ]),
      title: Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text([
          b.author,
          if (b.series.isNotEmpty) '${b.series}${b.seriesNumber == null ? '' : ' #${SeriesPage.fmtNum(b.seriesNumber)}'}',
          if (row.reads.isNotEmpty) statuses[row.status],
          if (fmts.isNotEmpty) fmts,
        ].where((s) => s != null && s.isNotEmpty).join('\n')),
        if (row.progress != null) Padding(padding: const EdgeInsets.only(top: 6, right: 8), child: SlimProgress(row.progress!)),
      ]),
      trailing: r == null ? null : Semantics(label: 'Rated ${r.toStringAsFixed(1)} of 5', child: Text(starsText(r), style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 15))),
      onTap: () => scope != null && scope.active ? scope.onToggle(row) : Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: b.id))),
      onLongPress: scope == null ? null : () {
        HapticFeedback.mediumImpact();
        scope.onToggle(row);
      },
    );
  }
}

// ───────────────────────── Add / edit ─────────────────────────
class AddBook extends StatefulWidget {
  final bool locked;
  /// Pre-fills the search (from the Share sheet); it is searched right away, nothing is saved until you pick a result.
  final String? initialQuery;
  const AddBook({super.key, required this.locked, this.initialQuery});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final qc = TextEditingController();
  List<BookMeta> results = [];
  bool showAll = false; // junk (summaries, study guides) and results beyond the first 12 sit behind a "show more" row
  static const _shown = 12;

  /// What the list shows now. If every result is junk (the user really wants a summary book) show them all.
  List<BookMeta> get _visible {
    if (showAll) return results;
    final real = results.where((m) => !Lookup.isJunk(m)).take(_shown).toList();
    return real.isEmpty ? results.take(_shown).toList() : real;
  }
  bool busy = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery;
    if (q != null && q.isNotEmpty) {
      qc.text = q;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) go(q); });
    }
  }

  @override
  void dispose() {
    qc.dispose();
    super.dispose();
  }

  Future<void> run(Future<List<BookMeta>> Function() f) async {
    setState(() { busy = true; showAll = false; });
    try {
      results = await f();
    } catch (e) {
      Log.w('addbook', 'lookup failed: $e');
      if (mounted) snack(context, e is LookupException ? '$e You can still add the book manually below.' : 'Lookup failed — you can add the book manually below.');
    }
    if (mounted) setState(() => busy = false);
  }

  /// A valid ISBN (typed, pasted or scanned) is looked up directly; anything else is a text search.
  /// First lookup from the locked library warns once that the text is sent to Open Library.
  Future<void> go(String q) async {
    if (widget.locked && !(prefs.getBool('vault_lookup_ok') ?? false)) {
      final choice = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Searching uses the internet'),
          content: const Text('Searching sends what you type to a free book website (Open Library). If you want a title to stay completely on your phone, add it by hand instead.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(c, 'manual'), child: const Text('Add by hand')),
            FilledButton(onPressed: () => Navigator.pop(c, 'search'), child: const Text('Search anyway')),
          ],
        ),
      );
      if (!mounted) return;
      if (choice == 'manual') { await manual(); return; }
      if (choice != 'search') return;
      await prefs.setBool('vault_lookup_ok', true);
    }
    await _search(q);
  }

  Future<void> manual() async {
    final r = await _manualDialog(context, qc.text);
    if (r != null) await save(BookMeta(title: r.$1, author: r.$2));
  }

  Future<void> _search(String q) => run(() async {
        if (Isbn.looksLikeBookCode(q)) {
          final m = await Lookup.byIsbn(q);
          return [?m];
        }
        return Lookup.search(q);
      });

  Future<void> scan() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const ScanPage()));
    if (code == null) return;
    qc.text = code;
    await go(code);
  }

  bool saving = false;

  Future<void> save(BookMeta m) async {
    if (saving) return; // a double tap must not add the book twice
    saving = true;
    try {
      final dup = await db.findDuplicate(title: m.title, author: m.author, isbn: m.isbn, locked: widget.locked);
      if (dup != null && mounted) {
        final choice = await showDialog<String>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Already in this library'),
            content: Text('"${dup.title}" by ${dup.author.isEmpty ? 'unknown author' : dup.author} is already here.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, 'cancel'), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(c, 'open'), child: const Text('Open it')),
              FilledButton(onPressed: () => Navigator.pop(c, 'add'), child: const Text('Add anyway')),
            ],
          ),
        );
        if (!mounted || choice == null || choice == 'cancel') return;
        if (choice == 'open') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookPage(bookId: dup.id)));
          return;
        }
      }
      await _insert(m);
    } finally {
      saving = false;
    }
  }

  Future<void> _insert(BookMeta m) async {
    final id = await db.into(db.books).insert(BooksCompanion.insert(
          title: m.title,
          author: Value(m.author), isbn: Value(m.isbn), coverUrl: Value(m.coverUrl), genre: Value(m.genre),
          publisher: Value(m.publisher), year: Value(m.year), pages: Value(m.pages),
          series: Value(m.series), description: Value(m.description), locked: Value(widget.locked),
        ));
    if (m.description.isEmpty && m.workKey.isNotEmpty) {
      Lookup.description(m.workKey).then((d) {
        if (d.isNotEmpty) (db.update(db.books)..where((b) => b.id.equals(id))).write(BooksCompanion(description: Value(d)));
      });
    }
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: id))); // Back returns to your search results
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add a book'), actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), tooltip: 'Scan a barcode', onPressed: scan)]),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: qc,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for a book (title, author or ISBN)', border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => go(qc.text)),
              ),
              onSubmitted: go,
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: ListView(children: [
              for (final m in _visible)
                ListTile(
                  leading: Cover(m.coverUrl, locked: widget.locked, title: m.title), title: Text(m.title),
                  subtitle: Text('${m.author}${m.year != null ? ' · ${m.year}' : ''}'),
                  onTap: () => save(m),
                ),
              if (!showAll && results.length > _visible.length)
                ListTile(
                  leading: const Icon(Icons.expand_more), title: Text('Show ${results.length - _visible.length} more results'),
                  subtitle: const Text('Includes summaries and study guides'),
                  onTap: () => setState(() => showAll = true),
                ),
              ListTile(
                leading: const Icon(Icons.edit_note), title: const Text('Add by hand'),
                subtitle: const Text('Not found? Enter the details yourself.'),
                onTap: manual,
              ),
            ]),
          ),
        ]),
      );
}

Future<(String, String)?> _manualDialog(BuildContext c, String title) {
  final t = TextEditingController(text: title), a = TextEditingController();
  return showDialog<(String, String)>(
    context: c,
    builder: (_) => AlertDialog(
      title: const Text('Add a book by hand'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: t, autofocus: true, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Title')),
        TextField(controller: a, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Author (optional)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(onPressed: () { if (t.text.trim().isNotEmpty) Navigator.pop(c, (t.text.trim(), a.text.trim())); }, child: const Text('Add')),
      ],
    ),
  );
}

Future<String?> ask(BuildContext c, String label, [String initial = '', bool multiline = false, bool obscure = false, TextInputType? kb]) {
  final ctl = TextEditingController(text: initial);
  return showDialog<String>(
    context: c,
    builder: (_) => AlertDialog(
      title: Text(label),
      content: TextField(controller: ctl, autofocus: true, maxLines: multiline ? 6 : 1, obscureText: obscure, keyboardType: kb),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, ctl.text), child: const Text('OK')),
      ],
    ),
  );
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final controller = MobileScannerController();
  bool done = false; // onDetect fires repeatedly; pop exactly once

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Scan a book barcode'), actions: [
          IconButton(icon: const Icon(Icons.flashlight_on_outlined), tooltip: 'Torch', onPressed: controller.toggleTorch),
        ]),
        body: Stack(children: [
          MobileScanner(
            controller: controller,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.no_photography_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    error.errorCode == MobileScannerErrorCode.permissionDenied
                        ? 'Pagemark needs the camera to scan barcodes. Allow it in Android Settings, or type the number under the barcode instead.'
                        : 'The camera is not available right now. You can type the number under the barcode instead.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (error.errorCode == MobileScannerErrorCode.permissionDenied) ...[
                    FilledButton.tonal(onPressed: openAppSettings, child: const Text('Open app settings')),
                    const SizedBox(height: 8),
                  ],
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Type the number instead')),
                ]),
              ),
            ),
            onDetect: (cap) {
              if (done) return;
              for (final b in cap.barcodes) {
                final v = b.rawValue;
                if (v != null && Isbn.looksLikeBookCode(v)) { // ignore QR codes / price labels
                  done = true;
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context, Isbn.to13(v));
                  return;
                }
              }
            },
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(padding: EdgeInsets.all(24), child: Text('Point the camera at the barcode on the back cover', style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 6)]))),
          ),
        ]),
      );
}

// ───────────────────────── Book detail ─────────────────────────
class BookPage extends StatelessWidget {
  final int bookId;
  const BookPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Book?>(
      stream: (db.select(db.books)..where((b) => b.id.equals(bookId))).watchSingleOrNull(),
      builder: (_, snap) {
        final b = snap.data;
        if (b == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snap.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('This book is no longer in your library.'),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
                    ]),
                  ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(b.title, overflow: TextOverflow.ellipsis), actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditBook(book: b)))),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'lock') await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(BooksCompanion(locked: Value(!b.locked)));
                if (v.startsWith('cover_')) {
                  final msg = await coverAction(b, v.substring(6));
                  if (msg != null && context.mounted) snack(context, msg);
                }
                if (v == 'del') {
                  if (!context.mounted) return;
                  final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                    title: const Text('Move to Trash?'), content: const Text('Its reading log and thoughts go with it. You can bring it back from Settings, Your library, Deleted books for 30 days.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Move to Trash'))]));
                  if (ok == true) {
                    await db.softDelete(b.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'lock', child: Text(b.locked ? 'Move to main library' : 'Move to locked library')),
                if (b.coverUrl.isNotEmpty && !CoverStore.isLocal(b.coverUrl)) const PopupMenuItem(value: 'cover_save', child: Text('Save cover on this phone')),
                const PopupMenuItem(value: 'cover_pick', child: Text('Choose cover from gallery')),
                if (CoverStore.isLocal(b.coverUrl)) const PopupMenuItem(value: 'cover_remove', child: Text('Remove saved cover')),
                const PopupMenuItem(value: 'del', child: Text('Move to Trash')),
              ],
            ),
          ]),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add), label: const Text('Log a read'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadEditor(bookId: b.id))),
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Cover(b.coverUrl, w: 100, tag: 'cover-${b.id}', locked: b.locked, title: b.title),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: Theme.of(context).textTheme.titleLarge),
                if (b.author.isNotEmpty) AuthorLinks(b),
                if (b.series.isNotEmpty) Text('Series: ${b.series}${b.seriesNumber == null ? '' : ' #${SeriesPage.fmtNum(b.seriesNumber)}'}${b.seriesTotal == null ? '' : ' of ${b.seriesTotal}'}'),
                if (b.genre.isNotEmpty) Text(b.genre),
                Text([if (b.year != null) '${b.year}', if (b.pages != null) '${b.pages} pages', if (b.publisher.isNotEmpty) b.publisher].join(' · ')),
                if (b.isbn.isNotEmpty) Text('ISBN ${b.isbn}'),
                if (b.tags.isNotEmpty) Wrap(spacing: 4, children: [for (final t in b.tags.split(',').where((t) => t.trim().isNotEmpty)) Chip(label: Text(t.trim()))]),
                const SizedBox(height: 6),
                ShelfChips(bookId: b.id, locked: b.locked),
              ])),
            ]),
            if (b.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: ExpandableText(b.description)),
            if (b.notes.isNotEmpty) Card(margin: const EdgeInsets.only(top: 12), child: Padding(padding: const EdgeInsets.all(12), child: Text(b.notes))),
            const Divider(height: 32),
            QuotesSection(book: b),
            const Divider(height: 32),
            Text('Reading log', style: Theme.of(context).textTheme.titleMedium),
            StreamBuilder<List<Read>>(
              stream: db.watchReads(b.id),
              builder: (_, rs) {
                final list = rs.data ?? [];
                if (list.isEmpty) return const Padding(padding: EdgeInsets.all(8), child: Text('Nothing logged yet.'));
                final active = list.where((r) => r.status == 'reading').firstOrNull;
                return Column(children: [
                  if (active != null) ProgressCard(book: b, read: active),
                  for (final r in list)
                    Card(child: ListTile(
                      leading: Icon(r.format == 'audio' ? Icons.headphones : r.format == 'ebook' ? Icons.tablet_android : Icons.menu_book),
                      title: Text('${formats[r.format]} · ${statuses[r.status]}'),
                      subtitle: Text([
                        if (detailText(r).isNotEmpty) detailText(r),
                        if (r.started != null) 'Started ${_date.format(r.started!)}',
                        if (r.finished != null) 'Finished ${_date.format(r.finished!)}',
                        if (r.narrator.isNotEmpty) 'Narrator: ${r.narrator}',
                        if (adultFieldsOn() && r.heat != null && r.heat! > 0) 'Heat ${heatText(r.heat!)}',
                        if (adultFieldsOn() && r.contentNotes.isNotEmpty) 'Content: ${r.contentNotes}',
                        if (r.thoughts.isNotEmpty) r.thoughts,
                      ].join('\n')),
                      isThreeLine: true,
                      trailing: r.rating == null ? null : Text(starsText(r.rating!), style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16)),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadEditor(bookId: b.id, read: r))),
                    )),
                ]);
              },
            ),
            const SizedBox(height: 80),
          ]),
        );
      },
    );
  }
}

class EditBook extends StatefulWidget {
  final Book book;
  const EditBook({super.key, required this.book});
  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  late final Map<String, TextEditingController> c = {
    for (final e in {
      'title': widget.book.title, 'author': widget.book.author, 'series': widget.book.series, 'seriesNumber': SeriesPage.fmtNum(widget.book.seriesNumber), 'seriesTotal': '${widget.book.seriesTotal ?? ''}', 'genre': widget.book.genre,
      'tags': widget.book.tags, 'publisher': widget.book.publisher, 'isbn': widget.book.isbn, 'coverUrl': widget.book.coverUrl,
      'year': '${widget.book.year ?? ''}', 'pages': '${widget.book.pages ?? ''}', 'description': widget.book.description, 'notes': widget.book.notes,
    }.entries) e.key: TextEditingController(text: e.value)
  };

  late final Map<String, String> _initial = {for (final e in c.entries) e.key: e.value.text};
  bool _saved = false;
  bool get _dirty => !_saved && c.entries.any((e) => e.value.text != _initial[e.key]);

  @override
  void initState() {
    super.initState();
    _initial; // snapshot before any typing
    for (final ctl in c.values) {
      ctl.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final ctl in c.values) {
      ctl.dispose();
    }
    super.dispose();
  }

  Widget f(String k, String label, {int lines = 1, bool num = false, bool decimal = false, TextCapitalization cap = TextCapitalization.none}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c[k], maxLines: lines, textCapitalization: cap,
          keyboardType: num ? TextInputType.numberWithOptions(decimal: decimal) : null,
          inputFormatters: num ? [FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.]' : r'[0-9]'))] : null,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        ),
      );

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await confirmDiscard(context) && context.mounted) {
            _saved = true; // user chose to discard
            Navigator.pop(context);
          }
        },
        child: Scaffold(
        appBar: AppBar(title: const Text('Edit book'), actions: [
          TextButton(onPressed: () async {
            _saved = true;
            await (db.update(db.books)..where((x) => x.id.equals(widget.book.id))).write(BooksCompanion(
              title: Value(c['title']!.text), author: Value(c['author']!.text), series: Value(c['series']!.text), seriesNumber: Value(SeriesPage.parseNum(c['seriesNumber']!.text)), seriesTotal: Value(int.tryParse(c['seriesTotal']!.text.trim())), genre: Value(c['genre']!.text),
              tags: Value(normalizeTags(c['tags']!.text)), publisher: Value(c['publisher']!.text), isbn: Value(c['isbn']!.text), coverUrl: Value(c['coverUrl']!.text),
              year: Value(int.tryParse(c['year']!.text)), pages: Value(int.tryParse(c['pages']!.text)),
              description: Value(c['description']!.text), notes: Value(c['notes']!.text),
            ));
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ]),
        body: ListView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, padding: const EdgeInsets.all(16), children: [
          f('title', 'Title', cap: TextCapitalization.words), f('author', 'Author', cap: TextCapitalization.words), f('series', 'Series', cap: TextCapitalization.words),
          f('seriesNumber', 'Number in series (e.g. 2 or 2.5)', num: true, decimal: true), f('seriesTotal', 'Books in the series (optional)', num: true), f('genre', 'Genre (fantasy, romance, science…)', cap: TextCapitalization.words),
          f('tags', 'Tags (separate with commas)'), f('publisher', 'Publisher', cap: TextCapitalization.words), f('isbn', 'ISBN'), f('coverUrl', 'Cover picture web address'),
          f('year', 'Year', num: true), f('pages', 'Pages', num: true),
          f('description', 'Description', lines: 4, cap: TextCapitalization.sentences), f('notes', 'Private notes', lines: 4, cap: TextCapitalization.sentences),
        ]),
        ),
      );
}

// ───────────────────────── Log a read ─────────────────────────
class ReadEditor extends StatefulWidget {
  final int bookId;
  final Read? read;
  const ReadEditor({super.key, required this.bookId, this.read});
  @override
  State<ReadEditor> createState() => _ReadEditorState();
}

class _ReadEditorState extends State<ReadEditor> {
  late String format = widget.read?.format ?? 'print';
  late String status = widget.read?.status ?? 'reading';
  late DateTime? started = widget.read?.started ?? DateTime.now();
  late DateTime? finished = widget.read?.finished;
  late double rating = widget.read?.rating ?? 0;
  late final thoughts = TextEditingController(text: widget.read?.thoughts);
  late final narrator = TextEditingController(text: widget.read?.narrator);
  late final minutes = TextEditingController(text: '${widget.read?.minutes ?? ''}');
  late final page = TextEditingController(text: '${widget.read?.currentPage ?? ''}');
  late final contentNotes = TextEditingController(text: widget.read?.contentNotes);
  late int heat = widget.read?.heat ?? 0;
  late final Map<String, double> detail = {for (final a in ratingAspects) if (widget.read != null && aspectOf(widget.read!, a.key) != null) a.key: aspectOf(widget.read!, a.key)!};

  String _state() => [format, status, started?.toIso8601String(), finished?.toIso8601String(), rating, thoughts.text, narrator.text, minutes.text, page.text, heat, contentNotes.text, ...[for (final a in ratingAspects) detail[a.key]]].join('|');
  late final String _snap = _state();
  bool _saved = false;
  bool get _dirty => !_saved && _state() != _snap;

  @override
  void initState() {
    super.initState();
    _snap; // snapshot before any editing
    for (final ctl in [thoughts, narrator, minutes, page, contentNotes]) {
      ctl.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    thoughts.dispose();
    narrator.dispose();
    minutes.dispose();
    page.dispose();
    contentNotes.dispose();
    super.dispose();
  }

  /// Dates can't be in the future (you can't have read it tomorrow).
  Future<DateTime?> pick(DateTime? init) {
    final now = DateTime.now();
    final start = init == null || init.isAfter(now) ? now : init;
    return showDatePicker(context: context, initialDate: start, firstDate: DateTime(1900), lastDate: now);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await confirmDiscard(context) && context.mounted) {
            _saved = true;
            Navigator.pop(context);
          }
        },
        child: Scaffold(
        appBar: AppBar(title: Text(widget.read == null ? 'Log a read' : 'Edit read'), actions: [
          if (widget.read != null) IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete this read', onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
              title: const Text('Delete this read?'), content: const Text('Its dates, rating and thoughts will be gone for good.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
            if (ok != true || !context.mounted) return;
            final old = widget.read!;
            final messenger = ScaffoldMessenger.of(context);
            await (db.delete(db.reads)..where((r) => r.id.equals(old.id))).go();
            messenger
              ..clearSnackBars()
              ..showSnackBar(SnackBar(
                content: const Text('Read deleted'),
                duration: const Duration(seconds: 8),
                action: SnackBarAction(label: 'Undo', onPressed: () => db.into(db.reads).insert(old)), // same row, same id
              ));
            _saved = true;
            if (context.mounted) Navigator.pop(context);
          }),
          TextButton(onPressed: () async {
            final fin = status == 'finished' ? (finished ?? DateTime.now()) : finished;
            DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
            if (fin != null && started != null && day(fin).isBefore(day(started!))) {
              snack(context, 'The finished date is before the start date');
              return;
            }
            final comp = ReadsCompanion(
              bookId: Value(widget.bookId), format: Value(format), status: Value(status), started: Value(started), finished: Value(fin),
              rating: Value(rating == 0 ? null : rating), thoughts: Value(thoughts.text), narrator: Value(narrator.text), minutes: Value(int.tryParse(minutes.text)), currentPage: Value(int.tryParse(page.text)),
              heat: Value(adultFieldsOn() ? (heat == 0 ? null : heat) : widget.read?.heat), contentNotes: Value(adultFieldsOn() ? contentNotes.text : (widget.read?.contentNotes ?? '')),
              // with detailed ratings off, whatever was saved before is kept as it was
              ratingStory: Value(detailedRatingsOn() ? detail['story'] : widget.read?.ratingStory), ratingCharacters: Value(detailedRatingsOn() ? detail['characters'] : widget.read?.ratingCharacters),
              ratingWriting: Value(detailedRatingsOn() ? detail['writing'] : widget.read?.ratingWriting), ratingPace: Value(detailedRatingsOn() ? detail['pace'] : widget.read?.ratingPace),
              ratingFeeling: Value(detailedRatingsOn() ? detail['feeling'] : widget.read?.ratingFeeling), ratingNarrator: Value(detailedRatingsOn() ? (format == 'audio' ? detail['narrator'] : null) : widget.read?.ratingNarrator),
            );
            _saved = true;
            if (widget.read == null) {
              await db.into(db.reads).insert(comp);
            } else {
              await (db.update(db.reads)..where((r) => r.id.equals(widget.read!.id))).write(comp);
            }
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ]),
        body: ListView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, padding: const EdgeInsets.all(16), children: [
          SegmentedButton<String>(
            segments: [for (final e in formats.entries) ButtonSegment(value: e.key, label: Text(e.value))],
            selected: {format}, onSelectionChanged: (s) => setState(() => format = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: [for (final e in statuses.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() {
              status = v!;
              if (status == 'finished') finished ??= DateTime.now(); // visible, editable default
              if (status == 'reading' || status == 'want') finished = null;
            }),
          ),
          if (status == 'reading') Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: page, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current page', border: OutlineInputBorder()))),
          ListTile(title: const Text('Started'), subtitle: Text(started == null ? '—' : _date.format(started!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(started); if (d != null) setState(() => started = d); }),
          Wrap(spacing: 8, children: [
            ActionChip(label: const Text('Started today'), onPressed: () => setState(() => started = DateTime.now())),
            ActionChip(label: const Text('Started yesterday'), onPressed: () => setState(() => started = DateTime.now().subtract(const Duration(days: 1)))),
          ]),
          ListTile(title: const Text('Finished'), subtitle: Text(finished == null ? '—' : _date.format(finished!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(finished); if (d != null) setState(() => finished = d); }),
          const SizedBox(height: 8),
          const Text('Rating'),
          Row(children: [
            StarRating(value: rating, onChanged: (v) => setState(() => rating = v)),
            const SizedBox(width: 8),
            Text(rating == 0 ? 'tap a star' : '$rating'),
          ]),
          if (detailedRatingsOn()) ...[
            const SizedBox(height: 8),
            DetailedRatingsEditor(values: detail, audio: format == 'audio', onChanged: (k, v) => setState(() => v == 0 ? detail.remove(k) : detail[k] = v)),
            const SizedBox(height: 8),
          ],
          if (format == 'audio') ...[
            TextField(controller: narrator, decoration: const InputDecoration(labelText: 'Narrator', border: OutlineInputBorder())),
            const SizedBox(height: 12),
          ],
          TextField(controller: minutes, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: format == 'audio' ? 'Listening time (minutes)' : 'Time spent (minutes)', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          if (adultFieldsOn()) ...[
            const Text('Heat (private)'),
            HeatRating(value: heat, onChanged: (v) => setState(() => heat = v)),
            TextField(controller: contentNotes, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Content notes (private)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
          ],
          TextField(controller: thoughts, minLines: 5, maxLines: 14, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Your thoughts', alignLabelWithHint: true, border: OutlineInputBorder())),
        ]),
        ),
      );
}

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
          const Divider(),
          _row(context, Icons.palette_outlined, SettingsTitles.appearance, 'Choose your colours', () => const _AppearancePage()),
          _row(context, Icons.notifications_active_outlined, SettingsTitles.notifications, 'Reading and backup reminders', () => const _NotificationsPage()),
          _row(context, Icons.widgets_outlined, SettingsTitles.widget, 'Home-screen widget and icon shortcuts', () => const _WidgetPage()),
          _row(context, Icons.lock_outline, SettingsTitles.privacy, 'PIN, fingerprint and your private library', () => _PrivacyPage(onLockNow: onLockNow)),
          _row(context, Icons.cloud_upload_outlined, SettingsTitles.backup, 'Keep your library safe, or bring it back', () => const _BackupPage()),
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
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: ListView(children: children));
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
    if (state == AppLifecycleState.resumed) _check(); // back from Android's settings
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
              trailing: TextButton(onPressed: openNotificationSettings, child: const Text('Turn on')),
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
            if (!ok && context.mounted) snack(context, 'Allow notifications for Pagemark in Android settings to get reminders.');
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

class _BackupPage extends StatefulWidget {
  const _BackupPage();
  @override
  State<_BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<_BackupPage> {
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

class _HelpPage extends StatelessWidget {
  const _HelpPage();
  @override
  Widget build(BuildContext context) => _SettingsSub(SettingsTitles.help, [
        ListTile(leading: const Icon(Icons.menu_book_outlined), title: const Text('How to use Pagemark'), subtitle: const Text('Short, simple steps for everything the app does'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidePage()))),
        ListTile(leading: const Icon(Icons.new_releases_outlined), title: const Text("What's new"), subtitle: const Text('Every change in every version'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogPage()))),
        ListTile(leading: const Icon(Icons.bug_report_outlined), title: const Text('Problem report'), subtitle: const Text('Only needed if someone is helping you fix a problem. It contains no book titles.'), trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsPage()))),
      ]);
}


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
        subtitle: const Text('A notification at the time you choose. It never names a book. Android may deliver it a few minutes late.'),
        value: on,
        onChanged: (v) async {
          final ok = await Reminders.setEnabled(v);
          if (!ok && context.mounted) snack(context, 'Allow notifications for Pagemark in Android settings to use reminders.');
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
