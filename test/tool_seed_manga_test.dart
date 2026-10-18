// Not a real test: adds a manga collection to the demo library used for documentation screenshots.
// Run with:  SEED_DB=C:\path\seed.sqlite flutter test test/tool_seed_manga_test.dart   (after tool_seed_demo_test.dart made the file)
// Without SEED_DB it is skipped. See docs/_tools/screenshots/README.md.
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';

void main() {
  final path = Platform.environment['SEED_DB'];
  test('add a manga collection to the demo library', () async {
    final db = AppDb.forFile(File(path!));

    Future<void> volume(String series, int n, {bool owned = true, bool read = false, String kind = 'manga', String author = ''}) async {
      final id = await db.into(db.books).insert(BooksCompanion.insert(
            title: '$series, Vol. $n',
            author: Value(author),
            series: Value(series),
            seriesNumber: Value(n.toDouble()),
            kind: Value(kind),
            owned: Value(owned),
            added: Value(DateTime(2026, 6, 1).add(Duration(days: n))),
          ));
      if (read) {
        await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('finished'), finished: Value(DateTime(2026, 7, n)), rating: const Value(4.5)));
      }
    }

    for (var n = 1; n <= 9; n++) {
      if (n == 5 || n == 8) continue;
      await volume('Berserk', n, read: n <= 3, author: 'Kentaro Miura');
    }
    await volume('Berserk', 5, owned: false, author: 'Kentaro Miura');
    await db.setSeriesInfo('Berserk', locked: false, total: 12, status: 'ongoing');
    for (var n = 1; n <= 4; n++) {
      await volume('One Piece', n, read: true, author: 'Eiichiro Oda');
    }
    await db.setSeriesInfo('One Piece', locked: false, total: 4, status: 'complete');
    for (var n = 1; n <= 3; n++) {
      await volume('Spice and Wolf', n, kind: 'lightnovel', author: 'Isuna Hasekura');
    }
    await db.close();
  }, skip: path == null);
}
