import 'dart:math' as math;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class StarRating extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double size;
  const StarRating({super.key, required this.value, required this.onChanged, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return Semantics(
      label: 'Rating ${value == 0 ? 'none' : value}',
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < 5; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final v = i + (d.localPosition.dx < size / 2 ? 0.5 : 1.0);
              HapticFeedback.selectionClick();
              onChanged(v == value ? 0 : v);
            },
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
      ]),
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
  const ShelfChips({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Shelf>>(
        stream: db.watchShelves(),
        builder: (_, sh) => StreamBuilder<List<BookShelf>>(
          stream: db.watchShelfLinks(),
          builder: (_, ln) {
            final mine = (ln.data ?? []).where((l) => l.bookId == bookId).map((l) => l.shelfId).toSet();
            final shelves = sh.data ?? [];
            return Wrap(spacing: 6, children: [
              for (final s in shelves.where((s) => mine.contains(s.id)))
                InputChip(avatar: const Icon(Icons.collections_bookmark_outlined, size: 16), label: Text(s.name), onDeleted: () => db.setOnShelf(bookId, s.id, false)),
              ActionChip(avatar: const Icon(Icons.add, size: 16), label: const Text('Shelf'), onPressed: () => pickShelves(context, bookId)),
            ]);
          },
        ),
      );
}

Future<void> pickShelves(BuildContext context, int bookId) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: StreamBuilder<List<Shelf>>(
          stream: db.watchShelves(),
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
  const ShelvesPage({super.key});
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
          stream: db.watchShelves(),
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

  static String fmtNum(double? n) => n == null ? '' : (n % 1 == 0 ? n.toInt().toString() : n.toString());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Series')),
        body: StreamBuilder<List<BookRow>>(
          stream: db.watchLibrary(locked: locked),
          builder: (_, snap) {
            final groups = <String, List<BookRow>>{};
            for (final r in snap.data ?? const <BookRow>[]) {
              final k = r.book.series.trim();
              if (k.isEmpty) continue;
              groups.putIfAbsent(k.toLowerCase(), () => []).add(r);
            }
            if (groups.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No series yet. Put a series name (and number) on a book via Edit and it appears here.', textAlign: TextAlign.center)));
            final keys = groups.keys.toList()..sort();
            return ListView(children: [
              for (final k in keys) _group(context, groups[k]!),
            ]);
          },
        ),
      );

  Widget _group(BuildContext context, List<BookRow> rows) {
    rows.sort((a, b) {
      final x = a.book.seriesNumber, y = b.book.seriesNumber;
      if (x != null && y != null && x != y) return x.compareTo(y);
      if (x != null && y == null) return -1;
      if (x == null && y != null) return 1;
      return a.book.title.compareTo(b.book.title);
    });
    final read = rows.where((r) => r.reads.any((e) => e.status == 'finished')).length;
    final next = rows.where((r) => !r.reads.any((e) => e.status == 'finished')).firstOrNull;
    return ExpansionTile(
      initiallyExpanded: rows.length <= 4,
      title: Text(rows.first.book.series.trim()),
      subtitle: Text('$read of ${rows.length} in your library read${next == null ? ' — all done' : ' · next: ${next.book.title}'}'),
      children: [
        for (final r in rows)
          ListTile(
            leading: Cover(r.book.coverUrl, locked: r.book.locked, title: r.book.title),
            title: Text('${r.book.seriesNumber == null ? '' : '#${fmtNum(r.book.seriesNumber)}  '}${r.book.title}'),
            subtitle: Text(r.reads.isEmpty ? 'Not logged' : statuses[r.status] ?? ''),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id))),
          ),
      ],
    );
  }
}

// ───────────────────────── Stats ─────────────────────────
class Stats extends StatefulWidget {
  const Stats({super.key});
  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  late final Stream<List<BookRow>> _stream = db.watchLibrary(locked: false).distinct();

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
          final dayOfYear = today.difference(DateTime(year)).inDays + 1;
          final pace = dayOfYear == 0 ? 0 : (thisYear.length / dayOfYear * 365).round();

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
          return ListView(padding: const EdgeInsets.all(12), children: [
            section('$year reading goal', Row(children: [
              GoalRing(done: thisYear.length, goal: goal),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal == 0 ? 'Set a goal to track your year.' : thisYear.length >= goal ? 'Goal reached — ${thisYear.length} books!' : '${goal - thisYear.length} to go'),
                if (goal > 0 && thisYear.isNotEmpty) Text('At this pace: about $pace books by Dec 31', style: Theme.of(context).textTheme.bodySmall),
                TextButton(onPressed: () => _setGoal(context, year, goal), child: Text(goal == 0 ? 'Set goal' : 'Change goal')),
              ])),
            ])),
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
            section('Top genres', RankBars(top(genres))),
            section('Top authors', RankBars(top(authors))),
          ]);
        },
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [Expanded(child: Text(k)), Text(v, style: Theme.of(context).textTheme.titleMedium)]),
      );
}
