// PGM-300 series audit script: every historic schema (1-5, built by the code of v0.1.0, v0.2.0, v0.4.2, v0.6.0, v0.9.0) must migrate to the
// current schema with all rows intact, pass SQLite's own checks, and then accept every write the 0.12/0.13 features make.
// Run: copy the seed databases to a folder, set SEEDS=<folder>, then `flutter test docs/release-audit/scripts/pgm300_migration_test.dart`.
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/reading_life.dart';

void main() {
  final seeds = Platform.environment['SEEDS']!;
  for (var v = 1; v <= 5; v++) {
    test('schema $v migrates to ${AppDb.currentSchema} and keeps everything', () async {
      final dir = Directory.systemTemp.createTempSync('pgm300_$v');
      final f = File('${dir.path}/pagemark.sqlite')..writeAsBytesSync(File('$seeds/schema$v.sqlite').readAsBytesSync());
      final db = AppDb.forFile(f);
      final books = await db.select(db.books).get();
      expect(books.where((b) => b.title == 'Old Book').length, 1);
      expect(books.firstWhere((b) => b.title == 'Secret Old').locked, isTrue);
      expect(books.length, v >= 2 ? 3 : 2, reason: 'trash row exists from schema 2');
      expect((await db.select(db.reads).get()).length, 2);
      if (v >= 3) expect((await db.select(db.shelves).get()).single.name, 'Fav');
      if (v >= 4) expect((await db.select(db.quotes).get()).single.body, 'kept line');
      expect((await db.customSelect('PRAGMA user_version').getSingle()).read<int>('user_version'), AppDb.currentSchema);
      expect((await db.customSelect('PRAGMA integrity_check').getSingle()).read<String>('integrity_check'), 'ok');
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      // the new features write cleanly into a migrated database
      final id = books.firstWhere((b) => b.title == 'Old Book').id;
      await db.addSession(id, 12, pages: 5);
      await db.lend(id, 'Sam', remindOn: DateTime(2027));
      await db.saveQueue([id]);
      await db.addQuote(id, 'new line', rating: 4);
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, ratingStory: const Value(4)));
      expect((await db.watchLibrary(locked: false).first).length, 1);
      // a second open of the same file is a no-op
      await db.close();
      final again = AppDb.forFile(f);
      expect((await again.select(again.books).get()).length, books.length);
      expect(await again.select(again.loans).get(), hasLength(1));
      await again.close();
      dir.deleteSync(recursive: true);
    });
  }
}
