import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Local notifications (no push service, nothing leaves the phone): the daily reading reminder and the backup reminder.
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

  /// Whether Android currently lets Pagemark show notifications.
  static Future<bool> areEnabled() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  /// One notification per moment in [when] (local times), ids [baseId], [baseId]+1... Text never mentions a book. Inexact delivery,
  /// so no special "exact alarm" permission is needed.
  static Future<void> scheduleAt(
    int baseId,
    List<DateTime> when, {
    required String title,
    required List<String> messages,
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) async {
    await init();
    for (var i = 0; i < when.length; i++) {
      await _plugin.zonedSchedule(
        id: baseId + i,
        title: title,
        body: messages[i % messages.length],
        scheduledDate: tz.TZDateTime.from(when[i], tz.UTC), // an exact instant; the UTC label only carries it
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId, channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance, priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelScheduled(int baseId, int count) async {
    await init();
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(id: baseId + i);
    }
  }

  /// Notifications from older versions (the Google Drive backup problem alert, id 1) are cleared once.
  static Future<void> clearLegacy() async {
    try {
      await init();
      await _plugin.cancel(id: 1);
    } catch (_) {}
  }
}
