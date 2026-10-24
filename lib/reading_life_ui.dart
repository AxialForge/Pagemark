import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'onboarding/coach.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'adaptive.dart';
import 'branding.dart';
import 'db.dart';
import 'finding.dart' show suggestNext;
import 'firstrun.dart' show appDate;
import 'main.dart';
import 'notifier.dart';
import 'reading_life.dart';
import 'report_pdf.dart';
import 'ui.dart';

// ───────────────────────── Reading timer ─────────────────────────
/// Start and stop while you read. Only one timer runs at a time; it survives the app being closed (the start time is saved).
class ReadingTimerCard extends StatefulWidget {
  final Book book;
  final Read read;
  const ReadingTimerCard({super.key, required this.book, required this.read});
  @override
  State<ReadingTimerCard> createState() => _ReadingTimerCardState();
}

class _ReadingTimerCardState extends State<ReadingTimerCard> {
  Timer? _tick;

  DateTime? get _start => DateTime.tryParse(prefs.getString('timer_start') ?? '');
  int? get _runningFor => prefs.getInt('timer_book');
  bool get _mine => _start != null && _runningFor == widget.book.id;
  bool get _other => _start != null && _runningFor != widget.book.id;

  @override
  void initState() {
    super.initState();
    if (_mine) _startTicking();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _startTicking() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
  }

  Future<void> _begin() async {
    await prefs.setInt('timer_book', widget.book.id);
    await prefs.setString('timer_start', DateTime.now().toIso8601String());
    _startTicking();
    setState(() {});
  }

  Future<void> _stop() async {
    final start = _start;
    _tick?.cancel();
    await prefs.remove('timer_start');
    await prefs.remove('timer_book');
    if (!mounted) return;
    setState(() {});
    if (start == null) return;
    final secs = DateTime.now().difference(start).inSeconds;
    if (secs < 30) {
      snack(context, 'That was under half a minute, so it was not counted.');
      return;
    }
    final minutes = (secs / 60).round().clamp(1, 24 * 60);
    final before = widget.read.currentPage;
    final txt = await ask(context, 'You read for $minutes min. Which page are you on now? (optional)', '${before ?? ''}', false, false, TextInputType.number);
    final page = int.tryParse(txt ?? '');
    final pages = page != null && before != null && page > before ? page - before : null;
    final fresh = await (db.select(db.reads)..where((r) => r.id.equals(widget.read.id))).getSingleOrNull();
    await db.addSession(widget.book.id, minutes, pages: pages);
    await (db.update(db.reads)..where((r) => r.id.equals(widget.read.id))).write(ReadsCompanion(
      minutes: Value((fresh?.minutes ?? 0) + minutes),
      currentPage: page != null && page >= 0 ? Value(page) : const Value.absent(),
    ));
    if (mounted) snack(context, 'Saved $minutes min of reading.');
  }

  /// A timer left running for a book that is no longer being read (finished, deleted) would block every other book, so it can be
  /// stopped from here: save the time to that book, or throw it away. The dialog names no book (it may be in the locked library).
  Future<void> _stopOther() async {
    final start = _start, id = _runningFor;
    if (start == null || id == null) return;
    final secs = DateTime.now().difference(start).inSeconds;
    final minutes = (secs / 60).round().clamp(1, 24 * 60);
    final choice = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Stop the other timer?'),
        content: Text('A reading timer for another book has been running for $minutes ${minutes == 1 ? 'minute' : 'minutes'}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Keep it running')),
          TextButton(onPressed: () => Navigator.pop(c, 'discard'), child: const Text('Throw it away')),
          if (secs >= 30) FilledButton(onPressed: () => Navigator.pop(c, 'save'), child: const Text('Save the time')),
        ],
      ),
    );
    if (choice == null) return;
    await prefs.remove('timer_start');
    await prefs.remove('timer_book');
    if (choice == 'save') {
      final rs = await (db.select(db.reads)..where((r) => r.bookId.equals(id))).get();
      final target = rs.where((r) => r.status == 'reading').lastOrNull ?? rs.lastOrNull;
      if (target != null) {
        await db.addSession(id, minutes);
        await (db.update(db.reads)..where((r) => r.id.equals(target.id))).write(ReadsCompanion(minutes: Value((target.minutes ?? 0) + minutes)));
      }
    }
    if (mounted) setState(() {});
  }

  String _clock(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final start = _start;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(_mine ? Icons.timer : Icons.timer_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mine && start != null ? 'Reading… ${_clock(DateTime.now().difference(start))}' : _other ? 'The reading timer is running for another book.' : 'Reading timer',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (_mine)
            FilledButton(onPressed: _stop, child: const Text('Stop'))
          else if (_other)
            TextButton(onPressed: _stopOther, child: const Text('Stop it'))
          else
            FilledButton.tonal(onPressed: _begin, child: const Text('Start')),
        ]),
      ),
    );
  }
}

// ───────────────────────── Streak calendar ─────────────────────────
class StreakCard extends StatefulWidget {
  final Set<DateTime> days;
  final DateTime now;
  const StreakCard({super.key, required this.days, required this.now});
  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int _offset = 0; // months back from the current one

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final month = DateTime(widget.now.year, widget.now.month - _offset);
    final first = DateTime(month.year, month.month);
    final length = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday % 7; // Sunday first
    final readDays = [for (var d = 1; d <= length; d++) if (widget.days.contains(DateTime(month.year, month.month, d))) d].length;
    final streak = currentStreak(widget.days, widget.now);
    final cells = <Widget>[
      for (final w in const ['S', 'M', 'T', 'W', 'T', 'F', 'S']) Center(child: ExcludeSemantics(child: Text(w, style: Theme.of(context).textTheme.labelSmall))),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= length; d++)
        Builder(builder: (_) {
          final day = DateTime(month.year, month.month, d);
          final read = widget.days.contains(day);
          final today = day == dayOf(widget.now);
          return Semantics(
            label: '${DateFormat.MMMMd().format(day)}${read ? ', you read' : ''}',
            excludeSemantics: true,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: read ? cs.primary : null,
                border: today ? Border.all(color: cs.primary, width: 1.5) : null,
              ),
              alignment: Alignment.center,
              child: Text('$d', style: TextStyle(fontSize: 12, color: read ? cs.onPrimary : null)),
            ),
          );
        }),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: 'Earlier month', onPressed: () => setState(() => _offset++)),
        Expanded(child: Text(DateFormat.yMMMM().format(month), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall)),
        IconButton(icon: const Icon(Icons.chevron_right), tooltip: 'Later month', onPressed: _offset == 0 ? null : () => setState(() => _offset--)),
      ]),
      // a fixed row height keeps a month one screen tall on tablets, where the width (and so a square cell) would be huge
      GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 44),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cells,
      ),
      const SizedBox(height: 6),
      Text(readDays == 0 ? 'No reading logged this month.' : 'You read on $readDays ${readDays == 1 ? 'day' : 'days'} this month.', style: Theme.of(context).textTheme.bodySmall),
      if (_offset == 0 && streak >= 2) Text('$streak days in a row. Lovely.', style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

// ───────────────────────── Year in books ─────────────────────────
/// A picture card to share. It holds counts, a favourite genre, a top author and the best-rated title. Nothing from the locked
/// library is ever counted, because the books come only from the main library.
class YearCard extends StatefulWidget {
  final YearSummary s;
  const YearCard({super.key, required this.s});
  @override
  State<YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<YearCard> {
  final _key = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3);
      final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/Pagemark-${widget.s.year}.png');
      await f.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'image/png')]));
    } catch (_) {
      if (mounted) snack(context, 'Could not make the picture. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final cs = Theme.of(context).colorScheme;
    if (s.isEmpty) return const Text('Finish a book this year and your card appears here.');
    // the charcoal band of the menu header, with the light shade of the theme colour as its accent
    final ink = cs.onInverseSurface;
    final accent = Theme.of(context).brightness == Brightness.dark ? cs.primary : cs.inversePrimary;
    Widget line(String big, String small) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(big, style: TextStyle(fontFamily: 'Newsreader', fontSize: 28, fontWeight: FontWeight.w600, color: ink)),
            Text(small, style: TextStyle(color: ink.withValues(alpha: 0.72))),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      RepaintBoundary(
        key: _key,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cs.inverseSurface, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${s.year} in books'.toUpperCase(), style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: accent)),
            line('${s.books}', s.books == 1 ? 'book finished' : 'books finished'),
            if (s.pages > 0) line(NumberFormat.decimalPattern().format(s.pages), 'pages'),
            if (s.minutes >= 60) line('${(s.minutes / 60).round()}', 'hours of reading'),
            if (s.topGenre != null) line(s.topGenre!, 'favourite genre'),
            if (s.topAuthor != null) line(s.topAuthor!, 'most-read author'),
            if (s.avgRating != null) line(ratingText(s.avgRating!), 'average rating'),
            if (s.best != null) line(s.best!.book.title, 'my top rated'),
            const SizedBox(height: 14),
            Text('Made with Pagemark', style: TextStyle(fontSize: 12, color: ink.withValues(alpha: 0.6))),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        CoachTarget(id: 'stats.share', child: FilledButton.tonalIcon(onPressed: _busy ? null : _share, icon: const Icon(Icons.share), label: const Text('Share picture'))),
        OutlinedButton.icon(onPressed: _busy ? null : () => shareYearReport(context, widget.s.year), icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('Report (PDF)')),
      ]),
    ]);
  }
}

Future<void> shareYearReport(BuildContext context, int year) async {
  try {
    final rows = await db.watchLibrary(locked: false).first;
    final f = await ReportPdf.write(rows, year);
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'application/pdf')]));
  } catch (_) {
    if (context.mounted) snack(context, 'Could not make the report. Please try again.');
  }
}

// ───────────────────────── Lending ─────────────────────────
class LoansSection extends StatelessWidget {
  final Book book;
  const LoansSection({super.key, required this.book});

  static int _noteId(int loanId) => 300000 + loanId;

  Future<void> _lend(BuildContext context) async {
    final who = (await ask(context, 'Who did you lend it to?'))?.trim();
    if (who == null || who.isEmpty || !context.mounted) return;
    final days = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(title: const Text('Remind you to ask for it back?'), children: [
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 1), child: const Text('Tomorrow')),
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 7), child: const Text('In a week')),
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 14), child: const Text('In 2 weeks')),
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 30), child: const Text('In a month')),
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 60), child: const Text('In 2 months')),
        SimpleDialogOption(onPressed: () => Navigator.pop(c, 0), child: const Text('No reminder')),
      ]),
    );
    if (days == null) return;
    final now = DateTime.now();
    final remind = days > 0 ? DateTime(now.year, now.month, now.day + days, 10) : null;
    final id = await db.lend(book.id, who, remindOn: remind);
    if (remind != null) {
      final ok = await Notifier.requestPermission();
      if (ok) {
        // the text names no book and no person: it can be read on a lock screen
        await Notifier.scheduleAt(_noteId(id), [remind],
            title: 'Pagemark', messages: ['A book you lent is due back. Open Pagemark to see which.'], channelId: 'loans', channelName: 'Lent books', channelDescription: 'A reminder to ask for a lent book back');
      } else if (context.mounted) {
        snack(context, 'Notifications are off, so there will be no reminder. You can turn them on in Android settings.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Loan>>(
        stream: db.watchLoans(book.id),
        builder: (_, snap) {
          final list = snap.data ?? [];
          final out = list.where((l) => l.returnedOn == null).toList();
          final df = appDate();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('Lending', style: Theme.of(context).textTheme.titleMedium)),
              if (out.isEmpty) TextButton.icon(onPressed: () => _lend(context), icon: const Icon(Icons.outbox_outlined), label: const Text('Lend this book')),
            ]),
            if (list.isEmpty) const Text('Not lent to anyone.'),
            for (final l in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(l.returnedOn == null ? Icons.outbox : Icons.check_circle_outline),
                title: Text(l.returnedOn == null ? 'Lent to ${l.person}' : '${l.person} gave it back'),
                subtitle: Text([
                  'Lent ${df.format(l.lentOn)}',
                  if (l.returnedOn != null) 'back ${df.format(l.returnedOn!)}',
                  if (l.returnedOn == null && l.remindOn != null) 'reminder ${df.format(l.remindOn!)}',
                ].join(' · ')),
                trailing: l.returnedOn == null
                    ? TextButton(
                        onPressed: () async {
                          await db.markReturned(l.id);
                          await Notifier.cancelScheduled(_noteId(l.id), 1);
                        },
                        child: const Text('Got it back'),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove from the list',
                        onPressed: () => db.deleteLoan(l.id),
                      ),
              ),
          ]);
        },
      );
}

// ───────────────────────── Read next order ─────────────────────────
class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Read next')),
        body: NarrowColumn(
          child: StreamBuilder<List<BookRow>>(
            // only the main library: the locked library has no place in a list that can be shown to others
            stream: db.watchLibrary(locked: false),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final rows = ReadingLifeDb.orderQueue(snap.data!);
              final tips = suggestNext(snap.data!, limit: 3);
              if (rows.isEmpty) return const EmptyState(message: 'Books you want to read appear here, so you can put them in the order you will read them.');
              return Column(children: [
                const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Press and hold a book, then drag it to where you want it.')),
                if (tips.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('You might like next', style: Theme.of(context).textTheme.titleSmall),
                        for (final s in tips)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(s.row.book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(s.reason),
                            trailing: TextButton(
                              onPressed: () => db.saveQueue([s.row.book.id, for (final r in rows) if (r.book.id != s.row.book.id) r.book.id]),
                              child: const Text('Read first'),
                            ),
                          ),
                      ]),
                    ),
                  ),
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: rows.length,
                    onReorderItem: (from, to) {
                      final ids = [for (final r in rows) r.book.id];
                      ids.insert(to, ids.removeAt(from));
                      db.saveQueue(ids);
                    },
                    itemBuilder: (_, i) {
                      final b = rows[i].book;
                      return ListTile(
                        key: ValueKey(b.id),
                        leading: CircleAvatar(child: Text('${i + 1}')),
                        title: Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: b.author.isEmpty ? null : Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis),
                      );
                    },
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}
