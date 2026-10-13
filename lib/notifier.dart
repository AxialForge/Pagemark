import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'log.dart';

/// Local notifications (no push service, nothing leaves the phone). Used for backup problems only.
class Notifier {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (_ready || defaultTargetPlatform != TargetPlatform.android) return;
    await _plugin.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    _ready = true;
  }

  /// Android 13+ asks the user once; older versions grant it implicitly. Returns whether notifications are allowed.
  static Future<bool> requestPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  static Future<void> backupProblem(String message) async {
    try {
      await init();
      await _plugin.show(
        id: 1,
        title: 'Pagemark backup needs attention',
        body: message,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'backup_problems', 'Backup problems',
            channelDescription: 'Tells you when scheduled Google Drive backups keep failing',
            importance: Importance.defaultImportance, priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
      );
    } catch (e) {
      Log.w('notify', 'could not show notification: $e'); // never let a notification failure break a backup run
    }
  }

  static Future<void> clearBackupProblem() async {
    try {
      await init();
      await _plugin.cancel(id: 1);
    } catch (_) {}
  }

  static const _reminderBase = 100;

  /// One notification per moment in [when] (local times), ids 100... Text never mentions a book. Inexact delivery, so no
  /// special "exact alarm" permission is needed.
  static Future<void> scheduleReminders(List<DateTime> when, List<String> messages) async {
    await init();
    for (var i = 0; i < when.length; i++) {
      await _plugin.zonedSchedule(
        id: _reminderBase + i,
        title: 'Pagemark',
        body: messages[i % messages.length],
        scheduledDate: tz.TZDateTime.from(when[i], tz.UTC), // an exact instant; the UTC label only carries it
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_reminders', 'Reading reminders',
            channelDescription: 'Your daily reading reminder',
            importance: Importance.defaultImportance, priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelReminders(int count) async {
    await init();
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(id: _reminderBase + i);
    }
  }
}
