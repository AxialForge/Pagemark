import 'package:drift/drift.dart';
import 'db.dart';

/// "Reading life" (0.12.0): reading sessions from the timer, the streak calendar, the year in books, the read-next order and lending.
/// Everything here is about the main library only unless a caller asks for the locked one: the locked library never feeds a card,
/// a calendar or a report.

DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

extension ReadingLifeDb on AppDb {
  // ── sessions ──
  Future<int> addSession(int bookId, int minutes, {int? pages, DateTime? when}) =>
      into(readingSessions).insert(ReadingSessionsCompanion.insert(bookId: bookId, day: dayOf(when ?? DateTime.now()), minutes: minutes, pages: Value(pages)));

  /// Sessions of live books in one library.
  Stream<List<ReadingSession>> watchSessions({required bool locked}) {
    final q = select(readingSessions).join([innerJoin(books, books.id.equalsExp(readingSessions.bookId))])
      ..where(books.locked.equals(locked) & books.deletedAt.isNull());
    return q.watch().map((rows) => [for (final r in rows) r.readTable(readingSessions)]);
  }

  // ── lending ──
  Stream<List<Loan>> watchLoans(int bookId) =>
      (select(loans)..where((l) => l.bookId.equals(bookId))..orderBy([(l) => OrderingTerm.desc(l.lentOn), (l) => OrderingTerm.desc(l.id)])).watch();

  Future<int> lend(int bookId, String person, {DateTime? lentOn, DateTime? remindOn}) => into(loans).insert(
      LoansCompanion.insert(bookId: bookId, person: person.trim(), lentOn: dayOf(lentOn ?? DateTime.now()), remindOn: Value(remindOn)));

  Future<void> markReturned(int loanId, {DateTime? when}) =>
      (update(loans)..where((l) => l.id.equals(loanId))).write(LoansCompanion(returnedOn: Value(dayOf(when ?? DateTime.now())), remindOn: const Value(null)));

  Future<void> deleteLoan(int loanId) => (delete(loans)..where((l) => l.id.equals(loanId))).go();

  // ── read-next order ──
  /// Books you want to read (main library), in your order; books you have not placed come after, newest first.
  static List<BookRow> orderQueue(Iterable<BookRow> rows) {
    final want = rows.where((r) => r.status == 'want').toList();
    want.sort((a, b) {
      final x = a.book.queuePos, y = b.book.queuePos;
      if (x != null && y != null) return x != y ? x.compareTo(y) : a.book.id.compareTo(b.book.id);
      if (x != null) return -1;
      if (y != null) return 1;
      return b.book.added.compareTo(a.book.added);
    });
    return want;
  }

  Future<void> saveQueue(List<int> ids) => transaction(() async {
        for (var i = 0; i < ids.length; i++) {
          await (update(books)..where((b) => b.id.equals(ids[i]))).write(BooksCompanion(queuePos: Value(i)));
        }
      });
}

/// The days you read: a day with a timer session, a day a read was finished, or a day a read was started.
Set<DateTime> readingDays(Iterable<ReadingSession> sessions, Iterable<Read> reads) => {
      for (final s in sessions) dayOf(s.day),
      for (final r in reads) ...[if (r.finished != null) dayOf(r.finished!), if (r.started != null) dayOf(r.started!)],
    };

/// Days in a row ending today (or yesterday, so an evening before you have read yet does not show 0).
int currentStreak(Set<DateTime> days, DateTime now) {
  var d = dayOf(now);
  if (!days.contains(d)) d = DateTime(d.year, d.month, d.day - 1);
  var n = 0;
  while (days.contains(d)) {
    n++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return n;
}

int longestStreak(Set<DateTime> days) {
  final sorted = days.toList()..sort();
  var best = 0, run = 0;
  DateTime? prev;
  for (final d in sorted) {
    run = prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d ? run + 1 : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}

/// What the "Year in books" card and report say. Counts finished reads only, from the books handed in.
class YearSummary {
  final int year, books, pages, minutes;
  final double? avgRating;
  final String? topGenre, topAuthor;
  final BookRow? best; // highest rated, earliest finished on a tie
  const YearSummary(this.year, this.books, this.pages, this.minutes, this.avgRating, this.topGenre, this.topAuthor, this.best);
  bool get isEmpty => books == 0;
}

YearSummary yearSummary(Iterable<BookRow> rows, int year, {Iterable<ReadingSession> sessions = const []}) {
  var count = 0, pages = 0, minutes = 0;
  final rated = <double>[], genres = <String, int>{}, authors = <String, int>{};
  BookRow? best;
  double bestRating = -1;
  DateTime? bestDate;
  for (final row in rows) {
    final done = row.reads.where((r) => r.status == 'finished' && r.finished?.year == year).toList();
    if (done.isEmpty) continue;
    count++;
    pages += row.book.pages ?? 0;
    final g = row.book.genre.split(',').first.trim(), a = row.book.author.split(',').first.trim();
    if (g.isNotEmpty) genres[g] = (genres[g] ?? 0) + 1;
    if (a.isNotEmpty) authors[a] = (authors[a] ?? 0) + 1;
    for (final r in done) {
      minutes += r.minutes ?? 0;
      if (r.rating != null) {
        rated.add(r.rating!);
        if (r.rating! > bestRating || (r.rating! == bestRating && bestDate != null && r.finished!.isBefore(bestDate))) {
          bestRating = r.rating!;
          bestDate = r.finished;
          best = row;
        }
      }
    }
  }
  String? top(Map<String, int> m) => m.isEmpty ? null : (m.entries.toList()..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key))).first.key;
  return YearSummary(year, count, pages, minutes, rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length, top(genres), top(authors), best);
}
