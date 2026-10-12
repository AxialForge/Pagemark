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
  static const _headers = {'User-Agent': 'Pagemark/0.3 (personal book tracker; https://github.com/AxialForge/Pagemark)'};

  /// Subjects that describe the edition/accessibility, not the book.
  static final _noisy = RegExp(r'accessible book|protected daisy|in library|large type|internet archive|open library|lending library|^fiction$', caseSensitive: false);

  static Future<http.Response> _get(Uri u) async {
    Object? last;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final r = await client.get(u, headers: _headers).timeout(const Duration(seconds: 12));
        if (r.statusCode == 429 || r.statusCode >= 500) {
          last = LookupException('Open Library is busy (HTTP ${r.statusCode}).');
        } else if (r.statusCode != 200) {
          throw LookupException('Open Library answered HTTP ${r.statusCode}.');
        } else {
          return r;
        }
      } on TimeoutException {
        last = LookupException('Open Library took too long to answer.');
      } on LookupException {
        rethrow;
      } catch (e) {
        last = LookupException('Could not reach Open Library — check your connection.');
        Log.w('lookup', 'network error: $e');
      }
      if (attempt < 2) await Future<void>.delayed(retryDelay * (attempt + 1));
    }
    throw last as LookupException;
  }

  static String _str(Object? v) => v is String ? v : '';
  static int? _int(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v'));
  static List<Object?> _list(Object? v) => v is List ? v : const [];

  static String genres(Iterable<Object?> subjects) =>
      subjects.whereType<String>().where((s) => s.length < 40 && !_noisy.hasMatch(s)).take(3).join(', ');

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
        year: _int(d['first_publish_year']),
        pages: _int(d['number_of_pages_median']),
        publisher: pubs.isNotEmpty ? pubs.first : '',
        genre: genres(_list(d['subject'])),
        workKey: _str(d['key']),
      );
    } catch (e) {
      Log.w('lookup', 'skipped malformed search record: $e');
      return null;
    }
  }

  static Future<List<BookMeta>> search(String q) async {
    final u = Uri.https('openlibrary.org', '/search.json', {
      'q': q.trim(), 'limit': '30',
      'fields': 'key,title,author_name,isbn,cover_i,first_publish_year,number_of_pages_median,publisher,subject',
    });
    final r = await _get(u);
    final body = jsonDecode(utf8.decode(r.bodyBytes));
    final seen = <String>{};
    final out = <BookMeta>[];
    for (final d in _list(body is Map ? body['docs'] : null)) {
      final m = _parseDoc(d);
      if (m == null) continue;
      // The API returns works, but guard against repeats of the same work/title+author.
      final k = m.workKey.isNotEmpty ? m.workKey : '${m.title.toLowerCase()}|${m.author.toLowerCase()}';
      if (seen.add(k)) out.add(m);
    }
    return out;
  }

  /// ISBN lookup: the data API first, then a search by ISBN as a fallback.
  static Future<BookMeta?> byIsbn(String raw) async {
    final isbn = Isbn.to13(raw);
    if (isbn == null) throw LookupException('"$raw" is not a valid ISBN.');
    final u = Uri.https('openlibrary.org', '/api/books', {'bibkeys': 'ISBN:$isbn', 'format': 'json', 'jscmd': 'data'});
    final r = await _get(u);
    final m = jsonDecode(utf8.decode(r.bodyBytes));
    final d = m is Map ? m['ISBN:$isbn'] : null;
    if (d is Map) {
      final subjects = _list(d['subjects']).map((s) => s is Map ? s['name'] : s);
      final pd = '${d['publish_date']}';
      return BookMeta(
        title: _str(d['title']),
        author: _list(d['authors']).map((a) => a is Map ? _str(a['name']) : '').where((s) => s.isNotEmpty).join(', '),
        isbn: isbn,
        coverUrl: d['cover'] is Map && _str(d['cover']['large']).isNotEmpty ? _str(d['cover']['large']) : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
        pages: _int(d['number_of_pages']),
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

  /// Best-effort description from the work record; empty if unavailable.
  static Future<String> description(String workKey) async {
    if (!workKey.startsWith('/works/')) return '';
    try {
      final r = await _get(Uri.https('openlibrary.org', '$workKey.json'));
      final j = jsonDecode(utf8.decode(r.bodyBytes));
      final d = j is Map ? j['description'] : null;
      final text = d is String ? d : (d is Map ? _str(d['value']) : '');
      return text.split('\n----------').first.trim(); // OL appends source/links after a rule
    } catch (e) {
      Log.w('lookup', 'description fetch failed: $e');
      return '';
    }
  }
}
