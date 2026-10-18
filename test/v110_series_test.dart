import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/features.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/series.dart';

Future<int> vol(AppDb db, String series, num? n, {bool owned = true, bool read = false, String kind = 'manga', bool locked = false, int? total, String title = ''}) async {
  final id = await db.into(db.books).insert(BooksCompanion.insert(
      title: title.isEmpty ? '$series $n' : title,
      series: Value(series),
      seriesNumber: Value(n?.toDouble()),
      seriesTotal: Value(total),
      kind: Value(kind),
      owned: Value(owned),
      locked: Value(locked)));
  if (read) await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('finished')));
  return id;
}

Future<List<SeriesGroup>> groups(AppDb db, {bool locked = false}) async =>
    groupSeries(await db.watchLibrary(locked: locked).first, await db.watchSeriesInfo(locked: locked).first);

void main() {
  test('the grid shows read, owned, wanted and missing volumes', () async {
    final db = AppDb.memory();
    await vol(db, 'Berserk', 1, read: true);
    await vol(db, 'Berserk', 2);
    await vol(db, 'Berserk', 4, owned: false);
    await db.setSeriesInfo('Berserk', locked: false, total: 6, status: 'ongoing');
    final g = (await groups(db)).single;
    expect(g.total, 6);
    expect(g.cells.map((c) => c.state), [VolumeState.read, VolumeState.owned, VolumeState.missing, VolumeState.wanted, VolumeState.missing, VolumeState.missing]);
    expect([g.ownedCount, g.readCount, g.wantedCount, g.status], [2, 1, 1, 'ongoing']);
    expect(g.missing, [3, 5, 6]);
    expect(g.nextToBuy, 3);
    expect(g.nextNumber, 5);
    expect(g.nextToRead!.book.seriesNumber, 2);
    expect(g.missingText, 'Berserk: missing 3, 5-6');
    await db.close();
  });

  test('a total smaller than the highest volume you hold cannot hide one', () async {
    final db = AppDb.memory();
    await vol(db, 'Naruto', 1);
    await vol(db, 'Naruto', 9);
    await db.setSeriesInfo('Naruto', locked: false, total: 3);
    final g = (await groups(db)).single;
    expect(g.total, 9);
    expect(g.cells.last.state, VolumeState.owned);
    await db.close();
  });

  test('with no stored total the old per-book total is still used', () async {
    final db = AppDb.memory();
    await vol(db, 'Bleach', 1, total: 74);
    expect((await groups(db)).single.total, 74);
    await db.close();
  });

  test('half volumes, unnumbered books and omnibus numbers sit under the grid', () async {
    final db = AppDb.memory();
    await vol(db, 'Monster', 1);
    await vol(db, 'Monster', 1.5, title: 'Monster extra');
    await vol(db, 'Monster', null, title: 'Monster guide');
    final g = (await groups(db)).single;
    expect(g.cells, hasLength(2));
    expect(g.others.map((r) => r.book.title), ['Monster extra', 'Monster guide']);
    await db.close();
  });

  test('two copies of one volume: owned and read beats a wanted duplicate', () async {
    final db = AppDb.memory();
    await vol(db, 'Akira', 1, owned: false);
    await vol(db, 'Akira', 1, read: true, title: 'Akira 1 hardcover');
    final g = (await groups(db)).single;
    expect(g.cells.first.state, VolumeState.read);
    expect(g.cells.first.books, hasLength(2));
    await db.close();
  });

  test('names are matched ignoring case and spaces; plain books are left out', () async {
    final db = AppDb.memory();
    await vol(db, 'One Piece', 1);
    await vol(db, ' one piece ', 2);
    await db.into(db.books).insert(BooksCompanion.insert(title: 'Dune'));
    final all = await groups(db);
    expect(all, hasLength(1));
    expect(all.single.rows, hasLength(2));
    expect(all.single.name, 'One Piece');
    await db.close();
  });

  test('locked isolation: a locked series never appears in the main library, and the two keep separate info', () async {
    final db = AppDb.memory();
    await vol(db, 'Berserk', 1);
    await vol(db, 'Berserk', 2, locked: true);
    await vol(db, 'Secret Series', 1, locked: true);
    await db.setSeriesInfo('Berserk', locked: false, total: 41, status: 'ongoing');
    await db.setSeriesInfo('Berserk', locked: true, total: 3, status: 'complete');
    final main = await groups(db);
    expect(main.map((g) => g.name), ['Berserk']);
    expect([main.single.total, main.single.status, main.single.rows.length], [41, 'ongoing', 1]);
    final vault = await groups(db, locked: true);
    expect(vault.map((g) => g.name), ['Berserk', 'Secret Series']);
    expect([vault.first.total, vault.first.status], [3, 'complete']);
    await db.close();
  });

  test('the missing list is squeezed into ranges', () {
    expect(squeezeNumbers([3, 4, 5, 7, 9, 10]), '3-5, 7, 9-10');
    expect(squeezeNumbers([]), '');
    expect(squeezeNumbers([2]), '2');
  });

  test('a finished set says nothing is missing and has nothing left to buy', () async {
    final db = AppDb.memory();
    await vol(db, 'Pluto', 1, read: true);
    await vol(db, 'Pluto', 2, read: true);
    await db.setSeriesInfo('Pluto', locked: false, total: 2, status: 'complete');
    final g = (await groups(db)).single;
    expect([g.missing, g.nextToBuy, g.nextToRead], [<int>[], null, null]);
    expect(g.missingText, 'Pluto: nothing missing');
    final st = seriesStats(await db.watchLibrary(locked: false).first, await db.watchSeriesInfo(locked: false).first);
    expect([st.volumesRead, st.seriesCompleted], [2, 1]);
    await db.close();
  });

  test('a series is not completed while it is ongoing or a volume is unread', () async {
    final db = AppDb.memory();
    await vol(db, 'A', 1, read: true);
    await vol(db, 'A', 2, read: true);
    await db.setSeriesInfo('A', locked: false, total: 2, status: 'ongoing');
    await vol(db, 'B', 1, read: true);
    await vol(db, 'B', 2);
    await db.setSeriesInfo('B', locked: false, total: 2, status: 'complete');
    final st = seriesStats(await db.watchLibrary(locked: false).first, await db.watchSeriesInfo(locked: false).first);
    expect(st.seriesCompleted, 0);
    expect(st.volumesRead, 3);
    await db.close();
  });

  test('a wanted volume is never counted as read, even with a finished read on it', () async {
    final db = AppDb.memory();
    await vol(db, 'C', 1, owned: false, read: true);
    final st = seriesStats(await db.watchLibrary(locked: false).first, await db.watchSeriesInfo(locked: false).first);
    expect(st.volumesRead, 0);
    await db.close();
  });

  test('auto grouping turns on when a series has three or more volumes', () async {
    final db = AppDb.memory();
    await vol(db, 'A', 1);
    await vol(db, 'A', 2);
    await vol(db, 'B', 1);
    expect(shouldAutoGroup(await db.watchLibrary(locked: false).first), isFalse);
    await vol(db, 'A', 3);
    expect(shouldAutoGroup(await db.watchLibrary(locked: false).first), isTrue);
    await db.close();
  });

  test('a huge total does not build an endless grid', () async {
    final db = AppDb.memory();
    await vol(db, 'Long', 1);
    await db.setSeriesInfo('Long', locked: false, total: 2000000000);
    final g = (await groups(db)).single;
    expect(g.cells.length, lessThanOrEqualTo(5000));
    await db.close();
  });

  group('volume grid widgets', () {
    testWidgets('every cell is a labelled button at least 48 dp square, even at 200% text', (t) async {
      final handle = t.ensureSemantics();
      var tapped = 0;
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MaterialApp(
          home: Scaffold(
            body: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in {1: VolumeState.read, 2: VolumeState.owned, 3: VolumeState.wanted, 4: VolumeState.missing, 120: VolumeState.owned}.entries)
                VolumeButton(cell: VolumeCell(e.key, e.value, const []), onTap: () => tapped++),
            ]),
          ),
        ),
      ));
      expect(find.bySemanticsLabel('Volume 1, read'), findsOneWidget);
      expect(find.bySemanticsLabel('Volume 2, owned'), findsOneWidget);
      expect(find.bySemanticsLabel('Volume 3, wanted'), findsOneWidget);
      expect(find.bySemanticsLabel('Volume 4, missing'), findsOneWidget);
      for (final b in t.widgetList<VolumeButton>(find.byType(VolumeButton))) {
        final size = t.getSize(find.byWidget(b));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      await t.tap(find.text('2'));
      expect(tapped, 1);
      expect(t.takeException(), isNull);
      handle.dispose();
    });
  });
}
