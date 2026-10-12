import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

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
}

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
  AppDb.forFile(File f) : super(NativeDatabase(f));
  @override
  int get schemaVersion => 1;

  static Future<File> file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'pagemark.sqlite'));
  }

  Stream<List<BookRow>> watchLibrary({required bool locked}) {
    final q = select(books).join([leftOuterJoin(reads, reads.bookId.equalsExp(books.id))])
      ..where(books.locked.equals(locked))
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
  double? get avgRating {
    final r = reads.where((e) => e.rating != null).map((e) => e.rating!).toList();
    return r.isEmpty ? null : r.reduce((a, b) => a + b) / r.length;
  }
  String get status => reads.isEmpty ? 'none' : reads.first.status;
}

LazyDatabase _open() => LazyDatabase(() async => NativeDatabase.createInBackground(await AppDb.file()));
