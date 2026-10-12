import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db.dart';
import 'features.dart';
import 'ui.dart';

/// How the Library draws your books. Same data, five looks; the choice is remembered per library.
enum LibrarySkin {
  classic('Classic', 'Cover, title, status and rating on every row', Icons.view_list_rounded),
  grid('Cover wall', 'A grid of covers with ratings and progress', Icons.grid_view_rounded),
  shelf('Bookshelf', 'Covers standing on wooden shelves', Icons.shelves),
  spines('Spines', 'Books side by side, sized by page count', Icons.menu_book_rounded),
  compact('Compact', 'One tight line per book - fits the most', Icons.format_list_bulleted_rounded);

  final String label, blurb;
  final IconData icon;
  const LibrarySkin(this.label, this.blurb, this.icon);
}

LibrarySkin skinById(String? id) => LibrarySkin.values.firstWhere((s) => s.name == id, orElse: () => LibrarySkin.classic);

Future<LibrarySkin?> showSkinPicker(BuildContext context, LibrarySkin current) => showModalBottomSheet<LibrarySkin>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [ // scrolls on short screens (landscape, small phones)
          const ListTile(title: Text('Library style', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final s in LibrarySkin.values)
            ListTile(
              leading: Icon(s.icon),
              title: Text(s.label),
              subtitle: Text(s.blurb),
              trailing: s == current ? const Icon(Icons.check) : null,
              selected: s == current,
              onTap: () => Navigator.pop(c, s),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );

/// Draws [rows] in the chosen [skin], cross-fading when the skin changes.
class SkinView extends StatelessWidget {
  final LibrarySkin skin;
  final List<BookRow> rows;
  const SkinView({super.key, required this.skin, required this.rows});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(skin),
          child: switch (skin) {
            LibrarySkin.classic => ClassicList(rows: rows),
            LibrarySkin.grid => CoverGrid(rows: rows),
            LibrarySkin.shelf => BookshelfView(rows: rows),
            LibrarySkin.spines => SpinesView(rows: rows),
            LibrarySkin.compact => CompactList(rows: rows),
          },
        ),
      );
}

const _bottomPad = 96.0; // clear of the Add button

void _open(BuildContext context, BookRow r) => Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id)));

int _hash(String s) => s.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0x7fffffff);

/// A stable colour per title, nudged 16% toward the theme's primary so spines and blank covers feel at home in
/// every theme (blue for "Him", rose/plum for "Her") while staying distinguishable from each other.
Color bookColorFor(String title, ColorScheme cs) {
  final dark = cs.brightness == Brightness.dark;
  final h = _hash(title);
  final base = HSLColor.fromAHSL(1, (h % 360).toDouble(), 0.42 + (h % 5) * 0.04, dark ? 0.30 : 0.42).toColor();
  return Color.lerp(base, cs.primary, 0.16)!;
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Text colour with the better WCAG contrast against [c] (black or white): always at least ~4.6:1.
Color onBookColor(Color c) => _contrast(c, Colors.white) >= _contrast(c, Colors.black87) ? Colors.white : Colors.black87;

Color _bookColor(BuildContext context, String title) => bookColorFor(title, Theme.of(context).colorScheme);
Color _onColor(Color c) => onBookColor(c);

/// The back of the bookcase: a faint theme-tinted panel behind the books.
Color _wall(ColorScheme cs) => Color.alphaBlend(cs.primary.withValues(alpha: 0.07), cs.surfaceContainer);

// ───────────────────────── Classic ─────────────────────────
class ClassicList extends StatelessWidget {
  final List<BookRow> rows;
  const ClassicList({super.key, required this.rows});
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.only(bottom: _bottomPad),
        itemCount: rows.length,
        itemBuilder: (_, i) => TweenAnimationBuilder<double>(
          key: ValueKey(rows[i].book.id),
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 280 + (i < 8 ? i * 40 : 320)),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child)),
          child: BookTile(row: rows[i]),
        ),
      );
}

// ───────────────────────── Compact ─────────────────────────
class CompactList extends StatelessWidget {
  final List<BookRow> rows;
  const CompactList({super.key, required this.rows});
  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: _bottomPad),
      itemCount: rows.length,
      itemExtent: 52,
      itemBuilder: (_, i) {
        final r = rows[i], b = r.book, rating = r.avgRating;
        return InkWell(
          onTap: () => _open(context, r),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(children: [
              Cover(b.coverUrl, w: 30, locked: b.locked),
              const SizedBox(width: 12),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(
                    [b.author, if (r.reads.isNotEmpty) statuses[r.status]].where((s) => s != null && s.isNotEmpty).join(' · '),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall,
                  ),
                ]),
              ),
              if (r.progress != null) Text('${(r.progress! * 100).round()}%', style: Theme.of(context).textTheme.labelMedium),
              if (rating != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(starsText(rating), style: TextStyle(color: tertiary, fontSize: 13))),
            ]),
          ),
        );
      },
    );
  }
}

// ───────────────────────── Cover wall ─────────────────────────
class _Blank extends StatelessWidget {
  final String title;
  final double w, h;
  const _Blank(this.title, this.w, this.h);
  @override
  Widget build(BuildContext context) {
    final c = _bookColor(context, title);
    return Container(
      width: w, height: h, padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.center,
      child: Text(title, textAlign: TextAlign.center, maxLines: 5, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _onColor(c), fontSize: math.max(9, w / 9), fontWeight: FontWeight.w700, height: 1.15)),
    );
  }
}

Widget _coverOrBlank(Book b, double w, {double? h}) =>
    b.coverUrl.isEmpty ? _Blank(b.title, w, h ?? w * 1.5) : Cover(b.coverUrl, w: w, tag: 'cover-${b.id}', locked: b.locked);

class CoverGrid extends StatelessWidget {
  final List<BookRow> rows;
  const CoverGrid({super.key, required this.rows});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        const pad = 14.0, gap = 12.0;
        final cols = math.max(2, ((box.maxWidth - pad * 2) / 120).floor());
        final w = (box.maxWidth - pad * 2 - gap * (cols - 1)) / cols;
        const textH = 52.0;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(pad, 10, pad, _bottomPad),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: gap, mainAxisSpacing: 14, childAspectRatio: w / (w * 1.5 + textH)),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final r = rows[i], b = r.book, rating = r.avgRating;
            final tertiary = Theme.of(context).colorScheme.tertiary;
            return TweenAnimationBuilder<double>(
              key: ValueKey(b.id),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + math.min(i, 10) * 35),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Opacity(opacity: v, child: Transform.scale(scale: 0.94 + 0.06 * v, child: child)),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _open(context, r),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    _coverOrBlank(b, w),
                    if (rating != null)
                      Positioned(
                        left: 4, bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: Text(starsText(rating), style: TextStyle(color: Color.lerp(tertiary, Colors.white, 0.45), fontSize: 11)),
                        ),
                      ),
                    if (r.progress != null) Positioned(left: 0, right: 0, bottom: 0, child: SlimProgress(r.progress!)),
                  ]),
                  const SizedBox(height: 4),
                  Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.15)),
                  Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
                ]),
              ),
            );
          },
        );
      });
}

// ───────────────────────── Shelves ─────────────────────────
class _Board extends StatelessWidget {
  const _Board();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final wood = Color.alphaBlend(cs.primary.withValues(alpha: 0.10), dark ? const Color(0xFF4A382B) : const Color(0xFFB88A5B));
    return Container(
      height: 14,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(wood, Colors.white, 0.18)!, wood, Color.lerp(wood, Colors.black, 0.28)!]),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
    );
  }
}

/// Lays out [items] (with their widths) into rows that fit [maxW]; returns the index ranges of each row.
List<List<int>> _packRows(List<double> widths, double maxW, double gap) {
  final rows = <List<int>>[];
  var cur = <int>[], used = 0.0;
  for (var i = 0; i < widths.length; i++) {
    final need = widths[i] + (cur.isEmpty ? 0 : gap);
    if (cur.isNotEmpty && used + need > maxW) {
      rows.add(cur);
      cur = [];
      used = 0;
    }
    used += widths[i] + (cur.isEmpty ? 0 : gap);
    cur.add(i);
  }
  if (cur.isNotEmpty) rows.add(cur);
  return rows;
}

class BookshelfView extends StatelessWidget {
  final List<BookRow> rows;
  const BookshelfView({super.key, required this.rows});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        const side = 16.0, gap = 10.0;
        final avail = box.maxWidth - side * 2;
        final n = math.max(2, ((avail + gap) / (84 + gap)).floor()); // covers per shelf
        final cw = ((avail - gap * (n - 1)) / n).clamp(70.0, 130.0); // stretch covers so each shelf is filled edge to edge
        final packed = _packRows(List.filled(rows.length, cw), avail + 0.5, gap);
        final cs = Theme.of(context).colorScheme;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: _bottomPad),
          itemCount: packed.length,
          itemBuilder: (_, ri) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(children: [
              Container(
                color: _wall(cs),
                padding: const EdgeInsets.fromLTRB(side, 10, side, 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final i in packed[ri])
                    Padding(
                      padding: EdgeInsets.only(right: i == packed[ri].last ? 0 : gap),
                      child: _ShelfBook(row: rows[i], w: cw, index: i),
                    ),
                ]),
              ),
              const _Board(),
            ]),
          ),
        );
      });
}

class _ShelfBook extends StatelessWidget {
  final BookRow row;
  final double w;
  final int index;
  const _ShelfBook({required this.row, required this.w, required this.index});
  @override
  Widget build(BuildContext context) {
    final b = row.book;
    final h = w * 1.5 * (0.94 + (_hash(b.title) % 7) * 0.01); // slightly different heights, like real books
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + math.min(index, 8) * 45),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(opacity: v.clamp(0.0, 1.0), child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child)),
      child: Semantics(
        label: '${b.title} by ${b.author}',
        button: true,
        child: GestureDetector(
          onTap: () => _open(context, row),
          child: Container(
            decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(2, 2))]),
            child: b.coverUrl.isEmpty ? _Blank(b.title, w, h) : SizedBox(width: w, height: h, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Cover(b.coverUrl, w: w, tag: 'cover-${b.id}', locked: b.locked))),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Spines ─────────────────────────
class SpinesView extends StatelessWidget {
  final List<BookRow> rows;
  const SpinesView({super.key, required this.rows});

  static double widthOf(Book b) => ((b.pages ?? 280) / 14).clamp(30.0, 64.0);
  static double heightOf(Book b) => 150.0 + (_hash(b.title) % 4) * 12;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        const side = 16.0, gap = 3.0;
        final packed = _packRows([for (final r in rows) widthOf(r.book)], box.maxWidth - side * 2, gap);
        final cs = Theme.of(context).colorScheme;
        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: _bottomPad),
          itemCount: packed.length,
          itemBuilder: (_, ri) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(children: [
              Container(
                color: _wall(cs),
                padding: const EdgeInsets.fromLTRB(side, 10, side, 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final i in packed[ri])
                    Padding(padding: EdgeInsets.only(right: i == packed[ri].last ? 0 : gap), child: _Spine(row: rows[i], index: i)),
                  const Spacer(),
                ]),
              ),
              const _Board(),
            ]),
          ),
        );
      });
}

class _Spine extends StatelessWidget {
  final BookRow row;
  final int index;
  const _Spine({required this.row, required this.index});
  @override
  Widget build(BuildContext context) {
    final b = row.book;
    final c = _bookColor(context, b.title);
    final on = _onColor(c);
    final w = SpinesView.widthOf(b), h = SpinesView.heightOf(b);
    final reading = row.status == 'reading';
    final done = row.status == 'finished';
    final tertiary = Theme.of(context).colorScheme.tertiary;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + math.min(index, 12) * 30),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Align(heightFactor: 1, alignment: Alignment.bottomCenter, child: SizedBox(width: w, height: h * (0.6 + 0.4 * v), child: child)),
      child: Semantics(
        label: '${b.title} by ${b.author}${reading ? ', reading' : done ? ', finished' : ''}',
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _open(context, row);
          },
          child: Container(
            width: w, height: h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              gradient: LinearGradient(colors: [Color.lerp(c, Colors.black, 0.28)!, c, Color.lerp(c, Colors.white, 0.10)!, Color.lerp(c, Colors.black, 0.22)!], stops: const [0, 0.25, 0.6, 1]),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 0))],
            ),
            child: Stack(children: [
              Positioned(top: 14, left: 0, right: 0, child: Container(height: 2, color: on.withValues(alpha: 0.35))),
              Positioned(top: 19, left: 0, right: 0, child: Container(height: 1, color: on.withValues(alpha: 0.25))),
              Positioned(
                top: 28, bottom: 24, left: 0, right: 0,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Align(alignment: Alignment.centerLeft, child: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: on, fontSize: math.min(13, w / 2.6), fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
              if (reading) Positioned(top: 0, right: 5, child: Container(width: 8, height: 22, decoration: BoxDecoration(color: tertiary, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3))))),
              if (done) Positioned(bottom: 5, left: 0, right: 0, child: Icon(Icons.check_rounded, size: 14, color: on.withValues(alpha: 0.85))),
              Positioned(bottom: 22, left: 0, right: 0, child: Container(height: 1, color: on.withValues(alpha: 0.25))),
            ]),
          ),
        ),
      ),
    );
  }
}
