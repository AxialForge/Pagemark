import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor, rootBundle;
import 'adaptive.dart';
import 'updater_ui.dart';

/// One topic of the in-app guide (a "## " section of assets/guide.md).
class GuideTopic {
  final String title;
  final List<String> lines;
  const GuideTopic(this.title, this.lines);
  String get text => '$title\n${lines.join('\n')}';
}

/// The names of the Settings pages. The guide refers to them, and a test checks that every "Settings → X" in the guide uses one of
/// these, so renaming a page without updating the guide fails the build.
/// The guide topic the empty Manga & comics page opens (a heading in assets/guide.md).
const mangaGuideTopic = 'Manga, comics and other series';

class SettingsTitles {
  static const promise = 'Our promise to you';
  static const appearance = 'Appearance';
  static const notifications = 'Notifications';
  static const widget = 'Widget and shortcuts';
  static const privacy = 'Privacy and lock';
  static const backup = 'Backup and restore';
  static const importExport = 'Import and export';
  static const library = 'Your library';
  static const help = 'Help and about';
  static const all = [promise, appearance, notifications, widget, privacy, backup, importExport, library, help];
}

/// Splits the guide markdown into topics. Lines starting with "[github] " are only for the GitHub build (the Google Play build
/// updates through Play, so it drops them).
List<GuideTopic> parseGuide(String md, {bool github = true}) {
  final topics = <GuideTopic>[];
  String? title;
  var lines = <String>[];
  void flush() {
    final t = title;
    if (t != null) topics.add(GuideTopic(t, _trim(lines)));
    lines = [];
  }

  for (final raw in md.split('\n')) {
    var line = raw.trimRight();
    if (line.startsWith('# ')) continue;
    if (line.startsWith('[github] ')) {
      if (!github) continue;
      line = line.substring(9);
    }
    if (line.startsWith('## ')) {
      flush();
      title = line.substring(3).trim();
    } else if (title != null) {
      lines.add(line);
    }
  }
  flush();
  return topics;
}

List<String> _trim(List<String> l) {
  var a = 0, b = l.length;
  while (a < b && l[a].trim().isEmpty) {
    a++;
  }
  while (b > a && l[b - 1].trim().isEmpty) {
    b--;
  }
  return l.sublist(a, b);
}

/// "How to use Pagemark": the topics in plain words, with a search box.
class GuidePage extends StatefulWidget {
  /// A topic title to open straight away (for example the manga topic from the empty Manga & comics page).
  final String? openTopic;
  const GuidePage({super.key, this.openTopic});
  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late final Future<List<GuideTopic>> _topics = rootBundle.loadString('assets/guide.md').then((s) => parseGuide(s, github: appFlavor != 'play'));
  String q = '';
  final _openKey = GlobalKey();
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('How to use Pagemark')),
        body: NarrowColumn(
          child: FutureBuilder<List<GuideTopic>>(
          future: _topics,
          builder: (_, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final all = snap.data!;
            final needle = q.trim().toLowerCase();
            final shown = needle.isEmpty ? all : all.where((t) => t.text.toLowerCase().contains(needle)).toList();
            if (widget.openTopic != null && !_scrolled) {
              _scrolled = true; // bring the opened topic to the top once
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final c = _openKey.currentContext;
                if (c != null) Scrollable.ensureVisible(c, duration: const Duration(milliseconds: 300));
              });
            }
            return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'What do you need help with?', border: OutlineInputBorder()),
                  onChanged: (v) => setState(() => q = v),
                ),
              ),
              if (shown.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Nothing matches that. Try a simpler word, like "backup", "PIN" or "shelf".')),
              for (final t in shown)
                ExpansionTile(
                  key: needle.isEmpty && t.title == widget.openTopic ? _openKey : PageStorageKey('${t.title}|${needle.isNotEmpty}'),
                  initiallyExpanded: (needle.isNotEmpty && shown.length <= 3) || (needle.isEmpty && t.title == widget.openTopic),
                  title: Text(t.title, style: Theme.of(context).textTheme.titleMedium),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: guideBody(t.lines),
                ),
            ]);
          },
        ),
        ),
      );
}

/// One guide topic's lines as widgets (the guide and Help & tips).
List<Widget> guideBody(List<String> lines) {
  final out = <Widget>[];
  for (final l in lines) {
    if (l.trim().isEmpty) {
      out.add(const SizedBox(height: 8));
    } else if (l.startsWith('- ')) {
      out.add(Padding(padding: const EdgeInsets.only(left: 8, top: 4), child: Text.rich(inlineMarkdown('•  ${l.substring(2)}'))));
    } else if (RegExp(r'^\d+\. ').hasMatch(l)) {
      out.add(Padding(padding: const EdgeInsets.only(left: 8, top: 4), child: Text.rich(inlineMarkdown(l))));
    } else {
      out.add(Padding(padding: const EdgeInsets.only(top: 4), child: Text.rich(inlineMarkdown(l))));
    }
  }
  return out;
}
