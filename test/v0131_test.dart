import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/finding.dart';
import 'package:pagemark/lookup.dart';

http.Response json(Object o, [int code = 200]) => http.Response.bytes(utf8.encode(jsonEncode(o)), code, headers: {'content-type': 'application/json'});

void main() {
  setUp(() => Lookup.retryDelay = Duration.zero);

  group('device test fixes in 0.13.2', () {
    test('PGM-333: pages and year typed into Edit book are checked, empty is fine', () {
      expect(checkBookNumbers('', ''), isNull);
      expect(checkBookNumbers('412', '1965'), isNull);
      expect(checkBookNumbers('0', ''), contains('Pages'));
      expect(checkBookNumbers('99999', ''), contains('Pages'));
      expect(checkBookNumbers('12x', ''), contains('Pages'));
      expect(checkBookNumbers('', '999'), contains('Year'));
      expect(checkBookNumbers('', '2101'), contains('Year'));
      expect(checkBookNumbers(' 20000 ', ' 2100 '), isNull);
    });

    test('PGM-334: adding books to a shelf reports only the new ones, and Undo takes off only those', () async {
      final db = AppDb.memory();
      final a = await db.into(db.books).insert(BooksCompanion.insert(title: 'A'));
      final b = await db.into(db.books).insert(BooksCompanion.insert(title: 'B'));
      final shelf = await db.addShelf('Test');
      await db.setOnShelf(a, shelf, true); // already there
      final added = await db.addManyToShelf([a, b], shelf);
      expect(added, [b]);
      expect((await db.select(db.bookShelves).get()).length, 2);
      await db.removeManyFromShelf(added, shelf);
      final left = await db.select(db.bookShelves).get();
      expect([for (final l in left) l.bookId], [a], reason: 'the book that was already on the shelf stays');
      expect(await db.addManyToShelf([a], shelf), isEmpty);
      await db.close();
    });

    test('PGM-335: the work id is found from the ISBN, else from a title search, and never throws', () async {
      Lookup.client = MockClient((req) async {
        if (req.url.path == '/isbn/9780441172719.json') return json({'works': [{'key': '/works/OL893415W'}]});
        return json({}, 500);
      });
      expect(await Lookup.findWorkKey(isbn: '9780441172719', title: 'Dune'), '/works/OL893415W');

      Lookup.client = MockClient((req) async {
        if (req.url.path == '/search.json') {
          return json({'docs': [{'key': '/works/OL1W', 'title': 'Summary of Dune'}, {'key': '/works/OL2W', 'title': 'Dune', 'author_name': ['Frank Herbert']}]});
        }
        return json({}, 404);
      });
      expect(await Lookup.findWorkKey(title: 'Dune', author: 'Frank Herbert'), '/works/OL2W', reason: 'a study guide is not picked');

      Lookup.client = MockClient((_) async => json({}, 500));
      expect(await Lookup.findWorkKey(isbn: '9780441172719', title: 'Dune'), '');
      expect(await Lookup.findWorkKey(), '');
    });
  });

  test('PGM-337/336: a failed lookup is a LookupException with a plain message the screens can show', () async {
    Lookup.client = MockClient((_) async => json({}, 503));
    try {
      await Lookup.byIsbnAll('9780441172719');
      fail('should have thrown');
    } on LookupException catch (e) {
      expect(e.message, isNotEmpty);
      expect(e.message.toLowerCase(), contains('busy'));
    }
  });
}
