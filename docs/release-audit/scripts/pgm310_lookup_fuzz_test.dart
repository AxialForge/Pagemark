// PGM-310 series audit script: hostile or broken answers from Open Library and Google Books must end in a result or a LookupException,
// never another exception, and refreshing must never write a value that breaks the database.
// Run: copy to the project's test folder, `flutter test test/pgm310_lookup_fuzz_test.dart`.
import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/finding.dart';
import 'package:pagemark/lookup.dart';

final rnd = Random(130);

Object? junk(int depth) {
  switch (rnd.nextInt(depth > 3 ? 6 : 9)) {
    case 0: return null;
    case 1: return rnd.nextInt(100000) - 50000;
    case 2: return rnd.nextDouble() * 1e12;
    case 3: return ['', 'x', '9780441172719', '0', '-5', 'NaN', 'A' * 5000, '\u0000‮', '1999-99-99'][rnd.nextInt(9)];
    case 4: return rnd.nextBool();
    case 5: return <Object?>[];
    case 6: return [for (var i = 0; i < rnd.nextInt(4); i++) junk(depth + 1)];
    default: return {for (final k in ['title', 'authors', 'volumeInfo', 'imageLinks', 'thumbnail', 'industryIdentifiers', 'identifier', 'pageCount', 'publishedDate', 'categories', 'description', 'publisher', 'isbn_13', 'isbn_10', 'covers', 'number_of_pages', 'publish_date', 'publishers', 'entries', 'items', 'docs', 'key', 'author_name', 'subject', 'cover_i']) if (rnd.nextInt(3) == 0) k: junk(depth + 1)};
  }
}

http.Response json(Object? o) => http.Response.bytes(utf8.encode(jsonEncode(o)), 200, headers: {'content-type': 'application/json'});

void main() {
  setUp(() => Lookup.retryDelay = Duration.zero);

  test('parseVolume survives 5000 random shapes', () {
    for (var i = 0; i < 5000; i++) {
      final v = junk(0);
      final m = Lookup.parseVolume(v is Map ? {'volumeInfo': v['volumeInfo'] ?? v} : v);
      if (m != null) {
        expect(m.title, isNotEmpty);
        expect(m.pages == null || m.pages! > 0 || m.pages == 0, isTrue);
      }
    }
  });

  test('searchAll, byIsbnAll and editions only ever return a result or a LookupException', () async {
    for (var i = 0; i < 400; i++) {
      final body = junk(0);
      Lookup.client = MockClient((_) async => json(body is Map ? {'items': [body, junk(1)], 'docs': [body, junk(1)], 'entries': [body, junk(1)]} : body));
      for (final f in <Future<Object?> Function()>[
        () => Lookup.searchAll('dune'),
        () => Lookup.byIsbnAll('9780441172719'),
        () => Lookup.editions('/works/OL1W'),
      ]) {
        try {
          await f();
        } on LookupException {
          // fine
        }
      }
    }
  });

  test('non-JSON bodies and cut-off JSON are a LookupException', () async {
    for (final body in ['<html>503</html>', '{"items": [', '', '\u0000\u0000']) {
      Lookup.client = MockClient((_) async => http.Response(body, 200));
      await expectLater(Lookup.searchAll('dune'), throwsA(isA<LookupException>()));
    }
  });

  test('refreshChanges and its write never produce a value the database rejects, whatever the lookup says', () async {
    final db = AppDb.memory();
    final id = await db.into(db.books).insert(BooksCompanion.insert(title: 'T'));
    final b = await (db.select(db.books)..where((x) => x.id.equals(id))).getSingle();
    for (var i = 0; i < 300; i++) {
      final m = BookMeta(
        title: 'T', author: 'A' * rnd.nextInt(3000), isbn: '9780441172719', coverUrl: 'https://x/${'y' * rnd.nextInt(5000)}', genre: '\u0000', publisher: '',
        description: 'd' * rnd.nextInt(100000), year: [null, -1, 0, 99999999, 1990][rnd.nextInt(5)], pages: [null, -5, 0, 1 << 40, 300][rnd.nextInt(5)],
      );
      final c = refreshChanges(b, m);
      await (db.update(db.books)..where((x) => x.id.equals(id))).write(changesToCompanion(c));
    }
    await db.close();
  });
}
