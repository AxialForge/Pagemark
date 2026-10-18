import 'db.dart';
import 'volume.dart';

/// The state of one volume number in a series.
enum VolumeState { read, owned, wanted, missing }

/// One volume slot of the grid: a whole number from 1 to the series total, with the books that sit on it.
class VolumeCell {
  final int number;
  final VolumeState state;
  final List<BookRow> books;
  const VolumeCell(this.number, this.state, this.books);
}

/// Every book of one series (in one library) with what is known about the series as a whole.
class SeriesGroup {
  final String key;
  final String name;
  final List<BookRow> rows; // in volume order
  final SeriesInfoRow? info;
  const SeriesGroup(this.key, this.name, this.rows, this.info);

  /// 'manga', 'comic', 'lightnovel' or '': the most common kind among the books.
  String get kind {
    final n = <String, int>{};
    for (final r in rows) {
      if (r.book.kind.isNotEmpty) n[r.book.kind] = (n[r.book.kind] ?? 0) + 1;
    }
    if (n.isEmpty) return '';
    return n.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Ongoing, complete or '' (not said).
  String get status => info?.status ?? '';

  static bool isRead(BookRow r) => r.reads.any((e) => e.status == 'finished');

  /// The highest whole volume number among the books.
  int get highest => rows.map((r) => r.book.seriesNumber).whereType<double>().fold<int>(0, (a, n) => n.ceil() > a ? n.ceil() : a);

  /// How many volumes the series has: the stored total when there is one, else the highest number seen, else the book count.
  /// Never smaller than the highest number you hold, so a wrong total cannot hide a volume.
  int get total {
    final stored = info?.total ?? rows.map((r) => r.book.seriesTotal ?? 0).fold<int>(0, (a, b) => a > b ? a : b);
    final floor = highest > 0 ? highest : rows.length;
    return stored > floor ? stored : floor;
  }

  /// Books you own (a wanted volume is on the list but not yours yet).
  int get ownedCount => rows.where((r) => r.book.owned).length;
  int get readCount => rows.where(isRead).length;
  int get wantedCount => rows.where((r) => !r.book.owned).length;

  /// The grid: volumes 1 to [total]. A volume with a book on it is read, owned or wanted (the best of its books); an empty slot is missing.
  List<VolumeCell> get cells {
    final byNumber = <int, List<BookRow>>{};
    for (final r in rows) {
      final n = r.book.seriesNumber;
      if (n == null || n % 1 != 0 || n < 1 || n > total) continue;
      (byNumber[n.toInt()] ??= []).add(r);
    }
    return [
      for (var i = 1; i <= total && i <= 5000; i++)
        VolumeCell(i, _state(byNumber[i]), byNumber[i] ?? const []),
    ];
  }

  static VolumeState _state(List<BookRow>? books) {
    if (books == null || books.isEmpty) return VolumeState.missing;
    if (books.any((r) => r.book.owned && isRead(r))) return VolumeState.read;
    if (books.any((r) => r.book.owned)) return VolumeState.owned;
    return VolumeState.wanted;
  }

  /// Books that are not on a whole-number slot (2.5, an omnibus) or have no number: listed under the grid.
  List<BookRow> get others => [
        for (final r in rows)
          if (r.book.seriesNumber == null || r.book.seriesNumber! % 1 != 0 || r.book.seriesNumber! < 1 || r.book.seriesNumber! > total) r,
      ];

  /// Volume numbers you neither own nor have on your wanted list.
  List<int> get missing => [for (final c in cells) if (c.state == VolumeState.missing) c.number];

  /// The first volume you do not own, counting a wanted one: what to buy next. Null when nothing is left to get.
  int? get nextToBuy {
    for (final c in cells) {
      if (c.state == VolumeState.missing || c.state == VolumeState.wanted) return c.number;
    }
    return null;
  }

  /// The number a new volume should get: one past the highest you hold, but not past a total you know to be complete.
  int get nextNumber => highest + 1;

  /// The first volume you own and have not read.
  BookRow? get nextToRead {
    for (final c in cells) {
      if (c.state == VolumeState.owned) return c.books.firstWhere((r) => r.book.owned && !isRead(r));
    }
    return rows.where((r) => r.book.owned && !isRead(r)).firstOrNull;
  }

  /// "Berserk: missing 3-4, 7" (ranges squeezed), or a line saying nothing is missing.
  String get missingText {
    final m = missing;
    if (m.isEmpty) return '$name: nothing missing';
    return '$name: missing ${squeezeNumbers(m)}';
  }
}

/// [3, 4, 5, 7, 9, 10] becomes "3-5, 7, 9-10".
String squeezeNumbers(List<int> sorted) {
  final out = <String>[];
  var i = 0;
  while (i < sorted.length) {
    var j = i;
    while (j + 1 < sorted.length && sorted[j + 1] == sorted[j] + 1) {
      j++;
    }
    out.add(j == i ? '${sorted[i]}' : '${sorted[i]}-${sorted[j]}');
    i = j + 1;
  }
  return out.join(', ');
}

int _byNumber(BookRow a, BookRow b) {
  final x = a.book.seriesNumber, y = b.book.seriesNumber;
  if (x != null && y != null && x != y) return x.compareTo(y);
  if (x != null && y == null) return -1;
  if (x == null && y != null) return 1;
  return a.book.title.compareTo(b.book.title);
}

/// Groups books by series name (ignoring case and surrounding spaces). Books with no series are left out.
List<SeriesGroup> groupSeries(Iterable<BookRow> rows, Iterable<SeriesInfoRow> infos) {
  final byKey = <String, List<BookRow>>{};
  for (final r in rows) {
    final k = AppDb.seriesKey(r.book.series);
    if (k.isEmpty) continue;
    (byKey[k] ??= []).add(r);
  }
  final info = {for (final i in infos) i.nameKey: i};
  final keys = byKey.keys.toList()..sort();
  return [
    for (final k in keys)
      SeriesGroup(k, byKey[k]!.first.book.series.trim(), byKey[k]!..sort(_byNumber), info[k]),
  ];
}

/// The title a new volume gets: "Berserk, Vol. 4", with the volume word Pagemark uses for the kind.
String volumeTitle(String series, int number) => '${series.trim()}, Vol. $number';

/// Whether to show the Library grouped by series without being asked: some series has this many volumes.
const groupAutoThreshold = 3;

bool shouldAutoGroup(Iterable<BookRow> rows) {
  final n = <String, int>{};
  for (final r in rows) {
    final k = AppDb.seriesKey(r.book.series);
    if (k.isEmpty) continue;
    n[k] = (n[k] ?? 0) + 1;
    if (n[k]! >= groupAutoThreshold) return true;
  }
  return false;
}

/// How the library counts toward Stats: volumes read and series completed, per kind.
class SeriesStats {
  final int volumesRead;
  final int seriesCompleted;
  final Map<String, int> readByKind; // finished books by kind ('' = plain books)
  const SeriesStats(this.volumesRead, this.seriesCompleted, this.readByKind);
}

SeriesStats seriesStats(Iterable<BookRow> rows, Iterable<SeriesInfoRow> infos) {
  var volumes = 0;
  final byKind = <String, int>{};
  for (final r in rows) {
    if (!r.book.owned || !SeriesGroup.isRead(r)) continue;
    byKind[r.book.kind] = (byKind[r.book.kind] ?? 0) + 1;
    if (r.book.kind.isNotEmpty) volumes++;
  }
  var done = 0;
  for (final g in groupSeries(rows, infos)) {
    if (g.status == 'complete' && g.total > 0 && g.cells.every((c) => c.state == VolumeState.read)) done++;
  }
  return SeriesStats(volumes, done, byKind);
}

/// The kind a book should get when a series is added to it, so a whole series is one kind.
String kindLabel(String kind) => kinds[kind] ?? 'Book';
