import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/onboarding/content.dart';
import 'package:pagemark/onboarding/tips.dart';
import 'package:pagemark/onboarding/tour_screen.dart';
import 'package:pagemark/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePerms implements PermissionService {
  PermState state;
  PermState answer;
  int asked = 0;
  _FakePerms(this.state, this.answer);
  @override
  Future<PermState> status(PermKind kind) async => state;
  @override
  Future<PermState> request(PermKind kind) async {
    asked++;
    return state = answer;
  }

  @override
  Future<void> openSettings() async {}
}

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
      theme: themes[0].data,
      home: MediaQuery(
        data: MediaQueryData(size: const Size(360, 740), textScaler: TextScaler.linear(scale), disableAnimations: true),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('content', () {
    test('ids are unique and every page has words', () {
      final ids = [...welcomePages.map((w) => w.id), ...permissionPages.map((p) => p.id), ...lessons.map((l) => l.id)];
      expect(ids.toSet().length, ids.length);
      for (final w in welcomePages) {
        expect(w.points, isNotEmpty, reason: w.id);
      }
      for (final l in lessons) {
        expect(l.steps.length, inInclusiveRange(2, 4), reason: l.id);
        expect(coachSteps.containsKey(l.coachId), isTrue, reason: '${l.id} tries a screen with no tips');
      }
    });

    test('every coach target named in a tip is marked somewhere in the app', () {
      final code = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).map((f) => f.readAsStringSync()).join('\n');
      for (final steps in coachSteps.values) {
        for (final s in steps) {
          final id = RegExp.escape(s.targetId);
          expect(RegExp("CoachTarget\\(\\s*id: '$id'").hasMatch(code), isTrue, reason: s.targetId);
        }
      }
      for (final id in coachSteps.keys) {
        expect(code.contains("tipId: '$id'") || code.contains("'$id' : '") || code.contains("? '$id'") || code.contains(": '$id'"), isTrue, reason: 'no CoachScope for $id');
      }
    });

    test('the tour never claims encryption of the library', () {
      final words = [
        ...welcomePages.expand((w) => [w.lead, ...w.points.map((p) => p.body)]),
        ...lessons.expand((l) => [l.summary, ?l.tip, ...l.steps.map((s) => s.body)]),
        ...permissionPages.expand((p) => [p.why, p.never, p.ifNo]),
      ].join(' ').toLowerCase();
      expect(words, isNot(contains('encrypt')));
    });

    test('search finds lessons by any word in them', () {
      expect(searchLessons('').length, lessons.length);
      expect(searchLessons('barcode').map((l) => l.id), contains('add'));
      expect(searchLessons('recovery code').map((l) => l.id), ['locked']);
      expect(searchLessons('zzzz'), isEmpty);
    });
  });

  group('routing', () {
    test('a new user gets the tour, an existing one the What\'s new sheet, once', () {
      expect(decideOnboarding(doneVersion: null, newsSeen: null, existingUser: false), OnboardingStart.tour);
      expect(decideOnboarding(doneVersion: null, newsSeen: null, existingUser: true), OnboardingStart.whatsNew);
      expect(decideOnboarding(doneVersion: tourVersion, newsSeen: tourVersion, existingUser: true), OnboardingStart.none);
      expect(decideOnboarding(doneVersion: '0.1.0', newsSeen: '0.1.0', existingUser: true), OnboardingStart.whatsNew);
      expect(decideOnboarding(doneVersion: '0.1.0', newsSeen: tourVersion, existingUser: true), OnboardingStart.none);
    });

    test('tips show once, can be forced, and stay off when turned off', () {
      expect(shouldShowTip('a', tipsEnabled: true, seen: {}), isTrue);
      expect(shouldShowTip('a', tipsEnabled: true, seen: {'a'}), isFalse);
      expect(shouldShowTip('a', tipsEnabled: false, seen: {}), isFalse);
      expect(shouldShowTip('a', tipsEnabled: false, seen: {'a'}, forced: 'a'), isTrue);
    });

    test('tip state is saved', () async {
      SharedPreferences.setMockInitialValues({});
      Guidance.init(await SharedPreferences.getInstance());
      expect(Guidance.doneVersion, isNull);
      await Guidance.markDone(tips: false);
      expect(Guidance.doneVersion, tourVersion);
      expect(Guidance.tipsEnabled, isFalse);
      await Guidance.markSeen('library');
      expect(Guidance.seen, {'library'});
      await Guidance.resetTips();
      expect(Guidance.seen, isEmpty);
      expect(Guidance.tipsEnabled, isTrue);
    });
  });

  group('pages', () {
    testWidgets('every lesson page fits at 200% text on a small phone', (t) async {
      for (final l in lessons) {
        await t.pumpWidget(_host(LessonView(l, number: 1, total: lessons.length), scale: 2));
        await t.pump();
        expect(t.takeException(), isNull, reason: l.id);
        expect(find.text(l.tryLabel), findsOneWidget);
      }
    });

    testWidgets('a permission is asked only after Allow, and a refusal offers Ask again', (t) async {
      final fake = _FakePerms(PermState.notAsked, PermState.denied);
      PermissionService.instance = fake;
      SharedPreferences.setMockInitialValues({});
      await t.pumpWidget(_host(const TourScreen(replay: true)));
      await t.pump();
      // move to the first permission page
      for (var i = 0; i < welcomePages.length; i++) {
        await t.tap(find.widgetWithText(FilledButton, i == welcomePages.length - 1 ? "Let's start" : 'Next'));
        await t.pumpAndSettle();
      }
      expect(find.text('Camera'), findsWidgets);
      expect(fake.asked, 0);
      await t.ensureVisible(find.widgetWithText(FilledButton, 'Allow camera'));
      await t.tap(find.widgetWithText(FilledButton, 'Allow camera'));
      await t.pumpAndSettle();
      expect(fake.asked, 1);
      expect(find.text('Ask again'), findsOneWidget);

      fake
        ..state = PermState.blocked
        ..answer = PermState.blocked;
      await t.ensureVisible(find.text('Ask again'));
      await t.tap(find.text('Ask again'));
      await t.pumpAndSettle();
      expect(find.text('Open phone settings'), findsOneWidget);
    });
  });
}
