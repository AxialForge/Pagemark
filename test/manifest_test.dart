import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Scheduled notifications silently do nothing unless the app's own manifest declares the plugin's receivers (the plugin does not).
/// This was the cause of "no reminder ever appears" on a real phone in 0.13.1, so it is checked here.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('the alarm receiver and the reboot receiver for scheduled notifications are declared, and not exported', () {
    for (final name in ['ScheduledNotificationReceiver', 'ScheduledNotificationBootReceiver']) {
      final m = RegExp('<receiver[^>]*com\.dexterous\.flutterlocalnotifications\.$name[^>]*>').firstMatch(manifest);
      expect(m, isNotNull, reason: '$name must be declared in AndroidManifest.xml');
      expect(m!.group(0), contains('android:exported="false"'));
    }
  });

  test('reminders are put back after a reboot or an update', () {
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });

  test('no exact-alarm permission is requested (inexact alarms are used, so Play needs no special approval)', () {
    expect(manifest, isNot(contains('SCHEDULE_EXACT_ALARM')));
    expect(manifest, isNot(contains('USE_EXACT_ALARM')));
  });
}
