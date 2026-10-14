import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'isbn.dart';
import 'log.dart';

class BookMeta {
  String title, author, isbn, coverUrl, genre, publisher, description, series;
  int? year, pages;
  String workKey; // Open Library work id, e.g. /works/OL45883W
  BookMeta({this.title = '', this.author = '', this.isbn = '', this.coverUrl = '', this.genre = '',
      this.publisher = '', this.description = '', this.series = '', this.year, this.pages, this.workKey = ''});
}

class LookupException implements Exception {
  final String message;
  LookupException(this.message);
  @override
  String toString() => message;
}

/// Free metadata from Open Library (no key). Covers: covers.openlibrary.org.
/// The client is injectable so the parsing and retry behaviour can be tested offline.
class Lookup {
  static http.Client client = http.Client();
  static Duration retryDelay = const Duration(milliseconds: 700);

  // Open Library asks API users to identify themselves.
  static const _headers = {'User-Agent': 'Pagemark (personal book tracker; https://github.com/AxialForge/Pagemark)'};

  /// Subjects that describe the edition/accessibility, not the book.
  static final _noisy = RegExp(r'accessible book|protected daisy|in library|large type|internet archive|open library|lending library|^fiction$', caseSensitive: false);

  static Future<http.Response> _get(Uri u) async {
    Object? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final r = await client.get(u, headers: _headers).timeout(const Duration(seconds: 12));
        if (r.statusCode == 429 || r.statusCode >= 500) {
          last = LookupException('The book search is busy right now. Please try again in a moment.');
        } else if (r.statusCode != 200) {
          throw LookupException('The book search had a problem. Please try again in a moment.');
        } else {
          return r;
        }
      } on TimeoutException {
        last = LookupException('The book search took too long. Check your internet and try again.');
      } on LookupException {
        rethrow;
      } catch (e) {
        last = LookupException('Could not reach the book search. Check your internet connection.');
        Log.w('lookup', 'network error: $e');
      }
      if (attempt < 2) await Future<void>.delayed(retryDelay * (attempt + 1));
    }
    throw last as LookupException;
  }

  /// Open Library sometimes answers with an HTML error page or a cut-off body; that is a lookup problem, not a crash.
  static Object? _decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException {
      throw LookupException('The book search sent an answer Pagemark could not read. Try again in a moment.');
    }
  }

  static String _str(Object? v) => v is String ? v : '';
  static int? _int(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v'));
  static List<Object?> _list(Object? v) => v is List ? v : const [];

  /// Library-catalogue labels that say nothing about the kind of book.
  static final _labels = RegExp(r'^(general|nyt:.*|reading level.*|new york times.*|bestsellers?|fiction in english|english fiction|large print.*)$|\((imaginary|fictitious)[^)]*\)|\bfictitious\b',
      caseSensitive: false);

  /// Up to three tidy genres from a list of subjects: each subject is split on commas ("Fiction, science fiction, general" is three
  /// subjects), labels, places, characters and edition notes are dropped, repeats ignoring case are dropped, first letter capitalised.
  static String genres(Iterable<Object?> subjects) {
    final seen = <String>{}, out = <String>[];
    for (final subject in subjects.whereType<String>()) {
      for (final raw in subject.split(RegExp(r'[,/]'))) {
        final g = raw.trim();
        if (g.isEmpty || g.length >= 40 || _noisy.hasMatch(g) || _labels.hasMatch(g) || !seen.add(g.toLowerCase())) continue;
        out.add(g[0].toUpperCase() + g.substring(1));
        if (out.length == 3) return out.join(', ');
      }
    }
    return out.join(', ');
  }

  /// A believable page count (1 to 20,000) or null; a negative or absurd number from a catalogue is not stored.
  static int? _pages(Object? v) {
    final n = _int(v);
    return n != null && n >= 1 && n <= 20000 ? n : null;
  }

  static int? _year(Object? v) {
    final n = _int(v);
    return n != null && n >= 1000 && n <= 2100 ? n : null;
  }

  /// One failing record never fails the whole list.
  static BookMeta? _parseDoc(Object? d) {
    try {
      if (d is! Map) return null;
      final title = _str(d['title']);
      if (title.isEmpty) return null;
      final isbns = _list(d['isbn']).whereType<String>().map(Isbn.to13).whereType<String>().toList();
      final cover = d['cover_i'];
      final pubs = _list(d['publisher']).whereType<String>();
      return BookMeta(
        title: title,
        author: _list(d['author_name']).whereType<String>().join(', '),
        isbn: isbns.isNotEmpty ? isbns.first : '',
        coverUrl: cover != null ? 'https://covers.openlibrary.org/b/id/$cover-L.jpg' : '',
        year: _year(d['first_publish_year']),
        pages: _pages(d['number_of_pages_median']),
        publisher: pubs.isNotEmpty ? pubs.first : '',
        genre: genres(_list(d['subject'])),
        workKey: _str(d['key']),
      );
    } catch (e) {
      Log.w('lookup', 'skipped malformed search record: $e');
      return null;
    }
  }

  static final _junk = RegExp(r'^(summary|study guide|workbook|analysis|trivia|quiz|a summary)\b|\bsummary of\b|\bstudy guide\b|\bworkbook\b|\bconversation starters\b', caseSensitive: false);

  /// Summaries, study guides and workbooks (third-party companions, not the book itself).
  static bool isJunk(BookMeta m) => _junk.hasMatch(m.title);

  /// Real editions first: a cover (+3) and an author named in the query (+2) rank up; summaries, study guides and
  /// workbooks (-5) sink. Stable, so Open Library's own order breaks ties.
  static List<BookMeta> rank(List<BookMeta> items, String query) {
    final q = query.toLowerCase();
    int score(BookMeta m) {
      var s = 0;
      if (m.coverUrl.isNotEmpty) s += 3;
      final firstAuthor = m.author.split(',').first.trim().toLowerCase();
      if (firstAuthor.isNotEmpty && q.contains(firstAuthor)) s += 2;
      if (isJunk(m)) s -= 5;
      return s;
    }

    final idx = {for (var i = 0; i < items.length; i++) items[i]: i};
    return [...items]..sort((a, b) {
        final d = score(b).compareTo(score(a));
        return d != 0 ? d : idx[a]!.compareTo(idx[b]!);
      });
  }

  static Future<List<BookMeta>> search(String q) async {
    final u = Uri.https('openlibrary.org', '/search.json', {
      'q': q.trim(), 'limit': '30',
      'fields': 'key,title,author_name,isbn,cover_i,first_publish_year,number_of_pages_median,publisher,subject',
    });
    final r = await _get(u);
    final body = _decode(r);
    final seen = <String>{};
    final out = <BookMeta>[];
    for (final d in _list(body is Map ? body['docs'] : null)) {
      final m = _parseDoc(d);
      if (m == null) continue;
      // The API returns works, but guard against repeats of the same work/title+author.
      final k = m.workKey.isNotEmpty ? m.workKey : '${m.title.toLowerCase()}|${m.author.toLowerCase()}';
      if (seen.add(k)) out.add(m);
    }
    return rank(out, q);
  }

  /// ISBN lookup: the data API first, then a search by ISBN as a fallback.
  static Future<BookMeta?> byIsbn(String raw) async {
    final isbn = Isbn.to13(raw);
    if (isbn == null) throw LookupException('"$raw" is not a valid barcode number (ISBN).');
    final u = Uri.https('openlibrary.org', '/api/books', {'bibkeys': 'ISBN:$isbn', 'format': 'json', 'jscmd': 'data'});
    final r = await _get(u);
    final m = _decode(r);
    final d = m is Map ? m['ISBN:$isbn'] : null;
    if (d is Map && _str(d['title']).isNotEmpty) {
      final subjects = _list(d['subjects']).map((s) => s is Map ? s['name'] : s);
      final pd = '${d['publish_date']}';
      return BookMeta(
        title: _str(d['title']),
        author: _list(d['authors']).map((a) => a is Map ? _str(a['name']) : '').where((s) => s.isNotEmpty).join(', '),
        isbn: isbn,
        coverUrl: d['cover'] is Map && _str(d['cover']['large']).isNotEmpty ? _str(d['cover']['large']) : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
        pages: _pages(d['number_of_pages']),
        publisher: _list(d['publishers']).map((a) => a is Map ? _str(a['name']) : '').where((s) => s.isNotEmpty).join(', '),
        genre: genres(subjects),
        year: _int(RegExp(r'(1[5-9]\d{2}|20\d{2})').firstMatch(pd)?.group(1)),
        workKey: _list(d['works']).isNotEmpty && _list(d['works']).first is Map ? _str((_list(d['works']).first as Map)['key']) : '',
      );
    }
    final viaSearch = await search('isbn:$isbn');
    if (viaSearch.isEmpty) return null;
    return viaSearch.first..isbn = isbn;
  }

  // ── Google Books (second source, no key) ──
  static String _https(String u) => u.startsWith('http://') ? 'https://${u.substring(7)}' : u;

  /// One Google Books "volume" as a [BookMeta]; null when it has no title.
  static BookMeta? parseVolume(Object? v) {
    try {
      final info = v is Map ? v['volumeInfo'] : null;
      if (info is! Map) return null;
      final title = _str(info['title']);
      if (title.isEmpty) return null;
      String isbn = '';
      for (final id in _list(info['industryIdentifiers'])) {
        if (id is Map) {
          final x = Isbn.to13(_str(id['identifier']));
          if (x != null && (isbn.isEmpty || id['type'] == 'ISBN_13')) isbn = x;
        }
      }
      final links = info['imageLinks'];
      final thumb = links is Map ? (_str(links['thumbnail']).isNotEmpty ? _str(links['thumbnail']) : _str(links['smallThumbnail'])) : '';
      final cats = _list(info['categories']).whereType<String>().expand((c) => c.split('/')).map((c) => c.trim()).where((c) => c.isNotEmpty && !_noisy.hasMatch(c));
      return BookMeta(
        title: title,
        author: _list(info['authors']).whereType<String>().join(', '),
        isbn: isbn,
        coverUrl: thumb.isEmpty ? '' : _https(thumb).replaceAll('&edge=curl', ''),
        genre: genres(cats),
        publisher: _str(info['publisher']),
        description: _str(info['description']).trim(),
        year: _int(RegExp(r'(1[5-9]\d{2}|20\d{2})').firstMatch(_str(info['publishedDate']))?.group(1)),
        pages: _pages(info['pageCount']),
      );
    } catch (e) {
      Log.w('lookup', 'skipped malformed Google record: $e');
      return null;
    }
  }

  static Future<List<BookMeta>> googleSearch(String q, {int max = 20}) async {
    final r = await _get(Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': q.trim(), 'maxResults': '$max', 'printType': 'books'}));
    final body = _decode(r);
    return [for (final v in _list(body is Map ? body['items'] : null)) ?parseVolume(v)];
  }

  static String _key(BookMeta m) => '${m.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}|${m.author.split(',').first.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '')}';

  /// Adds [extra] to [base]: the same book (same ISBN, or same title and first author) fills the gaps in the entry already there,
  /// and a book only [extra] knows is appended. Never overwrites something [base] already has.
  static List<BookMeta> merge(List<BookMeta> base, List<BookMeta> extra) {
    final out = [...base];
    for (final e in extra) {
      final i = out.indexWhere((m) => (m.isbn.isNotEmpty && m.isbn == e.isbn) || _key(m) == _key(e));
      if (i < 0) {
        out.add(e);
        continue;
      }
      fillGaps(out[i], e);
    }
    return out;
  }

  /// Copies into [m] only the details it lacks.
  static void fillGaps(BookMeta m, BookMeta e) {
    if (m.isbn.isEmpty) m.isbn = e.isbn;
    if (m.coverUrl.isEmpty) m.coverUrl = e.coverUrl;
    if (m.genre.isEmpty) m.genre = e.genre;
    if (m.publisher.isEmpty) m.publisher = e.publisher;
    if (m.description.isEmpty) m.description = e.description;
    m.year ??= e.year;
    m.pages ??= e.pages;
  }

  /// Open Library and (when [google]) Google Books together. One source failing is fine; both failing reports the first error.
  static Future<List<BookMeta>> searchAll(String q, {bool google = true}) async {
    if (!google) return search(q);
    Object? err;
    Future<List<BookMeta>> safe(Future<List<BookMeta>> f) => f.catchError((Object e) {
          err ??= e;
          return <BookMeta>[];
        });
    final both = await Future.wait([safe(search(q)), safe(googleSearch(q))]);
    if (both[0].isEmpty && both[1].isEmpty && err != null) throw err!;
    return rank(merge(both[0], both[1]), q);
  }

  /// ISBN lookup across both sources: Open Library first, then Google fills any gap (or answers alone).
  static Future<BookMeta?> byIsbnAll(String raw, {bool google = true}) async {
    BookMeta? m;
    Object? err;
    try {
      m = await byIsbn(raw);
    } on LookupException catch (e) {
      if (!google || e.message.contains('not a valid')) rethrow;
      err = e;
    }
    if (!google) return m;
    if (m != null && m.coverUrl.isNotEmpty && m.pages != null && m.description.isNotEmpty && m.publisher.isNotEmpty) return m;
    try {
      final isbn = Isbn.to13(raw)!;
      final g = await googleSearch('isbn:$isbn', max: 3);
      if (g.isNotEmpty) {
        if (m == null) return g.first..isbn = isbn;
        fillGaps(m, g.first);
      }
    } on LookupException catch (e) {
      if (m == null) throw err ?? e;
    }
    return m;
  }

  /// Every edition Open Library lists for a work (publisher, year, pages, ISBN, cover), for the edition picker.
  static Future<List<BookMeta>> editions(String workKey) async {
    if (!workKey.startsWith('/works/')) return [];
    final r = await _get(Uri.https('openlibrary.org', '$workKey/editions.json', {'limit': '50'}));
    final body = _decode(r);
    final out = <BookMeta>[];
    for (final e in _list(body is Map ? body['entries'] : null)) {
      try {
        if (e is! Map) continue;
        final isbns = [..._list(e['isbn_13']), ..._list(e['isbn_10'])].whereType<String>().map(Isbn.to13).whereType<String>().toList();
        final covers = _list(e['covers']).whereType<int>().where((c) => c > 0).toList();
        final pubs = _list(e['publishers']).whereType<String>();
        out.add(BookMeta(
          title: _str(e['title']),
          isbn: isbns.isNotEmpty ? isbns.first : '',
          coverUrl: covers.isNotEmpty ? 'https://covers.openlibrary.org/b/id/${covers.first}-L.jpg' : '',
          publisher: pubs.isNotEmpty ? pubs.first : '',
          year: _int(RegExp(r'(1[5-9]\d{2}|20\d{2})').firstMatch(_str(e['publish_date']))?.group(1)),
          pages: _pages(e['number_of_pages']),
          workKey: workKey,
        ));
      } catch (_) {}
    }
    return out;
  }

  /// Best-effort description from the work record; empty if unavailable.
  static Future<String> description(String workKey) async {
    if (!workKey.startsWith('/works/')) return '';
    try {
      final r = await _get(Uri.https('openlibrary.org', '$workKey.json'));
      final j = _decode(r);
      final d = j is Map ? j['description'] : null;
      final text = d is String ? d : (d is Map ? _str(d['value']) : '');
      return text.split('\n----------').first.trim(); // OL appends source/links after a rule
    } catch (e) {
      Log.w('lookup', 'description fetch failed: $e');
      return '';
    }
  }
}
