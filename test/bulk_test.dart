import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/selection.dart';
import 'package:pagemark/skins.dart';

Future<int> add(AppDb db, String t, {bool locked = false}) => db.into(db.books).insert(BooksCompanion.insert(title: t, locked: Value(locked)));

void main() {
  group('bulk database operations', () {
    late AppDb db;
    setUp(() => db = AppDb.memory());
    tearDown(() => db.close());

    test('trash many then restore many', () async {
      final a = await add(db, 'A'), b = await add(db, 'B'), c = await add(db, 'C');
      await db.softDeleteMany({a, b});
      expect((await db.watchLibrary(locked: false).first).map((r) => r.book.title), ['C']);
      await db.restoreMany({a, b});
      expect((await db.watchLibrary(locked: false).first).length, 3);
      expect(c, isPositive);
    });

    test('move to the vault and back', () async {
      final a = await add(db, 'A'), b = await add(db, 'B');
      await db.setLockedMany({a}, true);
      expect((await db.watchLibrary(locked: true).first).single.book.id, a);
      expect((await db.watchLibrary(locked: false).first).single.book.id, b);
      await db.setLockedMany({a}, false);
      expect((await db.watchLibrary(locked: true).first), isEmpty);
    });

    test('add many to a shelf is idempotent', () async {
      final a = await add(db, 'A'), b = await add(db, 'B');
      final s = await db.addShelf('Pile');
      await db.addManyToShelf({a, b}, s);
      await db.addManyToShelf({a}, s);
      expect((await db.watchShelfLinks().first).length, 2);
    });

    test('mark finished today: updates the active read, creates one when none, leaves finished ones, and undoes exactly', () async {
      final reading = await add(db, 'Reading'), none = await add(db, 'None'), done = await add(db, 'Done'), multi = await add(db, 'Multi');
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: reading, status: const Value('reading'), started: Value(DateTime(2026, 1, 1)), currentPage: const Value(40)));
      final doneDate = DateTime(2025, 5, 5);
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: done, status: const Value('finished'), finished: Value(doneDate)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: multi, status: const Value('finished'), finished: Value(doneDate))); // an old read
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: multi, status: const Value('reading'))); // a re-read in progress

      final before = (await db.select(db.reads).get()).length;
      final u = await db.markFinishedToday({reading, none, done, multi});
      expect(u.changed.length, 2, reason: 'the in-progress reads of "Reading" and "Multi"');
      expect(u.created.length, 1, reason: 'a read is made for "None"');
      final reads = await db.select(db.reads).get();
      expect(reads.length, before + 1);
      final r = reads.firstWhere((x) => x.bookId == reading);
      expect(r.status, 'finished');
      expect(r.currentPage, 40, reason: 'other fields are untouched');
      expect(r.finished!.day, DateTime.now().day);
      expect(reads.where((x) => x.bookId == done).single.finished, doneDate, reason: 'already-finished reads keep their date');
      expect(reads.where((x) => x.bookId == multi && x.finished == doneDate).length, 1, reason: 'the old read is not touched');

      await db.undoMarkFinished(u);
      final after = await db.select(db.reads).get();
      expect(after.length, before);
      expect(after.firstWhere((x) => x.bookId == reading).status, 'reading');
      expect(after.firstWhere((x) => x.bookId == reading).finished, isNull);
      expect(after.where((x) => x.bookId == none), isEmpty);
      expect(after.where((x) => x.bookId == multi && x.status == 'reading').length, 1);
    });
  });

  group('selection in every Library style', () {
    Future<List<BookRow>> rows() async {
      final db = AppDb.memory();
      for (var i = 0; i < 6; i++) {
        final id = await add(db, 'Book $i');
        if (i.isEven) await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('reading')));
      }
      final r = await db.watchLibrary(locked: false).first;
      await db.close();
      return r;
    }

    for (final skin in LibrarySkin.values) {
      testWidgets('${skin.name}: long-press selects, tap toggles while active, selected items show a check', (t) async {
        final data = (await t.runAsync(rows))!;
        final selected = <int>{};
        final toggled = <int>[];
        await t.binding.setSurfaceSize(const Size(411, 900));
        addTearDown(() => t.binding.setSurfaceSize(null));
        Widget app() => MaterialApp(
              home: StatefulBuilder(
                builder: (context, setState) => Scaffold(
                  body: SelectionScope(
                    selected: selected,
                    onToggle: (r) => setState(() { toggled.add(r.book.id); selected.contains(r.book.id) ? selected.remove(r.book.id) : selected.add(r.book.id); }),
                    onQuickFinish: (_) {},
                    onQuickTrash: (_) {},
                    child: SkinView(skin: skin, rows: data),
                  ),
                ),
              ),
            );
        await t.pumpWidget(app());
        await t.pumpAndSettle(const Duration(seconds: 2));
        expect(find.byType(SelectedBadge), findsNothing);

        final target = find.text('Book 0').first; // every style draws the title somewhere tappable
        await t.longPress(target);
        await t.pumpAndSettle();
        expect(toggled.length, 1, reason: '${skin.name}: long-press should start a selection');
        expect(find.byType(SelectedBadge), findsOneWidget);

        await t.tap(target); // selection active: a tap toggles it off instead of opening the book
        await t.pumpAndSettle();
        expect(toggled.length, 2);
        expect(find.byType(SelectedBadge), findsNothing);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('swiping a classic row right marks it finished, left trashes it; neither removes the widget itself', (t) async {
      final data = (await t.runAsync(rows))!;
      final finished = <int>[], trashed = <int>[];
      await t.binding.setSurfaceSize(const Size(411, 900));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SelectionScope(
            selected: const {},
            onToggle: (_) {},
            onQuickFinish: (r) => finished.add(r.book.id),
            onQuickTrash: (r) => trashed.add(r.book.id),
            child: SkinView(skin: LibrarySkin.classic, rows: data),
          ),
        ),
      ));
      await t.pumpAndSettle(const Duration(seconds: 2));
      await t.drag(find.textContaining('Book ').first, const Offset(400, 0));
      await t.pumpAndSettle();
      expect(finished.length, 1);
      await t.drag(find.textContaining('Book ').at(1), const Offset(-400, 0));
      await t.pumpAndSettle();
      expect(trashed.length, 1);
      expect(find.textContaining('Book '), findsWidgets, reason: 'rows stay until the database stream updates them');
      expect(t.takeException(), isNull);
    });
  });
}
