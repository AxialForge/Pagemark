import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/adaptive.dart';

Future<void> at(WidgetTester t, double w, Widget child) async {
  t.view.physicalSize = Size(w, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: child));
}

void main() {
  testWidgets('rail from 600 dp, two panes from 840 dp', (t) async {
    late BuildContext ctx;
    final w = Builder(builder: (c) { ctx = c; return const SizedBox(); });
    await at(t, 400, w);
    expect([useRail(ctx), useTwoPane(ctx)], [false, false]);
    await at(t, 700, w);
    expect([useRail(ctx), useTwoPane(ctx)], [true, false]);
    await at(t, 900, w);
    expect([useRail(ctx), useTwoPane(ctx)], [true, true]);
  });

  testWidgets('books open in the pane when there is one, as a page otherwise', (t) async {
    selectedBook.value = null;
    await at(t, 900, DetailPane(child: Builder(builder: (c) => TextButton(onPressed: () => openBookIn(c, 7, () => const Text('page')), child: const Text('go')))));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(selectedBook.value, 7);
    expect(find.text('page'), findsNothing);
    selectedBook.value = null;
    await at(t, 400, Builder(builder: (c) => TextButton(onPressed: () => openBookIn(c, 7, () => const Text('page')), child: const Text('go'))));
    await t.tap(find.text('go'));
    await t.pumpAndSettle();
    expect(selectedBook.value, isNull);
    expect(find.text('page'), findsOneWidget);
  });

  testWidgets('NarrowColumn caps width on big screens only', (t) async {
    await at(t, 1200, const NarrowColumn(child: SizedBox.expand(key: Key('c'))));
    expect(t.getSize(find.byKey(const Key('c'))).width, pageMaxWidth);
    await at(t, 400, const NarrowColumn(child: SizedBox.expand(key: Key('c'))));
    expect(t.getSize(find.byKey(const Key('c'))).width, 400);
  });
}
