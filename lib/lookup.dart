import 'dart:convert';
import 'package:http/http.dart' as http;

class BookMeta {
  String title, author, isbn, coverUrl, genre, publisher, description, series;
  int? year, pages;
  BookMeta({this.title = '', this.author = '', this.isbn = '', this.coverUrl = '', this.genre = '',
      this.publisher = '', this.description = '', this.series = '', this.year, this.pages});
}

/// Free metadata: Open Library (no key). Covers: covers.openlibrary.org.
class Lookup {
  static const _h = {'User-Agent': 'Pagemark/0.1 (personal book tracker)'};

  static Future<List<BookMeta>> search(String q) async {
    final u = Uri.https('openlibrary.org', '/search.json', {
      'q': q, 'limit': '20',
      'fields': 'title,author_name,isbn,cover_i,first_publish_year,number_of_pages_median,publisher,subject',
    });
    final r = await http.get(u, headers: _h).timeout(const Duration(seconds: 15));
    final docs = (jsonDecode(r.body)['docs'] as List);
    return docs.map((d) {
      final isbns = (d['isbn'] as List?) ?? [];
      final cover = d['cover_i'];
      return BookMeta(
        title: d['title'] ?? '',
        author: ((d['author_name'] as List?) ?? []).join(', '),
        isbn: isbns.isNotEmpty ? isbns.first.toString() : '',
        coverUrl: cover != null ? 'https://covers.openlibrary.org/b/id/$cover-L.jpg' : '',
        year: d['first_publish_year'],
        pages: d['number_of_pages_median'],
        publisher: ((d['publisher'] as List?) ?? []).isNotEmpty ? d['publisher'].first : '',
        genre: ((d['subject'] as List?) ?? []).take(3).join(', '),
      );
    }).toList();
  }

  static Future<BookMeta?> byIsbn(String isbn) async {
    final u = Uri.https('openlibrary.org', '/api/books', {'bibkeys': 'ISBN:$isbn', 'format': 'json', 'jscmd': 'data'});
    final r = await http.get(u, headers: _h).timeout(const Duration(seconds: 15));
    final m = jsonDecode(r.body) as Map;
    final d = m['ISBN:$isbn'];
    if (d == null) return null;
    return BookMeta(
      title: d['title'] ?? '',
      author: ((d['authors'] as List?) ?? []).map((a) => a['name']).join(', '),
      isbn: isbn,
      coverUrl: d['cover']?['large'] ?? 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
      pages: d['number_of_pages'],
      publisher: ((d['publishers'] as List?) ?? []).map((a) => a['name']).join(', '),
      genre: ((d['subjects'] as List?) ?? []).take(3).map((s) => s['name']).join(', '),
      year: int.tryParse(RegExp(r'\d{4}').firstMatch('${d['publish_date']}')?.group(0) ?? ''),
    );
  }
}
