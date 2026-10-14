import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/promise.dart';

/// The promise screen says Pagemark has no tracking, no ads and no AI, and talks to the internet only in three places. These tests
/// fail if the code stops being true to that, so the words cannot go stale unnoticed.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final deps = RegExp(r'^  ([a-z0-9_]+):', multiLine: true).allMatches(pubspec.split('dev_dependencies:').first).map((m) => m.group(1)!).toSet();

  test('no analytics, tracking, advertising, crash-reporting or AI packages', () {
    const banned = [
      'firebase', 'sentry', 'crashlytics', 'analytics', 'amplitude', 'mixpanel', 'segment', 'posthog', 'appsflyer', 'adjust', 'branch',
      'admob', 'google_mobile_ads', 'facebook', 'onesignal', 'openai', 'anthropic', 'gemini', 'generative', 'langchain', 'tflite', 'llama',
    ];
    final found = [for (final d in deps) if (banned.any(d.contains)) d];
    expect(found, isEmpty, reason: 'these packages contradict the promise screen');
  });

  test('the app only contacts the hosts the promise screen describes', () {
    final hosts = <String>{};
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final text = f.readAsStringSync();
      for (final m in RegExp(r"Uri\.https\('([^']+)'").allMatches(text)) {
        hosts.add(m.group(1)!);
      }
      for (final m in RegExp(r'https://([a-zA-Z0-9.\-]+)[/\x27"]').allMatches(text)) {
        hosts.add(m.group(1)!);
      }
    }
    hosts.removeWhere((h) => h == 'example.invalid'); // debug-only preview address, never contacted
    expect(hosts.difference(promiseHosts.toSet()), isEmpty, reason: 'a new internet address needs a line on the promise screen');
  });

  test('the barcode reader is mentioned on the promise screen whenever its library is in the app', () {
    if (deps.contains('mobile_scanner')) {
      final page = File('lib/promise.dart').readAsStringSync();
      expect(page.contains('barcode reader') && page.contains('ML Kit'), isTrue);
    }
  });

  test('no ads, accounts or sign-in code', () {
    expect(deps.any((d) => d.contains('google_sign_in') || d.contains('firebase_auth') || d.contains('sign_in_with')), isFalse);
  });
}
