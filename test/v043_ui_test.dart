import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/branding.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/features.dart';
import 'package:pagemark/lock.dart';
import 'package:pagemark/lock_ui.dart';
import 'package:pagemark/skins.dart';
import 'package:pagemark/themes.dart';
import 'package:pagemark/widgets.dart';

Future<List<BookRow>> sample(int n) async {
  final db = AppDb.memory();
  for (var i = 0; i < n; i++) {
    final id = await db.into(db.books).insert(BooksCompanion.insert(
        title: i % 3 == 0 ? 'A Very Long Title That Keeps Going For A While Volume ${i + 1}' : 'Book $i',
        author: Value(i % 2 == 0 ? 'Someone With A Rather Long Name' : ''), pages: Value(200 + i * 30), series: Value(i % 4 == 0 ? 'The Long Running Series' : '')));
    await db.into(db.reads).insert(ReadsCompanion.insert(
        bookId: id, status: Value(i % 2 == 0 ? 'reading' : 'finished'), rating: Value(i % 2 == 0 ? null : 4.5), currentPage: const Value(80)));
  }
  final rows = await db.watchLibrary(locked: false).first;
  await db.close();
  return rows;
}

Widget scaled(Widget child, double scale, {ThemeData? theme}) => MaterialApp(
      theme: theme,
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
      home: Scaffold(body: child),
    );

void main() {
  group('lock gate', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      LockService.debugDeviceSupported = false; // a phone with no screen lock / fingerprint
    });
    tearDown(() => LockService.debugDeviceSupported = null);

    testWidgets('device-lock mode with no screen lock explains itself instead of showing a dead Unlock button', (t) async {
      FlutterSecureStorage.setMockInitialValues({'mode': 'device'});
      await t.pumpWidget(MaterialApp(home: LockGate(onUnlock: () {})));
      await t.pumpAndSettle();
      expect(find.textContaining('no longer has a screen lock'), findsOneWidget);
      expect(find.text('Open security settings'), findsOneWidget);
      expect(find.text('Unlock'), findsNothing);
    });

    testWidgets('PIN mode shows the PIN field, Forgot PIN and no lockout text', (t) async {
      FlutterSecureStorage.setMockInitialValues({'mode': 'pin'});
      await t.pumpWidget(MaterialApp(home: LockGate(onUnlock: () {})));
      await t.pumpAndSettle();
      expect(find.text('Forgot PIN?'), findsOneWidget);
      expect(find.textContaining('Too many attempts'), findsNothing);
    });
  });

  group('widgets', () {
    testWidgets('ExpandableText shows Read more only when the text is long, and toggles', (t) async {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 200, child: ExpandableText('word ' * 80, maxLines: 3)))));
      expect(find.text('Read more'), findsOneWidget);
      await t.tap(find.text('Read more'));
      await t.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 200, child: ExpandableText('short', maxLines: 3)))));
      expect(find.text('Read more'), findsNothing);
    });

    testWidgets('confirmDiscard returns true only on Discard', (t) async {
      bool? result;
      await t.pumpWidget(MaterialApp(home: Builder(builder: (c) => Scaffold(body: Center(child: ElevatedButton(onPressed: () async => result = await confirmDiscard(c), child: const Text('go')))))));
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.text('Keep editing'));
      await t.pumpAndSettle();
      expect(result, isFalse);
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      await t.tap(find.text('Discard'));
      await t.pumpAndSettle();
      expect(result, isTrue);
    });
  });

  group('text at 200% (large accessibility font)', () {
    for (final skin in LibrarySkin.values) {
      testWidgets('${skin.name} survives 2x text on a phone', (t) async {
        final rows = await t.runAsync(() => sample(12)) ?? [];
        await t.binding.setSurfaceSize(const Size(411, 860));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await t.pumpWidget(scaled(SkinView(skin: skin, rows: rows), 2.0, theme: themes[3].data));
        await t.pumpAndSettle(const Duration(seconds: 2));
        expect(t.takeException(), isNull, reason: '${skin.name} overflows at 200% text');
      });
    }

    testWidgets('empty state, goal ring and charts survive 2x text', (t) async {
      await t.binding.setSurfaceSize(const Size(360, 700));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(scaled(const SingleChildScrollView(child: Column(children: [
        SizedBox(height: 300, child: EmptyState(message: 'Your shelf is empty.\nAdd your first book to start your log.', actionLabel: 'Add a book')),
        GoalRing(done: 12, goal: 24),
        BarChart(values: [1, 2, 3, 0, 4], labels: ['J', 'F', 'M', 'A', 'M']),
      ])), 2.0));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });
}
