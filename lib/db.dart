import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

@TableIndex(name: 'books_locked', columns: {#locked})
@TableIndex(name: 'books_title', columns: {#title})
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get isbn => text().withDefault(const Constant(''))();
  TextColumn get coverUrl => text().withDefault(const Constant(''))();
  TextColumn get genre => text().withDefault(const Constant(''))();
  TextColumn get series => text().withDefault(const Constant(''))();
  RealColumn get seriesNumber => real().nullable()(); // 1, 2, 2.5 ...
  IntColumn get seriesTotal => integer().nullable()(); // how many books the series has (user-entered)
  TextColumn get publisher => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  IntColumn get pages => integer().nullable()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get added => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // soft delete (Trash)
  IntColumn get queuePos => integer().nullable()(); // place in the "read next" order (smaller first); null = not placed
}

@TableIndex(name: 'reads_book', columns: {#bookId})
/// One read-through of a book (a book can be read/listened several times).
class Reads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get format => text().withDefault(const Constant('print'))(); // print|ebook|audio
  TextColumn get status => text().withDefault(const Constant('want'))(); // want|reading|finished|dnf
  DateTimeColumn get started => dateTime().nullable()();
  DateTimeColumn get finished => dateTime().nullable()();
  RealColumn get rating => real().nullable()(); // 0.5 - 5
  TextColumn get thoughts => text().withDefault(const Constant(''))();
  TextColumn get narrator => text().withDefault(const Constant(''))();
  IntColumn get minutes => integer().nullable()(); // audio length or time spent
  IntColumn get currentPage => integer().nullable()(); // reading progress (page or %)
  IntColumn get heat => integer().nullable()(); // 0-5 private "heat" level (opt-in field)
  TextColumn get contentNotes => text().withDefault(const Constant(''))(); // private content notes (opt-in field)
  // optional detailed ratings, 0.5 - 5 (opt-in in Settings); narrator only for audiobook reads
  RealColumn get ratingStory => real().nullable()();
  RealColumn get ratingCharacters => real().nullable()();
  RealColumn get ratingWriting => real().nullable()();
  RealColumn get ratingPace => real().nullable()();
  RealColumn get ratingFeeling => real().nullable()();
  RealColumn get ratingNarrator => real().nullable()();
}

/// One sitting of reading, from the reading timer.
@TableIndex(name: 'sessions_book', columns: {#bookId})
class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get day => dateTime()(); // the calendar day it counts for (midnight, local)
  IntColumn get minutes => integer()();
  IntColumn get pages => integer().nullable()(); // pages read in the sitting, when known
}

/// A book lent to someone.
@TableIndex(name: 'loans_book', columns: {#bookId})
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get person => text()();
  DateTimeColumn get lentOn => dateTime()();
  DateTimeColumn get remindOn => dateTime().nullable()();
  DateTimeColumn get returnedOn => dateTime().nullable()();
}

/// A passage you want to keep from a book.
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text()();
  IntColumn get page => integer().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  RealColumn get rating => real().nullable()(); // 0.5 - 5: how much you loved this line
  DateTimeColumn get created => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Shelf')
class Shelves extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// A book can sit on many shelves.
@DataClassName('BookShelf')
class BookShelves extends Table {
  IntColumn get bookId => integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get shelfId => integer().references(Shelves, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {bookId, shelfId};
}

@DriftDatabase(tables: [Books, Reads, Shelves, BookShelves, Quotes, ReadingSessions, Loans])
class AppDb extends _$AppDb {
  AppDb() : super(_open());
  AppDb.forFile(File f) : super(NativeDatabase(f, setup: _pragmas));
  AppDb.memory() : super(NativeDatabase.memory());
  static const currentSchema = 6;
  @override
  int get schemaVersion => currentSchema;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(books, books.deletedAt);
            await m.createIndex(booksLocked);
            await m.createIndex(booksTitle);
            await m.createIndex(readsBook);
          }
          if (from < 3) {
            await m.addColumn(books, books.seriesNumber);
            await m.addColumn(reads, reads.currentPage);
            await m.createTable(shelves);
            await m.createTable(bookShelves);
          }
          if (from < 4) {
            await m.addColumn(books, books.seriesTotal);
            await m.addColumn(reads, reads.heat);
            await m.addColumn(reads, reads.contentNotes);
            await m.createTable(quotes);
          }
          if (from < 5) {
            await m.addColumn(reads, reads.ratingStory);
            await m.addColumn(reads, reads.ratingCharacters);
            await m.addColumn(reads, reads.ratingWriting);
            await m.addColumn(reads, reads.ratingPace);
            await m.addColumn(reads, reads.ratingFeeling);
            await m.addColumn(reads, reads.ratingNarrator);
            // a database older than 4 just had the quotes table created (with this column) in the step above
            if (from >= 4) await m.addColumn(quotes, quotes.rating);
          }
          if (from < 6) {
            await m.addColumn(books, books.queuePos);
            await m.createTable(readingSessions);
            await m.createTable(loans);
          }
        },
        beforeOpen: (details) async {
          // Without this SQLite ignores ON DELETE CASCADE and leaves orphaned reads.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static const trashDays = 30;

  // ── shelves ──
  /// All shelves, or (with [locked]) only the ones that library may show: a shelf is visible in a library when one of its books lives
  /// there, or when it is still empty. A shelf holding only locked books therefore never appears (by name) in the main library.
  Stream<List<Shelf>> watchShelves({bool? locked}) {
    if (locked == null) return (select(shelves)..orderBy([(s) => OrderingTerm.asc(s.name)])).watch();
    return customSelect(
      'SELECT s.id, s.name FROM shelves s WHERE NOT EXISTS (SELECT 1 FROM book_shelves l WHERE l.shelf_id = s.id) '
      'OR EXISTS (SELECT 1 FROM book_shelves l JOIN books b ON b.id = l.book_id WHERE l.shelf_id = s.id AND b.locked = ?) ORDER BY s.name',
      variables: [Variable.withBool(locked)],
      readsFrom: {shelves, bookShelves, books},
    ).watch().map((rows) => [for (final r in rows) Shelf(id: r.read<int>('id'), name: r.read<String>('name'))]);
  }
  Stream<List<BookShelf>> watchShelfLinks() => select(bookShelves).watch();

  Future<int> addShelf(String name) async {
    final n = name.trim();
    final existing = await (select(shelves)..where((s) => s.name.equals(n))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(shelves).insert(ShelvesCompanion.insert(name: n));
  }

  Future<void> renameShelf(int id, String name) =>
      (update(shelves)..where((s) => s.id.equals(id))).write(ShelvesCompanion(name: Value(name.trim())));
  Future<void> deleteShelf(int id) => (delete(shelves)..where((s) => s.id.equals(id))).go();

  Future<void> setOnShelf(int bookId, int shelfId, bool on) async {
    if (on) {
      await into(bookShelves).insert(BookShelvesCompanion.insert(bookId: bookId, shelfId: shelfId), mode: InsertMode.insertOrIgnore);
    } else {
      await (delete(bookShelves)..where((l) => l.bookId.equals(bookId) & l.shelfId.equals(shelfId))).go();
    }
  }


  Future<void> softDelete(int id) =>
      (update(books)..where((b) => b.id.equals(id))).write(BooksCompanion(deletedAt: Value(DateTime.now())));
  Future<void> restoreBook(int id) =>
      (update(books)..where((b) => b.id.equals(id))).write(const BooksCompanion(deletedAt: Value(null)));
  // ── quotes ──
  Stream<List<Quote>> watchQuotes(int bookId) =>
      (select(quotes)..where((q) => q.bookId.equals(bookId))..orderBy([(q) => OrderingTerm.asc(q.page), (q) => OrderingTerm.asc(q.id)])).watch();

  /// Every quote's text keyed by book, for library search ("find the book with that line in it").
  Stream<Map<int, String>> watchQuoteText() => select(quotes).watch().map((all) {
        final m = <int, StringBuffer>{};
        for (final q in all) {
          (m[q.bookId] ??= StringBuffer()).write('${q.body} ${q.note} ');
        }
        return {for (final e in m.entries) e.key: e.value.toString()};
      });

  Future<int> addQuote(int bookId, String text, {int? page, String note = '', double? rating}) =>
      into(quotes).insert(QuotesCompanion.insert(bookId: bookId, body: text.trim(), page: Value(page), note: Value(note.trim()), rating: Value(rating)));
  Future<void> updateQuote(int id, String text, {int? page, String note = '', double? rating}) => (update(quotes)..where((q) => q.id.equals(id)))
      .write(QuotesCompanion(body: Value(text.trim()), page: Value(page), note: Value(note.trim()), rating: Value(rating)));
  Future<void> deleteQuote(int id) => (delete(quotes)..where((q) => q.id.equals(id))).go();
  Future<void> restoreQuote(Quote q) => into(quotes).insert(q, mode: InsertMode.insertOrReplace);

  // ── bulk operations (multi-select) ──
  /// SQLite allows only a limited number of `?` values per statement, so long id lists are written in slices.
  Future<void> _inChunks(Iterable<int> ids, Future<void> Function(List<int> slice) write) => transaction(() async {
        final all = ids.toList();
        for (var i = 0; i < all.length; i += 500) {
          await write(all.sublist(i, i + 500 > all.length ? all.length : i + 500));
        }
      });

  Future<void> softDeleteMany(Iterable<int> ids) =>
      _inChunks(ids, (s) => (update(books)..where((b) => b.id.isIn(s))).write(BooksCompanion(deletedAt: Value(DateTime.now()))));
  Future<void> restoreMany(Iterable<int> ids) =>
      _inChunks(ids, (s) => (update(books)..where((b) => b.id.isIn(s))).write(const BooksCompanion(deletedAt: Value(null))));
  Future<void> setLockedMany(Iterable<int> ids, bool locked) =>
      _inChunks(ids, (s) => (update(books)..where((b) => b.id.isIn(s))).write(BooksCompanion(locked: Value(locked))));

  /// Marks each book finished today: its active (else latest) read becomes Finished with today's date; a book with no
  /// read gets one. The result says exactly what changed so [undoMarkFinished] can put it back.
  Future<FinishUndo> markFinishedToday(Iterable<int> bookIds) => transaction(() async {
        final changed = <Read>[];
        final created = <int>[];
        final today = DateTime.now();
        final day = DateTime(today.year, today.month, today.day);
        for (final id in bookIds) {
          final reads = await (select(this.reads)..where((r) => r.bookId.equals(id))..orderBy([(r) => OrderingTerm.desc(r.id)])).get();
          final target = reads.where((r) => r.status == 'reading').firstOrNull ?? reads.firstOrNull;
          if (target == null) {
            created.add(await into(this.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('finished'), started: Value(day), finished: Value(day))));
          } else if (target.status != 'finished') {
            changed.add(target);
            await (update(this.reads)..where((r) => r.id.equals(target.id))).write(ReadsCompanion(status: const Value('finished'), finished: Value(day)));
          }
        }
        return FinishUndo(changed, created);
      });

  Future<void> undoMarkFinished(FinishUndo u) => transaction(() async {
        for (final r in u.changed) {
          await (update(reads)..where((x) => x.id.equals(r.id))).write(ReadsCompanion(status: Value(r.status), finished: Value(r.finished)));
        }
        // a read that was created by "mark finished" is removed only if the user has not added a rating or thoughts to it since
        await (delete(reads)..where((x) => x.id.isIn(u.created) & x.thoughts.equals('') & x.rating.isNull())).go();
      });

  /// Puts the books on a shelf and returns the ones that were not already there, so Undo takes off only those.
  Future<List<int>> addManyToShelf(Iterable<int> ids, int shelfId) async {
    final have = {for (final l in await (select(bookShelves)..where((l) => l.shelfId.equals(shelfId))).get()) l.bookId};
    final added = [for (final id in ids) if (!have.contains(id)) id];
    for (final id in added) {
      await setOnShelf(id, shelfId, true);
    }
    return added;
  }

  Future<void> removeManyFromShelf(Iterable<int> ids, int shelfId) =>
      _inChunks(ids, (s) => (delete(bookShelves)..where((l) => l.shelfId.equals(shelfId) & l.bookId.isIn(s))).go());

  Future<void> purgeBook(int id) => (delete(books)..where((b) => b.id.equals(id))).go();
  Future<int> purgeExpiredTrash() {
    final cutoff = DateTime.now().subtract(const Duration(days: trashDays));
    return (delete(books)..where((b) => b.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  /// Trashed books of one library. The main Trash never sees the vault's, and the vault has its own (opened only while unlocked).
  Stream<List<Book>> watchTrash({required bool locked}) => (select(books)
        ..where((b) => b.deletedAt.isNotNull() & b.locked.equals(locked))
        ..orderBy([(b) => OrderingTerm.desc(b.deletedAt)]))
      .watch();

  /// A duplicate is the same ISBN, or the same title+author (case-insensitive), among live books.
  Future<Book?> findDuplicate({required String title, required bool locked, String author = '', String isbn = ''}) async {
    // Only compare within the same library so the main library never reveals a locked title.
    final live = await (select(books)..where((b) => b.deletedAt.isNull() & b.locked.equals(locked))).get();
    final t = title.trim().toLowerCase(), a = author.trim().toLowerCase();
    for (final b in live) {
      if (isbn.isNotEmpty && b.isbn == isbn) return b;
      if (b.title.trim().toLowerCase() == t && b.author.trim().toLowerCase() == a) return b;
    }
    return null;
  }

  /// Tests point the live database at a temp folder (the path plugin has no implementation on the test VM).
  static Directory? debugDir;

  static Future<File> file() async {
    final dir = debugDir ?? await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'pagemark.sqlite'));
  }

  Stream<List<BookRow>> watchLibrary({required bool locked}) {
    final q = select(books).join([leftOuterJoin(reads, reads.bookId.equalsExp(books.id))])
      ..where(books.locked.equals(locked) & books.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(books.added)]);
    return q.watch().map((rows) {
      final map = <int, BookRow>{};
      for (final r in rows) {
        final b = r.readTable(books);
        final rd = r.readTableOrNull(reads);
        final e = map.putIfAbsent(b.id, () => BookRow(b, []));
        if (rd != null) e.reads.add(rd);
      }
      return map.values.toList();
    });
  }

  Stream<List<Read>> watchReads(int bookId) =>
      (select(reads)..where((r) => r.bookId.equals(bookId))..orderBy([(r) => OrderingTerm.desc(r.id)])).watch();
}

/// What [AppDb.markFinishedToday] did, so it can be reversed.
class FinishUndo {
  final List<Read> changed; // reads as they were before
  final List<int> created; // ids of reads it inserted
  const FinishUndo(this.changed, this.created);
  int get count => changed.length + created.length;
}

class BookRow {
  final Book book;
  final List<Read> reads;
  BookRow(this.book, this.reads);

  @override
  bool operator ==(Object other) {
    if (other is! BookRow || other.book != book || other.reads.length != reads.length) return false;
    for (var i = 0; i < reads.length; i++) {
      if (other.reads[i] != reads[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(book, reads.length);
  /// Average of finished reads' ratings only (want/reading/DNF don't count).
  double? get avgRating {
    final r = reads.where((e) => e.rating != null && e.status == 'finished').map((e) => e.rating!).toList();
    return r.isEmpty ? null : r.reduce((a, b) => a + b) / r.length;
  }

  /// The read that represents the book: an active one, else the most recently logged.
  Read? get primary {
    if (reads.isEmpty) return null;
    final active = reads.where((e) => e.status == 'reading').toList();
    final pool = active.isNotEmpty ? active : reads;
    return pool.reduce((a, b) => a.id >= b.id ? a : b);
  }

  String get status => primary?.status ?? 'none';

  /// 0..1 progress of the active read, when both a current page and the book's page count are known.
  double? get progress {
    final r = primary;
    final total = book.pages;
    if (r == null || r.status != 'reading' || r.currentPage == null || total == null || total <= 0) return null;
    return (r.currentPage! / total).clamp(0.0, 1.0);
  }
}

void _pragmas(dynamic db) {
  db.execute('PRAGMA journal_mode = WAL'); // readers don't block the backup isolate's connection
  db.execute('PRAGMA busy_timeout = 5000');
}

LazyDatabase _open() => LazyDatabase(() async => NativeDatabase.createInBackground(await AppDb.file(), setup: _pragmas));
