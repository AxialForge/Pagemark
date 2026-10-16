import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/branding.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/guide.dart';
import 'package:pagemark/lookup.dart';
import 'package:pagemark/main.dart' show prefs;
import 'package:pagemark/reading_life_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response json(Object o) => http.Response.bytes(utf8.encode(jsonEncode(o)), 200, headers: {'content-type': 'application/json'});

void main() {
  setUp(() => Lookup.retryDelay = Duration.zero);

  group('audit fixes in 0.13.1', () {
    testWidgets('PGM-320: a timer left on another book can be stopped from this one', (t) async {
      SharedPreferences.setMockInitialValues({'timer_book': 1, 'timer_start': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()});
      final p = await SharedPreferences.getInstance();
      prefs = p;
      final other = Book(id: 2, title: 'Other', author: '', isbn: '', coverUrl: '', genre: '', series: '', publisher: '', description: '', tags: '', notes: '', locked: false, added: DateTime(2026));
      final read = Read(id: 9, bookId: 2, format: 'print', status: 'reading', thoughts: '', narrator: '', contentNotes: '');
      await t.pumpWidget(MaterialApp(home: Scaffold(body: ReadingTimerCard(book: other, read: read))));
      expect(find.text('The reading timer is running for another book.'), findsOneWidget);
      await t.tap(find.text('Stop it'));
      await t.pumpAndSettle();
      expect(find.text('Stop the other timer?'), findsOneWidget);
      expect(find.textContaining('Other'), findsNothing, reason: 'the dialog names no book');
      await t.tap(find.text('Throw it away'));
      await t.pumpAndSettle();
      expect(p.getString('timer_start'), isNull);
      expect(p.getInt('timer_book'), isNull);
      expect(find.text('Start'), findsOneWidget);
    });

    test('PGM-302: genres are split, de-duplicated and stripped of labels, places and characters', () {
      expect(
        Lookup.genres(['Dune (Imaginary place)', 'Fiction, science fiction, general', 'Dune (imaginary place)', 'fiction', 'Ecology', 'Space opera', 'Atreides, Paul (Fictitious character)']),
        'Science fiction, Ecology, Space opera',
      );
      expect(Lookup.genres(['nyt:hardcover-fiction=2020-01-01', 'Reading Level-Grade 9', 'Accessible book']), '');
      expect(Lookup.genres(['Fantasy', 'fantasy', 'FANTASY']), 'Fantasy');
      expect(Lookup.genres(['Science fiction', 'Science-fiction', 'American literature']), 'Science fiction, American literature', reason: 'a hyphen is not a new genre');
      expect(Lookup.genres([1, null, 'Crime / Thriller']), 'Crime, Thriller');
    });

    test('PGM-303: absurd page counts and years from either source are not kept', () async {
      expect(Lookup.parseVolume({'volumeInfo': {'title': 'A', 'pageCount': -5}})!.pages, isNull);
      expect(Lookup.parseVolume({'volumeInfo': {'title': 'A', 'pageCount': 1 << 40}})!.pages, isNull);
      expect(Lookup.parseVolume({'volumeInfo': {'title': 'A', 'pageCount': 412}})!.pages, 412);
      Lookup.client = MockClient((_) async => json({'docs': [{'key': '/works/OL1W', 'title': 'B', 'number_of_pages_median': -3, 'first_publish_year': 99999}]}));
      final r = (await Lookup.search('b')).single;
      expect([r.pages, r.year], [null, null]);
    });

    testWidgets('PGM-300: a month of the calendar stays short on a wide screen', (t) async {
      t.view.physicalSize = const Size(2400, 1400);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: StreakCard(days: const {}, now: DateTime(2026, 10, 14))))));
      expect(t.getSize(find.byType(GridView)).height, lessThanOrEqualTo(44.0 * 6));
    });

    testWidgets('PGM-301: the guide keeps a reading width on a wide screen', (t) async {
      t.view.physicalSize = const Size(2400, 1400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const MaterialApp(home: GuidePage()));
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(TextField)).width, lessThanOrEqualTo(720));
    });

    testWidgets('PGM-322: the empty-state help button does not look like an Add button', (t) async {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: EmptyState(message: 'x', actionLabel: 'See how Pagemark works', onAction: () {}, actionIcon: Icons.help_outline))));
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });
}
