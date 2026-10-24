import 'dart:io';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../backup_reminder.dart';
import '../features.dart' show Stats;
import '../finding.dart' show googleOn;
import '../firstrun.dart';
import '../import_ui.dart';
import '../main.dart';
import '../promise.dart';
import '../restore_ui.dart';
import '../ui.dart';
import 'content.dart';
import 'tips.dart';
import 'tour_art.dart';

enum _Section {
  welcome('Welcome'),
  permissions('Permissions'),
  setup('Set-up'),
  lessons('Lessons'),
  start('Get started');

  final String label;
  const _Section(this.label);
}

class _Page {
  final String id;
  final _Section section;
  final Widget Function() build;
  const _Page(this.id, this.section, this.build);
}

/// The guided tour: welcome, permissions, set-up, lessons, get started. Skippable at every step; Back steps back.
class TourScreen extends StatefulWidget {
  /// Replaying from Help & tips: nothing is marked done, and leaving just goes back.
  final bool replay;
  const TourScreen({super.key, this.replay = false});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  final _controller = PageController();
  int _page = 0;

  late final List<_Page> _pages = [
    for (final w in welcomePages) _Page('welcome-${w.id}', _Section.welcome, () => _WelcomeView(w)),
    for (final p in permissionPages) _Page('perm-${p.id}', _Section.permissions, () => _PermissionView(p)),
    _Page('setup-look', _Section.setup, () => const _SetupLookView()),
    _Page('setup-reading', _Section.setup, () => const _SetupReadingView()),
    for (var i = 0; i < lessons.length; i++) _Page('lesson-${lessons[i].id}', _Section.lessons, () => LessonView(lessons[i], number: i + 1, total: lessons.length)),
    _Page('finale', _Section.start, () => _FinaleView(replay: widget.replay, onDone: _leave)),
  ];

  int get _finale => _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goTo(int i) async {
    if (i < 0 || i >= _pages.length) return;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.jumpToPage(i);
    } else {
      await _controller.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  Future<void> _skip() async {
    if (widget.replay) return _leave(tips: Guidance.tipsEnabled);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Skip the tour?'),
        content: const Text('You can take it any time from Help & tips in the menu. Tips on each screen stay off until you turn them on there.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep going')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Skip'))],
      ),
    );
    if (ok == true) await _leave(tips: false);
  }

  /// Finishing (or skipping) marks the tour done; [then] opens a screen on top of the Library afterwards.
  Future<void> _leave({bool tips = true, Widget? then}) async {
    if (!widget.replay) {
      await Guidance.markDone(tips: tips);
      await prefs.setBool('welcome_seen', true); // older versions' first-run flag
    }
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pop();
    if (then != null) nav.push(MaterialPageRoute(builder: (_) => then));
  }

  @override
  Widget build(BuildContext context) {
    final section = _pages[_page].section;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _page > 0 ? _goTo(_page - 1) : _skip();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    label: 'Step ${_page + 1} of ${_pages.length}, ${section.label}',
                    child: ExcludeSemantics(child: Text('${section.label}  ·  ${_page + 1} of ${_pages.length}', style: tt.labelMedium)),
                  ),
                ),
                TextButton(onPressed: _skip, child: Text(widget.replay ? 'Close' : 'Skip tour')),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: (_page + 1) / _pages.length, minHeight: 5, backgroundColor: cs.outlineVariant),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i].build(),
              ),
            ),
            if (_page != _finale) _bottomBar(section) else Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => _goTo(_page - 1), icon: const Icon(Icons.arrow_back), label: const Text('Back'))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _bottomBar(_Section section) {
    final label = switch (section) {
      _Section.welcome => _page == welcomePages.length - 1 ? "Let's start" : 'Next',
      _Section.permissions => 'Continue',
      _Section.setup => 'Next',
      _Section.lessons => _page == _finale - 1 ? 'Finish lessons' : 'Next lesson',
      _Section.start => 'Next',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          if (_page > 0) ...[OutlinedButton(onPressed: () => _goTo(_page - 1), child: const Text('Back')), const SizedBox(width: 10)],
          Expanded(child: FilledButton(onPressed: () => _goTo(_page + 1), child: Text(label))),
        ]),
        if (section == _Section.lessons) TextButton(onPressed: () => _goTo(_finale), child: const Text('Skip the rest of the lessons')),
      ]),
    );
  }
}

/// Shared page frame: scrolls, keeps its gutters, announces its title.
class TourPage extends StatelessWidget {
  final Art? art;
  final String title;
  final String? lead;
  final List<Widget> children;
  const TourPage({super.key, this.art, required this.title, this.lead, this.children = const []});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (art != null) ...[TourArt(art!), const SizedBox(height: 16)],
        Semantics(header: true, child: Text(title, style: tt.headlineSmall)),
        if (lead != null) ...[const SizedBox(height: 6), Text(lead!, style: tt.bodyLarge)],
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}

/// A numbered point of a page or lesson.
class StepTile extends StatelessWidget {
  final int number;
  final TourStep step;
  const StepTile(this.number, this.step, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        container: true,
        label: 'Step $number: ${step.title}. ${step.body}',
        child: ExcludeSemantics(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.16), shape: BoxShape.circle),
              child: Text('$number', textScaler: TextScaler.noScaling, style: tt.labelMedium?.copyWith(color: cs.onSurface)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(step.title, style: tt.titleMedium),
                const SizedBox(height: 2),
                Text(step.body, style: tt.bodyLarge),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A highlighted aside under a lesson.
class TipBox extends StatelessWidget {
  final String text;
  final IconData icon;
  const TipBox(this.text, {super.key, this.icon = Icons.lightbulb_outline});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ExcludeSemantics(child: Icon(icon, size: 20, color: cs.tertiary)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
      ]),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final WelcomeInfo page;
  const _WelcomeView(this.page);
  @override
  Widget build(BuildContext context) => TourPage(
        art: page.art,
        title: page.title,
        lead: page.lead,
        children: [
          for (var i = 0; i < page.points.length; i++) StepTile(i + 1, page.points[i]),
          if (page.id == 'privacy')
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromisePage())),
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Read our full promise'),
            ),
        ],
      );
}

String _stateLabel(PermState s) => switch (s) {
      PermState.notAsked => 'Not asked yet',
      PermState.granted => 'Allowed',
      PermState.denied => 'Not allowed',
      PermState.blocked => 'Blocked in phone settings',
    };

/// One permission: the explanation first, Android's question only on Allow.
class _PermissionView extends StatefulWidget {
  final PermissionInfo info;
  const _PermissionView(this.info);
  @override
  State<_PermissionView> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<_PermissionView> {
  PermState _state = PermState.notAsked;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    PermissionService.instance.status(widget.info.kind).then((s) {
      if (mounted) setState(() => _state = s);
    });
  }

  Future<void> _allow() async {
    setState(() => _busy = true);
    final s = await PermissionService.instance.request(widget.info.kind);
    if (mounted) {
      setState(() {
        _state = s;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final granted = _state == PermState.granted;
    final tt = Theme.of(context).textTheme;
    return TourPage(
      art: info.art,
      title: info.title,
      lead: 'Read this first. Android asks only after you tap Allow.',
      children: [
        _Section2('Why we ask', info.why),
        _Section2('What Pagemark never does', info.never),
        _Section2('If you say no', info.ifNo),
        _Section2('Change it later', info.later),
        const SizedBox(height: 4),
        Semantics(
          liveRegion: true,
          container: true,
          label: '${info.title} permission: ${_stateLabel(_state)}',
          child: ExcludeSemantics(
            child: Row(children: [
              Icon(granted ? Icons.check_circle : Icons.radio_button_unchecked, color: granted ? const Color(0xFF2F9E5B) : Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(child: Text(_stateLabel(_state), style: tt.titleMedium)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (_state == PermState.blocked) ...[
          Text('Android will not ask again. You can still turn it on in the phone\'s settings, or carry on without it.', style: tt.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: PermissionService.instance.openSettings, icon: const Icon(Icons.settings_outlined), label: const Text('Open phone settings')),
        ] else if (!granted)
          FilledButton(onPressed: _busy ? null : _allow, child: Text(_state == PermState.denied ? 'Ask again' : 'Allow ${info.title.toLowerCase()}'))
        else
          Text('Done. Tap Continue.', style: tt.bodySmall),
        if (!granted) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Not now is fine: tap Continue. You can allow it later.', style: tt.bodySmall)),
      ],
    );
  }
}

class _Section2 extends StatelessWidget {
  final String title;
  final String body;
  const _Section2(this.title, this.body);
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        container: true,
        label: '$title. $body',
        child: ExcludeSemantics(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title.toUpperCase(), style: tt.labelMedium?.copyWith(color: Theme.of(context).colorScheme.tertiary, letterSpacing: 1.1)),
            const SizedBox(height: 3),
            Text(body, style: tt.bodyLarge),
          ]),
        ),
      ),
    );
  }
}

/// Set-up 1: colours. The choice applies at once; the pills show both versions.
class _SetupLookView extends StatelessWidget {
  const _SetupLookView();
  @override
  Widget build(BuildContext context) => const TourPage(
        art: Art.setup,
        title: 'Pick your colours',
        lead: 'Tap a name to choose it, or its light or dark colours for that version. Change it any time in Settings, Appearance.',
        children: [ThemePicker()],
      );
}

/// Set-up 2: how reading starts, where searches go, and the backup reminder.
class _SetupReadingView extends StatefulWidget {
  const _SetupReadingView();
  @override
  State<_SetupReadingView> createState() => _SetupReadingViewState();
}

class _SetupReadingViewState extends State<_SetupReadingView> {
  @override
  Widget build(BuildContext context) {
    final fmt = defaultFormat();
    return TourPage(
      title: 'A few reading choices',
      lead: 'The defaults suit most people. Change any of them later in Settings.',
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              title: const Text('New reads start as'),
              subtitle: const Text('The format you use most, so you tap less'),
              trailing: DropdownButton<String>(
                value: fmt,
                underline: const SizedBox.shrink(),
                items: const [DropdownMenuItem(value: 'print', child: Text('Print')), DropdownMenuItem(value: 'ebook', child: Text('E-book')), DropdownMenuItem(value: 'audio', child: Text('Audiobook'))],
                onChanged: (v) async {
                  if (v != null) await prefs.setString('default_format', v);
                  if (mounted) setState(() {});
                },
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: const Text('Also search Google Books'),
              subtitle: const Text('Finds more books. Off: searches go to Open Library only.'),
              value: googleOn(),
              onChanged: (v) async {
                await prefs.setBool('src_google', v);
                if (mounted) setState(() {});
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            SwitchListTile(
              title: const Text('Remind me to back up'),
              subtitle: Text('A notification ${BackupReminder.everyChoices[BackupReminder.everyDays]?.toLowerCase() ?? 'now and then'}. It restarts each time you save a copy.'),
              value: BackupReminder.enabled,
              onChanged: (v) async {
                final ok = await BackupReminder.setEnabled(v);
                if (!ok && context.mounted) snack(context, 'Allow notifications for Pagemark to get reminders.');
                if (mounted) setState(() {});
              },
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const TipBox('Your books live only on this phone. A backup file you keep somewhere else is the only way back if the phone is lost.', icon: Icons.warning_amber_outlined),
      ],
    );
  }
}

/// One lesson page: animation, steps, tip, Try it.
class LessonView extends StatelessWidget {
  final Lesson lesson;
  final int number;
  final int total;
  const LessonView(this.lesson, {super.key, required this.number, required this.total});

  @override
  Widget build(BuildContext context) => TourPage(
        art: lesson.art,
        title: lesson.title,
        lead: total > 0 ? 'Lesson $number of $total. ${lesson.summary}' : lesson.summary,
        children: [
          for (var i = 0; i < lesson.steps.length; i++) StepTile(i + 1, lesson.steps[i]),
          if (lesson.tip != null) ...[TipBox(lesson.tip!), const SizedBox(height: 14)],
          TryItButton(lesson),
        ],
      );
}

/// "Try it": opens the real screen, with this lesson's tip shown once. Back returns here.
class TryItButton extends StatelessWidget {
  final Lesson lesson;
  const TryItButton(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(onPressed: () => openTryIt(context, lesson), icon: const Icon(Icons.play_arrow_rounded), label: Text(lesson.tryLabel));
}

Future<void> openTryIt(BuildContext context, Lesson lesson) async {
  Widget? page = switch (lesson.target) {
    TryTarget.addBook => const AddBook(locked: false),
    TryTarget.library => const Library(locked: false, volumes: false),
    TryTarget.manga => const Library(locked: false, volumes: true),
    TryTarget.locked => const VaultPage(),
    TryTarget.stats => const Stats(),
    TryTarget.backup => const BackupSettingsPage(),
    TryTarget.book => null,
  };
  var coach = lesson.coachId;
  if (lesson.target == TryTarget.book) {
    final first = await (db.select(db.books)..where((b) => b.locked.equals(false) & b.deletedAt.isNull())..limit(1)).getSingleOrNull();
    if (first == null) {
      page = const AddBook(locked: false);
      coach = 'add';
      if (context.mounted) snack(context, 'Add a book first, then open it to see this.');
    } else {
      page = BookPage(bookId: first.id);
    }
  }
  if (!context.mounted) return;
  Guidance.forced.value = coach;
  await Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
}

/// The last page: how to begin.
class _FinaleView extends StatelessWidget {
  final bool replay;
  final Future<void> Function({bool tips, Widget? then}) onDone;
  const _FinaleView({required this.replay, required this.onDone});

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: Samples.present(db),
        builder: (context, snap) => _build(context, snap.data ?? false),
      );

  Widget _build(BuildContext context, bool hasSamples) {
    final tt = Theme.of(context).textTheme;
    return TourPage(
      art: Art.start,
      title: replay ? "That's the tour" : "You're ready",
      lead: 'Pick how to begin. Nothing here is permanent.',
      children: [
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => onDone(then: const AddBook(locked: false)), icon: const Icon(Icons.add), label: const Text('Add my first book'))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => onDone(then: const ImportPage()), icon: const Icon(Icons.upload_file), label: const Text('Bring books in from Goodreads or StoryGraph'))),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
          onPressed: hasSamples
              ? null
              : () async {
                  await Samples.add(db);
                  await onDone();
                },
          icon: const Icon(Icons.auto_stories_outlined),
          label: Text(hasSamples ? 'Sample books already added' : 'Try it with 5 sample books'),
        ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: Text('Five well-known classics, clearly marked. Remove them in one tap from the card at the top of the Library.', style: tt.bodySmall),
        ),
        const SizedBox(height: 10),
        if (!replay)
          TextButton(
            onPressed: () async {
              final r = await FilePicker.pickFile();
              final path = r?.path;
              if (path == null || !context.mounted) return;
              await restoreFlow(context, File(path)); // closes the app when it restores
              if (context.mounted) await onDone();
            },
            child: const Text('I already use Pagemark: restore my library'),
          ),
        TextButton(onPressed: () => onDone(), child: Text(replay ? 'Done' : 'Just look around')),
      ],
    );
  }
}
