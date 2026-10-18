import 'dart:math' as math;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'adaptive.dart';
import 'book_extras.dart' show heatStatsCard, adultFieldsOn;
import 'detailed_ratings.dart';
import 'reading_life.dart';
import 'reading_life_ui.dart';
import 'series.dart';
import 'volume.dart' show kinds;
import 'branding.dart';
import 'db.dart';
import 'main.dart';
import 'ui.dart';

String starsText(double v) {
  final full = v.floor();
  final half = v - full >= 0.25 && v - full < 0.75;
  final round = v - full >= 0.75 ? 1 : 0;
  return '★' * (full + round) + (half ? '½' : '');
}

// ───────────────────────── Small widgets ─────────────────────────

/// Tap the left half of a star for .5, the right half for a whole star; tap the same value again to clear.
/// Screen readers get one control: "Rating, 3.5 of 5 stars" that can be swiped up or down in half-star steps. Each star is at least
/// 40 wide and 48 tall to touch, even when drawn small.
class StarRating extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double size;
  final String label;
  const StarRating({super.key, required this.value, required this.onChanged, this.size = 40, this.label = 'Rating'});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    final box = size < 40 ? 40.0 : size;
    String fmt(double v) => v == 0 ? 'no stars' : '${v % 1 == 0 ? v.toInt() : v} of 5 stars';
    return Semantics(
      label: label,
      value: fmt(value),
      increasedValue: fmt((value + 0.5).clamp(0, 5).toDouble()),
      decreasedValue: fmt((value - 0.5).clamp(0, 5).toDouble()),
      onIncrease: value < 5 ? () => onChanged(value + 0.5) : null,
      onDecrease: value > 0 ? () => onChanged(value - 0.5) : null,
      child: ExcludeSemantics(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 5; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final v = i + (d.localPosition.dx < box / 2 ? 0.5 : 1.0);
                HapticFeedback.selectionClick();
                onChanged(v == value ? 0 : v);
              },
              child: SizedBox(
                width: box, height: box < 48 ? 48 : box,
                child: Center(
                  child: AnimatedScale(
                    scale: value > i ? 1.12 : 1,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      value >= i + 1 ? Icons.star_rounded : value >= i + 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded,
                      size: size, color: color,
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class SlimProgress extends StatelessWidget {
  final double value;
  const SlimProgress(this.value, {super.key});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: v, minHeight: 6)),
      );
}

class GoalRing extends StatelessWidget {
  final int done, goal;
  final double size;
  const GoalRing({super.key, required this.done, required this.goal, this.size = 96});
  @override
  Widget build(BuildContext context) {
    final target = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        width: size, height: size,
        child: CustomPaint(
          painter: _RingPainter(v, cs.primary, cs.surfaceContainerHighest),
          child: Center(child: Text(goal <= 0 ? '$done' : '$done/$goal', style: Theme.of(context).textTheme.titleMedium)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color fg, bg;
  _RingPainter(this.v, this.fg, this.bg);
  @override
  void paint(Canvas c, Size s) {
    const w = 10.0;
    final r = Rect.fromLTWH(w / 2, w / 2, s.width - w, s.height - w);
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round;
    c.drawArc(r, 0, math.pi * 2, false, p..color = bg);
    if (v > 0) c.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.fg != fg || o.bg != bg;
}

/// Simple animated vertical bar chart.
class BarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;
  const BarChart({super.key, required this.values, required this.labels, this.height = 120});
  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<double>(0, math.max);
    final cs = Theme.of(context).colorScheme;
    final small = Theme.of(context).textTheme.labelSmall;
    return SizedBox(
      height: height + 44 * math.max(1.0, MediaQuery.textScalerOf(context).scale(11) / 11), // bar + value label above + axis label below (grow with the font)
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(values[i] == 0 ? '' : values[i].toStringAsFixed(values[i] % 1 == 0 ? 0 : 1), style: small),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: maxV == 0 ? 0 : values[i] / maxV),
                  duration: Duration(milliseconds: 500 + i * 30),
                  curve: Curves.easeOutCubic,
                  builder: (_, f, _) => Container(
                    height: math.max(2, f * height),
                    decoration: BoxDecoration(color: values[i] == 0 ? cs.surfaceContainerHighest : cs.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  ),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: small),
              ]),
            ),
          ),
      ]),
    );
  }
}

class RankBars extends StatelessWidget {
  final List<MapEntry<String, int>> items;
  const RankBars(this.items, {super.key});
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('Nothing yet.');
    final top = items.first.value;
    return Column(children: [
      for (final e in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(width: 120, child: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Expanded(child: SlimProgress(e.value / top)),
            SizedBox(width: 28, child: Text('${e.value}', textAlign: TextAlign.end)),
          ]),
        ),
    ]);
  }
}

// ───────────────────────── Reading progress ─────────────────────────
class ProgressCard extends StatelessWidget {
  final Book book;
  final Read read;
  const ProgressCard({super.key, required this.book, required this.read});

  Future<void> _update(BuildContext context) async {
    final txt = await ask(context, book.pages == null ? 'Current page' : 'Current page (of ${book.pages})', '${read.currentPage ?? ''}', false, false, TextInputType.number);
    final page = int.tryParse(txt ?? '');
    if (page == null || page < 0) return;
    await (db.update(db.reads)..where((r) => r.id.equals(read.id))).write(ReadsCompanion(currentPage: Value(page)));
    if (book.pages != null && page >= book.pages! && context.mounted) {
      final fin = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('You reached the last page'),
          content: const Text('Mark this read as finished today?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not yet')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Finish')),
          ],
        ),
      );
      if (fin == true) {
        await (db.update(db.reads)..where((r) => r.id.equals(read.id))).write(ReadsCompanion(status: const Value('finished'), finished: Value(DateTime.now())));
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = book.pages;
    final page = read.currentPage;
    final frac = total != null && total > 0 && page != null ? (page / total).clamp(0.0, 1.0) : null;
    final started = read.started;
    final days = started == null ? null : DateTime.now().difference(started).inDays;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(
                page == null ? 'Reading now' : total == null ? 'Page $page' : 'Page $page of $total · ${(frac! * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            FilledButton.tonal(onPressed: () => _update(context), child: const Text('Update progress')),
          ]),
          if (frac != null) Padding(padding: const EdgeInsets.only(top: 8), child: SlimProgress(frac)),
          if (frac == null && total == null)
            const Padding(padding: EdgeInsets.only(top: 6), child: Text('Add the page count (Edit) to see a progress bar.', style: TextStyle(fontSize: 12))),
          if (days != null && days >= 0 && page != null && page > 0 && total != null && days > 0) ...[
            const SizedBox(height: 6),
            Text('${(page / days).toStringAsFixed(1)} pages/day over $days days'
                '${page < total ? ' · about ${((total - page) / (page / days)).ceil()} days left at this pace' : ''}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
      ),
    );
  }
}

// ───────────────────────── Shelves ─────────────────────────
class ShelfChips extends StatelessWidget {
  final int bookId;
  final bool locked;
  const ShelfChips({super.key, required this.bookId, this.locked = false});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Shelf>>(
        stream: db.watchShelves(locked: locked),
        builder: (_, sh) => StreamBuilder<List<BookShelf>>(
          stream: db.watchShelfLinks(),
          builder: (_, ln) {
            final mine = (ln.data ?? []).where((l) => l.bookId == bookId).map((l) => l.shelfId).toSet();
            final shelves = sh.data ?? [];
            return Wrap(spacing: 6, children: [
              for (final s in shelves.where((s) => mine.contains(s.id)))
                InputChip(avatar: const Icon(Icons.collections_bookmark_outlined, size: 16), label: Text(s.name), onDeleted: () => db.setOnShelf(bookId, s.id, false)),
              ActionChip(avatar: const Icon(Icons.add, size: 16), label: const Text('Shelf'), onPressed: () => pickShelves(context, bookId, locked: locked)),
            ]);
          },
        ),
      );
}

Future<void> pickShelves(BuildContext context, int bookId, {bool locked = false}) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: StreamBuilder<List<Shelf>>(
          stream: db.watchShelves(locked: locked),
          builder: (_, sh) => StreamBuilder<List<BookShelf>>(
            stream: db.watchShelfLinks(),
            builder: (_, ln) {
              final mine = (ln.data ?? []).where((l) => l.bookId == bookId).map((l) => l.shelfId).toSet();
              return ListView(shrinkWrap: true, children: [
                const ListTile(title: Text('Shelves', style: TextStyle(fontWeight: FontWeight.bold))),
                for (final s in sh.data ?? [])
                  CheckboxListTile(title: Text(s.name), value: mine.contains(s.id), onChanged: (v) => db.setOnShelf(bookId, s.id, v ?? false)),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New shelf'),
                  onTap: () async {
                    final n = await ask(c, 'Shelf name');
                    if (n == null || n.trim().isEmpty) return;
                    final id = await db.addShelf(n);
                    await db.setOnShelf(bookId, id, true);
                  },
                ),
              ]);
            },
          ),
        ),
      ),
    );

class ShelvesPage extends StatelessWidget {
  final bool locked;
  const ShelvesPage({super.key, this.locked = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Shelves')),
        floatingActionButton: FloatingActionButton(
          tooltip: 'New shelf',
          child: const Icon(Icons.add),
          onPressed: () async {
            final n = await ask(context, 'Shelf name');
            if (n != null && n.trim().isNotEmpty) await db.addShelf(n);
          },
        ),
        body: StreamBuilder<List<Shelf>>(
          stream: db.watchShelves(locked: locked),
          builder: (_, snap) {
            final list = snap.data ?? [];
            if (list.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No shelves yet. Shelves group books any way you like — "Comfort reads", "Book club", "Lent out". Add one, then put books on it from the book page.', textAlign: TextAlign.center)));
            return ListView(children: [
              for (final s in list)
                ListTile(
                  leading: const Icon(Icons.collections_bookmark_outlined),
                  title: Text(s.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Rename', onPressed: () async {
                      final n = await ask(context, 'Rename shelf', s.name);
                      if (n != null && n.trim().isNotEmpty) await db.renameShelf(s.id, n);
                    }),
                    IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete shelf (books stay)', onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text('Delete "${s.name}"?'),
                          content: const Text('Only the shelf is removed; the books stay in your library.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))],
                        ),
                      );
                      if (ok == true) await db.deleteShelf(s.id);
                    }),
                  ]),
                ),
            ]);
          },
        ),
      );
}

// ───────────────────────── Series ─────────────────────────
class SeriesPage extends StatelessWidget {
  final bool locked;
  const SeriesPage({super.key, required this.locked});

  static String fmtNum(double? n) => n == null || !n.isFinite ? '' : (n % 1 == 0 && n.abs() < 1e9 ? n.toInt().toString() : n.toString());

  /// A sensible series number from text: finite, above zero and not absurd; otherwise null.
  static double? parseNum(String text) {
    final d = double.tryParse(text.trim());
    return d != null && d.isFinite && d > 0 && d < 100000 ? d : null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Series')),
        body: SeriesData(
          locked: locked,
          builder: (context, groups) {
            if (groups.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No series yet. Put a series name (and number) on a book via Edit and it appears here.', textAlign: TextAlign.center)));
            }
            return ListView(children: [for (final g in groups) SeriesTile(group: g, locked: locked)]);
          },
        ),
      );
}

/// Feeds a builder the series of one library, kept up to date as books and series facts change.
class SeriesData extends StatelessWidget {
  final bool locked;
  final Widget Function(BuildContext, List<SeriesGroup>) builder;
  const SeriesData({super.key, required this.locked, required this.builder});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<BookRow>>(
        stream: db.watchLibrary(locked: locked),
        builder: (_, books) => StreamBuilder<List<SeriesInfoRow>>(
          stream: db.watchSeriesInfo(locked: locked),
          builder: (c, infos) => builder(c, groupSeries(books.data ?? const <BookRow>[], infos.data ?? const <SeriesInfoRow>[])),
        ),
      );
}

String seriesSummary(SeriesGroup g) {
  final total = g.total;
  return [
    '${g.ownedCount} of $total owned',
    '${g.readCount} read',
    if (g.wantedCount > 0) '${g.wantedCount} wanted',
    if (g.status.isNotEmpty) g.status == 'ongoing' ? 'ongoing' : 'complete',
  ].join(' · ');
}

class SeriesTile extends StatelessWidget {
  final SeriesGroup group;
  final bool locked;
  const SeriesTile({super.key, required this.group, required this.locked});

  @override
  Widget build(BuildContext context) {
    final first = group.rows.first.book;
    return ListTile(
      leading: Cover(first.coverUrl, locked: first.locked, title: first.title),
      title: Text(group.name),
      subtitle: Text(seriesSummary(group)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SeriesDetailPage(locked: locked, nameKey: group.key))),
    );
  }
}

/// One series: its volumes as a grid, what is missing, and a quick way to add the next volume.
class SeriesDetailPage extends StatelessWidget {
  final bool locked;
  final String nameKey;
  const SeriesDetailPage({super.key, required this.locked, required this.nameKey});

  @override
  Widget build(BuildContext context) => SeriesData(
        locked: locked,
        builder: (context, groups) {
          final g = groups.where((x) => x.key == nameKey).firstOrNull;
          if (g == null) {
            return Scaffold(appBar: AppBar(), body: const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('This series has no books left.', textAlign: TextAlign.center))));
          }
          return _SeriesBody(group: g, locked: locked);
        },
      );
}

class _SeriesBody extends StatelessWidget {
  final SeriesGroup group;
  final bool locked;
  const _SeriesBody({required this.group, required this.locked});

  Future<int> _addVolume(int n, {required bool owned}) {
    final seed = group.rows.last.book;
    return db.into(db.books).insert(BooksCompanion.insert(
          title: volumeTitle(group.name, n),
          author: Value(group.rows.map((r) => r.book.author).firstWhere((a) => a.isNotEmpty, orElse: () => '')),
          series: Value(group.name),
          seriesNumber: Value(n.toDouble()),
          kind: Value(group.kind),
          owned: Value(owned),
          genre: Value(seed.genre),
          publisher: Value(seed.publisher),
          locked: Value(locked),
        ));
  }

  Future<void> _add(BuildContext context, int n, {required bool owned}) async {
    final id = await _addVolume(n, owned: owned);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(owned ? 'Added volume $n' : 'Volume $n is on your wanted list'),
        action: SnackBarAction(label: 'Open', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: id)))),
      ));
  }

  Future<void> _tapMissing(BuildContext context, int n) async {
    final pick = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: Text('Volume $n', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Not in your library yet')),
          ListTile(leading: const Icon(Icons.add_circle_outline), title: const Text('I own it'), subtitle: const Text('Add it to your library'), onTap: () => Navigator.pop(c, 'own')),
          ListTile(leading: const Icon(Icons.bookmark_border), title: const Text('Add to my wanted list'), subtitle: const Text('Remember to get it'), onTap: () => Navigator.pop(c, 'want')),
        ]),
      ),
    );
    if (pick == null || !context.mounted) return;
    await _add(context, n, owned: pick == 'own');
  }

  Future<void> _tapBooks(BuildContext context, VolumeCell cell) async {
    if (cell.books.length == 1) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: cell.books.first.book.id)));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final r in cell.books)
            ListTile(
              title: Text(r.book.title),
              subtitle: Text(r.book.owned ? (SeriesGroup.isRead(r) ? 'Owned, read' : 'Owned') : 'Wanted'),
              onTap: () {
                Navigator.pop(c);
                Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id)));
              },
            ),
        ]),
      ),
    );
  }

  Future<void> _editTotal(BuildContext context) async {
    final t = await ask(context, 'How many volumes does it have?', group.info?.total == null ? '' : '${group.info!.total}', false, false, TextInputType.number);
    if (t == null) return;
    final n = int.tryParse(t.trim());
    await db.setSeriesInfo(group.name, locked: locked, total: n?.clamp(1, 5000), clearTotal: n == null);
  }

  @override
  Widget build(BuildContext context) {
    final g = group;
    final cells = g.cells;
    final next = g.nextToRead;
    return Scaffold(
      appBar: AppBar(title: Text(g.name, overflow: TextOverflow.ellipsis)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text('Add volume ${g.nextNumber}'),
        onPressed: () => _add(context, g.nextNumber, owned: true),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
        Text(seriesSummary(g), style: Theme.of(context).textTheme.titleMedium),
        if (g.nextToBuy != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Next to get: volume ${g.nextToBuy}')),
        if (next != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text('Next to read: ${next.book.title}')),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (final e in const {'ongoing': 'Ongoing', 'complete': 'Complete'}.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: g.status == e.key,
              onSelected: (on) => db.setSeriesInfo(g.name, locked: locked, status: on ? e.key : ''),
            ),
          ActionChip(avatar: const Icon(Icons.edit_outlined, size: 18), label: Text(g.info?.total == null ? 'Set the number of volumes' : '${g.info!.total} volumes'), onPressed: () => _editTotal(context)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final e in kinds.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: g.kind == e.key,
              onSelected: (_) => db.setSeriesKind(g.name, locked: locked, kind: e.key),
            ),
        ]),
        const SizedBox(height: 16),
        Semantics(
          label: 'Volumes. Each button is one volume: read, owned, wanted or missing.',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in cells)
              VolumeButton(
                cell: c,
                onTap: () => c.state == VolumeState.missing ? _tapMissing(context, c.number) : _tapBooks(context, c),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        ExcludeSemantics(
          child: Wrap(spacing: 16, runSpacing: 4, children: [
            for (final s in VolumeState.values) Row(mainAxisSize: MainAxisSize.min, children: [VolumeBox(state: s, size: 18), const SizedBox(width: 6), Text(volumeStateName(s), style: Theme.of(context).textTheme.bodySmall)]),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share missing list'),
            onPressed: g.missing.isEmpty && g.wantedCount == 0 ? null : () => SharePlus.instance.share(ShareParams(text: g.missingText)),
          ),
        ]),
        if (g.others.isNotEmpty) ...[
          const Divider(height: 32),
          Text('Other books in this series', style: Theme.of(context).textTheme.titleMedium),
          for (final r in g.others) _bookTile(context, r),
        ],
        const Divider(height: 32),
        Text('All books', style: Theme.of(context).textTheme.titleMedium),
        for (final r in g.rows) _bookTile(context, r),
        if (_ratingLine(g).isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_ratingLine(g), style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }

  static String _ratingLine(SeriesGroup g) {
    final avg = seriesAverage(g.rows);
    return avg.average == null ? '' : 'Average ${avg.average!.toStringAsFixed(1)} stars (${avg.rated} rated)';
  }

  Widget _bookTile(BuildContext context, BookRow r) => ListTile(
        leading: Cover(r.book.coverUrl, locked: r.book.locked, title: r.book.title),
        title: Text('${r.book.seriesNumber == null ? '' : '#${SeriesPage.fmtNum(r.book.seriesNumber)}  '}${r.book.title}'),
        subtitle: Text(!r.book.owned ? 'Wanted' : r.reads.isEmpty ? 'Not logged' : statuses[r.status] ?? ''),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id))),
      );
}

String volumeStateName(VolumeState s) => switch (s) {
      VolumeState.read => 'Read',
      VolumeState.owned => 'Owned',
      VolumeState.wanted => 'Wanted',
      VolumeState.missing => 'Missing',
    };

/// One volume of the grid: a labelled button at least 48 dp square.
class VolumeButton extends StatelessWidget {
  final VolumeCell cell;
  final VoidCallback onTap;
  const VolumeButton({super.key, required this.cell, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Volume ${cell.number}, ${volumeStateName(cell.state).toLowerCase()}',
        excludeSemantics: true,
        onTap: onTap,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: VolumeBox(state: cell.state, size: 48, label: '${cell.number}'),
          ),
        ),
      );
}

/// The picture of a volume: filled (read), outlined (owned), dashed (wanted) or grey (missing). The state is also in the words of the
/// legend and the spoken label, never colour alone.
class VolumeBox extends StatelessWidget {
  final VolumeState state;
  final double size;
  final String? label;
  const VolumeBox({super.key, required this.state, required this.size, this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fill, line, ink) = switch (state) {
      VolumeState.read => (cs.primary, cs.primary, cs.onPrimary),
      VolumeState.owned => (Colors.transparent, cs.primary, cs.onSurface),
      VolumeState.wanted => (Colors.transparent, cs.tertiary, cs.onSurface),
      VolumeState.missing => (cs.surfaceContainerHighest, cs.outlineVariant, cs.onSurfaceVariant),
    };
    return CustomPaint(
      painter: _BoxPainter(fill: fill, line: line, dashed: state == VolumeState.wanted, radius: size / 5),
      child: SizedBox(
        width: size,
        height: size,
        child: label == null
            ? null
            : Center(child: Text(label!, style: TextStyle(color: ink, fontWeight: state == VolumeState.read ? FontWeight.bold : FontWeight.normal, fontSize: label!.length > 3 ? 12 : 15))),
      ),
    );
  }
}

class _BoxPainter extends CustomPainter {
  final Color fill, line;
  final bool dashed;
  final double radius;
  _BoxPainter({required this.fill, required this.line, required this.dashed, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(1);
    canvas.drawRRect(rrect, Paint()..color = fill);
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (!dashed) {
      canvas.drawRRect(rrect, stroke);
      return;
    }
    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, (d + 4).clamp(0, m.length)), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_BoxPainter o) => o.fill != fill || o.line != line || o.dashed != dashed || o.radius != radius;
}

// ───────────────────────── Stats ─────────────────────────
class Stats extends StatefulWidget {
  const Stats({super.key});
  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  late final Stream<List<BookRow>> _stream = db.watchLibrary(locked: false).distinct();
  late final Stream<List<ReadingSession>> _sessions = db.watchSessions(locked: false);

  static const _months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

  Future<void> _setGoal(BuildContext context, int year, int current) async {
    final t = await ask(context, 'How many books in $year?', current > 0 ? '$current' : '', false, false, TextInputType.number);
    final n = int.tryParse(t ?? '');
    if (n == null) return;
    await prefs.setInt('goal_$year', n.clamp(0, 9999));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: StreamBuilder<List<BookRow>>(
        // The vault never feeds the stats: only the main library is counted.
        stream: _stream,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          final reads = [for (final r in rows) ...r.reads];
          final done = reads.where((r) => r.status == 'finished').toList();
          final thisYear = done.where((r) => r.finished?.year == year).toList();
          final goal = prefs.getInt('goal_$year') ?? 0;
          final today = DateTime.now();
          // calendar days in UTC, so a daylight-saving day of 23 or 25 hours cannot shift the count
          final dayOfYear = DateTime.utc(today.year, today.month, today.day).difference(DateTime.utc(year)).inDays + 1;
          final daysInYear = DateTime.utc(year + 1).difference(DateTime.utc(year)).inDays;
          final pace = dayOfYear <= 0 ? 0 : (thisYear.length / dayOfYear * daysInYear).round();

          final perMonth = List<double>.filled(12, 0);
          for (final r in thisYear) { perMonth[r.finished!.month - 1] += 1; }

          final rated = done.where((r) => r.rating != null).map((r) => r.rating!).toList();
          final hist = List<double>.filled(10, 0);
          for (final v in rated) { hist[(v * 2).round().clamp(1, 10) - 1] += 1; }

          final byFmt = <String, int>{};
          for (final r in done) { byFmt[r.format] = (byFmt[r.format] ?? 0) + 1; }

          final bookOf = {for (final r in rows) r.book.id: r.book};
          final genres = <String, int>{}, authors = <String, int>{};
          for (final r in done) {
            final b = bookOf[r.bookId];
            if (b == null) continue;
            final g = b.genre.split(',').first.trim();
            if (g.isNotEmpty) genres[g] = (genres[g] ?? 0) + 1;
            final a = b.author.split(',').first.trim();
            if (a.isNotEmpty) authors[a] = (authors[a] ?? 0) + 1;
          }
          List<MapEntry<String, int>> top(Map<String, int> m) => (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();

          final spans = done.where((r) => r.started != null && r.finished != null && !r.finished!.isBefore(r.started!)).map((r) => r.finished!.difference(r.started!).inDays + 1).toList();
          final avgDays = spans.isEmpty ? null : spans.reduce((a, b) => a + b) / spans.length;
          final mins = done.fold<int>(0, (a, r) => a + (r.minutes ?? 0));
          final pages = done.fold<int>(0, (a, r) => a + (bookOf[r.bookId]?.pages ?? 0));

          Widget section(String title, Widget child) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  child,
                ])),
              );

          if (rows.isEmpty) return const EmptyState(message: 'Add and finish some books to see your stats.');
          return NarrowColumn(child: ListView(padding: const EdgeInsets.all(12), children: [
            section('$year reading goal', Row(children: [
              GoalRing(done: thisYear.length, goal: goal),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal == 0 ? 'Set a goal to track your year.' : thisYear.length >= goal ? 'Goal reached — ${thisYear.length} books!' : '${goal - thisYear.length} to go'),
                if (goal > 0 && thisYear.isNotEmpty) Text('At this pace: about $pace books by Dec 31', style: Theme.of(context).textTheme.bodySmall),
                TextButton(onPressed: () => _setGoal(context, year, goal), child: Text(goal == 0 ? 'Set goal' : 'Change goal')),
              ])),
            ])),
            section('$year in books', YearCard(s: yearSummary(rows, year))),
            section('Days you read', StreamBuilder<List<ReadingSession>>(
              stream: _sessions,
              builder: (_, ss) => StreakCard(days: readingDays(ss.data ?? const [], reads), now: DateTime.now()),
            )),
            section('Finished per month ($year)', BarChart(values: perMonth, labels: _months)),
            section('Your ratings', rated.isEmpty
                ? const Text('Rate finished books to see the spread.')
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    BarChart(values: hist, labels: const ['½', '1', '1½', '2', '2½', '3', '3½', '4', '4½', '5'], height: 90),
                    const SizedBox(height: 6),
                    Text('Average ${(rated.reduce((a, b) => a + b) / rated.length).toStringAsFixed(2)} across ${rated.length} rated books', style: Theme.of(context).textTheme.bodySmall),
                  ])),
            section('Totals', Column(children: [
              _kv(context, 'Books tracked', '${rows.length}'),
              _kv(context, 'Finished (all time)', '${done.length}'),
              if (pages > 0) _kv(context, 'Pages in finished books', '$pages'),
              if (mins > 0) _kv(context, 'Logged time', '${(mins / 60).toStringAsFixed(1)} h'),
              if (avgDays != null) _kv(context, 'Average days to finish', avgDays.toStringAsFixed(1)),
              for (final e in byFmt.entries) _kv(context, 'Finished · ${formats[e.key]}', '${e.value}'),
            ])),
            detailedRatingsCard(context, rows.expand((r) => r.reads)),
            if (adultFieldsOn()) heatStatsCard(context, done),
            section('Top genres', RankBars(top(genres))),
            section('Top authors', RankBars(top(authors))),
          ]));
        },
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [Expanded(child: Text(k)), Text(v, style: Theme.of(context).textTheme.titleMedium)]),
      );
}
