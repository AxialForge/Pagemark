// PGM-320: the reading timer can get stuck. Start the timer on book 1, then finish (or delete) book 1: its timer card disappears, but the
// saved timer keeps blocking every other book ("running for another book") with no Stop button anywhere.
// Run: copy to the project's test folder, `flutter test test/pgm320_stuck_timer_test.dart`  (EXPECTED TO FAIL until fixed).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/main.dart' show prefs;
import 'package:pagemark/reading_life_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('a timer left running for a book that is no longer being read can still be stopped from another book', (t) async {
    SharedPreferences.setMockInitialValues({'timer_book': 1, 'timer_start': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()});
    prefs = await SharedPreferences.getInstance();
    final other = Book(id: 2, title: 'Other', author: '', isbn: '', coverUrl: '', genre: '', series: '', publisher: '', description: '', tags: '', notes: '', locked: false, added: DateTime(2026));
    final read = Read(id: 9, bookId: 2, format: 'print', status: 'reading', thoughts: '', narrator: '', contentNotes: '');
    await t.pumpWidget(MaterialApp(home: Scaffold(body: ReadingTimerCard(book: other, read: read))));
    expect(find.text('The reading timer is running for another book.'), findsOneWidget, reason: 'precondition: blocked by the stale timer');
    expect(find.text('Stop'), findsOneWidget, reason: 'there must be a way to stop a stale timer');
  });
}
