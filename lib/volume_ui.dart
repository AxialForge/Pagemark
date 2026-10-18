import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'db.dart';
import 'main.dart' as app;
import 'series.dart';
import 'volume.dart';

AppDb get _db => app.db;

/// Puts a book into the series a [VolumeGuess] suggested: the series name, the volume number, and the kind the series already has
/// (the other volumes decide it; a first volume stays a plain book until the Series page says otherwise).
Future<void> applyVolume(int bookId, VolumeGuess g, {AppDb? database}) async {
  final db = database ?? _db;
  final book = await (db.select(db.books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
  if (book == null) return;
  final mates = await (db.select(db.books)..where((b) => b.locked.equals(book.locked))..where((b) => b.deletedAt.isNull())).get();
  final key = AppDb.seriesKey(g.series);
  final same = [for (final m in mates) if (m.id != bookId && AppDb.seriesKey(m.series) == key) m];
  final kind = same.map((m) => m.kind).firstWhere((k) => k.isNotEmpty, orElse: () => book.kind);
  // reuse the spelling the library already has, so "one piece" and "One Piece" stay one series
  final name = same.isEmpty ? g.series : same.first.series.trim();
  await (db.update(db.books)..where((b) => b.id.equals(bookId))).write(BooksCompanion(
    series: Value(name),
    seriesNumber: Value(g.number),
    kind: Value(kind),
  ));
}

/// Asks whether a freshly added book is a volume of a series, when its title says so. Nothing changes unless the owner says yes.
Future<void> offerVolume(BuildContext context, int bookId) async {
  final book = await (_db.select(_db.books)..where((b) => b.id.equals(bookId))).getSingleOrNull();
  if (book == null || book.series.trim().isNotEmpty) return;
  final g = parseVolume(book.title);
  if (g == null || !context.mounted) return;
  final yes = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('Is this volume ${_fmt(g.number)} of ${g.series}?'),
      content: Text(g.sure
          ? 'Pagemark can add it to the series ${g.series}, so you can see which volumes you have.'
          : 'The title looks like a set of several volumes, so check the number first. You can change it later in Edit.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not a series')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
      ],
    ),
  );
  if (yes == true) await applyVolume(bookId, g);
}

String _fmt(double n) => n % 1 == 0 ? n.toInt().toString() : n.toString();

/// The line for a suggestion beside a scanned book: "Volume 3 of Dragon Ball Z?".
String guessText(VolumeGuess g) => 'Volume ${_fmt(g.number)} of ${g.series}?';

/// Used by tests and the Series page to show a kind in words.
String kindWord(String kind) => kindLabel(kind);
