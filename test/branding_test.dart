import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/branding.dart';

void main() {
  testWidgets('logo asset loads and EmptyState shows message and action', (t) async {
    var tapped = false;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: EmptyState(message: 'Your shelf is empty.', actionLabel: 'Add a book', onAction: () => tapped = true))));
    await t.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.bySemanticsLabel('Pagemark logo'), findsOneWidget);
    expect(find.text('Your shelf is empty.'), findsOneWidget);
    await t.tap(find.text('Add a book'));
    expect(tapped, isTrue);
    expect(t.takeException(), isNull, reason: 'the logo asset must be declared in pubspec and decodable');
  });
}
