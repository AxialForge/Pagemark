import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/text_utils.dart';
import 'package:drift/drift.dart' show Value;

void main() {
  group('normalizeTags', () {
    test('trims, de-duplicates ignoring case, drops empties, accepts , ; and newlines', () {
      expect(normalizeTags('  epic ,Epic,, classic ; sci-fi\nSCI-FI  '), 'epic, classic, sci-fi');
      expect(normalizeTags(''), '');
      expect(normalizeTags('a,  b   c , A'), 'a, b c');
    });
  });

  group('client id and sizes', () {
    test('Google client id shape', () {
      expect(looksLikeGoogleClientId('1234567890-abcdefg123.apps.googleusercontent.com'), isTrue);
      expect(looksLikeGoogleClientId(' 1234567890-abcdefg123.apps.googleusercontent.com '), isTrue);
      expect(looksLikeGoogleClientId('my-client-id'), isFalse);
      expect(looksLikeGoogleClientId('1234567890-abc.apps.example.com'), isFalse);
      expect(looksLikeGoogleClientId(''), isFalse);
    });
    test('humanBytes', () {
      expect(humanBytes(512), '512 B');
      expect(humanBytes(412 * 1024), '412 KB');
      expect(humanBytes((1.3 * 1048576).round()), '1.3 MB');
    });
  });

  group('BookRow equality (lets identical stream emissions be skipped)', () {
    test('same data == same, a changed read != same', () async {
      final db = AppDb.memory();
      final id = await db.into(db.books).insert(BooksCompanion.insert(title: 'A'));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: id, status: const Value('reading')));
      final one = (await db.watchLibrary(locked: false).first).single;
      final two = (await db.watchLibrary(locked: false).first).single;
      expect(one, two);
      expect(one.hashCode, two.hashCode);
      await (db.update(db.reads)).write(const ReadsCompanion(currentPage: Value(5)));
      final three = (await db.watchLibrary(locked: false).first).single;
      expect(one == three, isFalse);
      await db.close();
    });
    test('distinct() really collapses repeated identical emissions', () async {
      final db = AppDb.memory();
      await db.into(db.books).insert(BooksCompanion.insert(title: 'A'));
      var emissions = 0;
      final sub = db.watchLibrary(locked: false).distinct().listen((_) => emissions++);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // a write to an unrelated table re-runs the query but yields identical rows
      await db.addShelf('Unrelated');
      await db.addShelf('Unrelated 2');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(emissions, 1);
      await sub.cancel();
      await db.close();
    });
  });
}
