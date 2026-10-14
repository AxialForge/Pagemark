import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/features.dart' show StarRating;
import 'package:pagemark/promise.dart';
import 'package:pagemark/themes.dart';
import 'package:pagemark/welcome.dart';

Widget host(Widget child, ThemeData theme, {double scale = 1}) => MaterialApp(
      theme: theme,
      builder: (c, w) => MediaQuery(data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)), child: w!),
      home: child,
    );

void main() {
  group('star rating works with a screen reader', () {
    testWidgets('it is one control that says its value and can be swiped up and down in half-star steps', (t) async {
      final handle = t.ensureSemantics();
      var v = 3.0;
      await t.pumpWidget(StatefulBuilder(builder: (c, set) => MaterialApp(home: Scaffold(body: StarRating(value: v, label: 'Rating', onChanged: (n) => set(() => v = n))))));
      final rating = find.semantics.byLabel('Rating');
      final data = rating.evaluate().single.getSemanticsData();
      expect(data.value, '3 of 5 stars');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      t.semantics.performAction(rating, SemanticsAction.increase);
      await t.pump();
      expect(v, 3.5);
      t.semantics.performAction(rating, SemanticsAction.decrease);
      await t.pump();
      t.semantics.performAction(rating, SemanticsAction.decrease);
      await t.pump();
      expect(v, 2.5);
      handle.dispose();
    });

    testWidgets('each star is a comfortable touch target, even when drawn small', (t) async {
      await t.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: StarRating(value: 0, size: 24, onChanged: (_) {})))));
      final s = t.getSize(find.byType(StarRating));
      expect(s.height, greaterThanOrEqualTo(48));
      expect(s.width / 5, greaterThanOrEqualTo(40));
    });
  });

  for (final theme in themes) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('promise page: ${theme.name}, text ${(scale * 100).round()}%: readable colours, big enough taps, no overflow', (t) async {
        final handle = t.ensureSemantics();
        await t.pumpWidget(host(const PromisePage(), theme.data, scale: scale));
        await t.pumpAndSettle();
        await expectLater(t, meetsGuideline(textContrastGuideline));
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  }

  testWidgets('welcome screens fit and stay usable at 200% text', (t) async {
    final handle = t.ensureSemantics();
    tester(t);
    await t.pumpWidget(host(const WelcomePage(), themes.first.data, scale: 2.0));
    await t.pumpAndSettle();
    await expectLater(t, meetsGuideline(androidTapTargetGuideline));
    await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
    expect(find.text('Skip'), findsOneWidget);
    handle.dispose();
  });
}

void tester(WidgetTester t) => t.view.physicalSize = const Size(1080, 2200); // a typical phone
