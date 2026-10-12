// Not a real test: generates the sample library used for documentation screenshots.
// Run with:  SEED_OUT=C:\path\seed.sqlite flutter test test/tool_seed_demo_test.dart
// Without SEED_OUT it is skipped (so `flutter test` stays fast and side-effect free).
// See docs/_tools/screenshots/README.md.
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';

class B {
  final String title, author, isbn, genre, desc, series, tags;
  final int pages;
  final double? num;
  final bool locked;
  const B(this.title, this.author, this.isbn, this.pages, this.genre, this.desc, {this.series = '', this.num, this.tags = '', this.locked = false});
}

void main() {
  final path = Platform.environment['SEED_OUT'];
  test('seed demo library', () async {
    final out = File(path!);
    if (out.existsSync()) out.deleteSync();
    final db = AppDb.forFile(out);

    Future<int> book(B b) => db.into(db.books).insert(BooksCompanion.insert(
          title: b.title, author: Value(b.author), isbn: Value(b.isbn), genre: Value(b.genre), pages: Value(b.pages),
          coverUrl: Value('https://covers.openlibrary.org/b/isbn/${b.isbn}-L.jpg'), series: Value(b.series), seriesNumber: Value(b.num),
          description: Value(b.desc), tags: Value(b.tags), locked: Value(b.locked),
          added: Value(DateTime(2026, 1, 1).add(Duration(days: b.title.length * 7))),
        ));
    Future<void> read(int id, String status, {String fmt = 'print', DateTime? s, DateTime? f, double? r, String t = '', String narrator = '', int? min, int? page}) =>
        db.into(db.reads).insert(ReadsCompanion.insert(
            bookId: id, format: Value(fmt), status: Value(status), started: Value(s), finished: Value(f), rating: Value(r),
            thoughts: Value(t), narrator: Value(narrator), minutes: Value(min), currentPage: Value(page)));

    final dune = await book(const B('Dune', 'Frank Herbert', '9780441172719', 604, 'Science fiction', 'A young heir is thrown into a desert war over the one substance that makes interstellar travel possible.', series: 'Dune', num: 1, tags: 'classic, epic'));
    final hobbit = await book(const B('The Hobbit', 'J.R.R. Tolkien', '9780547928227', 300, 'Fantasy', 'A reluctant homebody is swept into a quest to reclaim a mountain from a dragon.', tags: 'cozy'));
    final pride = await book(const B('Pride and Prejudice', 'Jane Austen', '9780141439518', 480, 'Romance', 'Manners, money and misjudgement in a country neighbourhood.', tags: 'classic'));
    final martian = await book(const B('The Martian', 'Andy Weir', '9780553418026', 384, 'Science fiction', 'An astronaut left behind on Mars has to science his way home.'));
    final sapiens = await book(const B('Sapiens', 'Yuval Noah Harari', '9780062316097', 464, 'History', 'A sweeping history of how our species came to dominate the planet.'));
    final circe = await book(const B('Circe', 'Madeline Miller', '9780316556347', 400, 'Fantasy', 'The witch of Aiaia tells her own side of the old myths.', tags: 'mythology'));
    final educated = await book(const B('Educated', 'Tara Westover', '9780399590504', 352, 'Memoir', 'A memoir of growing up off the grid and finding a way into the classroom.'));
    final hawking = await book(const B('A Brief History of Time', 'Stephen Hawking', '9780553380163', 256, 'Science', 'Black holes, the Big Bang and the nature of time for the general reader.'));
    final emma = await book(const B('Emma', 'Jane Austen', '9780141439587', 474, 'Romance', 'A confident matchmaker discovers she has understood very little.', tags: 'classic'));
    final wind = await book(const B('The Name of the Wind', 'Patrick Rothfuss', '9780756404741', 662, 'Fantasy', 'A famous innkeeper finally tells the true story of his legend.', series: 'The Kingkiller Chronicle', num: 1));
    final hail = await book(const B('Project Hail Mary', 'Andy Weir', '9780593135204', 496, 'Science fiction', 'A lone teacher wakes on a spaceship with a mission he cannot remember.'));
    final cosmos = await book(const B('Cosmos', 'Carl Sagan', '9780345539434', 432, 'Science', 'A tour of the universe and our small place in it.'));
    final messiah = await book(const B('Dune Messiah', 'Frank Herbert', '9780593098233', 336, 'Science fiction', 'The cost of the prophecy comes due.', series: 'Dune', num: 2));
    final moby = await book(const B('Moby-Dick', 'Herman Melville', '9780142437247', 720, 'Classic', 'A whaling voyage turns into an obsession.'));
    await book(const B('Private Title', 'Hidden Author', '9781501161933', 400, 'Romance', 'Kept in the vault.', locked: true));

    await read(dune, 'finished', s: DateTime(2026, 1, 3), f: DateTime(2026, 1, 18), r: 5.0, min: 1320, t: 'Slow start, huge payoff. The ecology of Arrakis is the real star.');
    await read(hobbit, 'finished', fmt: 'audio', narrator: 'Rob Inglis', s: DateTime(2026, 2, 1), f: DateTime(2026, 2, 9), r: 4.5, min: 660, t: 'Perfect road-trip listen.');
    await read(pride, 'finished', fmt: 'ebook', s: DateTime(2026, 3, 2), f: DateTime(2026, 3, 14), r: 4.0, t: 'Sharper and funnier than I remembered.');
    await read(martian, 'finished', s: DateTime(2026, 3, 25), f: DateTime(2026, 4, 2), r: 4.5, min: 540, t: 'Could not put it down.');
    await read(sapiens, 'finished', fmt: 'audio', narrator: 'Derek Perkins', s: DateTime(2026, 5, 1), f: DateTime(2026, 5, 20), r: 3.5, min: 900);
    await read(circe, 'finished', s: DateTime(2026, 6, 1), f: DateTime(2026, 6, 11), r: 5.0, t: 'Lyrical and furious. Already want to re-read it.');
    await read(educated, 'finished', s: DateTime(2026, 7, 10), f: DateTime(2026, 7, 26), r: 4.0);
    await read(hawking, 'finished', s: DateTime(2026, 8, 20), f: DateTime(2026, 8, 30), r: 3.5);
    await read(emma, 'finished', fmt: 'ebook', s: DateTime(2026, 9, 1), f: DateTime(2026, 9, 12), r: 4.0);
    await read(wind, 'reading', s: DateTime(2026, 10, 1), page: 248);
    await read(hail, 'reading', fmt: 'audio', narrator: 'Ray Porter', s: DateTime(2026, 10, 6), page: 150);
    await read(cosmos, 'want');
    await read(messiah, 'want');
    await read(moby, 'dnf', s: DateTime(2026, 4, 10), r: 2.0, t: 'Gave up around the whaling chapters.');

    final comfort = await db.addShelf('Comfort reads');
    final club = await db.addShelf('Book club');
    final scifi = await db.addShelf('Sci-fi 2026');
    for (final b in [hobbit, pride, emma]) { await db.setOnShelf(b, comfort, true); }
    for (final b in [circe, educated]) { await db.setOnShelf(b, club, true); }
    for (final b in [dune, martian, hail]) { await db.setOnShelf(b, scifi, true); }

    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    await db.close();
  }, skip: path == null ? 'set SEED_OUT to generate the demo database' : false);
}
