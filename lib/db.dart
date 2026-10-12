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
  TextColumn get publisher => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  IntColumn get pages => integer().nullable()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get added => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // soft delete (Trash)
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
}

@DriftDatabase(tables: [Books, Reads])
class AppDb extends _$AppDb {
  AppDb() : super(_open());
  AppDb.forFile(File f) : super(NativeDatabase(f, setup: _pragmas));
  AppDb.memory() : super(NativeDatabase.memory());
  static const currentSchema = 2;
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
        },
        beforeOpen: (details) async {
          // Without this SQLite ignores ON DELETE CASCADE and leaves orphaned reads.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static const trashDays = 30;

  Future<void> softDelete(int id) =>
      (update(books)..where((b) => b.id.equals(id))).write(BooksCompanion(deletedAt: Value(DateTime.now())));
  Future<void> restoreBook(int id) =>
      (update(books)..where((b) => b.id.equals(id))).write(const BooksCompanion(deletedAt: Value(null)));
  Future<void> purgeBook(int id) => (delete(books)..where((b) => b.id.equals(id))).go();
  Future<int> purgeExpiredTrash() {
    final cutoff = DateTime.now().subtract(const Duration(days: trashDays));
    return (delete(books)..where((b) => b.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  Stream<List<Book>> watchTrash() =>
      (select(books)..where((b) => b.deletedAt.isNotNull())..orderBy([(b) => OrderingTerm.desc(b.deletedAt)])).watch();

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

  static Future<File> file() async {
    final dir = await getApplicationDocumentsDirectory();
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

class BookRow {
  final Book book;
  final List<Read> reads;
  BookRow(this.book, this.reads);
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
}

void _pragmas(dynamic db) {
  db.execute('PRAGMA journal_mode = WAL'); // readers don't block the backup isolate's connection
  db.execute('PRAGMA busy_timeout = 5000');
}

LazyDatabase _open() => LazyDatabase(() async => NativeDatabase.createInBackground(await AppDb.file(), setup: _pragmas));
