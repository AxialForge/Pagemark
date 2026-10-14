part of '../ui.dart';

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
  bool searched = false;

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
    setState(() { busy = true; showAll = false; searched = true; });
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
    final typed = qc.text.trim();
    final isCode = Isbn.looksLikeBookCode(typed);
    final r = await _manualDialog(context, isCode ? '' : typed); // a barcode number is kept for the book, not typed into the title
    if (r != null) await save(BookMeta(title: r.$1, author: r.$2, isbn: isCode ? (Isbn.to13(typed) ?? '') : ''));
  }

  /// Shown when a search finds nothing: other ways to ask, instead of a dead end.
  Widget _noResults() {
    final tips = searchSuggestions(qc.text);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nothing found for "${qc.text.trim()}"', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          const Text('Check the spelling, or try just the title. You can also scan the barcode, or add the book by hand below.'),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Try:'),
            Wrap(spacing: 8, children: [for (final t in tips) ActionChip(label: Text(t), onPressed: () { qc.text = t; go(t); })]),
          ],
        ]),
      ),
    );
  }

  Future<void> _search(String q) => run(() async {
        if (Isbn.looksLikeBookCode(q)) {
          final m = await Lookup.byIsbnAll(q, google: googleOn());
          return [?m];
        }
        return Lookup.searchAll(q, google: googleOn());
      });

  Future<void> scan() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const ScanPage()));
    if (code == null) return;
    qc.text = code;
    await go(code);
  }

  /// Scan a whole shelf: each barcode is looked up and added on its own. The locked library gets the same one-time internet warning.
  Future<void> scanMany() async {
    if (widget.locked && !await confirmVaultLookup(context)) return;
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => BulkScanPage(locked: widget.locked)));
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
    final id = await insertMeta(m, locked: widget.locked);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: id))); // Back returns to your search results
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add a book'), actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), tooltip: 'Scan a barcode', onPressed: scan),
          IconButton(icon: const Icon(Icons.library_add_check_outlined), tooltip: 'Scan many books', onPressed: scanMany),
        ]),
        body: NarrowColumn(child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: qc,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for a book (title, author or ISBN)', border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), tooltip: 'Search', onPressed: () => go(qc.text)),
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
              if (searched && !busy && results.isEmpty && qc.text.trim().isNotEmpty) _noResults(),
              ListTile(
                leading: const Icon(Icons.edit_note), title: const Text('Add by hand'),
                subtitle: const Text('Not found? Enter the details yourself.'),
                onTap: manual,
              ),
            ]),
          ),
        ])),
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

/// Saves a looked-up book (and fetches its description in the background when the lookup had none).
Future<int> insertMeta(BookMeta m, {required bool locked}) async {
  final id = await db.into(db.books).insert(BooksCompanion.insert(
        title: m.title,
        author: Value(m.author), isbn: Value(m.isbn), coverUrl: Value(m.coverUrl), genre: Value(m.genre),
        publisher: Value(m.publisher), year: Value(m.year), pages: Value(m.pages),
        series: Value(m.series), description: Value(m.description), locked: Value(locked),
      ));
  if (m.description.isEmpty && m.workKey.isNotEmpty) {
    Lookup.description(m.workKey).then((d) {
      if (d.isNotEmpty) (db.update(db.books)..where((b) => b.id.equals(id))).write(BooksCompanion(description: Value(d)));
    });
  }
  return id;
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
