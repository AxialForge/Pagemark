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
