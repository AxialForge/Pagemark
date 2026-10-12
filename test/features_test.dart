import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/features.dart';

Future<int> addBook(AppDb db, String title, {int? pages, String series = '', double? number, bool locked = false}) =>
    db.into(db.books).insert(BooksCompanion.insert(
        title: title, pages: Value(pages), series: Value(series), seriesNumber: Value(number), locked: Value(locked)));

void main() {
  group('shelves', () {
    late AppDb db;
    setUp(() => db = AppDb.memory());
    tearDown(() => db.close());

    test('a book can sit on several shelves; names are unique; deleting a shelf keeps the books', () async {
      final a = await addBook(db, 'A');
      final s1 = await db.addShelf('Comfort reads');
      final again = await db.addShelf('  Comfort reads ');
      expect(again, s1, reason: 'same name reuses the shelf');
      final s2 = await db.addShelf('Book club');
      await db.setOnShelf(a, s1, true);
      await db.setOnShelf(a, s2, true);
      await db.setOnShelf(a, s2, true); // idempotent
      expect((await db.watchShelfLinks().first).length, 2);
      await db.setOnShelf(a, s1, false);
      expect((await db.watchShelfLinks().first).single.shelfId, s2);
      await db.deleteShelf(s2);
      expect(await db.watchShelfLinks().first, isEmpty);
      expect((await db.watchLibrary(locked: false).first).single.book.id, a);
    });

    test('purging a book removes its shelf links', () async {
      final a = await addBook(db, 'A');
      final s = await db.addShelf('X');
      await db.setOnShelf(a, s, true);
      await db.purgeBook(a);
      expect(await db.watchShelfLinks().first, isEmpty);
    });
  });

  group('progress', () {
    test('fraction comes from the active read, clamped, and needs a page count', () async {
      final db = AppDb.memory();
      final id = await addBook(db, 'Dune', pages: 400);
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('reading'), currentPage: const Value(100)));
      var row = (await db.watchLibrary(locked: false).first).single;
      expect(row.progress, 0.25);
      await (db.update(db.reads)).write(const ReadsCompanion(currentPage: Value(900)));
      row = (await db.watchLibrary(locked: false).first).single;
      expect(row.progress, 1.0);
      await (db.update(db.reads)).write(const ReadsCompanion(status: Value('finished')));
      row = (await db.watchLibrary(locked: false).first).single;
      expect(row.progress, isNull, reason: 'finished reads show no progress bar');
      await db.close();
    });

    test('no page count means no progress', () async {
      final db = AppDb.memory();
      final id = await addBook(db, 'X');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('reading'), currentPage: const Value(10)));
      expect((await db.watchLibrary(locked: false).first).single.progress, isNull);
      await db.close();
    });
  });

  group('stars', () {
    test('starsText renders whole and half stars', () {
      expect(starsText(5), '★★★★★');
      expect(starsText(4.5), '★★★★½');
      expect(starsText(3), '★★★');
      expect(starsText(0.5), '½');
    });

    testWidgets('tapping the left half of a star gives .5, right half a whole, same value clears', (t) async {
      double v = 0;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(builder: (c, set) => StarRating(value: v, size: 40, onChanged: (x) => set(() => v = x))))));
      final first = t.getTopLeft(find.byType(Icon).first);
      await t.tapAt(first + const Offset(5, 20)); // left half of star 1
      expect(v, 0.5);
      await t.pumpAndSettle(const Duration(seconds: 1));
      await t.tapAt(t.getTopLeft(find.byType(Icon).first) + const Offset(35, 20)); // right half of star 1
      expect(v, 1.0);
      await t.pumpAndSettle(const Duration(seconds: 1));
      await t.tapAt(t.getTopLeft(find.byType(Icon).first) + const Offset(35, 20)); // same again -> clear
      expect(v, 0);
      await t.pumpAndSettle(const Duration(seconds: 1));
      final third = t.getTopLeft(find.byType(Icon).at(2));
      await t.tapAt(third + const Offset(30, 20));
      expect(v, 3.0);
    });
  });

  group('series', () {
    test('series numbers are kept as decimals and formatted without a trailing .0', () async {
      expect(SeriesPage.fmtNum(2), '2');
      expect(SeriesPage.fmtNum(2.5), '2.5');
      expect(SeriesPage.fmtNum(null), '');
      final db = AppDb.memory();
      await addBook(db, 'Book 2.5', series: 'Dune', number: 2.5);
      expect((await db.watchLibrary(locked: false).first).single.book.seriesNumber, 2.5);
      await db.close();
    });
  });

  testWidgets('goal ring and bar chart render without errors', (t) async {
    await t.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: Column(children: [
      GoalRing(done: 3, goal: 10),
      GoalRing(done: 12, goal: 10),
      GoalRing(done: 0, goal: 0),
      BarChart(values: [0, 1, 4, 2], labels: ['a', 'b', 'c', 'd']),
      BarChart(values: [0, 0], labels: ['a', 'b']),
    ])))));
    await t.pumpAndSettle();
    expect(find.text('3/10'), findsOneWidget);
    expect(find.text('12/10'), findsOneWidget);
    expect(tester(t), isNull);
  });
}

Object? tester(WidgetTester t) => t.takeException();
