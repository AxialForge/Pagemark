import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/finding.dart';
import 'package:pagemark/lookup.dart';

http.Response json(Object o, [int code = 200]) => http.Response.bytes(utf8.encode(jsonEncode(o)), code, headers: {'content-type': 'application/json'});

Map<String, Object?> volume(String title, {String authors = 'Frank Herbert', String isbn = '9780441172719', int? pages = 412, String thumb = 'http://books.example/cover?id=1&edge=curl', String desc = 'A desert.'}) => {
      'volumeInfo': {
        'title': title,
        'authors': [authors],
        'publisher': 'Ace',
        'publishedDate': '1990-09-01',
        'description': desc,
        'pageCount': pages,
        'categories': ['Fiction / Science Fiction / Space Opera'],
        'imageLinks': {'thumbnail': thumb},
        'industryIdentifiers': [
          {'type': 'ISBN_10', 'identifier': '0441172717'},
          {'type': 'ISBN_13', 'identifier': isbn},
        ],
      }
    };

Book book({String author = '', String isbn = '', String cover = '', int? pages, String publisher = '', String genre = '', String desc = ''}) => Book(kind: '', owned: true,
    id: 1, title: 'Dune', author: author, isbn: isbn, coverUrl: cover, genre: genre, series: '', publisher: publisher, year: null, pages: pages, description: desc,
    tags: '', notes: '', locked: false, added: DateTime(2026), queuePos: null);

void main() {
  setUp(() => Lookup.retryDelay = Duration.zero);

  group('Google Books', () {
    test('a volume becomes a book: ISBN-13 preferred, https cover, tidy genres, year from the date', () {
      final m = Lookup.parseVolume(volume('Dune'))!;
      expect([m.title, m.author, m.isbn, m.pages, m.year, m.publisher], ['Dune', 'Frank Herbert', '9780441172719', 412, 1990, 'Ace']);
      expect(m.coverUrl, 'https://books.example/cover?id=1');
      expect(m.genre, 'Science Fiction, Space Opera');
      expect(Lookup.parseVolume({'volumeInfo': {}}), isNull);
      expect(Lookup.parseVolume('junk'), isNull);
      expect(Lookup.parseVolume(volume('Zero', pages: 0))!.pages, isNull);
    });

    test('merge fills gaps in a book both sources know, appends one only Google knows, never overwrites', () {
      final ol = [BookMeta(title: 'Dune', author: 'Frank Herbert', isbn: '9780441172719', pages: 500)];
      final g = [Lookup.parseVolume(volume('Dune'))!, Lookup.parseVolume(volume('Children of Dune', isbn: '9780441104024'))!];
      final out = Lookup.merge(ol, g);
      expect(out.map((m) => m.title), ['Dune', 'Children of Dune']);
      expect(out.first.pages, 500, reason: 'Open Library had pages, so they stay');
      expect(out.first.coverUrl, isNotEmpty);
      expect(out.first.description, 'A desert.');
    });

    test('searchAll merges both sources', () async {
      Lookup.client = MockClient((req) async {
        if (req.url.host == 'www.googleapis.com') return json({'items': [volume('Dune')]});
        return json({'docs': [{'key': '/works/OL1W', 'title': 'Dune', 'author_name': ['Frank Herbert'], 'isbn': ['9780441172719']}]});
      });
      final r = await Lookup.searchAll('dune');
      expect(r, hasLength(1));
      expect([r.first.workKey, r.first.pages], ['/works/OL1W', 412]);
    });

    test('one source failing is fine; both failing reports the problem; Google can be switched off', () async {
      final hosts = <String>[];
      Lookup.client = MockClient((req) async {
        hosts.add(req.url.host);
        return req.url.host == 'www.googleapis.com' ? json({}, 500) : json({'docs': [{'key': '/works/OL1W', 'title': 'Dune'}]});
      });
      expect((await Lookup.searchAll('dune')).single.title, 'Dune');
      hosts.clear();
      await Lookup.searchAll('dune', google: false);
      expect(hosts.toSet(), {'openlibrary.org'});
      Lookup.client = MockClient((_) async => json({}, 500));
      await expectLater(Lookup.searchAll('dune'), throwsA(isA<LookupException>()));
    });

    test('ISBN lookup falls back to Google when Open Library does not know the book, and tops up missing details', () async {
      Lookup.client = MockClient((req) async {
        if (req.url.host == 'www.googleapis.com') return json({'items': [volume('Dune')]});
        if (req.url.path == '/api/books') return json({});
        return json({'docs': []});
      });
      final m = (await Lookup.byIsbnAll('9780441172719'))!;
      expect([m.title, m.isbn], ['Dune', '9780441172719']);

      Lookup.client = MockClient((req) async {
        if (req.url.host == 'www.googleapis.com') return json({'items': [volume('Dune')]});
        return json({'ISBN:9780441172719': {'title': 'Dune', 'authors': [{'name': 'Frank Herbert'}]}});
      });
      final topped = (await Lookup.byIsbnAll('9780441172719'))!;
      expect([topped.pages, topped.publisher, topped.description], [412, 'Ace', 'A desert.']);
    });
  });

  group('editions', () {
    test('are listed with publisher, year, pages, ISBN and cover, skipping bad records', () async {
      Lookup.client = MockClient((req) async {
        expect(req.url.path, '/works/OL1W/editions.json');
        return json({
          'entries': [
            {'title': 'Dune', 'publishers': ['Ace'], 'publish_date': 'Sep 1990', 'number_of_pages': 412, 'isbn_13': ['9780441172719'], 'covers': [123]},
            'junk',
            {'title': 'Dune', 'isbn_10': ['0441172717'], 'covers': [-1]},
          ]
        });
      });
      final e = await Lookup.editions('/works/OL1W');
      expect(e, hasLength(2));
      expect([e[0].publisher, e[0].year, e[0].pages, e[0].isbn, e[0].coverUrl], ['Ace', 1990, 412, '9780441172719', 'https://covers.openlibrary.org/b/id/123-L.jpg']);
      expect([e[1].isbn, e[1].coverUrl], ['9780441172719', '']);
      expect(await Lookup.editions('nope'), isEmpty);
    });

    test('choosing one swaps in its cover, publisher, year, pages and ISBN but keeps the rest', () {
      final base = BookMeta(title: 'Dune', author: 'Frank Herbert', genre: 'SF', description: 'd', workKey: '/works/OL1W', pages: 1, isbn: '9780000000002');
      final e = BookMeta(title: 'Dune (movie tie-in)', isbn: '9780441172719', publisher: 'Ace', pages: 412);
      final m = EditionPicker.applyEdition(base, e);
      expect([m.title, m.author, m.genre, m.isbn, m.publisher, m.pages, m.workKey], ['Dune', 'Frank Herbert', 'SF', '9780441172719', 'Ace', 412, '/works/OL1W']);
    });
  });

  group('refresh details', () {
    final found = BookMeta(title: 'Dune', author: 'Frank Herbert', isbn: '9780441172719', pages: 412, publisher: 'Ace', genre: 'SF', description: 'A desert.', coverUrl: 'https://c/x.jpg', year: 1990);

    test('missing details are offered ticked; details you already have are offered unticked', () {
      final c = {for (final f in refreshChanges(book(author: 'F. Herbert', pages: 300), found)) f.key: f};
      expect(c['pages']!.fill, isFalse);
      expect(c['author']!.fill, isFalse);
      expect(c['publisher']!.fill, isTrue);
      expect(c['description']!.fill, isTrue);
      expect(c['year']!.newText, '1990');
    });

    test('an ISBN you have is never offered, and a cover you saved on the phone is left alone', () {
      final keys = refreshChanges(book(isbn: '9780000000002', cover: 'local:1.jpg'), found).map((f) => f.key);
      expect(keys.contains('isbn'), isFalse);
      expect(keys.contains('coverUrl'), isFalse);
    });

    test('identical and empty values are not offered at all', () {
      expect(refreshChanges(book(pages: 412, publisher: 'Ace'), found).map((f) => f.key), isNot(containsAll(['pages', 'publisher'])));
      expect(refreshChanges(book(), BookMeta(title: 'Dune')), isEmpty);
    });

    test('only the ticked details are written', () async {
      final db = AppDb.memory();
      final id = await db.into(db.books).insert(BooksCompanion.insert(title: 'Dune', author: const Value('Mine'), pages: const Value(300)));
      final b = (await db.select(db.books).getSingle());
      final changes = refreshChanges(b, found);
      await (db.update(db.books)..where((x) => x.id.equals(id))).write(changesToCompanion(changes.where((f) => f.fill)));
      final after = await db.select(db.books).getSingle();
      expect([after.author, after.pages, after.publisher, after.year], ['Mine', 300, 'Ace', 1990]);
      await db.close();
    });
  });

  group('suggestions from your own library', () {
    Future<List<BookRow>> library(AppDb db) => db.watchLibrary(locked: false).first;
    Future<int> add(AppDb db, String title, String status, {String author = '', String series = '', String genre = '', double? rating, bool locked = false}) async {
      final id = await db.into(db.books).insert(BooksCompanion.insert(title: title, author: Value(author), series: Value(series), genre: Value(genre), locked: Value(locked)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: Value(status), rating: Value(rating), finished: Value(status == 'finished' ? DateTime(2026, 1, 1) : null)));
      return id;
    }

    test('next in a series outranks more from a loved author, which outranks a loved genre', () async {
      final db = AppDb.memory();
      await add(db, 'Dune', 'finished', author: 'Frank Herbert', series: 'Dune', genre: 'Science fiction', rating: 5);
      await add(db, 'Genre only', 'want', genre: 'Science fiction');
      await add(db, 'Messiah', 'want', author: 'Frank Herbert', series: 'Dune', genre: 'Science fiction');
      await add(db, 'Other Herbert', 'want', author: 'Frank Herbert');
      await add(db, 'Unrelated', 'want', author: 'Someone', genre: 'Crime');
      final s = suggestNext(await library(db));
      expect(s.map((x) => x.row.book.title), ['Messiah', 'Other Herbert', 'Genre only']);
      expect(s.first.reason, 'Next in Dune');
      await db.close();
    });

    test('authors you rated low are not pushed, and nothing is suggested from nothing', () async {
      final db = AppDb.memory();
      await add(db, 'Meh', 'finished', author: 'A', rating: 2);
      await add(db, 'More A', 'want', author: 'A');
      expect(suggestNext(await library(db)), isEmpty);
      await db.close();
    });

    test('locked books neither suggest nor are suggested', () async {
      final db = AppDb.memory();
      await add(db, 'Secret loved', 'finished', author: 'S', rating: 5, locked: true);
      await add(db, 'Secret want', 'want', author: 'S', locked: true);
      await add(db, 'Open want', 'want', author: 'S');
      expect(suggestNext(await library(db)), isEmpty);
      await db.close();
    });
  });
}
