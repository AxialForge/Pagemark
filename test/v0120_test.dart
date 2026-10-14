import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/reading_life.dart';
import 'package:pagemark/reading_life_ui.dart';
import 'package:pagemark/report_pdf.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

DateTime d(int y, int m, int day) => DateTime(y, m, day);

Future<int> book(AppDb db, String title, {bool locked = false, int? pages, String genre = '', String author = ''}) =>
    db.into(db.books).insert(BooksCompanion.insert(title: title, locked: Value(locked), pages: Value(pages), genre: Value(genre), author: Value(author)));

Future<void> read(AppDb db, int b, String status, {DateTime? finished, double? rating, int? minutes}) => db
    .into(db.reads)
    .insert(ReadsCompanion.insert(bookId: b, status: Value(status), finished: Value(finished), rating: Value(rating), minutes: Value(minutes)));

void main() {
  group('streaks', () {
    final days = {d(2026, 10, 10), d(2026, 10, 11), d(2026, 10, 12), d(2026, 10, 5)};
    test('count back from today, or from yesterday when today is still empty', () {
      expect(currentStreak(days, d(2026, 10, 12)), 3);
      expect(currentStreak(days, d(2026, 10, 13)), 3);
      expect(currentStreak(days, d(2026, 10, 14)), 0);
    });
    test('longest run', () => expect(longestStreak(days), 3));
    test('month and year ends do not break a run', () => expect(currentStreak({d(2025, 12, 31), d(2026, 1, 1)}, d(2026, 1, 1)), 2));
  });

  group('year in books', () {
    test('counts only reads finished that year, and ranks genre and best book', () async {
      final db = AppDb.memory();
      final a = await book(db, 'A', pages: 100, genre: 'Fantasy', author: 'X');
      final b = await book(db, 'B', pages: 200, genre: 'Fantasy', author: 'X');
      final c = await book(db, 'C', pages: 300, genre: 'Crime');
      await read(db, a, 'finished', finished: d(2026, 3, 1), rating: 4, minutes: 120);
      await read(db, b, 'finished', finished: d(2026, 5, 1), rating: 5);
      await read(db, c, 'finished', finished: d(2025, 5, 1), rating: 5);
      final s = yearSummary(await db.watchLibrary(locked: false).first, 2026);
      expect([s.books, s.pages, s.minutes, s.topGenre, s.topAuthor, s.avgRating], [2, 300, 120, 'Fantasy', 'X', 4.5]);
      expect(s.best!.book.title, 'B');
      expect(yearSummary(await db.watchLibrary(locked: false).first, 2024).isEmpty, isTrue);
      await db.close();
    });

    test('locked books never reach the card, the calendar or the report', () async {
      final db = AppDb.memory();
      final open = await book(db, 'Open');
      final secret = await book(db, 'Secret', locked: true);
      await read(db, open, 'finished', finished: d(2026, 2, 1));
      await read(db, secret, 'finished', finished: d(2026, 2, 2));
      await db.addSession(open, 10, when: d(2026, 2, 1));
      await db.addSession(secret, 10, when: d(2026, 2, 2));
      final rows = await db.watchLibrary(locked: false).first;
      expect(yearSummary(rows, 2026).books, 1);
      expect((await db.watchSessions(locked: false).first).length, 1);
      expect((await db.watchSessions(locked: true).first).length, 1);
      final text = String.fromCharCodes(await ReportPdf.build(rows, 2026).save());
      expect(text.contains('Secret'), isFalse);
      await db.close();
    });
  });

  test('the PDF report builds, and non-Latin letters become ?', () async {
    final db = AppDb.memory();
    final a = await book(db, 'Café 世界', pages: 10);
    await read(db, a, 'finished', finished: d(2026, 1, 2), rating: 3.5);
    final bytes = await ReportPdf.build(await db.watchLibrary(locked: false).first, 2026).save();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(ReportPdf.clean('a世bé'), 'a?bé');
    await db.close();
  });

  group('read-next order', () {
    test('placed books first by position, the rest newest first; only wanted books', () async {
      final db = AppDb.memory();
      final a = await book(db, 'A'), b = await book(db, 'B'), c = await book(db, 'C'), done = await book(db, 'Done');
      for (final id in [a, b, c]) {
        await read(db, id, 'want');
      }
      await read(db, done, 'finished');
      await db.saveQueue([c, a]);
      var order = ReadingLifeDb.orderQueue(await db.watchLibrary(locked: false).first).map((r) => r.book.title).toList();
      expect(order, ['C', 'A', 'B']);
      await db.saveQueue([b, c, a]);
      order = ReadingLifeDb.orderQueue(await db.watchLibrary(locked: false).first).map((r) => r.book.title).toList();
      expect(order, ['B', 'C', 'A']);
      await db.close();
    });
  });

  test('lending: lend, return, remove, and the loan goes with the book', () async {
    final db = AppDb.memory();
    final a = await book(db, 'A');
    final id = await db.lend(a, '  Sam ', remindOn: d(2026, 11, 1));
    var l = (await db.watchLoans(a).first).single;
    expect([l.person, l.returnedOn], ['Sam', null]);
    await db.markReturned(id);
    l = (await db.watchLoans(a).first).single;
    expect([l.returnedOn != null, l.remindOn], [true, null]);
    await db.lend(a, 'Kim');
    expect((await db.watchLoans(a).first).length, 2);
    await db.deleteLoan(id);
    expect((await db.watchLoans(a).first).length, 1);
    await db.purgeBook(a);
    expect(await db.select(db.loans).get(), isEmpty);
    await db.close();
  });

  test('a schema 5 database gains the order column and the two new tables, keeping its rows', () async {
    final dir = Directory.systemTemp.createTempSync('pgm120');
    final f = File('${dir.path}/v5.sqlite');
    final raw = sql.sqlite3.open(f.path);
    raw.execute('''
      CREATE TABLE books (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, author TEXT NOT NULL DEFAULT '', isbn TEXT NOT NULL DEFAULT '',
        cover_url TEXT NOT NULL DEFAULT '', genre TEXT NOT NULL DEFAULT '', series TEXT NOT NULL DEFAULT '', series_number REAL NULL, series_total INTEGER NULL,
        publisher TEXT NOT NULL DEFAULT '', year INTEGER NULL, pages INTEGER NULL, description TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '', locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0, 1)), added INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
        deleted_at INTEGER NULL);
      INSERT INTO books (title) VALUES ('Old');
      PRAGMA user_version = 5;
    ''');
    raw.close();
    final db = AppDb.forFile(f);
    final b = (await db.select(db.books).get()).single;
    expect([b.title, b.queuePos], ['Old', null]);
    await db.lend(b.id, 'Sam');
    await db.addSession(b.id, 5);
    expect(await db.select(db.loans).get(), hasLength(1));
    await db.close();
    dir.deleteSync(recursive: true);
  });

  group('calendar widget', () {
    testWidgets('marks the days read with a spoken label and pages between months', (t) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: StreakCard(days: {d(2026, 10, 12), d(2026, 10, 13)}, now: d(2026, 10, 14))))));
      expect(find.text('You read on 2 days this month.'), findsOneWidget);
      expect(find.text('2 days in a row. Lovely.'), findsOneWidget);
      expect(find.bySemanticsLabel('October 12, you read'), findsOneWidget);
      await t.tap(find.byTooltip('Earlier month'));
      await t.pump();
      expect(find.text('No reading logged this month.'), findsOneWidget);
      handle.dispose();
    });
  });
}
