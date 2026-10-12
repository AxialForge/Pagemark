import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'db.dart';

class Exporter {
  static Future<File> _tmp(String name) async => File('${(await getTemporaryDirectory()).path}/$name');

  static Future<List<Map<String, Object?>>> _rows(AppDb db, {bool includeLocked = true}) async {
    final books = await db.select(db.books).get();
    final reads = await db.select(db.reads).get();
    final out = <Map<String, Object?>>[];
    for (final b in books.where((b) => includeLocked || !b.locked)) {
      final rs = reads.where((r) => r.bookId == b.id).toList();
      for (final r in (rs.isEmpty ? [null] : rs)) {
        out.add({
          'title': b.title, 'author': b.author, 'isbn': b.isbn, 'genre': b.genre, 'series': b.series,
          'publisher': b.publisher, 'year': b.year, 'pages': b.pages, 'tags': b.tags, 'notes': b.notes,
          'locked': b.locked, 'format': r?.format, 'status': r?.status,
          'started': r?.started?.toIso8601String(), 'finished': r?.finished?.toIso8601String(),
          'rating': r?.rating, 'thoughts': r?.thoughts, 'narrator': r?.narrator, 'minutes': r?.minutes,
        });
      }
    }
    return out;
  }

  static Future<void> shareCsv(AppDb db, {bool includeLocked = false}) async {
    final rows = await _rows(db, includeLocked: includeLocked);
    final keys = rows.isEmpty ? <String>[] : rows.first.keys.toList();
    final text = csv.encode([keys, ...rows.map((r) => keys.map((k) => r[k]).toList())]);
    final f = await _tmp('pagemark-library.csv');
    await f.writeAsString(text);
    await Share.shareXFiles([XFile(f.path)]);
  }

  static Future<void> shareJson(AppDb db, {bool includeLocked = false}) async {
    final f = await _tmp('pagemark-library.json');
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(await _rows(db, includeLocked: includeLocked)));
    await Share.shareXFiles([XFile(f.path)]);
  }

  /// Consistent single-file copy of the whole database, importable on another device.
  static Future<File> snapshotDb(AppDb db) async {
    final f = await _tmp('pagemark-backup.sqlite');
    if (await f.exists()) await f.delete();
    await db.customStatement("VACUUM INTO '${f.path.replaceAll("'", "''")}'");
    return f;
  }

  static Future<void> shareDb(AppDb db) async {
    await Share.shareXFiles([XFile((await snapshotDb(db)).path)]);
  }

  /// Replace the live database with a backup file. Caller must restart the app afterwards.
  static Future<void> restoreDb(AppDb db, File src) async {
    await db.close();
    final dest = await AppDb.file();
    for (final ext in ['-wal', '-shm']) {
      final side = File('${dest.path}$ext');
      if (await side.exists()) await side.delete();
    }
    await src.copy(dest.path);
  }
}
