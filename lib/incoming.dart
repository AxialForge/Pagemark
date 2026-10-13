import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'isbn.dart';
import 'log.dart';
import 'privacy.dart';
import 'ui.dart';

/// What another app (the Share sheet) or a launcher shortcut asked Pagemark to do.
/// Everything that arrives this way is untrusted text: it only ever pre-fills the Add book search, never saves anything itself.
class Incoming {
  static const _ch = MethodChannel('pagemark/intent');
  static const maxLength = 300;

  /// The search text for a shared snippet: an ISBN anywhere in it wins; Goodreads and Open Library links give the title in their
  /// address; otherwise the text itself (first line, links removed). Null when nothing usable is in it.
  static String? queryFromShared(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final capped = text.length > maxLength ? text.substring(0, maxLength) : text;

    for (final m in RegExp(r'\d[\d\- ]{8,16}[\dXx]').allMatches(capped)) {
      final isbn = Isbn.to13(m.group(0)!);
      if (isbn != null) return isbn;
    }

    final gr = RegExp(r'goodreads\.com/(?:[a-z]{2}/)?book/show/\d+(?:[.-]([A-Za-z0-9_%-]+))?', caseSensitive: false).firstMatch(capped);
    final ol = RegExp(r'openlibrary\.org/(?:works|books)/OL\w+/([A-Za-z0-9_%-]+)', caseSensitive: false).firstMatch(capped);
    final slug = gr?.group(1) ?? ol?.group(1);
    if (slug != null && slug.isNotEmpty) {
      var t = slug.replaceAll(RegExp(r'[_-]+'), ' ').trim();
      try {
        t = Uri.decodeComponent(t);
      } catch (_) {}
      if (t.isNotEmpty) return t;
    }

    final firstLine = capped.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).firstWhere((l) => l.isNotEmpty, orElse: () => '');
    final noLinks = firstLine.replaceAll(RegExp(r'https?://\S+'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return noLinks.isEmpty ? null : noLinks;
  }

  /// Shortcut names the launcher can send.
  static const shortcutAdd = 'add', shortcutReading = 'reading';

  /// Wires the platform channel. Safe to call once after the first frame; handles an intent that started the app and ones that
  /// arrive while it is running. Never throws.
  static Future<void> start() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'incoming') _handle(call.arguments);
      return null;
    });
    try {
      _handle(await _ch.invokeMethod<Object>('take'));
    } catch (e) {
      Log.w('incoming', 'could not read the starting intent: $e');
    }
  }

  static void _handle(Object? raw) {
    if (raw is! Map) return;
    final nav = navKey.currentState;
    if (nav == null) return;
    final type = raw['type'];
    if (type == 'text') {
      final q = queryFromShared('${raw['text'] ?? ''}');
      if (q == null) return;
      nav.push(MaterialPageRoute(builder: (_) => AddBook(locked: false, initialQuery: q)));
    } else if (type == 'shortcut') {
      switch (raw['name']) {
        case shortcutAdd:
          nav.push(MaterialPageRoute(builder: (_) => const AddBook(locked: false)));
        case shortcutReading:
          nav.popUntil((r) => r.isFirst);
          readingShortcut.value++; // the Library listens and switches to its Reading filter
      }
    }
  }

  /// Bumped when the "Log progress" shortcut is used; the Library shows only books being read.
  static final readingShortcut = ValueNotifier<int>(0);
}
