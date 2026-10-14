part of '../ui.dart';

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
            IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit book', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditBook(book: b)))),
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
