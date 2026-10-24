import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content.dart';

/// Tour and tip state, kept in the app's preferences.
class Guidance {
  static SharedPreferences? _p;
  static void init(SharedPreferences p) => _p = p;

  static String? get doneVersion => _p?.getString('tour_done');
  static String? get newsSeen => _p?.getString('tour_news');
  static bool get tipsEnabled => _p?.getBool('tips_on') ?? true;
  static Set<String> get seen => (_p?.getStringList('tips_seen') ?? const <String>[]).toSet();

  /// The tour was finished or skipped (or the What's new sheet answered): it will not open by itself again.
  static Future<void> markDone({required bool tips}) async {
    await _p?.setString('tour_done', tourVersion);
    await _p?.setString('tour_news', tourVersion);
    await _p?.setBool('tips_on', tips);
  }

  static Future<void> setTips(bool on) async => _p?.setBool('tips_on', on);

  static Future<void> markSeen(String id) async => _p?.setStringList('tips_seen', {...seen, id}.toList());

  /// "Show tips again": every screen's tip shows once more.
  static Future<void> resetTips() async {
    await _p?.remove('tips_seen');
    await _p?.setBool('tips_on', true);
  }

  /// "Try it" in a lesson forces that screen's tip to show once, even if tips are off or already seen.
  static final forced = ValueNotifier<String?>(null);

  /// Tests set this so screens never pop a tip over what they are testing.
  static bool disabledForTests = false;
}

/// Where a permission stands, in the words the tour uses.
enum PermState { notAsked, granted, denied, blocked }

/// The tour talks to permissions through this, so tests can fake every answer.
abstract class PermissionService {
  Future<PermState> status(PermKind kind);

  /// Shows Android's question (returns the current state if already granted or blocked).
  Future<PermState> request(PermKind kind);
  Future<void> openSettings();

  static PermissionService instance = SystemPermissionService();
}

class SystemPermissionService implements PermissionService {
  Permission _of(PermKind k) => switch (k) {
        PermKind.camera => Permission.camera,
        PermKind.notifications => Permission.notification,
      };

  PermState _map(PermissionStatus s, {bool asked = false}) {
    if (s.isGranted || s.isLimited || s.isProvisional) return PermState.granted;
    if (s.isPermanentlyDenied || s.isRestricted) return PermState.blocked;
    return asked ? PermState.denied : PermState.notAsked;
  }

  @override
  Future<PermState> status(PermKind kind) async {
    try {
      return _map(await _of(kind).status);
    } catch (_) {
      return PermState.notAsked;
    }
  }

  @override
  Future<PermState> request(PermKind kind) async {
    try {
      return _map(await _of(kind).request(), asked: true);
    } catch (_) {
      return PermState.denied;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {}
  }
}
