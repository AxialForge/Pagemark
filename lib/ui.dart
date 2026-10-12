import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'backup_page.dart';
import 'db.dart';
import 'export.dart';
import 'lock.dart';
import 'lookup.dart';
import 'main.dart';
import 'themes.dart';

const formats = {'print': 'Print', 'ebook': 'E-book', 'audio': 'Audiobook'};
const statuses = {'want': 'Want to read', 'reading': 'Reading', 'finished': 'Finished', 'dnf': 'Did not finish'};
final _date = DateFormat.yMMMd();

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

// ───────────────────────── Home ─────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  bool unlocked = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Library(locked: false),
      unlocked ? Library(locked: true) : LockGate(onUnlock: () => setState(() => unlocked = true)),
      Stats(),
      SettingsPage(onLockNow: () => setState(() { unlocked = false; tab = 0; })),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
        ),
        child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() {
          if (i != 1 && tab == 1) unlocked = false; // re-lock when leaving the locked tab
          tab = i;
        }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.lock_outline), label: 'Locked'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

// ───────────────────────── Library ─────────────────────────
class Library extends StatefulWidget {
  final bool locked;
  const Library({super.key, required this.locked});
  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  String q = '', status = 'all', format = 'all', sort = 'added';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.locked ? 'Locked library' : 'Library'), actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          onSelected: (v) => setState(() => sort = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'added', child: Text('Recently added')),
            PopupMenuItem(value: 'title', child: Text('Title')),
            PopupMenuItem(value: 'author', child: Text('Author')),
            PopupMenuItem(value: 'rating', child: Text('Rating')),
          ],
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add), label: const Text('Add book'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddBook(locked: widget.locked))),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search title, author, tag, genre', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => q = v.toLowerCase()),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), children: [
            for (final e in {'all': 'All', ...statuses}.entries)
              Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(e.value), selected: status == e.key, onSelected: (_) => setState(() => status = e.key))),
            const VerticalDivider(),
            for (final e in {'all': 'Any format', ...formats}.entries)
              Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(e.value), selected: format == e.key, onSelected: (_) => setState(() => format = e.key))),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<BookRow>>(
            stream: db.watchLibrary(locked: widget.locked),
            builder: (_, snap) {
              var rows = (snap.data ?? []).where((r) {
                final b = r.book;
                if (q.isNotEmpty && !'${b.title} ${b.author} ${b.tags} ${b.genre} ${b.series}'.toLowerCase().contains(q)) return false;
                if (status != 'all' && !r.reads.any((e) => e.status == status)) return false;
                if (format != 'all' && !r.reads.any((e) => e.format == format)) return false;
                return true;
              }).toList();
              rows.sort((a, b) {
                switch (sort) {
                  case 'title': return a.book.title.toLowerCase().compareTo(b.book.title.toLowerCase());
                  case 'author': return a.book.author.toLowerCase().compareTo(b.book.author.toLowerCase());
                  case 'rating': return (b.avgRating ?? -1).compareTo(a.avgRating ?? -1);
                  default: return b.book.added.compareTo(a.book.added);
                }
              });
              if (rows.isEmpty) return Center(child: Text(snap.data?.isEmpty ?? true ? 'No books yet — tap Add book.' : 'No matches.'));
              return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, i) => TweenAnimationBuilder<double>(
                  key: ValueKey(rows[i].book.id),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 280 + (i < 8 ? i * 40 : 320)),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child)),
                  child: BookTile(row: rows[i]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class Cover extends StatelessWidget {
  final String url;
  final double w;
  final Object? tag; // shared-element (Hero) tag between list and detail
  const Cover(this.url, {super.key, this.w = 48, this.tag});
  @override
  Widget build(BuildContext context) {
    final ph = Container(width: w, height: w * 1.5, color: Theme.of(context).colorScheme.secondaryContainer, child: const Icon(Icons.book));
    final img = url.isEmpty
        ? ph
        : ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(imageUrl: url, width: w, height: w * 1.5, fit: BoxFit.cover,
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
    return ListTile(
      leading: Cover(b.coverUrl, tag: 'cover-${b.id}'),
      title: Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text([b.author, if (row.reads.isNotEmpty) statuses[row.status], if (fmts.isNotEmpty) fmts].where((s) => s != null && s.isNotEmpty).join('\n')),
      isThreeLine: true,
      trailing: r == null ? null : Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 18, color: Colors.amber), Text(r.toStringAsFixed(1))]),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: b.id))),
    );
  }
}

// ───────────────────────── Add / edit ─────────────────────────
class AddBook extends StatefulWidget {
  final bool locked;
  const AddBook({super.key, required this.locked});
  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final qc = TextEditingController();
  List<BookMeta> results = [];
  bool busy = false;

  Future<void> run(Future<List<BookMeta>> Function() f) async {
    setState(() => busy = true);
    try {
      results = await f();
    } catch (e) {
      if (mounted) snack(context, 'Lookup failed (offline?) — add manually below.');
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> scan() async {
    final code = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const ScanPage()));
    if (code == null) return;
    qc.text = code;
    await run(() async => [if (await Lookup.byIsbn(code) case final m?) m]);
  }

  Future<void> save(BookMeta m) async {
    final id = await db.into(db.books).insert(BooksCompanion.insert(
          title: m.title,
          author: Value(m.author), isbn: Value(m.isbn), coverUrl: Value(m.coverUrl), genre: Value(m.genre),
          publisher: Value(m.publisher), year: Value(m.year), pages: Value(m.pages),
          series: Value(m.series), description: Value(m.description), locked: Value(widget.locked),
        ));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookPage(bookId: id)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add a book'), actions: [IconButton(icon: const Icon(Icons.qr_code_scanner), tooltip: 'Scan ISBN', onPressed: scan)]),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: qc,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Open Library (title, author, ISBN)', border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => run(() => Lookup.search(qc.text))),
              ),
              onSubmitted: (v) => run(() => Lookup.search(v)),
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: ListView(children: [
              for (final m in results)
                ListTile(
                  leading: Cover(m.coverUrl), title: Text(m.title),
                  subtitle: Text('${m.author}${m.year != null ? ' · ${m.year}' : ''}'),
                  onTap: () => save(m),
                ),
              ListTile(
                leading: const Icon(Icons.edit_note), title: const Text('Add manually'),
                subtitle: const Text('Not found? Enter the details yourself.'),
                onTap: () async {
                  final t = await ask(context, 'Title', qc.text);
                  if (t != null && t.trim().isNotEmpty) await save(BookMeta(title: t.trim()));
                },
              ),
            ]),
          ),
        ]),
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

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Scan barcode')),
        body: MobileScanner(onDetect: (cap) {
          final v = cap.barcodes.firstOrNull?.rawValue;
          if (v != null) Navigator.pop(context, v);
        }),
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
        if (b == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return Scaffold(
          appBar: AppBar(title: Text(b.title, overflow: TextOverflow.ellipsis), actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditBook(book: b)))),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'lock') await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(BooksCompanion(locked: Value(!b.locked)));
                if (v == 'del') {
                  final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
                    title: const Text('Delete this book?'), content: const Text('Its reading log and thoughts are deleted too.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
                  if (ok == true) {
                    await (db.delete(db.books)..where((x) => x.id.equals(b.id))).go();
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'lock', child: Text(b.locked ? 'Move to main library' : 'Move to locked library')),
                const PopupMenuItem(value: 'del', child: Text('Delete')),
              ],
            ),
          ]),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add), label: const Text('Log a read'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReadEditor(bookId: b.id))),
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Cover(b.coverUrl, w: 100, tag: 'cover-${b.id}'),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: Theme.of(context).textTheme.titleLarge),
                if (b.author.isNotEmpty) Text(b.author),
                if (b.series.isNotEmpty) Text('Series: ${b.series}'),
                if (b.genre.isNotEmpty) Text(b.genre),
                Text([if (b.year != null) '${b.year}', if (b.pages != null) '${b.pages} pages', if (b.publisher.isNotEmpty) b.publisher].join(' · ')),
                if (b.isbn.isNotEmpty) Text('ISBN ${b.isbn}'),
                if (b.tags.isNotEmpty) Wrap(spacing: 4, children: [for (final t in b.tags.split(',').where((t) => t.trim().isNotEmpty)) Chip(label: Text(t.trim()))]),
              ])),
            ]),
            if (b.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(b.description)),
            if (b.notes.isNotEmpty) Card(margin: const EdgeInsets.only(top: 12), child: Padding(padding: const EdgeInsets.all(12), child: Text(b.notes))),
            const Divider(height: 32),
            Text('Reading log', style: Theme.of(context).textTheme.titleMedium),
            StreamBuilder<List<Read>>(
              stream: db.watchReads(b.id),
              builder: (_, rs) {
                final list = rs.data ?? [];
                if (list.isEmpty) return const Padding(padding: EdgeInsets.all(8), child: Text('Nothing logged yet.'));
                return Column(children: [
                  for (final r in list)
                    Card(child: ListTile(
                      leading: Icon(r.format == 'audio' ? Icons.headphones : r.format == 'ebook' ? Icons.tablet_android : Icons.menu_book),
                      title: Text('${formats[r.format]} · ${statuses[r.status]}'),
                      subtitle: Text([
                        if (r.started != null) 'Started ${_date.format(r.started!)}',
                        if (r.finished != null) 'Finished ${_date.format(r.finished!)}',
                        if (r.narrator.isNotEmpty) 'Narrator: ${r.narrator}',
                        if (r.thoughts.isNotEmpty) r.thoughts,
                      ].join('\n')),
                      isThreeLine: true,
                      trailing: r.rating == null ? null : Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.amber), Text('${r.rating}')]),
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
      'title': widget.book.title, 'author': widget.book.author, 'series': widget.book.series, 'genre': widget.book.genre,
      'tags': widget.book.tags, 'publisher': widget.book.publisher, 'isbn': widget.book.isbn, 'coverUrl': widget.book.coverUrl,
      'year': '${widget.book.year ?? ''}', 'pages': '${widget.book.pages ?? ''}', 'description': widget.book.description, 'notes': widget.book.notes,
    }.entries) e.key: TextEditingController(text: e.value)
  };

  Widget f(String k, String label, {int lines = 1, bool num = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: c[k], maxLines: lines, keyboardType: num ? TextInputType.number : null, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit book'), actions: [
          TextButton(onPressed: () async {
            await (db.update(db.books)..where((x) => x.id.equals(widget.book.id))).write(BooksCompanion(
              title: Value(c['title']!.text), author: Value(c['author']!.text), series: Value(c['series']!.text), genre: Value(c['genre']!.text),
              tags: Value(c['tags']!.text), publisher: Value(c['publisher']!.text), isbn: Value(c['isbn']!.text), coverUrl: Value(c['coverUrl']!.text),
              year: Value(int.tryParse(c['year']!.text)), pages: Value(int.tryParse(c['pages']!.text)),
              description: Value(c['description']!.text), notes: Value(c['notes']!.text),
            ));
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          f('title', 'Title'), f('author', 'Author'), f('series', 'Series'), f('genre', 'Genre (fantasy, romance, science…)'),
          f('tags', 'Tags (comma separated)'), f('publisher', 'Publisher'), f('isbn', 'ISBN'), f('coverUrl', 'Cover image URL'),
          f('year', 'Year', num: true), f('pages', 'Pages', num: true), f('description', 'Description', lines: 4), f('notes', 'Private notes', lines: 4),
        ]),
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

  Future<DateTime?> pick(DateTime? init) =>
      showDatePicker(context: context, initialDate: init ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.read == null ? 'Log a read' : 'Edit read'), actions: [
          if (widget.read != null) IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
            await (db.delete(db.reads)..where((r) => r.id.equals(widget.read!.id))).go();
            if (context.mounted) Navigator.pop(context);
          }),
          TextButton(onPressed: () async {
            final fin = status == 'finished' ? (finished ?? DateTime.now()) : finished;
            final comp = ReadsCompanion(
              bookId: Value(widget.bookId), format: Value(format), status: Value(status), started: Value(started), finished: Value(fin),
              rating: Value(rating == 0 ? null : rating), thoughts: Value(thoughts.text), narrator: Value(narrator.text), minutes: Value(int.tryParse(minutes.text)),
            );
            if (widget.read == null) {
              await db.into(db.reads).insert(comp);
            } else {
              await (db.update(db.reads)..where((r) => r.id.equals(widget.read!.id))).write(comp);
            }
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          SegmentedButton<String>(
            segments: [for (final e in formats.entries) ButtonSegment(value: e.key, label: Text(e.value))],
            selected: {format}, onSelectionChanged: (s) => setState(() => format = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: [for (final e in statuses.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => status = v!),
          ),
          ListTile(title: const Text('Started'), subtitle: Text(started == null ? '—' : _date.format(started!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(started); if (d != null) setState(() => started = d); }),
          ListTile(title: const Text('Finished'), subtitle: Text(finished == null ? '—' : _date.format(finished!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(finished); if (d != null) setState(() => finished = d); }),
          const Text('Rating'),
          Row(children: [
            Expanded(child: Slider(value: rating, min: 0, max: 5, divisions: 10, label: rating == 0 ? 'unrated' : '$rating', onChanged: (v) => setState(() => rating = v))),
            Text(rating == 0 ? '—' : '$rating ★'),
          ]),
          if (format == 'audio') ...[
            TextField(controller: narrator, decoration: const InputDecoration(labelText: 'Narrator', border: OutlineInputBorder())),
            const SizedBox(height: 12),
          ],
          TextField(controller: minutes, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: format == 'audio' ? 'Listening time (minutes)' : 'Time spent (minutes)', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: thoughts, minLines: 5, maxLines: 14, decoration: const InputDecoration(labelText: 'Your thoughts', alignLabelWithHint: true, border: OutlineInputBorder())),
        ]),
      );
}

// ───────────────────────── Stats ─────────────────────────
class Stats extends StatelessWidget {
  const Stats({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Stats')),
        body: FutureBuilder(
          future: Future.wait([db.select(db.books).get(), db.select(db.reads).get()]),
          builder: (_, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final books = s.data![0] as List<Book>;
            final reads = (s.data![1] as List<Read>);
            final done = reads.where((r) => r.status == 'finished').toList();
            final yr = DateTime.now().year;
            final thisYear = done.where((r) => r.finished?.year == yr).length;
            final rated = reads.where((r) => r.rating != null).map((r) => r.rating!).toList();
            final byFmt = <String, int>{};
            for (final r in done) { byFmt[r.format] = (byFmt[r.format] ?? 0) + 1; }
            final mins = done.fold<int>(0, (a, r) => a + (r.minutes ?? 0));
            Widget t(String k, String v) {
              final n = int.tryParse(v); // integer stats count up
              final style = Theme.of(context).textTheme.titleLarge;
              return Card(
                child: ListTile(
                  title: Text(k),
                  trailing: n == null
                      ? Text(v, style: style)
                      : TweenAnimationBuilder<int>(tween: IntTween(begin: 0, end: n), duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic, builder: (_, x, _) => Text('$x', style: style)),
                ),
              );
            }
            return ListView(padding: const EdgeInsets.all(12), children: [
              t('Books tracked', '${books.length}'),
              t('Finished', '${done.length}'),
              t('Finished in $yr', '$thisYear'),
              t('Average rating', rated.isEmpty ? '—' : (rated.reduce((a, b) => a + b) / rated.length).toStringAsFixed(2)),
              for (final e in byFmt.entries) t('Finished · ${formats[e.key]}', '${e.value}'),
              if (mins > 0) t('Logged time', '${(mins / 60).toStringAsFixed(1)} h'),
            ]);
          },
        ),
      );
}

// ───────────────────────── Lock gate ─────────────────────────
class LockGate extends StatefulWidget {
  final VoidCallback onUnlock;
  const LockGate({super.key, required this.onUnlock});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  final pin = TextEditingController();
  bool? hasPin;
  String? err;

  @override
  void initState() {
    super.initState();
    LockService.hasPin().then((v) { if (mounted) setState(() => hasPin = v); });
  }

  Future<void> tryPin() async {
    if (await LockService.checkPin(pin.text)) {
      widget.onUnlock();
    } else {
      setState(() => err = 'Wrong PIN');
      pin.clear();
    }
  }

  Future<void> device() async {
    if (await LockService.deviceAuth()) widget.onUnlock();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Locked library')),
        body: hasPin == null
            ? const SizedBox()
            : Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock, size: 64),
                const SizedBox(height: 16),
                if (hasPin!) ...[
                  TextField(controller: pin, obscureText: true, keyboardType: TextInputType.number, textAlign: TextAlign.center, onSubmitted: (_) => tryPin(),
                      decoration: InputDecoration(labelText: 'PIN', errorText: err, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: tryPin, child: const Text('Unlock')),
                  TextButton.icon(onPressed: device, icon: const Icon(Icons.fingerprint), label: const Text('Use fingerprint / device lock')),
                ] else ...[
                  const Text('Choose how to protect this library.', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () async {
                    final p = await ask(context, 'New PIN (4+ digits)', '', false, true, TextInputType.number);
                    if (p != null && p.length >= 4) { await LockService.setPin(p); widget.onUnlock(); }
                  }, child: const Text('Set a PIN')),
                  TextButton.icon(onPressed: device, icon: const Icon(Icons.fingerprint), label: const Text('Use device lock only')),
                ],
              ]))),
      );
}

// ───────────────────────── Settings ─────────────────────────
class SettingsPage extends StatelessWidget {
  final VoidCallback onLockNow;
  const SettingsPage({super.key, required this.onLockNow});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(children: [
          const ListTile(title: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold))),
          ValueListenableBuilder<String>(
            valueListenable: themeId,
            builder: (_, id, __) => Column(children: [
              for (final t in themes)
                ListTile(
                  leading: CircleAvatar(backgroundColor: t.seed, radius: 12),
                  title: Text(t.name),
                  trailing: id == t.id ? const Icon(Icons.check) : null,
                  onTap: () => themeId.value = t.id,
                ),
            ]),
          ),
          const Divider(),
          const ListTile(title: Text('Export (main library only)', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.table_chart), title: const Text('Library log as CSV'), onTap: () => Exporter.shareCsv(db)),
          ListTile(leading: const Icon(Icons.data_object), title: const Text('Library log as JSON'), onTap: () => Exporter.shareJson(db)),
          const Divider(),
          ListTile(leading: const Icon(Icons.cloud_sync), title: const Text('Google Drive backup'), subtitle: const Text('Scheduled automatic backups'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupPage()))),
          const Divider(),
          const ListTile(title: Text('Database (includes locked books)', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.storage), title: const Text('Export database file'), subtitle: const Text('Import on another device'), onTap: () => Exporter.shareDb(db)),
          ListTile(leading: const Icon(Icons.restore), title: const Text('Restore from database file'), onTap: () async {
            final r = await FilePicker.pickFile();
            final path = r?.path;
            if (path == null || !context.mounted) return;
            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
              title: const Text('Replace everything?'), content: const Text('This replaces your current library with the backup. The app will close.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore'))]));
            if (ok == true) {
              await Exporter.restoreDb(db, File(path));
              exit(0);
            }
          }),
          const Divider(),
          const ListTile(title: Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(leading: const Icon(Icons.lock_clock), title: const Text('Lock now'), onTap: onLockNow),
          ListTile(leading: const Icon(Icons.pin), title: const Text('Change PIN'), onTap: () async {
            final p = await ask(context, 'New PIN (4+ digits)', '', false, true, TextInputType.number);
            if (p != null && p.length >= 4) { await LockService.setPin(p); if (context.mounted) snack(context, 'PIN updated'); }
          }),
          ListTile(leading: const Icon(Icons.no_encryption), title: const Text('Remove PIN'), onTap: () async { await LockService.clearPin(); if (context.mounted) snack(context, 'PIN removed'); }),
          const ListTile(title: Text('Pagemark 0.1.0 · all data stays on this device'), dense: true),
        ]),
      );
}
