import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db.dart';
import 'features.dart';
import 'main.dart';
import 'selection.dart';
import 'ui.dart';

/// How the Library draws your books. Same data, five looks; the choice is remembered per library.
enum LibrarySkin {
  classic('Classic', 'Cover, title, status and rating on every row', Icons.view_list_rounded),
  grid('Cover wall', 'A grid of covers with ratings and progress', Icons.grid_view_rounded),
  shelf('Bookshelf', 'Covers standing on wooden shelves', Icons.shelves),
  spines('Spines', 'Cloth-bound spines, sized by page count', Icons.menu_book_rounded),
  compact('Compact', 'One tight line per book - fits the most', Icons.format_list_bulleted_rounded);

  final String label, blurb;
  final IconData icon;
  const LibrarySkin(this.label, this.blurb, this.icon);
}

LibrarySkin skinById(String? id) => LibrarySkin.values.firstWhere((s) => s.name == id, orElse: () => LibrarySkin.classic);

/// Bottom sheet to pick the style. [onGrouped] fires immediately when the "Group by my shelves" switch changes
/// (it applies to Bookshelf and Spines); picking a style closes the sheet and returns it.
Future<LibrarySkin?> showSkinPicker(BuildContext context, LibrarySkin current,
        {bool grouped = false, ValueChanged<bool>? onGrouped, bool hasShelves = false}) =>
    showModalBottomSheet<LibrarySkin>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: StatefulBuilder(
          builder: (c, setSheet) => ListView(shrinkWrap: true, children: [ // scrolls on short screens (landscape, small phones)
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
            if (onGrouped != null) ...[
              const Divider(height: 8),
              SwitchListTile(
                secondary: const Icon(Icons.label_outline),
                title: const Text('Group by my shelves'),
                subtitle: Text(hasShelves
                    ? 'Bookshelf and Spines: one wooden shelf per named shelf, with a nameplate (tap it to rename)'
                    : 'Create a shelf first: Library menu, then Manage shelves'),
                value: grouped && hasShelves,
                onChanged: hasShelves ? (v) { grouped = v; onGrouped(v); setSheet(() {}); } : null,
              ),
            ],
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );

/// A named group of books (one of the user's shelves, or "Not on a shelf").
class ShelfGroup {
  final int? shelfId; // null = the catch-all group
  final String? label; // null = no nameplate (ungrouped view)
  final List<BookRow> rows;
  const ShelfGroup(this.shelfId, this.label, this.rows);
  bool get renamable => shelfId != null;
}

/// One group per non-empty shelf (a book on two shelves appears on both) plus "Not on a shelf".
/// With no shelves at all, a single unlabelled group, so the ungrouped look is unchanged.
List<ShelfGroup> groupRows(List<BookRow> rows, List<Shelf> shelves, Map<int, Set<int>> shelfBooks) {
  final out = <ShelfGroup>[];
  final placed = <int>{};
  for (final s in shelves) {
    final inShelf = rows.where((r) => shelfBooks[s.id]?.contains(r.book.id) ?? false).toList();
    if (inShelf.isEmpty) continue;
    placed.addAll(inShelf.map((r) => r.book.id));
    out.add(ShelfGroup(s.id, s.name, inShelf));
  }
  final rest = rows.where((r) => !placed.contains(r.book.id)).toList();
  if (rest.isNotEmpty) out.add(ShelfGroup(null, out.isEmpty ? null : 'Not on a shelf', rest));
  return out;
}

/// Draws [rows] in the chosen [skin], cross-fading when the skin changes.
class SkinView extends StatelessWidget {
  final LibrarySkin skin;
  final List<BookRow> rows;
  final bool groupByShelf; // Bookshelf / Spines only
  final List<Shelf> shelves;
  final Map<int, Set<int>> shelfBooks;
  const SkinView({super.key, required this.skin, required this.rows, this.groupByShelf = false, this.shelves = const [], this.shelfBooks = const {}});

  @override
  Widget build(BuildContext context) {
    final grouped = groupByShelf && (skin == LibrarySkin.shelf || skin == LibrarySkin.spines);
    final groups = grouped ? groupRows(rows, shelves, shelfBooks) : [ShelfGroup(null, null, rows)];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      child: KeyedSubtree(
        key: ValueKey('${skin.name}-$grouped'),
        child: switch (skin) {
          LibrarySkin.classic => ClassicList(rows: rows),
          LibrarySkin.grid => CoverGrid(rows: rows),
          LibrarySkin.shelf => BookshelfView(groups: groups),
          LibrarySkin.spines => SpinesView(groups: groups),
          LibrarySkin.compact => CompactList(rows: rows),
        },
      ),
    );
  }
}

const _bottomPad = 96.0; // clear of the Add button

/// Tap: open the book, or toggle it while a selection is active. Long-press: start/extend a selection.
void _open(BuildContext context, BookRow r) {
  final s = SelectionScope.maybeOf(context);
  if (s != null && s.active) {
    s.onToggle(r);
  } else {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookPage(bookId: r.book.id)));
  }
}

void _hold(BuildContext context, BookRow r) {
  HapticFeedback.mediumImpact();
  SelectionScope.maybeOf(context)?.onToggle(r);
}

bool _sel(BuildContext context, BookRow r) => SelectionScope.isSelected(context, r.book.id);

int _hash(String s) => s.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0x7fffffff);

// ───────────────────────── Colour (cloth-bound palette) ─────────────────────────
/// Gold leaf, as stamped on cloth and leather bindings.
const _gilt = Color(0xFFDDBF74);

/// Dark, natural binding colours (oxblood, bottle green, navy ...), so gilt lettering always reads.
const _cloth = [
  Color(0xFF6B1E2A), Color(0xFF1F4A35), Color(0xFF1F2F55), Color(0xFF2B2E34), Color(0xFF5A3A22), Color(0xFF24474D), Color(0xFF4B2A55),
  Color(0xFF55512A), Color(0xFF7A3524), Color(0xFF2D3A4A), Color(0xFF1B3B2C), Color(0xFF6A4B2A), Color(0xFF402B3A), Color(0xFF3A3F2B),
];

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// A stable binding colour per title, nudged 10% toward the theme's primary so a bookcase feels at home in every theme,
/// and darkened if needed so gilt lettering keeps at least 4.6:1 contrast.
Color bookColorFor(String title, ColorScheme cs) {
  var c = _cloth[_hash(title) % _cloth.length];
  c = Color.lerp(c, cs.primary, 0.10)!;
  if (cs.brightness == Brightness.dark) c = Color.lerp(c, Colors.black, 0.10)!;
  for (var i = 0; i < 12 && _contrast(c, _gilt) < 4.6; i++) {
    c = Color.lerp(c, Colors.black, 0.08)!;
  }
  return c;
}

/// Lettering colour for a binding: gilt when it reads (always, for [bookColorFor] colours), else the best of white/black.
Color onBookColor(Color c) {
  if (_contrast(c, _gilt) >= 4.5) return _gilt;
  return _contrast(c, Colors.white) >= _contrast(c, Colors.black87) ? Colors.white : Colors.black87;
}

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
          child: SwipeActions(row: rows[i], child: BookTile(row: rows[i])),
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
      itemExtent: 52 * math.max(1.0, MediaQuery.textScalerOf(context).scale(14) / 14 * 0.92), // grows with large accessibility fonts
      itemBuilder: (_, i) {
        final r = rows[i], b = r.book, rating = r.avgRating;
        final picked = _sel(context, r);
        return SwipeActions(row: r, child: Material(
          color: picked ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          child: InkWell(
          onTap: () => _open(context, r),
          onLongPress: () => _hold(context, r),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(children: [
              Cover(b.coverUrl, w: 30, locked: b.locked, title: b.title),
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
              if (picked) const Padding(padding: EdgeInsets.only(left: 8), child: SelectedBadge()),
            ]),
          ),
        )));
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
          style: TextStyle(color: _onColor(c), fontFamily: 'serif', fontSize: math.max(9, w / 9), fontWeight: FontWeight.w700, height: 1.15)),
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
        final textH = 52.0 * math.max(1.0, MediaQuery.textScalerOf(context).scale(14) / 14); // title + author lines grow with the font size
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
                onLongPress: () => _hold(context, r),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    _coverOrBlank(b, w),
                    if (_sel(context, r)) ...[
                      Positioned.fill(child: Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3), color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)))),
                      const Positioned(top: 6, right: 6, child: SelectedBadge()),
                    ],
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

// ───────────────────────── Shared shelf furniture ─────────────────────────
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

/// Brass nameplate screwed above a group of shelves. Tap to rename (real shelves only).
class _Nameplate extends StatelessWidget {
  final ShelfGroup group;
  const _Nameplate(this.group);

  Future<void> _rename(BuildContext context) async {
    final n = await ask(context, 'Rename shelf', group.label ?? '');
    if (n != null && n.trim().isNotEmpty && n.trim() != group.label) await db.renameShelf(group.shelfId!, n);
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF3B2A12);
    Widget screw() => Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: ink.withValues(alpha: 0.55)));
    final plate = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE9D08C), Color(0xFFB8913F), Color(0xFFD9BC6E)]),
        border: Border.all(color: const Color(0xFF8A6A25), width: 0.8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        screw(),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '${group.label!.toUpperCase()}  ·  ${group.rows.length}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ink, fontFamily: 'serif', fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.4),
          ),
        ),
        const SizedBox(width: 8),
        screw(),
      ]),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          label: '${group.label}, ${group.rows.length} books${group.renamable ? ', tap to rename' : ''}',
          button: group.renamable,
          child: group.renamable ? GestureDetector(onTap: () => _rename(context), child: plate) : plate,
        ),
      ),
    );
  }
}

/// Lays widths into rows that fit [maxW]; returns the index lists of each row.
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

/// A bookcase: for each group an optional nameplate, then its books packed onto shelves. [bookWidth] gives each book's
/// width; [builder] draws one book.
class _Bookcase extends StatelessWidget {
  final List<ShelfGroup> groups;
  final double Function(double avail) coverWidth; // fixed width for shelf covers, or -1 to use bookWidth
  final double? Function(BookRow r) bookWidth;
  final double gap;
  final Widget Function(BookRow r, double w, int index) builder;
  final double topRoom; // headroom above the tallest book (ribbons)
  const _Bookcase({required this.groups, required this.coverWidth, required this.bookWidth, required this.gap, required this.builder, this.topRoom = 10});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        const side = 16.0;
        final avail = box.maxWidth - side * 2;
        final cw = coverWidth(avail);
        final cs = Theme.of(context).colorScheme;
        final items = <Widget>[];
        var index = 0;
        for (final g in groups) {
          if (g.label != null) items.add(_Nameplate(g));
          final widths = [for (final r in g.rows) cw > 0 ? cw : bookWidth(r)!];
          final packed = _packRows(widths, avail + 0.5, gap);
          for (final row in packed) {
            items.add(Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(children: [
                Container(
                  color: _wall(cs),
                  padding: EdgeInsets.fromLTRB(side, topRoom, side, 0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    for (final i in row)
                      Padding(
                        padding: EdgeInsets.only(right: i == row.last ? 0 : gap),
                        child: builder(g.rows[i], widths[i], index++),
                      ),
                    const Spacer(),
                  ]),
                ),
                const _Board(),
              ]),
            ));
          }
        }
        return ListView(padding: const EdgeInsets.only(top: 12, bottom: _bottomPad), children: items);
      });
}

// ───────────────────────── Bookshelf (covers) ─────────────────────────
class BookshelfView extends StatelessWidget {
  final List<ShelfGroup> groups;
  const BookshelfView({super.key, required this.groups});

  @override
  Widget build(BuildContext context) => _Bookcase(
        groups: groups,
        gap: 10,
        coverWidth: (avail) {
          final n = math.max(2, ((avail + 10) / (84 + 10)).floor()); // covers per shelf
          return ((avail - 10 * (n - 1)) / n).clamp(70.0, 130.0); // stretch so each shelf is filled edge to edge
        },
        bookWidth: (_) => null,
        builder: (r, w, i) => _ShelfBook(row: r, w: w, index: i),
      );
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
          onLongPress: () => _hold(context, row),
          child: Stack(children: [
            Container(
              decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 5, offset: Offset(2, 2))]),
              child: b.coverUrl.isEmpty ? _Blank(b.title, w, h) : SizedBox(width: w, height: h, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Cover(b.coverUrl, w: w, tag: 'cover-${b.id}', locked: b.locked))),
            ),
            if (_sel(context, row)) ...[
              Positioned.fill(child: Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3), color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)))),
              const Positioned(top: 5, right: 5, child: SelectedBadge()),
            ],
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────── Spines (cloth-bound) ─────────────────────────
class SpinesView extends StatelessWidget {
  final List<ShelfGroup> groups;
  const SpinesView({super.key, required this.groups});

  static double widthOf(Book b) => ((b.pages ?? 280) / 14).clamp(30.0, 62.0);
  static double heightOf(Book b) => 168.0 + (_hash(b.title) % 5) * 8;

  @override
  Widget build(BuildContext context) => _Bookcase(
        groups: groups,
        gap: 2,
        topRoom: 16,
        coverWidth: (_) => -1,
        bookWidth: (r) => widthOf(r.book),
        builder: (r, w, i) => _Spine(row: r, index: i),
      );
}

/// Paints cloth: cylindrical shading, woven grain, a worn hinge at each edge, headbands and gilt bands.
class _SpinePainter extends CustomPainter {
  final Color base;
  final int seed;
  final bool bands;
  const _SpinePainter(this.base, this.seed, this.bands);

  Color _shade(Color c, double t) => Color.lerp(c, t < 0 ? Colors.black : Colors.white, t.abs())!;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;
    final body = RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(2), topRight: const Radius.circular(2));
    // rounded spine: dark at both edges, soft highlight just left of centre
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [_shade(base, -0.42), _shade(base, -0.12), _shade(base, 0.09), base, _shade(base, -0.10), _shade(base, -0.38)],
          stops: const [0, 0.14, 0.38, 0.62, 0.86, 1],
        ).createShader(rect),
    );
    // top-to-bottom ageing: a little darker at the foot (shelf shadow) and head
    canvas.drawRRect(
      body,
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.18), Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.26)], stops: const [0, 0.08, 0.8, 1]).createShader(rect),
    );
    // cloth grain: short fibres, deterministic per book
    final r = math.Random(seed);
    final fibre = Paint()..strokeWidth = 0.6;
    final n = (s.width * s.height / 38).round();
    for (var i = 0; i < n; i++) {
      final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height;
      fibre.color = (r.nextBool() ? Colors.white : Colors.black).withValues(alpha: 0.03 + r.nextDouble() * 0.06);
      canvas.drawLine(Offset(x, y), Offset(x + 1.2 + r.nextDouble() * 1.8, y), fibre);
    }
    // hinges (the grooves where board meets spine)
    final groove = Paint()..strokeWidth = 1;
    groove.color = Colors.black.withValues(alpha: 0.35);
    canvas.drawLine(const Offset(3, 2), Offset(3, s.height), groove);
    canvas.drawLine(Offset(s.width - 3, 2), Offset(s.width - 3, s.height), groove);
    groove.color = Colors.white.withValues(alpha: 0.07);
    canvas.drawLine(const Offset(4, 2), Offset(4, s.height), groove);
    canvas.drawLine(Offset(s.width - 4, 2), Offset(s.width - 4, s.height), groove);
    // headbands
    canvas.drawRect(Rect.fromLTWH(0, 0, s.width, 2.5), Paint()..color = Colors.black.withValues(alpha: 0.28));
    canvas.drawRect(Rect.fromLTWH(0, s.height - 3, s.width, 3), Paint()..color = Colors.black.withValues(alpha: 0.30));
    // gilt bands (blind-stamped pairs near head and tail)
    if (bands) {
      final foil = Paint()..color = _gilt.withValues(alpha: 0.78);
      for (final y in [12.0, s.height - 16]) {
        canvas.drawRect(Rect.fromLTWH(5, y, s.width - 10, 1.1), foil);
        canvas.drawRect(Rect.fromLTWH(5, y + 3.2, s.width - 10, 0.6), foil..color = _gilt.withValues(alpha: 0.55));
      }
    }
  }

  @override
  bool shouldRepaint(_SpinePainter o) => o.base != base || o.seed != seed || o.bands != bands;
}

String _surname(String author) {
  final first = author.split(',').first.trim();
  return first.isEmpty ? '' : first.split(RegExp(r'\s+')).last;
}

class _Spine extends StatelessWidget {
  final BookRow row;
  final int index;
  const _Spine({required this.row, required this.index});

  @override
  Widget build(BuildContext context) {
    final b = row.book;
    final cs = Theme.of(context).colorScheme;
    final c = _bookColor(context, b.title);
    final w = SpinesView.widthOf(b), h = SpinesView.heightOf(b);
    final reading = row.status == 'reading';
    final done = row.status == 'finished';
    final author = _surname(b.author);
    // The author's surname shares the spine only when the title still fits beside it (titles always win).
    final titleSize = math.min(13.5, w / 2.7);
    final room = h - 48 - 10;
    final showAuthor = w >= 40 && author.isNotEmpty && b.title.length * titleSize * 0.55 + author.length * 8 * 0.95 + 14 <= room;
    final foil = TextStyle(
      color: _gilt, fontFamily: 'serif', fontWeight: FontWeight.w600, letterSpacing: 0.6,
      shadows: const [Shadow(color: Colors.black54, offset: Offset(0.6, 0.8), blurRadius: 0.4)], // stamped into the cloth
    );
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
          onLongPress: () => _hold(context, row),
          child: Container(
            width: w, height: h,
            decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(1.5, 0))]),
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(child: CustomPaint(painter: _SpinePainter(c, _hash(b.title), w >= 34))),
              Positioned(
                top: 24, bottom: 24, left: 5, right: 5,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Row(children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: foil.copyWith(fontSize: titleSize)))),
                    if (showAuthor) ...[
                      const SizedBox(width: 6),
                      Text(author.toUpperCase(), maxLines: 1, style: foil.copyWith(fontSize: 8, letterSpacing: 1.3, fontWeight: FontWeight.w500, color: _gilt.withValues(alpha: 0.8))),
                    ],
                  ]),
                ),
              ),
              // a marker ribbon sticking out of the head of the book you're reading
              if (reading)
                Positioned(
                  top: -9, right: w * 0.3,
                  child: Container(width: 4.5, height: 15, decoration: BoxDecoration(color: cs.tertiary, boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 1.5)])),
                ),
              if (_sel(context, row)) ...[
                Positioned.fill(child: Container(decoration: BoxDecoration(border: Border.all(color: cs.primary, width: 2.5), color: cs.primary.withValues(alpha: 0.28)))),
                const Positioned(top: 6, left: 0, right: 0, child: Center(child: SelectedBadge())),
              ],
              // finished: a small gilt seal near the foot
              if (done)
                Positioned(
                  bottom: 22, left: 0, right: 0,
                  child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _gilt.withValues(alpha: 0.85), width: 0.9)))),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
