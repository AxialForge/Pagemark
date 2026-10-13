import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Tiny rolling log (~200 KB) in app storage, shared by the UI and the background backup task.
/// Never records book titles or thoughts - only event names, error types and messages from code. Database errors carry
/// the SQL values they were given, so [scrub] cuts those off before anything is written.
class Log {
  static const _max = 200 * 1024;
  static File? _file;
  static bool echo = kDebugMode;
  static Future<void> _chain = Future.value(); // serialise writes

  /// Test hook.
  @visibleForTesting
  static void useFile(File f) => _file = f;

  static Future<File> _f() async => _file ??= File('${(await getApplicationSupportDirectory()).path}/pagemark.log');

  static void i(String tag, String msg) => _write('I', tag, msg);
  static void w(String tag, String msg) => _write('W', tag, msg);
  static void e(String tag, Object err, [StackTrace? st]) =>
      _write('E', tag, '$err${st == null ? '' : '\n${st.toString().split('\n').take(6).join('\n')}'}');

  /// Removes anything a database exception could have copied from the library (bound values, the statement) and caps the length.
  @visibleForTesting
  static String scrub(String msg) {
    var m = msg;
    final cut = RegExp(r'Causing statement|with parameters|Parameters:|SQL logic error|constraint failed', caseSensitive: false).firstMatch(m);
    if (cut != null) m = '${m.substring(0, cut.start)}[database details removed]';
    return m.length > 600 ? '${m.substring(0, 600)}...' : m;
  }

  static void _write(String level, String tag, String msg) {
    msg = scrub(msg);
    final line = '${DateTime.now().toIso8601String()} $level $tag: $msg\n';
    if (echo) debugPrint(line.trimRight());
    // Lines logged in the same burst are written together (one file open instead of one per line).
    _buf.write(line);
    if (level == 'E') _urgent = true;
    if (_scheduled) return;
    _scheduled = true;
    _chain = _chain.then((_) async {
      _scheduled = false;
      final text = _buf.toString();
      final flush = _urgent;
      _buf.clear();
      _urgent = false;
      try {
        final f = await _f();
        await f.writeAsString(text, mode: FileMode.append, flush: flush);
        if (await f.length() > _max) {
          final all = await f.readAsString();
          await f.writeAsString(all.substring(all.length ~/ 2)); // keep the newest half
        }
      } catch (_) {/* logging must never crash the app */}
    });
  }

  static final StringBuffer _buf = StringBuffer();
  static bool _scheduled = false, _urgent = false;

  static Future<String> read() async {
    await _chain;
    try {
      final f = await _f();
      return await f.exists() ? await f.readAsString() : '';
    } catch (_) {
      return '';
    }
  }

  static Future<void> clear() async {
    await _chain;
    try {
      final f = await _f();
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// Route framework, platform and uncaught async errors into the log instead of losing them.
  static void installGlobalHandlers() {
    final previous = FlutterError.onError;
    FlutterError.onError = (d) {
      Log.e('flutter', d.exception, d.stack);
      previous?.call(d);
    };
    PlatformDispatcher.instance.onError = (err, st) {
      Log.e('async', err, st);
      return true;
    };
  }
}
