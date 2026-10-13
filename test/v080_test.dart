import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/incoming.dart';
import 'package:pagemark/reminders.dart';
import 'package:pagemark/widget_sync.dart';

BookRow row(String title, {bool locked = false, String? status, DateTime? finished, bool trashed = false}) {
  final b = Book(
    id: title.hashCode, title: title, author: '', isbn: '', coverUrl: '', genre: '', series: '', seriesNumber: null, publisher: '', year: null,
    pages: null, description: '', tags: '', notes: '', locked: locked, added: DateTime(2026), deletedAt: trashed ? DateTime(2026) : null, seriesTotal: null,
  );
  final reads = status == null
      ? <Read>[]
      : [Read(id: 1, bookId: b.id, format: 'print', status: status, started: null, finished: finished, rating: null, thoughts: '', narrator: '', minutes: null, currentPage: null, heat: null, contentNotes: '')];
  return BookRow(b, reads);
}

void main() {
  group('share target: what text becomes a search', () {
    test('an ISBN anywhere in the text wins, hyphens and ISBN-10 are fine', () {
      expect(Incoming.queryFromShared('9780441172719'), '9780441172719');
      expect(Incoming.queryFromShared('Check out ISBN 978-0-441-17271-9 !'), '9780441172719');
      expect(Incoming.queryFromShared('0441172717'), '9780441172719');
    });
    test('Goodreads and Open Library links give the title from the address', () {
      expect(Incoming.queryFromShared('https://www.goodreads.com/book/show/44767458-dune'), 'dune');
      expect(Incoming.queryFromShared('https://www.goodreads.com/book/show/5907.The_Hobbit'), 'The Hobbit');
      expect(Incoming.queryFromShared('https://openlibrary.org/works/OL45804W/Fantastic_Mr_Fox'), 'Fantastic Mr Fox');
    });
    test('plain text: first line, links removed; nothing usable gives null', () {
      expect(Incoming.queryFromShared('The Glass Orchard\nsecond line'), 'The Glass Orchard');
      expect(Incoming.queryFromShared('Great read https://example.com/x'), 'Great read');
      expect(Incoming.queryFromShared('https://example.com/x'), isNull);
      expect(Incoming.queryFromShared('   '), isNull);
    });
    test('very long shared text is capped', () {
      expect(Incoming.queryFromShared('a' * 5000)!.length, Incoming.maxLength);
    });
  });

  group('reminders', () {
    test('time text parses, bad text falls back to 20:00', () {
      expect(Reminders.parseTime('07:30'), (7, 30));
      expect(Reminders.parseTime('9:05'), (9, 5));
      expect(Reminders.parseTime('25:00'), (20, 0));
      expect(Reminders.parseTime('soon'), (20, 0));
      expect(Reminders.formatTime(7, 5), '07:05');
    });
    test('upcoming: later today if the time has not passed, otherwise tomorrow; one per day', () {
      final morning = Reminders.upcoming(DateTime(2026, 3, 7, 9), 20, 0, count: 3);
      expect(morning, [DateTime(2026, 3, 7, 20), DateTime(2026, 3, 8, 20), DateTime(2026, 3, 9, 20)]);
      final late = Reminders.upcoming(DateTime(2026, 3, 7, 21), 20, 0, count: 2);
      expect(late.first, DateTime(2026, 3, 8, 20));
      expect(Reminders.upcoming(DateTime(2026, 1, 1), 20, 0).length, Reminders.days);
    });
    test('across a month and year end the days keep their local time', () {
      final r = Reminders.upcoming(DateTime(2026, 12, 30, 22), 8, 15, count: 4);
      expect(r, [DateTime(2026, 12, 31, 8, 15), DateTime(2027, 1, 1, 8, 15), DateTime(2027, 1, 2, 8, 15), DateTime(2027, 1, 3, 8, 15)]);
    });
  });

  group('home-screen widget data never includes locked books', () {
    final rows = [
      row('Public One', status: 'reading'),
      row('Secret Book', locked: true, status: 'reading'),
      row('Binned', trashed: true, status: 'reading'),
      row('Done A', status: 'finished', finished: DateTime(2026, 2, 1)),
      row('Done B', status: 'finished', finished: DateTime(2025, 2, 1)),
    ];
    test('titles shown: only the main library reading list, plus the goal line', () {
      final d = WidgetSync.payload(rows, year: 2026, goal: 12, titles: true);
      expect(d['w_reading'], 'Public One');
      expect(d.values.join(' '), isNot(contains('Secret')));
      expect(d['w_goal'], '1 of 12 books in 2026');
    });
    test('titles hidden: counts only', () {
      final d = WidgetSync.payload(rows, year: 2026, goal: 0, titles: false);
      expect(d['w_reading'], '1 book in progress');
      expect(d['w_goal'], '1 book finished in 2026');
    });
    test('nothing in progress', () {
      expect(WidgetSync.payload([row('X', status: 'want')], year: 2026, goal: 0, titles: true)['w_reading'], 'Nothing in progress');
    });
    test('more than three are summarised', () {
      final many = [for (var i = 0; i < 5; i++) row('B$i', status: 'reading')];
      expect(WidgetSync.payload(many, year: 2026, goal: 0, titles: true)['w_reading']!.split('\n').length, 4);
    });
  });
}
