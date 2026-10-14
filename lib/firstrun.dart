import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:intl/intl.dart';
import 'db.dart';
import 'main.dart';

/// Five well-known public-domain books a new reader can try the app with, and take away again in one tap.
class Samples {
  static const _key = 'sample_ids';

  static List<int> ids() => [for (final s in (prefs.getString(_key) ?? '').split(',')) if (int.tryParse(s) != null) int.parse(s)];

  /// Do the sample books still exist? (They may have been removed or deleted one by one.)
  static Future<bool> present(AppDb db) async {
    final ids = Samples.ids();
    if (ids.isEmpty) return false;
    final rows = await (db.select(db.books)..where((b) => b.id.isIn(ids) & b.deletedAt.isNull())).get();
    return rows.isNotEmpty;
  }

  static Future<void> add(AppDb db, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    DateTime ago(int days) => DateTime(t.year, t.month, t.day).subtract(Duration(days: days));
    final shelf = await db.addShelf('Sample books');
    final made = <int>[];

    Future<void> book(String title, String author, int year, int pages, String genre, String status,
        {double? rating, String thoughts = '', int? page, int startedAgo = 30, int? finishedAgo}) async {
      final id = await db.into(db.books).insert(BooksCompanion.insert(
            title: title, author: Value(author), year: Value(year), pages: Value(pages), genre: Value(genre),
            description: Value('A sample book to try Pagemark with. Remove all the samples any time from the Library.'),
          ));
      await db.into(db.reads).insert(ReadsCompanion.insert(
            bookId: id, status: Value(status), started: Value(status == 'want' ? null : ago(startedAgo)),
            finished: Value(finishedAgo == null ? null : ago(finishedAgo)), rating: Value(rating), thoughts: Value(thoughts), currentPage: Value(page),
          ));
      await db.setOnShelf(id, shelf, true);
      made.add(id);
    }

    await book('Pride and Prejudice', 'Jane Austen', 1813, 432, 'Classic', 'finished', rating: 4.5, thoughts: 'A sparkling comedy of manners.', startedAgo: 40, finishedAgo: 26);
    await book('Frankenstein', 'Mary Shelley', 1818, 280, 'Gothic', 'reading', page: 120, startedAgo: 6);
    await book('The Time Machine', 'H. G. Wells', 1895, 118, 'Science fiction', 'finished', rating: 4.0, thoughts: 'Short, strange and still thrilling.', startedAgo: 14, finishedAgo: 9);
    await book('Dracula', 'Bram Stoker', 1897, 418, 'Gothic', 'want');
    await book('Moby-Dick', 'Herman Melville', 1851, 635, 'Classic', 'dnf', startedAgo: 60, finishedAgo: 50);
    await prefs.setString(_key, made.join(','));
  }

  /// Removes the sample books for good (and their shelf). Returns how many were removed.
  static Future<int> remove(AppDb db) async {
    final ids = Samples.ids();
    var n = 0;
    for (final id in ids) {
      n += await (db.delete(db.books)..where((b) => b.id.equals(id))).go();
    }
    final shelves = await db.select(db.shelves).get();
    for (final s in shelves.where((s) => s.name == 'Sample books')) {
      await db.deleteShelf(s.id);
    }
    await prefs.remove(_key);
    return n;
  }
}

/// The "set up a backup" card on the Library: only for people who have real books, no automatic folder backup and no recent backup.
class BackupNudge {
  static const everyDays = 30;

  static bool shouldShow(DateTime now, {required int realBooks, required bool folderSet, required DateTime? lastBackup, required DateTime? snoozedUntil}) {
    if (realBooks < 5 || folderSet) return false;
    if (snoozedUntil != null && snoozedUntil.isAfter(now)) return false;
    if (lastBackup == null) return true;
    return DateTime(now.year, now.month, now.day).difference(DateTime(lastBackup.year, lastBackup.month, lastBackup.day)).inDays > everyDays;
  }

  static DateTime? get snoozedUntil => DateTime.tryParse(prefs.getString('nudge_until') ?? '');
  static Future<void> snooze() => prefs.setString('nudge_until', DateTime.now().add(const Duration(days: everyDays)).toIso8601String());
}

/// Other ways to ask when a book search finds nothing: shorter, cleaner versions of what was typed.
List<String> searchSuggestions(String typed) {
  final q = typed.trim();
  if (q.length < 3) return const [];
  final out = <String>[];
  void add(String s) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length >= 3 && t.toLowerCase() != q.toLowerCase() && !out.any((o) => o.toLowerCase() == t.toLowerCase())) out.add(t);
  }

  add(q.split(RegExp(r'\s[:\-–—]\s|:')).first); // drop a subtitle
  add(q.replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), '')); // drop (brackets)
  add(q.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')); // drop punctuation
  add(q.replaceFirst(RegExp(r'^(the|a|an)\s+', caseSensitive: false), '')); // drop a leading "The"
  final words = q.split(RegExp(r'\s+'));
  if (words.length > 3) add(words.take(2).join(' ')); // just the first words
  return out.take(3).toList();
}

/// How dates are written in the app (Settings > Your library).
const dateStyles = <String, String>{
  'mdy': 'Oct 13, 2026',
  'dmy': '13 Oct 2026',
  'slash_dmy': '13/10/2026',
  'slash_mdy': '10/13/2026',
  'iso': '2026-10-13',
};

DateFormat dateFormatFor(String style) => switch (style) {
      'dmy' => DateFormat('d MMM y'),
      'slash_dmy' => DateFormat('dd/MM/y'),
      'slash_mdy' => DateFormat('MM/dd/y'),
      'iso' => DateFormat('yyyy-MM-dd'),
      _ => DateFormat.yMMMd(),
    };

DateFormat appDate() => dateFormatFor(prefs.getString('date_style') ?? 'mdy');

/// The format a new read starts with: print, ebook or audio.
String defaultFormat() {
  final v = prefs.getString('default_format') ?? 'print';
  return const {'print', 'ebook', 'audio'}.contains(v) ? v : 'print';
}
