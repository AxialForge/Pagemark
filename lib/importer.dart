import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'db.dart';
import 'isbn.dart';
import 'text_utils.dart';

/// One read-through found in a file.
class ImportRead {
  String format; // print | ebook | audio
  String status; // want | reading | finished | dnf
  DateTime? started, finished;
  double? rating;
  String thoughts, narrator;
  int? minutes, heat;
  String contentNotes;
  ImportRead({this.heat, this.contentNotes = '', this.format = 'print', this.status = 'want', this.started, this.finished, this.rating, this.thoughts = '', this.narrator = '', this.minutes});
}

/// One book (with its reads and shelves) found in a file.
class ImportQuote {
  String text, note;
  int? page;
  DateTime? created;
  ImportQuote(this.text, {this.page, this.note = '', this.created});
}

class ImportBook {
  final List<ImportQuote> quotes = [];
  int? seriesTotal;
  String title, author, isbn, genre, series, publisher, tags, notes, coverUrl, description = '';
  double? seriesNumber;
  int? year, pages;
  final List<ImportRead> reads = [];
  final Set<String> shelves = {};
  ImportBook({required this.title, this.author = '', this.isbn = '', this.genre = '', this.series = '', this.seriesNumber, this.publisher = '', this.year, this.pages, this.tags = '', this.notes = '', this.coverUrl = ''});

  String get key => isbn.isNotEmpty ? 'isbn:$isbn' : 'ta:${title.trim().toLowerCase()}|${author.trim().toLowerCase()}';
}

enum ImportSource {
  pagemarkCsv('Pagemark CSV export'),
  pagemarkJson('Pagemark JSON export'),
  goodreads('Goodreads export'),
  storygraph('StoryGraph export');

  final String label;
  const ImportSource(this.label);
}

class ImportParse {
  final ImportSource source;
  final List<ImportBook> books;
  final List<String> skipped; // human-readable reasons for rows that could not be imported
  ImportParse(this.source, this.books, this.skipped);
  int get readCount => books.fold(0, (a, b) => a + b.reads.length);
}

class ImportException implements Exception {
  final String message;
  ImportException(this.message);
  @override
  String toString() => message;
}

/// Parsing of reading-history files. Pure Dart: no database, no network.
class Importer {
  // ───────── helpers ─────────
  static String _s(Object? v) => v == null ? '' : '$v'.trim();

  /// Goodreads wraps ISBNs as ="0441172717"; also strip hyphens/spaces. Returns an ISBN-13 or ''.
  static String cleanIsbn(String raw) {
    final c = raw.replaceAll(RegExp(r'[="\s-]'), '');
    return Isbn.to13(c) ?? '';
  }

  /// Accepts 2023/05/14, 2023-05-14, 14/05/2023-style is NOT guessed; 5/14/2023 (US) is accepted; ISO timestamps.
  static DateTime? parseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final plain = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (plain != null) {
      // DateTime.tryParse rolls 02-30 over to 03-02; only a date that really exists is accepted
      final d = _valid(int.parse(plain[1]!), int.parse(plain[2]!), int.parse(plain[3]!));
      return d != null && d.month == int.parse(plain[2]!) ? d : null;
    }
    final iso = DateTime.tryParse(s);
    if (iso != null) return _valid(iso.year, iso.month, iso.day);
    final ymd = RegExp(r'^(\d{4})[/.-](\d{1,2})[/.-](\d{1,2})').firstMatch(s);
    if (ymd != null) return _valid(int.parse(ymd[1]!), int.parse(ymd[2]!), int.parse(ymd[3]!));
    final mdy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(s);
    if (mdy != null) return _valid(int.parse(mdy[3]!), int.parse(mdy[1]!), int.parse(mdy[2]!));
    return null;
  }

  static DateTime? _valid(int y, int m, int d) {
    if (y < 1900 || y > DateTime.now().year + 1 || m < 1 || m > 12 || d < 1 || d > 31) return null;
    return DateTime(y, m, d);
  }

  /// Nearest half star between 0.5 and 5, or null for "no rating".
  static double? halfStars(Object? v) {
    final d = double.tryParse(_s(v));
    if (d == null || !d.isFinite || d <= 0) return null;
    return ((d.clamp(0.5, 5.0)) * 2).round() / 2;
  }

  static int? _int(Object? v) {
    final d = double.tryParse(_s(v).replaceAll(',', ''));
    return d == null || !d.isFinite || d <= 0 || d > 1e9 ? null : d.round();
  }

  /// CSV text -> list of maps keyed by (trimmed) header. Tolerates a BOM and ragged rows.
  static List<Map<String, String>> table(String text) {
    final t = text.startsWith('﻿') ? text.substring(1) : text;
    final rows = csv.decode(t);
    if (rows.length < 2) return const [];
    final head = [for (final h in rows.first) _s(h)];
    return [
      for (final r in rows.skip(1))
        if (r.any((c) => _s(c).isNotEmpty)) {for (var i = 0; i < head.length; i++) head[i]: i < r.length ? _s(r[i]) : ''},
    ];
  }

  /// "'=1+1" -> "=1+1": undo the formula neutralisation that exports apply.
  static String _unsafe(String s) => s.length > 1 && s[0] == "'" && '=+-@'.contains(s[1]) ? s.substring(1) : s;

  // ───────── detection ─────────
  static ImportSource? detect(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final j = jsonDecode(text);
        if (j is Map && j['pagemark_export'] != null) return ImportSource.pagemarkJson;
      } catch (_) {}
      return null;
    }
    final first = (text.startsWith('﻿') ? text.substring(1) : text).split(RegExp(r'\r?\n')).first;
    final cols = first.split(',').map((c) => c.replaceAll('"', '').trim().toLowerCase()).toSet();
    if (cols.contains('exclusive shelf') && cols.contains('title')) return ImportSource.goodreads;
    if (cols.contains('read status') && (cols.contains('star rating') || cols.contains('last date read'))) return ImportSource.storygraph;
    if (cols.contains('title') && cols.contains('status') && cols.contains('format')) return ImportSource.pagemarkCsv;
    return null;
  }

  static ImportParse parse(String text) {
    try {
      return _parse(text);
    } on ImportException {
      rethrow;
    } catch (_) {
      // odd shapes (a number where a list should be, NaN cells...) are a bad file, not an app crash
      throw ImportException('This file could not be read. It looks like a Pagemark, Goodreads or StoryGraph export, but its contents are not in the expected shape.');
    }
  }

  static ImportParse _parse(String text) {
    final src = detect(text);
    if (src == null) {
      throw ImportException('This file is not one Pagemark recognises. It can import Pagemark CSV/JSON exports, Goodreads library exports and StoryGraph exports.');
    }
    switch (src) {
      case ImportSource.pagemarkJson:
        final j = jsonDecode(text) as Map;
        final v = j['pagemark_export'];
        if (v != null && (v is! int || v > 2)) throw ImportException('This export is from a newer Pagemark (format $v). Update the app first.');
        final rows = [
          for (final r in (j['books'] is List ? j['books'] as List : const [])) if (r is Map) {for (final e in r.entries) '${e.key}': e.value == null ? '' : '${e.value}'},
        ];
        final parsed = _fromPagemarkRows(src, rows);
        for (final q in (j['quotes'] is List ? j['quotes'] as List : const [])) {
          if (q is! Map) continue;
          final text = _s(q['quote']);
          if (text.isEmpty) continue;
          final key = ImportBook(title: _s(q['title']), author: _s(q['author']), isbn: cleanIsbn(_s(q['isbn']))).key;
          final book = parsed.books.where((b) => b.key == key).firstOrNull;
          if (book != null) book.quotes.add(ImportQuote(text, page: _int(q['page']), note: _s(q['note']), created: DateTime.tryParse(_s(q['created']))));
        }
        return parsed;
      case ImportSource.pagemarkCsv:
        return _fromPagemarkRows(src, table(text));
      case ImportSource.goodreads:
        return _fromGoodreads(table(text));
      case ImportSource.storygraph:
        return _fromStoryGraph(table(text));
    }
  }

  // ───────── Pagemark ─────────
  static ImportParse _fromPagemarkRows(ImportSource src, List<Map<String, String>> rows) {
    final byKey = <String, ImportBook>{};
    final skipped = <String>[];
    var n = 1;
    for (final r in rows) {
      n++;
      final title = _unsafe(_s(r['title']));
      if (title.isEmpty) {
        skipped.add('Row $n has no title');
        continue;
      }
      if (_s(r['locked']).toLowerCase() == 'true') continue; // exports never contain these; ignore if hand-edited
      final b = ImportBook(
        title: title, author: _unsafe(_s(r['author'])), isbn: cleanIsbn(_s(r['isbn'])), genre: _unsafe(_s(r['genre'])), series: _unsafe(_s(r['series'])),
        publisher: _unsafe(_s(r['publisher'])), year: _int(r['year']), pages: _int(r['pages']), tags: normalizeTags(_unsafe(_s(r['tags']))), notes: _unsafe(_s(r['notes'])),
      );
      b.seriesTotal = _int(r['series_total']);
      final sn = double.tryParse(_s(r['series_number']));
      b.seriesNumber = sn != null && sn.isFinite && sn > 0 && sn < 100000 ? sn : null;
      b.description = _unsafe(_s(r['description']));
      final book = byKey.putIfAbsent(b.key, () => b);
      final status = _s(r['status']);
      if (status.isNotEmpty) {
        book.reads.add(ImportRead(
          format: const {'print', 'ebook', 'audio'}.contains(_s(r['format'])) ? _s(r['format']) : 'print',
          status: const {'want', 'reading', 'finished', 'dnf'}.contains(status) ? status : 'want',
          started: parseDate(_s(r['started'])), finished: parseDate(_s(r['finished'])), rating: halfStars(r['rating']),
          thoughts: _unsafe(_s(r['thoughts'])), narrator: _unsafe(_s(r['narrator'])), minutes: _int(r['minutes']),
          heat: _int(r['heat']), contentNotes: _unsafe(_s(r['content_notes'])),
        ));
      }
    }
    return ImportParse(src, byKey.values.toList(), skipped);
  }

  // ───────── Goodreads ─────────
  static ImportParse _fromGoodreads(List<Map<String, String>> rows) {
    final books = <ImportBook>[];
    final skipped = <String>[];
    var n = 1;
    for (final r in rows) {
      n++;
      final title = _s(r['Title']);
      if (title.isEmpty) {
        skipped.add('Row $n has no title');
        continue;
      }
      final isbn = cleanIsbn(_s(r['ISBN13']).isNotEmpty ? _s(r['ISBN13']) : _s(r['ISBN']));
      final b = ImportBook(
        title: title, author: _s(r['Author']), isbn: isbn, publisher: _s(r['Publisher']), pages: _int(r['Number of Pages']),
        year: _int(r['Original Publication Year']) ?? _int(r['Year Published']),
        coverUrl: isbn.isEmpty ? '' : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
      );
      final shelf = _s(r['Exclusive Shelf']).toLowerCase();
      final status = switch (shelf) {
        'read' => 'finished',
        'currently-reading' => 'reading',
        'to-read' => 'want',
        'dnf' || 'did-not-finish' || 'abandoned' => 'dnf',
        _ => '',
      };
      final binding = _s(r['Binding']).toLowerCase();
      final format = binding.contains('audio') ? 'audio' : (binding.contains('kindle') || binding.contains('ebook') || binding.contains('e-book') || binding.contains('nook')) ? 'ebook' : 'print';
      final dateRead = parseDate(_s(r['Date Read']));
      final dateAdded = parseDate(_s(r['Date Added']));
      final review = _s(r['My Review']).replaceAll(RegExp(r'<br\s*/?>'), '\n');
      if (status.isNotEmpty) {
        b.reads.add(ImportRead(
          format: format, status: status, rating: halfStars(r['My Rating']), thoughts: review,
          finished: status == 'finished' ? (dateRead ?? dateAdded) : null,
          started: status == 'reading' ? dateAdded : null,
        ));
      }
      // custom shelves ("Bookshelves" is a comma list that also repeats the exclusive shelf)
      for (final s in _s(r['Bookshelves']).split(',')) {
        final t = s.trim();
        if (t.isNotEmpty && !const {'read', 'currently-reading', 'to-read'}.contains(t.toLowerCase())) b.shelves.add(t);
      }
      books.add(b);
    }
    return ImportParse(ImportSource.goodreads, books, skipped);
  }

  // ───────── StoryGraph ─────────
  static ImportParse _fromStoryGraph(List<Map<String, String>> rows) {
    final books = <ImportBook>[];
    final skipped = <String>[];
    var n = 1;
    for (final r in rows) {
      n++;
      final title = _s(r['Title']);
      if (title.isEmpty) {
        skipped.add('Row $n has no title');
        continue;
      }
      // "ISBN/UID" holds an ISBN or a StoryGraph/Amazon id; only a valid ISBN is kept
      final isbn = cleanIsbn(_s(r['ISBN/UID']));
      final b = ImportBook(
        title: title, author: _s(r['Authors']).split(',').first.trim(), isbn: isbn, tags: normalizeTags(_s(r['Tags'])),
        notes: _s(r['Content Warnings']).isEmpty ? '' : 'Content warnings: ${_s(r['Content Warnings'])}',
        coverUrl: isbn.isEmpty ? '' : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
      );
      final status = switch (_s(r['Read Status']).toLowerCase()) {
        'read' => 'finished',
        'currently-reading' => 'reading',
        'to-read' => 'want',
        'did-not-finish' => 'dnf',
        'paused' => 'reading',
        _ => '',
      };
      final fmt = _s(r['Format']).toLowerCase();
      final format = fmt.contains('audio') ? 'audio' : fmt.contains('digital') || fmt.contains('ebook') ? 'ebook' : 'print';
      if (status.isNotEmpty) {
        b.reads.add(ImportRead(
          format: format, status: status, rating: halfStars(r['Star Rating']), thoughts: _s(r['Review']),
          finished: status == 'finished' ? (parseDate(_s(r['Last Date Read'])) ?? parseDate(_s(r['Date Added']))) : null,
          started: status == 'reading' ? (parseDate(_s(r['Last Date Read'])) ?? parseDate(_s(r['Date Added']))) : null,
        ));
      }
      books.add(b);
    }
    return ImportParse(ImportSource.storygraph, books, skipped);
  }
}

/// How to treat books that are already in the library (same ISBN, or same title + author).
enum DuplicatePolicy { skip, addReads, addAnyway }

class ImportPlan {
  final List<ImportBook> fresh;
  final List<(ImportBook, Book)> duplicates;
  const ImportPlan(this.fresh, this.duplicates);
}

class ImportResult {
  final int booksAdded, readsAdded, shelvesCreated, duplicatesSkipped;
  final List<int> newBookIds; // for Undo
  const ImportResult(this.booksAdded, this.readsAdded, this.shelvesCreated, this.duplicatesSkipped, this.newBookIds);
}

class ImportRunner {
  /// Splits parsed books into new ones and ones already in the main library. The vault is never compared or touched.
  static Future<ImportPlan> plan(AppDb db, ImportParse p) async {
    final live = await (db.select(db.books)..where((b) => b.deletedAt.isNull() & b.locked.equals(false))).get();
    final byIsbn = {for (final b in live) if (b.isbn.isNotEmpty) b.isbn: b};
    final byTa = {for (final b in live) '${b.title.trim().toLowerCase()}|${b.author.trim().toLowerCase()}': b};
    final fresh = <ImportBook>[];
    final dups = <(ImportBook, Book)>[];
    final seen = <String>{};
    for (final b in p.books) {
      final hit = (b.isbn.isNotEmpty ? byIsbn[b.isbn] : null) ?? byTa['${b.title.trim().toLowerCase()}|${b.author.trim().toLowerCase()}'];
      if (hit != null) {
        dups.add((b, hit));
      } else if (seen.add(b.key)) {
        fresh.add(b); // a file that lists the same book twice only adds it once
      }
    }
    return ImportPlan(fresh, dups);
  }

  /// Writes everything in one transaction: either all of it lands or none of it does.
  static Future<ImportResult> run(AppDb db, ImportPlan plan, DuplicatePolicy policy) {
    return db.transaction(() async {
      final newIds = <int>[];
      var reads = 0, skipped = 0;
      final shelfIds = <String, int>{};
      final shelvesBefore = (await db.select(db.shelves).get()).length;

      Future<int> shelfId(String name) async => shelfIds[name.toLowerCase()] ??= await db.addShelf(name);

      Future<int> addBook(ImportBook b) async {
        final id = await db.into(db.books).insert(BooksCompanion.insert(
              title: b.title, author: Value(b.author), isbn: Value(b.isbn), genre: Value(b.genre), series: Value(b.series), seriesNumber: Value(b.seriesNumber), description: Value(b.description),
              publisher: Value(b.publisher), year: Value(b.year), pages: Value(b.pages), tags: Value(b.tags), notes: Value(b.notes), coverUrl: Value(b.coverUrl),
              seriesTotal: Value(b.seriesTotal),
            ));
        return id;
      }

      Future<void> addReads(int bookId, ImportBook b) async {
        for (final r in b.reads) {
          await db.into(db.reads).insert(ReadsCompanion.insert(
                bookId: bookId, format: Value(r.format), status: Value(r.status), started: Value(r.started), finished: Value(r.finished),
                rating: Value(r.rating), thoughts: Value(r.thoughts), narrator: Value(r.narrator), minutes: Value(r.minutes),
                heat: Value(r.heat), contentNotes: Value(r.contentNotes),
              ));
          reads++;
        }
        for (final q in b.quotes) {
          await db.into(db.quotes).insert(QuotesCompanion.insert(bookId: bookId, body: q.text, page: Value(q.page), note: Value(q.note), created: Value(q.created ?? DateTime.now())));
        }
        for (final s in b.shelves) {
          await db.setOnShelf(bookId, await shelfId(s), true);
        }
      }

      for (final b in plan.fresh) {
        final id = await addBook(b);
        newIds.add(id);
        await addReads(id, b);
      }
      for (final (b, existing) in plan.duplicates) {
        switch (policy) {
          case DuplicatePolicy.skip:
            skipped++;
          case DuplicatePolicy.addReads:
            await addReads(existing.id, b);
          case DuplicatePolicy.addAnyway:
            final id = await addBook(b);
            newIds.add(id);
            await addReads(id, b);
        }
      }
      final shelvesAfter = (await db.select(db.shelves).get()).length;
      return ImportResult(newIds.length, reads, shelvesAfter - shelvesBefore, skipped, newIds);
    });
  }
}
