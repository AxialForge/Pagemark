import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/isbn.dart';
import 'package:pagemark/log.dart';
import 'package:pagemark/lookup.dart';

http.Response json(Object o, [int code = 200]) => http.Response.bytes(utf8.encode(jsonEncode(o)), code, headers: {'content-type': 'application/json'});

void main() {
  setUp(() => Lookup.retryDelay = Duration.zero);

  group('ISBN', () {
    test('checksums and conversion', () {
      expect(Isbn.isValid13('978-0-441-17271-9'), isTrue);
      expect(Isbn.isValid13('9780441172718'), isFalse);
      expect(Isbn.isValid10('0441172717'), isTrue);
      expect(Isbn.isValid10('0441172718'), isFalse);
      expect(Isbn.isValid10('080442957X'), isTrue); // X check digit
      expect(Isbn.to13('0441172717'), '9780441172719');
      expect(Isbn.to13('nonsense'), isNull);
    });

    test('scanner only accepts book barcodes', () {
      expect(Isbn.looksLikeBookCode('9780441172719'), isTrue);
      expect(Isbn.looksLikeBookCode('4006381333931'), isFalse, reason: 'valid EAN-13 but not a book (no 978/979)');
      expect(Isbn.looksLikeBookCode('https://example.com'), isFalse);
      expect(Isbn.looksLikeBookCode('012345678905'), isFalse);
    });
  });

  group('search', () {
    test('parses results, skips malformed records, dedupes works, filters noisy subjects, sends a User-Agent', () async {
      String? ua;
      Lookup.client = MockClient((req) async {
        ua = req.headers['User-Agent'];
        return json({
          'docs': [
            {'key': '/works/OL1W', 'title': 'Dune', 'author_name': ['Frank Herbert'], 'isbn': ['0441172717', 'bad'], 'cover_i': 99,
              'first_publish_year': 1965, 'number_of_pages_median': 412, 'publisher': ['Ace'],
              'subject': ['Science fiction', 'Accessible book', 'Protected DAISY', 'Desert planets', 'Politics']},
            {'key': '/works/OL1W', 'title': 'Dune (again)'},
            {'title': 'Weird', 'publisher': 'not-a-list', 'isbn': 5, 'author_name': 'str'},
            'garbage',
            {'key': '/works/OL2W'},
          ],
        });
      });
      final r = await Lookup.search('dune');
      expect(ua, contains('Pagemark'));
      expect(ua, contains('github.com/AxialForge/Pagemark'));
      expect(r.map((m) => m.title), ['Dune', 'Weird']);
      expect(r.first.isbn, '9780441172719');
      expect(r.first.coverUrl, 'https://covers.openlibrary.org/b/id/99-L.jpg');
      expect(r.first.genre, 'Science fiction, Desert planets, Politics');
      expect(r.first.year, 1965);
    });

    test('retries a busy server then succeeds', () async {
      var n = 0;
      Lookup.client = MockClient((_) async => ++n < 3 ? http.Response('busy', 503) : json({'docs': []}));
      expect(await Lookup.search('x'), isEmpty);
      expect(n, 3);
    });

    test('gives a readable error when the network is down or the server keeps failing', () async {
      Lookup.client = MockClient((_) async => throw const SocketException('offline'));
      await expectLater(Lookup.search('x'), throwsA(isA<LookupException>().having((e) => e.message, 'message', contains('connection'))));
      Lookup.client = MockClient((_) async => http.Response('x', 503));
      await expectLater(Lookup.search('x'), throwsA(isA<LookupException>().having((e) => e.message, 'message', contains('busy'))));
    });
  });

  group('ISBN lookup', () {
    test('uses the data API and parses a varied record', () async {
      Lookup.client = MockClient((_) async => json({
            'ISBN:9780441172719': {
              'title': 'Dune', 'authors': [{'name': 'Frank Herbert'}], 'number_of_pages': 604, 'publish_date': 'August 2005',
              'publishers': [{'name': 'Ace'}], 'subjects': [{'name': 'Science fiction'}, 'Accessible book'],
              'cover': {'large': 'https://covers/x-L.jpg'}, 'works': [{'key': '/works/OL1W'}],
            },
          }));
      final m = (await Lookup.byIsbn('0441172717'))!; // ISBN-10 input is normalised
      expect(m.isbn, '9780441172719');
      expect(m.year, 2005);
      expect(m.pages, 604);
      expect(m.genre, 'Science fiction');
      expect(m.workKey, '/works/OL1W');
    });

    test('falls back to a search by ISBN when the data API has nothing', () async {
      final seen = <String>[];
      Lookup.client = MockClient((req) async {
        seen.add(req.url.path);
        if (req.url.path == '/api/books') return json({});
        return json({'docs': [{'key': '/works/OL9W', 'title': 'Found by search', 'author_name': ['A']}]});
      });
      final m = await Lookup.byIsbn('9780441172719');
      expect(seen, ['/api/books', '/search.json']);
      expect(m!.title, 'Found by search');
      expect(m.isbn, '9780441172719');
    });

    test('rejects an invalid ISBN without calling the network', () async {
      var called = false;
      Lookup.client = MockClient((_) async { called = true; return json({}); });
      await expectLater(Lookup.byIsbn('12345'), throwsA(isA<LookupException>()));
      expect(called, isFalse);
    });
  });

  group('description', () {
    test('handles string and {value} forms and strips the source footer', () async {
      Lookup.client = MockClient((_) async => json({'description': {'type': '/type/text', 'value': 'A desert epic.\n----------\nSource: x'}}));
      expect(await Lookup.description('/works/OL1W'), 'A desert epic.');
      Lookup.client = MockClient((_) async => json({'description': 'Plain'}));
      expect(await Lookup.description('/works/OL1W'), 'Plain');
      Lookup.client = MockClient((_) async => http.Response('nope', 404));
      expect(await Lookup.description('/works/OL1W'), '');
      expect(await Lookup.description('bad'), '');
    });
  });

  group('log', () {
    test('writes, reads, caps its size and clears', () async {
      final dir = Directory.systemTemp.createTempSync('pgmlog');
      Log.useFile(File('${dir.path}/t.log'));
      Log.echo = false;
      Log.i('t', 'hello');
      Log.e('t', 'boom');
      expect(await Log.read(), allOf(contains('I t: hello'), contains('E t: boom')));
      for (var i = 0; i < 4000; i++) {
        Log.w('t', 'line $i ${'x' * 80}');
      }
      final text = await Log.read();
      expect(text.length, lessThan(260 * 1024));
      expect(text, contains('line 3999'));
      await Log.clear();
      expect(await Log.read(), '');
      dir.deleteSync(recursive: true);
    });
  });
}
