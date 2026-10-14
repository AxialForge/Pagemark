import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/features.dart';
import 'package:pagemark/firstrun.dart';
import 'package:pagemark/main.dart' show prefs;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('sample books', () {
    test('five books with a shelf, a mix of statuses, and nothing locked; removal takes exactly them away', () async {
      final db = AppDb.memory();
      final mine = await db.into(db.books).insert(BooksCompanion.insert(title: 'My own book'));
      await Samples.add(db);
      final all = await db.select(db.books).get();
      expect(all.length, 6);
      expect(all.where((b) => b.locked), isEmpty);
      final reads = await db.select(db.reads).get();
      expect(reads.map((r) => r.status).toSet(), {'finished', 'reading', 'want', 'dnf'});
      expect(reads.firstWhere((r) => r.status == 'reading').currentPage, 120);
      expect((await db.select(db.shelves).get()).single.name, 'Sample books');
      expect(await Samples.present(db), isTrue);

      expect(await Samples.remove(db), 5);
      final left = await db.select(db.books).get();
      expect(left.single.id, mine);
      expect(await db.select(db.shelves).get(), isEmpty);
      expect(await Samples.present(db), isFalse);
      await db.close();
    });
  });

  group('backup nudge', () {
    final now = DateTime(2026, 10, 14, 9);
    bool show({int books = 8, bool folder = false, DateTime? last, DateTime? snooze}) =>
        BackupNudge.shouldShow(now, realBooks: books, folderSet: folder, lastBackup: last, snoozedUntil: snooze);

    test('shows for someone with real books and no backup', () => expect(show(), isTrue));
    test('not for a nearly empty library, or when a folder backup is set', () {
      expect(show(books: 3), isFalse);
      expect(show(folder: true), isFalse);
    });
    test('not when the last backup is recent; yes when it is old', () {
      expect(show(last: DateTime(2026, 10, 1)), isFalse);
      expect(show(last: DateTime(2026, 8, 1)), isTrue);
    });
    test('"not now" hides it until the date passes', () {
      expect(show(snooze: DateTime(2026, 11, 1)), isFalse);
      expect(show(snooze: DateTime(2026, 10, 1)), isTrue);
    });
  });

  group('suggestions when a search finds nothing', () {
    test('drops a subtitle, brackets, punctuation and a leading The', () {
      expect(searchSuggestions('Dune: The Illustrated Edition'), contains('Dune'));
      expect(searchSuggestions('Emma (Penguin Classics)'), contains('Emma'));
      expect(searchSuggestions('The Hobbit'), contains('Hobbit'));
      expect(searchSuggestions('Mr. Mercedes!!'), contains('Mr Mercedes'));
    });
    test('long titles also offer the first words; short or empty input offers nothing; never the same text', () {
      expect(searchSuggestions('A very long title about many things'), contains('A very'));
      expect(searchSuggestions('ab'), isEmpty);
      expect(searchSuggestions('   '), isEmpty);
      expect(searchSuggestions('Dune'), isEmpty);
      expect(searchSuggestions('Dune: Part One').length, lessThanOrEqualTo(3));
    });
  });

  group('date style and defaults', () {
    final d = DateTime(2026, 10, 13);
    test('each style writes the date its own way', () {
      expect(dateFormatFor('mdy').format(d), 'Oct 13, 2026');
      expect(dateFormatFor('dmy').format(d), '13 Oct 2026');
      expect(dateFormatFor('slash_dmy').format(d), '13/10/2026');
      expect(dateFormatFor('slash_mdy').format(d), '10/13/2026');
      expect(dateFormatFor('iso').format(d), '2026-10-13');
      expect(dateFormatFor('nonsense').format(d), 'Oct 13, 2026');
    });
    test('the chosen style and format come from settings, with safe fallbacks', () async {
      expect(appDate().format(d), 'Oct 13, 2026');
      await prefs.setString('date_style', 'iso');
      expect(appDate().format(d), '2026-10-13');
      expect(defaultFormat(), 'print');
      await prefs.setString('default_format', 'audio');
      expect(defaultFormat(), 'audio');
      await prefs.setString('default_format', 'hologram');
      expect(defaultFormat(), 'print');
    });
    test('the style list is complete', () => expect(dateStyles.keys, containsAll(['mdy', 'dmy', 'slash_dmy', 'slash_mdy', 'iso'])));
  });

  test('Features import still compiles with the new helpers', () => expect(SeriesPage.fmtNum(2), '2'));
}
