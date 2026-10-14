part of '../ui.dart';

// ───────────────────────── Log a read ─────────────────────────
class ReadEditor extends StatefulWidget {
  final int bookId;
  final Read? read;
  const ReadEditor({super.key, required this.bookId, this.read});
  @override
  State<ReadEditor> createState() => _ReadEditorState();
}

class _ReadEditorState extends State<ReadEditor> {
  late String format = widget.read?.format ?? defaultFormat();
  late String status = widget.read?.status ?? 'reading';
  late DateTime? started = widget.read?.started ?? DateTime.now();
  late DateTime? finished = widget.read?.finished;
  late double rating = widget.read?.rating ?? 0;
  late final thoughts = TextEditingController(text: widget.read?.thoughts);
  late final narrator = TextEditingController(text: widget.read?.narrator);
  late final minutes = TextEditingController(text: '${widget.read?.minutes ?? ''}');
  late final page = TextEditingController(text: '${widget.read?.currentPage ?? ''}');
  late final contentNotes = TextEditingController(text: widget.read?.contentNotes);
  late int heat = widget.read?.heat ?? 0;
  late final Map<String, double> detail = {for (final a in ratingAspects) if (widget.read != null && aspectOf(widget.read!, a.key) != null) a.key: aspectOf(widget.read!, a.key)!};

  String _state() => [format, status, started?.toIso8601String(), finished?.toIso8601String(), rating, thoughts.text, narrator.text, minutes.text, page.text, heat, contentNotes.text, ...[for (final a in ratingAspects) detail[a.key]]].join('|');
  late final String _snap = _state();
  bool _saved = false;
  bool get _dirty => !_saved && _state() != _snap;

  @override
  void initState() {
    super.initState();
    _snap; // snapshot before any editing
    for (final ctl in [thoughts, narrator, minutes, page, contentNotes]) {
      ctl.addListener(_onChange);
    }
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    thoughts.dispose();
    narrator.dispose();
    minutes.dispose();
    page.dispose();
    contentNotes.dispose();
    super.dispose();
  }

  /// Dates can't be in the future (you can't have read it tomorrow).
  Future<DateTime?> pick(DateTime? init) {
    final now = DateTime.now();
    final start = init == null || init.isAfter(now) ? now : init;
    return showDatePicker(context: context, initialDate: start, firstDate: DateTime(1900), lastDate: now);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await confirmDiscard(context) && context.mounted) {
            _saved = true;
            Navigator.pop(context);
          }
        },
        child: Scaffold(
        appBar: AppBar(title: Text(widget.read == null ? 'Log a read' : 'Edit read'), actions: [
          if (widget.read != null) IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete this read', onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
              title: const Text('Delete this read?'), content: const Text('Its dates, rating and thoughts will be gone for good.'),
              actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))]));
            if (ok != true || !context.mounted) return;
            final old = widget.read!;
            final messenger = ScaffoldMessenger.of(context);
            await (db.delete(db.reads)..where((r) => r.id.equals(old.id))).go();
            messenger
              ..clearSnackBars()
              ..showSnackBar(SnackBar(
                content: const Text('Read deleted'),
                duration: const Duration(seconds: 8),
                action: SnackBarAction(label: 'Undo', onPressed: () => db.into(db.reads).insert(old)), // same row, same id
              ));
            _saved = true;
            if (context.mounted) Navigator.pop(context);
          }),
          TextButton(onPressed: () async {
            final fin = status == 'finished' ? (finished ?? DateTime.now()) : finished;
            DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
            if (fin != null && started != null && day(fin).isBefore(day(started!))) {
              snack(context, 'The finished date is before the start date');
              return;
            }
            final comp = ReadsCompanion(
              bookId: Value(widget.bookId), format: Value(format), status: Value(status), started: Value(started), finished: Value(fin),
              rating: Value(rating == 0 ? null : rating), thoughts: Value(thoughts.text), narrator: Value(narrator.text), minutes: Value(int.tryParse(minutes.text)), currentPage: Value(int.tryParse(page.text)),
              heat: Value(adultFieldsOn() ? (heat == 0 ? null : heat) : widget.read?.heat), contentNotes: Value(adultFieldsOn() ? contentNotes.text : (widget.read?.contentNotes ?? '')),
              // with detailed ratings off, whatever was saved before is kept as it was
              ratingStory: Value(detailedRatingsOn() ? detail['story'] : widget.read?.ratingStory), ratingCharacters: Value(detailedRatingsOn() ? detail['characters'] : widget.read?.ratingCharacters),
              ratingWriting: Value(detailedRatingsOn() ? detail['writing'] : widget.read?.ratingWriting), ratingPace: Value(detailedRatingsOn() ? detail['pace'] : widget.read?.ratingPace),
              ratingFeeling: Value(detailedRatingsOn() ? detail['feeling'] : widget.read?.ratingFeeling), ratingNarrator: Value(detailedRatingsOn() ? (format == 'audio' ? detail['narrator'] : null) : widget.read?.ratingNarrator),
            );
            _saved = true;
            if (widget.read == null) {
              await db.into(db.reads).insert(comp);
            } else {
              await (db.update(db.reads)..where((r) => r.id.equals(widget.read!.id))).write(comp);
            }
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ]),
        body: ListView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, padding: const EdgeInsets.all(16), children: [
          SegmentedButton<String>(
            segments: [for (final e in formats.entries) ButtonSegment(value: e.key, label: Text(e.value))],
            selected: {format}, onSelectionChanged: (s) => setState(() => format = s.first),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: status, decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: [for (final e in statuses.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() {
              status = v!;
              if (status == 'finished') finished ??= DateTime.now(); // visible, editable default
              if (status == 'reading' || status == 'want') finished = null;
            }),
          ),
          if (status == 'reading') Padding(padding: const EdgeInsets.only(top: 12), child: TextField(controller: page, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Current page', border: OutlineInputBorder()))),
          ListTile(title: const Text('Started'), subtitle: Text(started == null ? '—' : _date.format(started!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(started); if (d != null) setState(() => started = d); }),
          Wrap(spacing: 8, children: [
            ActionChip(label: const Text('Started today'), onPressed: () => setState(() => started = DateTime.now())),
            ActionChip(label: const Text('Started yesterday'), onPressed: () => setState(() => started = DateTime.now().subtract(const Duration(days: 1)))),
          ]),
          ListTile(title: const Text('Finished'), subtitle: Text(finished == null ? '—' : _date.format(finished!)), trailing: const Icon(Icons.calendar_today),
              onTap: () async { final d = await pick(finished); if (d != null) setState(() => finished = d); }),
          const SizedBox(height: 8),
          const Text('Rating'),
          Row(children: [
            StarRating(value: rating, onChanged: (v) => setState(() => rating = v)),
            const SizedBox(width: 8),
            Text(rating == 0 ? 'tap a star' : '$rating'),
          ]),
          if (detailedRatingsOn()) ...[
            const SizedBox(height: 8),
            DetailedRatingsEditor(values: detail, audio: format == 'audio', onChanged: (k, v) => setState(() => v == 0 ? detail.remove(k) : detail[k] = v)),
            const SizedBox(height: 8),
          ],
          if (format == 'audio') ...[
            TextField(controller: narrator, decoration: const InputDecoration(labelText: 'Narrator', border: OutlineInputBorder())),
            const SizedBox(height: 12),
          ],
          TextField(controller: minutes, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: format == 'audio' ? 'Listening time (minutes)' : 'Time spent (minutes)', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          if (adultFieldsOn()) ...[
            const Text('Heat (private)'),
            HeatRating(value: heat, onChanged: (v) => setState(() => heat = v)),
            TextField(controller: contentNotes, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Content notes (private)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
          ],
          TextField(controller: thoughts, minLines: 5, maxLines: 14, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Your thoughts', alignLabelWithHint: true, border: OutlineInputBorder())),
        ]),
        ),
      );
}
