import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/guide.dart';

/// The in-app guide (assets/guide.md) must stay true to the app. These checks fail when a screen is renamed and the guide is not.
void main() {
  final md = File('assets/guide.md').readAsStringSync();
  final topics = parseGuide(md);

  test('the guide has topics, each with a title and some text', () {
    expect(topics.length, greaterThan(10));
    for (final t in topics) {
      expect(t.title, isNotEmpty);
      expect(t.lines, isNotEmpty, reason: t.title);
    }
  });

  test('github-only lines are dropped for the Play build', () {
    final play = parseGuide(md, github: false).map((t) => t.text).join('\n');
    final gh = topics.map((t) => t.text).join('\n');
    expect(gh, contains('**Updates**'));
    expect(play, isNot(contains('**Updates**')));
    expect(gh, isNot(contains('[github]')));
  });

  test('every "Settings → X" path starts with a real Settings page', () {
    final text = topics.map((t) => t.text).join('\n');
    final paths = RegExp('Settings → ([^\n]*)').allMatches(text).map((m) => m.group(1)!).toList();
    expect(paths, isNotEmpty);
    for (final p in paths) {
      expect(SettingsTitles.all.any(p.startsWith), isTrue, reason: 'unknown Settings page in "$p"');
    }
  });

  test('every **bold** name in the guide appears somewhere in the app', () {
    final source = [
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) f.readAsStringSync(),
      File('android/app/src/main/res/values/strings.xml').readAsStringSync(),
    ].join('\n').toLowerCase();
    // things the guide names that belong to Android's own screens, not to Pagemark
    const outside = {'widgets', 'pagemark', 'add'};
    final bold = RegExp(r'\*\*([^*]+)\*\*').allMatches(topics.map((t) => t.text).join('\n')).map((m) => m.group(1)!).toSet();
    for (final b in bold) {
      final name = b.replaceFirst(RegExp(r'^\+\s*'), '').toLowerCase();
      if (outside.contains(name)) continue;
      expect(source.contains(name), isTrue, reason: 'the guide mentions "$b" but no screen in the app says that');
    }
  });
}
