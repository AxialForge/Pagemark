import 'main.dart';
import 'log.dart';
import 'notifier.dart';

/// Optional daily "time to read" notification. Off by default; scheduled on the phone (no server), with no book titles in the text.
/// The next [days] reminders are scheduled one by one with exact local times, so a daylight-saving change cannot shift them, and
/// the list is topped up every time Pagemark opens. Delivery is "about" that time: Android may delay it a few minutes in battery saver.
class Reminders {
  static const days = 21;

  static bool get enabled => prefs.getBool('rem_on') ?? false;
  static String get timeText => prefs.getString('rem_time') ?? '20:00';

  /// "HH:mm" -> (hour, minute); anything unreadable becomes 20:00.
  static (int, int) parseTime(String s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s.trim());
    final h = m == null ? null : int.parse(m[1]!), min = m == null ? null : int.parse(m[2]!);
    return h != null && min != null && h < 24 && min < 60 ? (h, min) : (20, 0);
  }

  static String formatTime(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  /// The next [count] reminder moments after [now] at hour:minute, in local time.
  static List<DateTime> upcoming(DateTime now, int hour, int minute, {int count = days}) {
    var day = DateTime(now.year, now.month, now.day, hour, minute);
    if (!day.isAfter(now)) day = DateTime(now.year, now.month, now.day + 1, hour, minute);
    return [for (var i = 0; i < count; i++) DateTime(day.year, day.month, day.day + i, hour, minute)];
  }

  static const messages = [
    'A few pages tonight?',
    'Your book is waiting.',
    'Ten minutes of reading?',
    'Time for a chapter.',
    'Log what you read today.',
  ];

  /// (Re)builds the schedule from the saved settings. Never throws.
  static Future<void> apply() async {
    try {
      await Notifier.cancelScheduled(100, days);
      if (!enabled) return;
      final (h, m) = parseTime(timeText);
      await Notifier.scheduleAt(100, upcoming(DateTime.now(), h, m),
          title: 'Pagemark', messages: messages, channelId: 'reading_reminders', channelName: 'Reading reminders', channelDescription: 'Your daily reading reminder');
    } catch (e) {
      Log.w('reminders', 'could not schedule: $e');
    }
  }

  /// Turns reminders on (asking for notification permission first) or off. Returns false when permission was refused.
  static Future<bool> setEnabled(bool on) async {
    if (on && !await Notifier.requestPermission()) return false;
    await prefs.setBool('rem_on', on);
    await apply();
    return true;
  }

  static Future<void> setTime(int h, int m) async {
    await prefs.setString('rem_time', formatTime(h, m));
    await apply();
  }
}
