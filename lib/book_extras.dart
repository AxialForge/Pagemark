import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'covers.dart';
import 'db.dart';
import 'features.dart';
import 'log.dart';
import 'main.dart';
import 'text_utils.dart';
import 'ui.dart';

// ───────────────────────── Quotes ─────────────────────────

String quoteShareText(Book b, Quote q) =>
    '“${q.body}”\n— ${[if (b.author.isNotEmpty) b.author, b.title, if (q.page != null) 'p. ${q.page}'].join(', ')}';

/// The "Quotes" section of a book page.
class QuotesSection extends StatelessWidget {
  final Book book;
  const QuotesSection({super.key, required this.book});

  Future<void> _edit(BuildContext context, [Quote? q]) async {
    final r = await showModalBottomSheet<(String, int?, String)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => _QuoteEditor(quote: q),
    );
    if (r == null) return;
    if (q == null) {
      await db.addQuote(book.id, r.$1, page: r.$2, note: r.$3);
    } else {
      await db.updateQuote(q.id, r.$1, page: r.$2, note: r.$3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<Quote>>(
      stream: db.watchQuotes(book.id),
      builder: (_, snap) {
        final list = snap.data ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Quotes', style: Theme.of(context).textTheme.titleMedium)),
            TextButton.icon(onPressed: () => _edit(context), icon: const Icon(Icons.format_quote), label: const Text('Add quote')),
          ]),
          if (list.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Save a line you loved, with its page.')),
          for (final q in list)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _edit(context, q),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Container(width: 3, decoration: BoxDecoration(color: cs.tertiary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(q.body, style: const TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic, fontSize: 15.5, height: 1.4)),
                          if (q.page != null || q.note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text([if (q.page != null) 'p. ${q.page}', if (q.note.isNotEmpty) q.note].join(' · '), style: Theme.of(context).textTheme.bodySmall),
                            ),
                        ]),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Quote actions',
                        onSelected: (v) async {
                          if (v == 'copy') {
                            await Clipboard.setData(ClipboardData(text: quoteShareText(book, q)));
                            if (context.mounted) snack(context, 'Quote copied');
                          } else if (v == 'share') {
                            await SharePlus.instance.share(ShareParams(text: quoteShareText(book, q)));
                          } else if (v == 'edit') {
                            await _edit(context, q);
                          } else if (v == 'del') {
                            await db.deleteQuote(q.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(SnackBar(content: const Text('Quote deleted'), duration: const Duration(seconds: 8), action: SnackBarAction(label: 'Undo', onPressed: () => db.restoreQuote(q))));
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'copy', child: Text('Copy')),
                          PopupMenuItem(value: 'share', child: Text('Share')),
                          PopupMenuItem(value: 'del', child: Text('Delete')),
                        ],
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }
}

class _QuoteEditor extends StatefulWidget {
  final Quote? quote;
  const _QuoteEditor({this.quote});
  @override
  State<_QuoteEditor> createState() => _QuoteEditorState();
}

class _QuoteEditorState extends State<_QuoteEditor> {
  late final text = TextEditingController(text: widget.quote?.body);
  late final page = TextEditingController(text: '${widget.quote?.page ?? ''}');
  late final note = TextEditingController(text: widget.quote?.note);

  @override
  void dispose() {
    text.dispose();
    page.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.quote == null ? 'New quote' : 'Edit quote', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: text, autofocus: true, minLines: 3, maxLines: 8, textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'The passage', alignLabelWithHint: true, border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(children: [
              SizedBox(
                width: 110,
                child: TextField(controller: page, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Page', border: OutlineInputBorder())),
              ),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: note, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Why it stuck (optional)', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  if (text.text.trim().isEmpty) {
                    snack(context, 'Type the passage first');
                    return;
                  }
                  Navigator.pop(context, (text.text.trim(), int.tryParse(page.text), note.text.trim()));
                },
                child: const Text('Save'),
              ),
            ),
          ]),
        ),
      );
}

// ───────────────────────── Covers on the phone ─────────────────────────

/// Menu actions for a book's cover. Returns a short message to show, or null.
Future<String?> coverAction(Book b, String action) async {
  switch (action) {
    case 'save':
      if (b.coverUrl.isEmpty || CoverStore.isLocal(b.coverUrl)) return 'This cover is already saved on your phone.';
      final saved = await CoverStore.saveFromUrl(b.id, b.coverUrl);
      if (saved == null) return 'Could not download this cover. Check your connection, or choose a picture from your gallery.';
      await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(BooksCompanion(coverUrl: Value(saved)));
      return 'Cover saved on your phone. It now works offline and is included in backups.';
    case 'pick':
      try {
        final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 900, maxHeight: 1350, imageQuality: 85);
        if (x == null) return null;
        final saved = await CoverStore.saveFile(b.id, File(x.path));
        await CoverStore.delete(b.coverUrl); // replace the old saved picture, if there was one
        await (db.update(db.books)..where((y) => y.id.equals(b.id))).write(BooksCompanion(coverUrl: Value(saved)));
        return 'Cover updated.';
      } catch (e) {
        Log.w('covers', 'gallery pick failed: $e');
        return 'Could not use that picture.';
      }
    case 'remove':
      if (!CoverStore.isLocal(b.coverUrl)) return null;
      await CoverStore.delete(b.coverUrl);
      await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(BooksCompanion(coverUrl: Value(CoverStore.webFallback(b.isbn))));
      return 'Saved cover removed.';
  }
  return null;
}

/// Settings -> Covers: see what is saved on the phone and save everything for offline use.
class CoversPage extends StatefulWidget {
  const CoversPage({super.key});
  @override
  State<CoversPage> createState() => _CoversPageState();
}

class _CoversPageState extends State<CoversPage> {
  int online = 0, local = 0, bytes = 0, doneCount = 0, failed = 0;
  bool running = false, cancel = false;
  int total = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final books = await (db.select(db.books)..where((b) => b.deletedAt.isNull())).get();
    final files = await CoverStore.allFiles();
    if (!mounted) return;
    setState(() {
      online = books.where((b) => b.coverUrl.startsWith('http')).length;
      local = books.where((b) => CoverStore.isLocal(b.coverUrl)).length;
      bytes = files.fold(0, (a, f) => a + f.lengthSync());
    });
  }

  Future<void> _saveAll() async {
    final books = (await (db.select(db.books)..where((b) => b.deletedAt.isNull())).get()).where((b) => b.coverUrl.startsWith('http')).toList();
    setState(() { running = true; cancel = false; total = books.length; doneCount = 0; failed = 0; });
    for (final b in books) {
      if (cancel || !mounted) break;
      final saved = await CoverStore.saveFromUrl(b.id, b.coverUrl);
      if (saved != null) {
        await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(BooksCompanion(coverUrl: Value(saved)));
      } else {
        failed++;
      }
      if (mounted) setState(() => doneCount++);
    }
    if (mounted) setState(() => running = false);
    await _refresh();
  }

  Future<void> _tidy() async {
    final all = await db.select(db.books).get(); // includes Trash: a trashed book may still be restored
    final n = await CoverStore.removeUnused({for (final b in all) b.coverUrl});
    if (mounted) snack(context, n == 0 ? 'Nothing to tidy.' : 'Removed $n unused cover files.');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Covers')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Covers normally load from Open Library each time. Saving them on your phone makes your library look right offline, and '
              'backups include them so a restore brings them back.'),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              ListTile(title: const Text('Saved on this phone'), trailing: Text('$local · ${humanBytes(bytes)}', style: Theme.of(context).textTheme.titleMedium)),
              ListTile(title: const Text('Still loaded from the internet'), trailing: Text('$online', style: Theme.of(context).textTheme.titleMedium)),
            ]),
          ),
          const SizedBox(height: 12),
          if (running) ...[
            LinearProgressIndicator(value: total == 0 ? null : doneCount / total),
            const SizedBox(height: 6),
            Text('Saving $doneCount of $total${failed > 0 ? ' ($failed could not be downloaded)' : ''}…'),
            TextButton(onPressed: () => setState(() => cancel = true), child: const Text('Stop')),
          ] else ...[
            FilledButton.icon(onPressed: online == 0 ? null : _saveAll, icon: const Icon(Icons.download_for_offline_outlined), label: Text(online == 0 ? 'All covers are saved' : 'Save $online covers on this phone')),
            if (failed > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text('$failed covers could not be downloaded last time (no picture exists for them). Set one from the book page.')),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: _tidy, icon: const Icon(Icons.cleaning_services_outlined), label: const Text('Remove unused cover files')),
          ],
          const SizedBox(height: 16),
          const Text('Covers of locked books are saved here too. They stay on the phone (they are not erased when the vault closes) and are included '
              'in backups, so protect backups with a passphrase.', style: TextStyle(fontSize: 12)),
        ]),
      );
}

// ───────────────────────── Authors ─────────────────────────

List<String> authorsOf(String author) => [for (final a in author.split(RegExp(r'[,;&]|\band\b')).map((s) => s.trim())) if (a.isNotEmpty) a];

bool bookBy(Book b, String author) => authorsOf(b.author).any((a) => a.toLowerCase() == author.toLowerCase());

class AuthorLinks extends StatelessWidget {
  final Book book;
  const AuthorLinks(this.book, {super.key});
  @override
  Widget build(BuildContext context) {
    final names = authorsOf(book.author);
    if (names.isEmpty) return const SizedBox.shrink();
    final color = Theme.of(context).colorScheme.primary;
    return Wrap(spacing: 4, children: [
      for (var i = 0; i < names.length; i++)
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AuthorPage(author: names[i], locked: book.locked))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('${names[i]}${i < names.length - 1 ? ',' : ''}', style: TextStyle(color: color, decoration: TextDecoration.underline, decorationColor: color)),
          ),
        ),
    ]);
  }
}

/// Everything by one author in the current library (the vault's authors are only listed inside the vault).
class AuthorPage extends StatelessWidget {
  final String author;
  final bool locked;
  const AuthorPage({super.key, required this.author, required this.locked});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(author, overflow: TextOverflow.ellipsis)),
        body: StreamBuilder<List<BookRow>>(
          stream: db.watchLibrary(locked: locked),
          builder: (_, snap) {
            final rows = (snap.data ?? []).where((r) => bookBy(r.book, author)).toList()
              ..sort((a, b) => a.book.title.toLowerCase().compareTo(b.book.title.toLowerCase()));
            if (snap.hasData && rows.isEmpty) return const Center(child: Text('No books by this author in your library.'));
            final finished = rows.where((r) => r.reads.any((e) => e.status == 'finished')).length;
            final ratings = [for (final r in rows) if (r.avgRating != null) r.avgRating!];
            final avg = ratings.isEmpty ? null : ratings.reduce((a, b) => a + b) / ratings.length;
            return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(child: _stat(context, '${rows.length}', rows.length == 1 ? 'book' : 'books')),
                  Expanded(child: _stat(context, '$finished', 'read')),
                  Expanded(child: _stat(context, avg == null ? '-' : avg.toStringAsFixed(1), 'avg rating')),
                ]),
              ),
              for (final r in rows) BookTile(row: r),
            ]);
          },
        ),
      );

  Widget _stat(BuildContext context, String v, String label) => Column(children: [
        Text(v, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ]);
}

// ───────────────────────── Heat / content notes (opt-in) ─────────────────────────

/// Five flames. Tap one to set the level; tap the same one again to clear.
class HeatRating extends StatelessWidget {
  final int value; // 0 = unset
  final ValueChanged<int> onChanged;
  const HeatRating({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Semantics(
      label: 'Heat level ${value == 0 ? 'not set' : value} of 5',
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: 'Heat $i',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              HapticFeedback.selectionClick();
              onChanged(i == value ? 0 : i);
            },
            icon: Icon(i <= value ? Icons.local_fire_department : Icons.local_fire_department_outlined, color: i <= value ? color : null),
          ),
      ]),
    );
  }
}

String heatText(int h) => '🔥' * h;

/// Whether the private heat / content-notes fields are switched on (Settings -> Privacy).
bool adultFieldsOn() => prefs.getBool('adult_fields') ?? false;

/// The Stats card for heat, drawn only when the field is on.
Widget heatStatsCard(BuildContext context, List<Read> done) {
  final rated = done.where((r) => r.heat != null && r.heat! > 0).toList();
  if (rated.isEmpty) return const SizedBox.shrink();
  final hist = List<double>.filled(5, 0);
  for (final r in rated) {
    hist[r.heat!.clamp(1, 5) - 1] += 1;
  }
  final avg = rated.fold<int>(0, (a, r) => a + r.heat!) / rated.length;
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Heat', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        BarChart(values: hist, labels: const ['1', '2', '3', '4', '5'], height: 80),
        Text('Average ${avg.toStringAsFixed(1)} across ${rated.length} finished books', style: Theme.of(context).textTheme.bodySmall),
      ]),
    ),
  );
}
