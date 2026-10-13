import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'log.dart';

/// Covers saved on the phone. A book's `coverUrl` is either a web address or `local:<file name>`; the files live in one
/// folder (`covers/` in app storage) so backups can include them and the app works offline.
class CoverStore {
  static Directory? _dir;
  static http.Client client = http.Client();

  static Future<void> init() async {
    _dir = Directory('${(await getApplicationDocumentsDirectory()).path}/covers');
    await _dir!.create(recursive: true);
  }

  /// Tests point the store at a temp folder.
  static void useDir(Directory d) {
    d.createSync(recursive: true);
    _dir = d;
  }

  static Directory get dir => _dir ?? (throw StateError('CoverStore.init() was not called'));
  static bool get ready => _dir != null;

  static const prefix = 'local:';
  static bool isLocal(String url) => url.startsWith(prefix);

  /// Only plain file names, never paths: a backup cannot make us read or write outside the covers folder.
  static bool safeName(String name) => RegExp(r'^[A-Za-z0-9._-]{1,80}$').hasMatch(name) && !name.contains('..');

  static File? fileFor(String url) {
    if (!isLocal(url) || !ready) return null;
    final name = url.substring(prefix.length);
    return safeName(name) ? File('${dir.path}/$name') : null;
  }

  static String _newName(int bookId, String ext) => 'b$bookId-${DateTime.now().millisecondsSinceEpoch}$ext';

  /// Copies a picked or downloaded image into the store and returns the `local:` value for the book.
  static Future<String> saveFile(int bookId, File src, {String ext = '.jpg'}) async {
    final name = _newName(bookId, ext);
    await src.copy('${dir.path}/$name');
    return '$prefix$name';
  }

  /// Downloads a web cover into the store. Returns null when it is not a usable image (Open Library answers a tiny
  /// placeholder GIF when it has no cover for an ISBN).
  static Future<String?> saveFromUrl(int bookId, String url) async {
    try {
      final r = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (r.statusCode != 200 || r.bodyBytes.length < 1500) return null;
      final ct = r.headers['content-type'] ?? '';
      if (!ct.startsWith('image/')) return null;
      final name = _newName(bookId, ct.contains('png') ? '.png' : '.jpg');
      await File('${dir.path}/$name').writeAsBytes(r.bodyBytes, flush: true);
      return '$prefix$name';
    } catch (e) {
      Log.w('covers', 'download failed: $e');
      return null;
    }
  }

  /// What to show again once a saved cover is removed: the Open Library cover for the ISBN, if there is one.
  static String webFallback(String isbn) => isbn.isEmpty ? '' : 'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg';

  static Future<void> delete(String url) async {
    final f = fileFor(url);
    if (f != null && await f.exists()) await f.delete();
  }

  static Future<List<File>> allFiles() async {
    if (!ready || !await dir.exists()) return [];
    return [for (final e in dir.listSync()) if (e is File && safeName(e.uri.pathSegments.last)) e];
  }

  /// Names + sizes, used to tell whether a backup would differ from the last one.
  static Future<String> signature() async {
    final files = await allFiles();
    final parts = [for (final f in files) '${f.uri.pathSegments.last}:${f.lengthSync()}']..sort();
    return parts.join(',');
  }

  /// Removes files no book points at any more (after deleting books for good, restoring, replacing covers).
  /// How old a cover file must be before the clean-up may delete it (tests set zero).
  static Duration minAgeForCleanup = const Duration(minutes: 10);

  static Future<int> removeUnused(Set<String> inUse) async {
    var n = 0;
    for (final f in await allFiles()) {
      // a cover saved in the last few minutes may not be written to its book yet; leave it for the next sweep
      final fresh = DateTime.now().difference(f.lastModifiedSync()) < minAgeForCleanup;
      if (!fresh && !inUse.contains('$prefix${f.uri.pathSegments.last}')) {
        await f.delete();
        n++;
      }
    }
    return n;
  }

  /// Copies the covers of a restored backup in (same names overwrite; nothing else is deleted).
  static Future<int> importFrom(Directory staged) async {
    if (!await staged.exists()) return 0;
    var n = 0;
    for (final e in staged.listSync()) {
      if (e is File && safeName(e.uri.pathSegments.last)) {
        await e.copy('${dir.path}/${e.uri.pathSegments.last}');
        n++;
      }
    }
    return n;
  }
}
