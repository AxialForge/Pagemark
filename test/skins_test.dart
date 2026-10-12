import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/skins.dart';
import 'package:pagemark/themes.dart';

Future<List<BookRow>> sample(int n) async {
  final db = AppDb.memory();
  for (var i = 0; i < n; i++) {
    final id = await db.into(db.books).insert(BooksCompanion.insert(
          title: i % 5 == 0 ? 'A Very Long Title That Goes On And On About Everything Imaginable Volume $i' : 'Book $i',
          author: Value(i % 3 == 0 ? '' : 'Author $i'),
          pages: Value(i % 4 == 0 ? null : 120 + i * 37),
          series: Value(i % 6 == 0 ? 'Series' : ''),
        ));
    if (i % 2 == 0) {
      await db.into(db.reads).insert(ReadsCompanion.insert(
          bookId: id, status: Value(i % 4 == 0 ? 'reading' : 'finished'), rating: Value(i % 4 == 0 ? null : 3.5 + (i % 3) * 0.5), currentPage: Value(i % 4 == 0 ? 60 : null)));
    }
  }
  final rows = await db.watchLibrary(locked: false).first;
  await db.close();
  return rows;
}

void main() {
  group('every skin renders cleanly at phone and tablet widths', () {
    for (final skin in LibrarySkin.values) {
      for (final width in [320.0, 411.0, 820.0]) {
        for (final count in [0, 1, 7, 40]) {
          testWidgets('${skin.name} · ${width.toInt()}dp · $count books', (t) async {
            final rows = await t.runAsync(() => sample(count)) ?? [];
            await t.binding.setSurfaceSize(Size(width, 900));
            addTearDown(() => t.binding.setSurfaceSize(null));
            for (final theme in [themes[0], themes[3]]) {
              await t.pumpWidget(MaterialApp(theme: theme.data, home: Scaffold(body: SkinView(skin: skin, rows: rows))));
              await t.pumpAndSettle(const Duration(seconds: 2));
              expect(t.takeException(), isNull, reason: 'layout/overflow problem in ${skin.name} @${width}dp with $count books (${theme.id})');
            }
          });
        }
      }
    }
  });

  testWidgets('switching skins cross-fades without errors and ends on the new skin', (t) async {
    final rows = await t.runAsync(() => sample(12)) ?? [];
    Widget app(LibrarySkin s) => MaterialApp(home: Scaffold(body: SkinView(skin: s, rows: rows)));
    await t.pumpWidget(app(LibrarySkin.classic));
    await t.pumpAndSettle();
    for (final s in [LibrarySkin.grid, LibrarySkin.shelf, LibrarySkin.spines, LibrarySkin.compact, LibrarySkin.classic]) {
      await t.pumpWidget(app(s));
      await t.pump(const Duration(milliseconds: 100)); // mid-fade: both skins mounted
      expect(t.takeException(), isNull);
      await t.pumpAndSettle();
    }
  });

  test('spine and blank-cover text is readable (WCAG AA 4.5:1) on every colour in every theme', () {
    for (final theme in themes) {
      final cs = theme.data.colorScheme;
      for (var i = 0; i < 2000; i++) {
        final title = 'Title number $i about ${i * 7919 % 977}';
        final bg = bookColorFor(title, cs), fg = onBookColor(bg);
        final lb = bg.computeLuminance(), lf = fg.computeLuminance();
        final ratio = (lb > lf ? lb + 0.05 : lf + 0.05) / (lb > lf ? lf + 0.05 : lb + 0.05);
        expect(ratio, greaterThanOrEqualTo(4.5), reason: '${theme.id}: "$title" ratio $ratio');
      }
    }
  });

  test('spine colours differ between themes (they follow the theme) but are stable within one', () {
    final a = bookColorFor('Dune', themes[0].data.colorScheme), a2 = bookColorFor('Dune', themes[0].data.colorScheme);
    final b = bookColorFor('Dune', themes[2].data.colorScheme);
    expect(a, a2);
    expect(a, isNot(b));
  });

  group('group by shelf', () {
    Future<(List<BookRow>, List<Shelf>, Map<int, Set<int>>)> world() async {
      final db = AppDb.memory();
      final a = await db.into(db.books).insert(BooksCompanion.insert(title: 'Alpha'));
      final b = await db.into(db.books).insert(BooksCompanion.insert(title: 'Beta'));
      await db.into(db.books).insert(BooksCompanion.insert(title: 'Gamma'));
      final fav = await db.addShelf('Favourites');
      final club = await db.addShelf('Book club');
      await db.addShelf('Empty one');
      await db.setOnShelf(a, fav, true);
      await db.setOnShelf(b, fav, true);
      await db.setOnShelf(b, club, true);
      final rows = await db.watchLibrary(locked: false).first;
      final shelves = await db.watchShelves().first;
      final links = <int, Set<int>>{};
      for (final l in await db.watchShelfLinks().first) { (links[l.shelfId] ??= {}).add(l.bookId); }
      await db.close();
      return (rows, shelves, links);
    }

    test('groupRows: one group per non-empty shelf, a book may sit on two, the rest are "Not on a shelf"', () async {
      final (rows, shelves, links) = await world();
      final g = groupRows(rows, shelves, links);
      expect(g.map((x) => x.label), ['Book club', 'Favourites', 'Not on a shelf']);
      expect(g.map((x) => x.rows.length), [1, 2, 1]);
      expect(g.last.renamable, isFalse);
      expect(g.first.renamable, isTrue);
    });

    test('with no shelves at all there is a single unlabelled group', () async {
      final (rows, _, _) = await world();
      final g = groupRows(rows, const [], const {});
      expect(g.length, 1);
      expect(g.single.label, isNull);
    });

    for (final skin in [LibrarySkin.shelf, LibrarySkin.spines]) {
      testWidgets('${skin.name}: nameplates show shelf names and counts, tapping one offers to rename it', (t) async {
        final (rows, shelves, links) = (await t.runAsync(world))!;
        await t.binding.setSurfaceSize(const Size(411, 900));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await t.pumpWidget(MaterialApp(home: Scaffold(body: SkinView(skin: skin, rows: rows, groupByShelf: true, shelves: shelves, shelfBooks: links))));
        await t.pumpAndSettle(const Duration(seconds: 2));
        expect(find.textContaining('FAVOURITES'), findsOneWidget);
        expect(find.textContaining('BOOK CLUB'), findsOneWidget);
        expect(find.textContaining('NOT ON A SHELF'), findsOneWidget);
        expect(find.textContaining('FAVOURITES  ·  2'), findsOneWidget);
        await t.tap(find.textContaining('FAVOURITES'));
        await t.pumpAndSettle();
        expect(find.text('Rename shelf'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('grouping is ignored by styles that cannot show it', (t) async {
      final (rows, shelves, links) = (await t.runAsync(world))!;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SkinView(skin: LibrarySkin.compact, rows: rows, groupByShelf: true, shelves: shelves, shelfBooks: links))));
      await t.pumpAndSettle();
      expect(find.textContaining('FAVOURITES'), findsNothing);
    });
  });

  group('themes', () {
    test('six themes with unique ids and names; the original four ids are unchanged so saved choices survive', () {
      expect(themes.length, 6);
      expect({for (final t in themes) t.id}.length, 6);
      expect({for (final t in themes) t.name}.length, 6);
      for (final id in ['light_him', 'dark_him', 'light_her', 'dark_her']) {
        expect(themes.any((t) => t.id == id), isTrue, reason: id);
      }
      expect(themes.where((t) => t.brightness == Brightness.dark).length, 3);
      expect(themeById('nonsense').id, 'light_him');
    });

    test('no theme name mentions gender', () {
      for (final t in themes) {
        expect(t.name.toLowerCase(), isNot(anyOf(contains('him'), contains('her '), contains('his'), contains('men'))), reason: t.name);
      }
    });
  });

  test('skin ids round-trip and unknown ids fall back to classic', () {
    for (final s in LibrarySkin.values) {
      expect(skinById(s.name), s);
    }
    expect(skinById(null), LibrarySkin.classic);
    expect(skinById('nonsense'), LibrarySkin.classic);
  });

  testWidgets('the picker lists every skin and returns the tapped one', (t) async {
    LibrarySkin? picked;
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => Scaffold(body: Center(child: ElevatedButton(onPressed: () async => picked = await showSkinPicker(c, LibrarySkin.classic), child: const Text('open')))),
      ),
    ));
    await t.binding.setSurfaceSize(const Size(411, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    for (final s in LibrarySkin.values) {
      expect(find.text(s.label), findsOneWidget);
    }
    await t.tap(find.text('Bookshelf'));
    await t.pumpAndSettle();
    expect(picked, LibrarySkin.shelf);
  });

  testWidgets('on a short screen the picker scrolls instead of overflowing, and every skin is reachable', (t) async {
    LibrarySkin? picked;
    await t.binding.setSurfaceSize(const Size(640, 360)); // landscape phone
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(MaterialApp(
      home: Builder(
        builder: (c) => Scaffold(body: Center(child: ElevatedButton(onPressed: () async => picked = await showSkinPicker(c, LibrarySkin.classic), child: const Text('open')))),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Compact'), 60);
    await t.tap(find.text('Compact'));
    await t.pumpAndSettle();
    expect(picked, LibrarySkin.compact);
    expect(t.takeException(), isNull);
  });
}
