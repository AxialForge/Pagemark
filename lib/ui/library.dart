part of '../ui.dart';

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
        if (!widget.locked) const LibraryBanners(),
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
