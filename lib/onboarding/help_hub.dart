import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor, rootBundle;

import '../firstrun.dart';
import '../guide.dart';
import '../home_nav.dart';
import '../main.dart';
import '../ui.dart' show snack;
import 'content.dart';
import 'tips.dart';
import 'tour_screen.dart';

const _issuesUrl = 'https://github.com/AxialForge/Pagemark/issues';

/// Help & tips: search every lesson and guide topic, replay the tour, turn tips on or off, remove the sample books,
/// report a problem. In the menu, and in Settings.
class HelpHubPage extends StatefulWidget {
  const HelpHubPage({super.key});
  @override
  State<HelpHubPage> createState() => _HelpHubPageState();
}

class _HelpHubPageState extends State<HelpHubPage> {
  late final Future<List<GuideTopic>> _topics = rootBundle.loadString('assets/guide.md').then((s) => parseGuide(s, github: appFlavor != 'play'));
  late Future<bool> _samples = Samples.present(db);
  String q = '';

  Future<void> _report() async {
    try {
      await const AndroidIntent(action: 'action_view', data: _issuesUrl).launch();
    } catch (_) {
      if (mounted) snack(context, 'Open $_issuesUrl in your browser.');
    }
  }

  Future<void> _removeSamples() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove the sample books?'),
        content: const Text('This removes the 5 sample books for good. Books you added yourself are not touched.'),
        actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove them'))],
      ),
    );
    if (ok != true) return;
    await Samples.remove(db);
    if (!mounted) return;
    snack(context, 'Sample books removed.');
    setState(() => _samples = Samples.present(db));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final needle = q.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(leading: navButton(context), title: const Text('Help & tips')),
      body: FutureBuilder<List<GuideTopic>>(
        future: _topics,
        builder: (context, snap) {
          final topics = snap.data ?? const <GuideTopic>[];
          final words = needle.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
          final shownTopics = [for (final t in topics) if (words.every(t.text.toLowerCase().contains)) t];
          final shownLessons = searchLessons(needle);
          return ListView(padding: const EdgeInsets.only(bottom: 32), children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'What do you need help with?'),
                onChanged: (v) => setState(() => q = v),
              ),
            ),
            if (needle.isEmpty) ...[
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Take the tour'),
                subtitle: const Text('Eight short lessons with a Try it button, about four minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (_) => const TourScreen(replay: true))),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.tips_and_updates_outlined),
                title: const Text('Tips on each screen'),
                subtitle: const Text('The first time you open a screen, a tip points out what is there'),
                value: Guidance.tipsEnabled,
                onChanged: (v) async {
                  await Guidance.setTips(v);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay),
                title: const Text('Show all tips again'),
                subtitle: const Text('Every screen shows its tip once more'),
                onTap: () async {
                  await Guidance.resetTips();
                  if (!context.mounted) return;
                  setState(() {});
                  snack(context, 'Tips are on and will show again.');
                },
              ),
              FutureBuilder<bool>(
                future: _samples,
                builder: (_, s) => s.data == true
                    ? ListTile(leading: const Icon(Icons.auto_stories_outlined), title: const Text('Remove the sample books'), subtitle: const Text('The 5 example books from the tour'), onTap: _removeSamples)
                    : const SizedBox.shrink(),
              ),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Report a problem or ask a question'),
                subtitle: const Text('Opens Pagemark\'s page on GitHub in your browser'),
                trailing: const Icon(Icons.open_in_new),
                onTap: defaultTargetPlatform == TargetPlatform.android ? _report : null,
              ),
              const Divider(),
            ],
            if (shownLessons.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('LESSONS', style: tt.labelMedium?.copyWith(letterSpacing: 1.1))),
            for (final l in shownLessons)
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(l.title),
                subtitle: Text(l.summary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _LessonPage(l))),
              ),
            if (shownTopics.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text('HOW TO', style: tt.labelMedium?.copyWith(letterSpacing: 1.1))),
            for (final t in shownTopics)
              ExpansionTile(
                key: PageStorageKey('${t.title}|${needle.isNotEmpty}'),
                initiallyExpanded: needle.isNotEmpty && shownTopics.length <= 3,
                title: Text(t.title, style: tt.titleMedium),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: guideBody(t.lines),
              ),
            if (needle.isNotEmpty && shownLessons.isEmpty && shownTopics.isEmpty)
              const Padding(padding: EdgeInsets.all(24), child: Text('Nothing matches that. Try a simpler word, like "backup", "PIN" or "shelf".')),
          ]);
        },
      ),
    );
  }
}

/// A lesson on its own (from Help & tips), with its Try it button.
class _LessonPage extends StatelessWidget {
  final Lesson lesson;
  const _LessonPage(this.lesson);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(lesson.title)), body: LessonView(lesson, number: 0, total: 0));
}

enum WhatsNewChoice { tour, tips, notNow }

/// The short sheet for someone who already uses Pagemark: offers the tour, never forces it.
Future<WhatsNewChoice> showWhatsNewSheet(BuildContext context) async {
  final tt = Theme.of(context).textTheme;
  final choice = await showModalBottomSheet<WhatsNewChoice>(
    context: context,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(header: true, child: Text('New: a tour and tips', style: tt.headlineSmall)),
          const SizedBox(height: 12),
          for (final i in whatsNewItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Semantics(
                container: true,
                label: '${i.title}. ${i.body}',
                child: ExcludeSemantics(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(i.title, style: tt.titleMedium), Text(i.body, style: tt.bodyLarge)]),
                ),
              ),
            ),
          const SizedBox(height: 6),
          FilledButton(onPressed: () => Navigator.pop(c, WhatsNewChoice.tour), child: const Text('Take the tour')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.pop(c, WhatsNewChoice.tips), child: const Text('Just show me tips as I go')),
          TextButton(onPressed: () => Navigator.pop(c, WhatsNewChoice.notNow), child: const Text('Not now')),
          Text('All of this is in Help & tips in the menu.', style: tt.bodySmall, textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
  final result = choice ?? WhatsNewChoice.notNow; // swiping the sheet away counts as Not now
  await Guidance.markDone(tips: result != WhatsNewChoice.notNow);
  return result;
}
