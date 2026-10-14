import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'branding.dart';
import 'covers.dart';
import 'db.dart';
import 'isbn.dart';
import 'log.dart';
import 'lookup.dart';
import 'main.dart';
import 'ui.dart';

/// "Finding books" (0.13.0): refresh a book's details, pick an edition, and suggestions from your own library.

/// Settings > Your library: also search Google Books. Off means Open Library only.
bool googleOn() => prefs.getBool('src_google') ?? true;

/// The first time a locked book's text goes to the internet, say so once (the same wording as adding one).
Future<bool> confirmVaultLookup(BuildContext context) async {
  if (prefs.getBool('vault_lookup_ok') ?? false) return true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Searching uses the internet'),
      content: const Text('This sends the title, author or barcode number to the free book websites Pagemark uses. If you want this book to stay completely on your phone, cancel.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continue')),
      ],
    ),
  );
  if (ok == true) await prefs.setBool('vault_lookup_ok', true);
  return ok == true;
}

// ───────────────────────── Refresh details ─────────────────────────
/// One thing a lookup would change on a book. Details the book lacks ([fill]) are ticked by default; details you already have that
/// differ are listed but start unticked, so a refresh never overwrites your own edits unless you say so.
class FieldChange {
  final String key, label, oldText, newText;
  final bool fill;
  const FieldChange(this.key, this.label, this.oldText, this.newText, this.fill);
}

List<FieldChange> refreshChanges(Book b, BookMeta m) {
  final out = <FieldChange>[];
  void text(String key, String label, String old, String found, {bool skipIf = false}) {
    final n = found.trim();
    if (skipIf || n.isEmpty || n == old.trim()) return;
    out.add(FieldChange(key, label, old.trim(), n, old.trim().isEmpty));
  }

  void number(String key, String label, int? old, int? found) {
    if (found == null || found == old || found <= 0) return;
    out.add(FieldChange(key, label, old == null ? '' : '$old', '$found', old == null));
  }

  text('author', 'Author', b.author, m.author);
  text('isbn', 'ISBN', b.isbn, m.isbn, skipIf: b.isbn.isNotEmpty); // an ISBN you have is never replaced
  text('coverUrl', 'Cover picture', b.coverUrl, m.coverUrl, skipIf: CoverStore.isLocal(b.coverUrl)); // a cover you saved or chose stays
  text('genre', 'Genre', b.genre, m.genre);
  text('publisher', 'Publisher', b.publisher, m.publisher);
  number('year', 'Year', b.year, m.year);
  number('pages', 'Pages', b.pages, m.pages);
  text('description', 'Description', b.description, m.description);
  return out;
}

BooksCompanion changesToCompanion(Iterable<FieldChange> picked) {
  var c = const BooksCompanion();
  for (final f in picked) {
    c = switch (f.key) {
      'author' => c.copyWith(author: Value(f.newText)),
      'isbn' => c.copyWith(isbn: Value(f.newText)),
      'coverUrl' => c.copyWith(coverUrl: Value(f.newText)),
      'genre' => c.copyWith(genre: Value(f.newText)),
      'publisher' => c.copyWith(publisher: Value(f.newText)),
      'year' => c.copyWith(year: Value(int.parse(f.newText))),
      'pages' => c.copyWith(pages: Value(int.parse(f.newText))),
      'description' => c.copyWith(description: Value(f.newText)),
      _ => c,
    };
  }
  return c;
}

/// Looks the book up again and lets you choose what to take. Nothing is changed without a tap on Update.
Future<void> refreshDetails(BuildContext context, Book b) async {
  if (b.locked && !await confirmVaultLookup(context)) return;
  if (!context.mounted) return;
  BookMeta? meta;
  try {
    snack(context, 'Looking it up…');
    final code = Isbn.to13(b.isbn);
    if (code != null) {
      meta = await Lookup.byIsbnAll(code, google: googleOn());
    } else {
      final found = await Lookup.searchAll('${b.title} ${b.author}'.trim(), google: googleOn());
      meta = found.where((m) => !Lookup.isJunk(m)).firstOrNull ?? found.firstOrNull;
    }
  } catch (e) {
    Log.w('refresh', 'lookup failed: $e');
    if (context.mounted) snack(context, e is LookupException ? e.message : 'The lookup failed. Please try again.');
    return;
  }
  if (!context.mounted) return;
  if (meta == null) {
    snack(context, 'Could not find this book online.');
    return;
  }
  var current = meta;
  while (true) {
    final changes = refreshChanges(b, current);
    // the loop only continues after the mounted checks below, which the analyzer cannot see across iterations
    // ignore: use_build_context_synchronously
    final result = await showDialog<Object>(context: context, builder: (_) => _RefreshDialog(changes: changes, canPickEdition: current.workKey.isNotEmpty));
    if (!context.mounted) return;
    if (result == 'edition') {
      final picked = await Navigator.push<BookMeta>(context, MaterialPageRoute(builder: (_) => EditionPicker(base: current)));
      if (picked != null) current = picked;
      if (!context.mounted) return;
      continue;
    }
    if (result is List<FieldChange> && result.isNotEmpty) {
      await (db.update(db.books)..where((x) => x.id.equals(b.id))).write(changesToCompanion(result));
      if (context.mounted) snack(context, 'Updated ${result.length} ${result.length == 1 ? 'detail' : 'details'}.');
    }
    return;
  }
}

class _RefreshDialog extends StatefulWidget {
  final List<FieldChange> changes;
  final bool canPickEdition;
  const _RefreshDialog({required this.changes, required this.canPickEdition});
  @override
  State<_RefreshDialog> createState() => _RefreshDialogState();
}

class _RefreshDialogState extends State<_RefreshDialog> {
  late final Set<String> on = {for (final c in widget.changes) if (c.fill) c.key};

  String _short(String s) => s.length > 90 ? '${s.substring(0, 90)}…' : s;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Refresh details'),
        content: SizedBox(
          width: double.maxFinite,
          child: widget.changes.isEmpty
              ? const Text('Nothing new was found. This book already has these details.')
              : ListView(shrinkWrap: true, children: [
                  const Text('Tick what you want to take. Your own details are left alone unless you tick them.'),
                  for (final c in widget.changes)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: on.contains(c.key),
                      onChanged: (v) => setState(() => v == true ? on.add(c.key) : on.remove(c.key)),
                      title: Text(c.label),
                      subtitle: Text(c.oldText.isEmpty ? _short(c.newText) : 'Now: ${_short(c.oldText)}\nFound: ${_short(c.newText)}'),
                      isThreeLine: c.oldText.isNotEmpty,
                    ),
                ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          if (widget.canPickEdition) TextButton(onPressed: () => Navigator.pop(context, 'edition'), child: const Text('Choose another edition')),
          if (widget.changes.isNotEmpty)
            FilledButton(onPressed: on.isEmpty ? null : () => Navigator.pop(context, [for (final c in widget.changes) if (on.contains(c.key)) c]), child: const Text('Update')),
        ],
      );
}

// ───────────────────────── Edition picker ─────────────────────────
/// The editions Open Library lists for a book. Picking one returns the book's details with that edition's cover, publisher, year,
/// pages and ISBN.
class EditionPicker extends StatelessWidget {
  final BookMeta base;
  const EditionPicker({super.key, required this.base});

  static BookMeta applyEdition(BookMeta base, BookMeta e) => BookMeta(
        title: base.title,
        author: base.author,
        genre: base.genre,
        description: base.description,
        series: base.series,
        workKey: base.workKey,
        isbn: e.isbn.isNotEmpty ? e.isbn : base.isbn,
        coverUrl: e.coverUrl.isNotEmpty ? e.coverUrl : base.coverUrl,
        publisher: e.publisher.isNotEmpty ? e.publisher : base.publisher,
        year: e.year ?? base.year,
        pages: e.pages ?? base.pages,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Choose an edition')),
        body: FutureBuilder<List<BookMeta>>(
          future: Lookup.editions(base.workKey),
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return const EmptyState(message: 'Could not load the editions. Check your internet and try again.');
            final list = snap.data ?? [];
            if (list.isEmpty) return const EmptyState(message: 'No other editions were listed for this book.');
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final e = list[i];
                final sub = [if (e.year != null) '${e.year}', if (e.pages != null) '${e.pages} pages', if (e.isbn.isNotEmpty) 'ISBN ${e.isbn}'].join(' · ');
                return ListTile(
                  leading: SizedBox(width: 44, child: Cover(e.coverUrl, w: 44, title: e.title)),
                  title: Text(e.publisher.isEmpty ? 'Publisher not listed' : e.publisher),
                  subtitle: sub.isEmpty ? null : Text(sub),
                  onTap: () => Navigator.pop(context, applyEdition(base, e)),
                );
              },
            );
          },
        ),
      );
}

// ───────────────────────── Suggestions ─────────────────────────
/// A book from your want-to-read list and why it came up. Worked out on the phone from your own library only.
class Suggestion {
  final BookRow row;
  final String reason;
  final int score;
  const Suggestion(this.row, this.reason, this.score);
}

String _norm(String s) => s.trim().toLowerCase();
String _first(String s) => _norm(s.split(',').first);

/// Next in a series you have started (5), more from an author whose book you rated 4 or more (3), a genre you rate highly (1).
/// Only wanted books are suggested; ties keep your own order. Nothing here leaves the phone.
List<Suggestion> suggestNext(Iterable<BookRow> rows, {int limit = 5}) {
  final started = <String>{}, lovedAuthors = <String, String>{}, lovedGenres = <String, int>{};
  for (final r in rows) {
    final finished = r.reads.where((x) => x.status == 'finished').toList();
    if (finished.isEmpty) continue;
    if (r.book.series.trim().isNotEmpty) started.add(_norm(r.book.series));
    final avg = r.avgRating;
    if (avg != null && avg >= 4) {
      final a = _first(r.book.author);
      if (a.isNotEmpty) lovedAuthors.putIfAbsent(a, () => r.book.author.split(',').first.trim());
      final g = _first(r.book.genre);
      if (g.isNotEmpty) lovedGenres[g] = (lovedGenres[g] ?? 0) + 1;
    }
  }
  final out = <Suggestion>[];
  final want = rows.where((r) => r.status == 'want').toList();
  for (final r in want) {
    final s = _norm(r.book.series), a = _first(r.book.author), g = _first(r.book.genre);
    if (s.isNotEmpty && started.contains(s)) {
      out.add(Suggestion(r, 'Next in ${r.book.series.trim()}', 5));
    } else if (a.isNotEmpty && lovedAuthors.containsKey(a)) {
      out.add(Suggestion(r, 'More from ${lovedAuthors[a]}, whose book you rated highly', 3));
    } else if (g.isNotEmpty && lovedGenres.containsKey(g)) {
      out.add(Suggestion(r, 'You rate ${r.book.genre.split(',').first.trim()} books highly', 1));
    }
  }
  final order = {for (var i = 0; i < want.length; i++) want[i].book.id: i};
  out.sort((x, y) => y.score != x.score ? y.score.compareTo(x.score) : order[x.row.book.id]!.compareTo(order[y.row.book.id]!));
  return out.take(limit).toList();
}
