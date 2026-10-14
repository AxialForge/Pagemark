import 'package:flutter/foundation.dart';
import 'log.dart';
import 'main.dart';
import 'notifier.dart';

/// "Time to save a backup": an optional notification every week, two weeks or month, counted from the last time you saved a copy
/// of your library (or a spreadsheet of it). Nothing leaves the phone. The next few reminders are scheduled one by one with exact local
/// times (10:00) and topped up whenever Pagemark opens or you save a copy.
class BackupReminder {
  static const _baseId = 200, count = 6;
  static const everyChoices = <int, String>{7: 'Every week', 14: 'Every 2 weeks', 30: 'Every month'};

  static bool get enabled => prefs.getBool('bkr_on') ?? true;
  static int get everyDays {
    final v = prefs.getInt('bkr_every') ?? 30;
    return everyChoices.containsKey(v) ? v : 30;
  }

  static DateTime? get lastBackup => DateTime.tryParse(prefs.getString('last_backup') ?? '');

  /// Pure: the next [count] reminder moments after [now], [everyDays] apart, starting from [since] (the last backup, or the day
  /// Pagemark was first opened), always at 10:00 local time and never in the past.
  static List<DateTime> upcoming(DateTime now, DateTime since, int everyDays, {int count = count}) {
    var day = DateTime(since.year, since.month, since.day + everyDays, 10);
    while (!day.isAfter(now)) {
      day = DateTime(day.year, day.month, day.day + everyDays, 10);
    }
    return [for (var i = 0; i < count; i++) DateTime(day.year, day.month, day.day + i * everyDays, 10)];
  }

  /// Days since the last saved copy, or null if there never was one.
  static int? daysSince(DateTime now) {
    final l = lastBackup;
    return l == null ? null : DateTime(now.year, now.month, now.day).difference(DateTime(l.year, l.month, l.day)).inDays;
  }

  /// Called whenever a copy was saved or shared. Restarts the countdown.
  static Future<void> recordBackup() async {
    await prefs.setString('last_backup', DateTime.now().toIso8601String());
    await apply();
  }

  static Future<void> apply() async {
    try {
      await Notifier.cancelScheduled(_baseId, count);
      if (!enabled) return;
      final since = lastBackup ?? DateTime.tryParse(prefs.getString('first_run') ?? '') ?? DateTime.now();
      await Notifier.scheduleAt(
        _baseId,
        upcoming(DateTime.now(), since, everyDays),
        title: 'Pagemark',
        messages: const ['Time to save a backup of your library.', 'Keep your books safe: save a backup today.'],
        channelId: 'backup_reminders',
        channelName: 'Backup reminders',
        channelDescription: 'A now-and-then reminder to save a copy of your library',
      );
    } catch (e) {
      Log.w('backup-reminder', 'could not schedule: $e');
    }
  }

  static Future<bool> setEnabled(bool on) async {
    if (on && defaultTargetPlatform == TargetPlatform.android && !await Notifier.requestPermission()) return false;
    await prefs.setBool('bkr_on', on);
    await apply();
    return true;
  }

  static Future<void> setEvery(int days) async {
    await prefs.setInt('bkr_every', days);
    await apply();
  }
}
