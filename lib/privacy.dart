import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Lets lock code pop any locked screen that is on top of the Home tabs.
final navKey = GlobalKey<NavigatorState>();

/// Locked-library covers use their own short-lived cache so relocking can wipe them.
final lockedCache = CacheManager(Config('lockedCovers', stalePeriod: const Duration(days: 1), maxNrOfCacheObjects: 300));

class Secure {
  static const _ch = MethodChannel('pagemark/secure');

  /// True while the locked library is on screen (so the lifecycle code does not drop screen protection under it).
  static bool hold = false;

  /// Android FLAG_SECURE: blocks screenshots/screen recording and blanks the recents thumbnail.
  /// Build-time switch for documentation builds only (`--dart-define=PAGEMARK_SCREENSHOTS=true`): lets the emulator capture the
  /// locked screens. Never set for releases.
  static const _docBuild = bool.fromEnvironment('PAGEMARK_SCREENSHOTS');

  static Future<void> set(bool on) async {
    if (_docBuild) return;
    try {
      await _ch.invokeMethod('setSecure', on);
    } catch (_) {/* not Android / channel missing */}
  }
}

/// Delete shared export/snapshot files (they can hold locked books) left in the cache dir.
Future<void> cleanTempExports() async {
  try {
    final dir = await getTemporaryDirectory();
    for (final f in dir.listSync()) {
      final n = f.uri.pathSegments.last;
      if (f is File && (n.startsWith('pagemark-') || n == 'restore.sqlite')) await f.delete();
    }
  } catch (_) {}
}

/// Called whenever the locked library closes: close its screens, wipe its covers and exports.
Future<void> wipeLockedTraces() async {
  navKey.currentState?.popUntil((r) => r.isFirst);
  await lockedCache.emptyCache();
  await cleanTempExports();
}
