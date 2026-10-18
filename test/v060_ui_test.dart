import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/book_extras.dart';
import 'package:pagemark/covers.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/skins.dart';
import 'package:pagemark/ui.dart' show Cover;

void main() {
  group('authors', () {
    test('several authors are split on commas, semicolons, & and "and"; matching ignores case', () {
      expect(authorsOf('Terry Pratchett, Neil Gaiman'), ['Terry Pratchett', 'Neil Gaiman']);
      expect(authorsOf('A. One & B. Two'), ['A. One', 'B. Two']);
      expect(authorsOf('A and B; C'), ['A', 'B', 'C']);
      expect(authorsOf(''), isEmpty);
      final b = Book(kind: '', owned: true, id: 1, title: 't', author: 'Terry Pratchett, Neil Gaiman', isbn: '', coverUrl: '', genre: '', series: '', publisher: '', description: '', tags: '', notes: '', locked: false, added: DateTime(2026), seriesNumber: null, seriesTotal: null, year: null, pages: null, deletedAt: null);
      expect(bookBy(b, 'neil gaiman'), isTrue);
      expect(bookBy(b, 'Pratchett'), isFalse, reason: 'whole names only');
    });
  });

  group('heat', () {
    testWidgets('tapping a flame sets the level, tapping the same one again clears it', (t) async {
      var v = 0;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(builder: (c, set) => HeatRating(value: v, onChanged: (x) => set(() => v = x))))));
      await t.tap(find.byTooltip('Heat 3'));
      await t.pump();
      expect(v, 3);
      await t.tap(find.byTooltip('Heat 3'));
      await t.pump();
      expect(v, 0);
      await t.tap(find.byTooltip('Heat 5'));
      await t.pump();
      expect(v, 5);
    });
    test('heatText', () => expect(heatText(3), '🔥🔥🔥'));
  });

  group('local covers are drawn in every Library style', () {
    late Directory tmp;
    setUp(() {
      tmp = Directory.systemTemp.createTempSync('pgm060ui');
      CoverStore.useDir(Directory('${tmp.path}/covers'));
    });
    tearDown(() {
      imageCache.clear(); // release decoded-file handles (Windows cannot delete open files)
      imageCache.clearLiveImages();
      try {
        tmp.deleteSync(recursive: true);
      } catch (_) {}
    });

    // a valid 1x1 PNG
    final png = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0x0D, 0x49, 0x48, 0x44, 0x52, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 0x1F, 0x15, 0xC4, 0x89,
      0, 0, 0, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0, 0x1F, 0, 5, 0, 1, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0, 0, 0, 0, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];

    testWidgets('Cover shows a saved picture from disk, and falls back to the initial tile when the file is missing', (t) async {
      final local = (await t.runAsync(() => CoverStore.saveFile(1, File('${tmp.path}/p.png')..writeAsBytesSync(png), ext: '.png')))!;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: Column(children: [Cover(local, w: 60, title: 'Dune'), Cover('local:gone.jpg', w: 60, title: 'Dune'), Cover('local:../x', w: 60, title: 'Zed')]))));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200))); // let the real image decoder run
      await t.pump(const Duration(milliseconds: 300));
      expect(find.byType(Image), findsNWidgets(2), reason: 'the existing file and the missing one (which falls back via errorBuilder)');
      expect(find.text('D'), findsOneWidget, reason: 'missing file: the title-initial tile');
      expect(find.text('Z'), findsOneWidget, reason: 'unsafe name never touches the disk');
      expect(t.takeException(), isNull);
    });

    for (final skin in LibrarySkin.values) {
      testWidgets('${skin.name} with a saved cover renders without errors', (t) async {
        final db = AppDb.memory();
        final local = await t.runAsync(() => CoverStore.saveFile(1, File('${tmp.path}/q.png')..writeAsBytesSync(png), ext: '.png'));
        await t.runAsync(() => db.into(db.books).insert(BooksCompanion.insert(title: 'Saved Cover', coverUrl: Value(local!), pages: const Value(300))));
        final rows = (await t.runAsync(() => db.watchLibrary(locked: false).first))!;
        await t.runAsync(db.close);
        await t.binding.setSurfaceSize(const Size(411, 800));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await t.pumpWidget(MaterialApp(home: Scaffold(body: SkinView(skin: skin, rows: rows))));
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await t.pump(const Duration(seconds: 1));
        await t.pump(const Duration(seconds: 1));
        expect(t.takeException(), isNull);
      });
    }
  });
}
