import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'app_lock.dart';
import 'db.dart';
import 'log.dart';
import 'main.dart';

/// Feeds the home-screen widget. Only the MAIN library is ever read here (locked books never reach the widget), and when the
/// whole-app lock is on or the owner turned titles off, the widget shows counts only.
class WidgetSync {
  static const provider = 'com.axialforge.pagemark.PagemarkWidgetProvider';

  /// Setting: show book titles on the widget (default on).
  static final showTitles = ValueNotifier<bool>(true);

  /// Pure: the three lines the widget shows.
  static Map<String, String> payload(List<BookRow> main, {required int year, required int goal, required bool titles}) {
    final reading = <String>[];
    var finished = 0;
    for (final r in main) {
      if (r.book.locked || r.book.deletedAt != null) continue; // belt and braces: never a locked or trashed book
      if (r.reads.any((x) => x.status == 'reading')) reading.add(r.book.title);
      finished += r.reads.where((x) => x.status == 'finished' && x.finished?.year == year).length;
    }
    final goalLine = goal > 0 ? '$finished of $goal books in $year' : '$finished ${finished == 1 ? 'book' : 'books'} finished in $year';
    final readingText = reading.isEmpty
        ? 'Nothing in progress'
        : titles
            ? reading.take(3).join('\n') + (reading.length > 3 ? '\n+${reading.length - 3} more' : '')
            : '${reading.length} ${reading.length == 1 ? 'book' : 'books'} in progress';
    return {'w_goal': goalLine, 'w_reading': readingText};
  }

  static StreamSubscription<List<BookRow>>? _sub;
  static Timer? _debounce;
  static List<BookRow> _last = const [];

  /// Starts keeping the widget current. Safe to call once; never throws.
  static void start() {
    if (defaultTargetPlatform != TargetPlatform.android || _sub != null) return;
    showTitles.value = prefs.getBool('widget_titles') ?? true;
    showTitles.addListener(() {
      prefs.setBool('widget_titles', showTitles.value);
      _push();
    });
    appLockEnabled.addListener(_push);
    _sub = db.watchLibrary(locked: false).listen((rows) {
      _last = rows;
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 1), _push);
    });
  }

  static Future<void> _push() async {
    try {
      final year = DateTime.now().year;
      final data = payload(_last, year: year, goal: prefs.getInt('goal_$year') ?? 0, titles: showTitles.value && !appLockEnabled.value);
      for (final e in data.entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: provider);
    } catch (e) {
      Log.w('widget', 'could not update the widget: $e');
    }
  }
}
