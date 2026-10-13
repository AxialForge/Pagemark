import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/app_lock.dart';
import 'package:pagemark/lock.dart';

Widget host() => MaterialApp(
      builder: (context, child) => AppLockOverlay(child: child!),
      home: const Scaffold(body: Center(child: Text('secret library contents'))),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shouldRelock', () {
    test('delay 0 always relocks; a delay relocks only once you have been away at least that long', () {
      expect(shouldRelock(Duration.zero, 0), isTrue);
      expect(shouldRelock(const Duration(seconds: 5), 0), isTrue);
      expect(shouldRelock(const Duration(seconds: 59), 60), isFalse);
      expect(shouldRelock(const Duration(seconds: 60), 60), isTrue);
      expect(shouldRelock(const Duration(minutes: 20), 900), isTrue);
      expect(shouldRelock(const Duration(minutes: 14), 900), isFalse);
    });
    test('the choices include 0 (the strict default) and are sorted ascending', () {
      expect(lockDelayChoices.keys.first, 0);
      final k = lockDelayChoices.keys.toList();
      expect([...k]..sort(), k);
    });
  });

  group('whole-app lock overlay', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({'mode': 'pin'});
      LockService.debugDeviceSupported = false;
      appLockEnabled.value = true;
      appLocked.value = false;
      lockDelay.value = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('pagemark/secure'), (_) async => null);
    });
    tearDown(() {
      LockService.debugDeviceSupported = null;
      appLockEnabled.value = false;
      appLocked.value = false;
    });

    testWidgets('unlocked: the app is visible and there is no gate', (t) async {
      await t.pumpWidget(host());
      await t.pumpAndSettle();
      expect(find.text('secret library contents'), findsOneWidget);
      expect(find.text('Pagemark is locked'), findsNothing);
    });

    testWidgets('locked: the gate shows with a PIN field, and nothing underneath can be tapped', (t) async {
      appLocked.value = true;
      await t.pumpWidget(host());
      await t.pumpAndSettle();
      expect(find.text('Pagemark is locked'), findsOneWidget);
      expect(find.text('Forgot PIN?'), findsOneWidget);
      expect(find.text('secret library contents').hitTestable(), findsNothing, reason: 'the gate covers the app completely');
    });

    testWidgets('going to the background with delay 0 locks at once; with a delay it waits', (t) async {
      await t.pumpWidget(host());
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await t.pump();
      expect(appLocked.value, isTrue, reason: 'delay 0: locked before the recents card is captured');

      appLocked.value = false;
      lockDelay.value = 300;
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await t.pump();
      expect(appLocked.value, isFalse, reason: 'a 5 minute delay has not run out yet');
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump();
      expect(appLocked.value, isFalse, reason: 'back after a moment: still unlocked');
    });

    testWidgets('with the lock switched off, leaving the app never locks it', (t) async {
      appLockEnabled.value = false;
      await t.pumpWidget(host());
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await t.pump();
      expect(appLocked.value, isFalse);
    });
  });
}
