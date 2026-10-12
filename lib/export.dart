import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'crypto_backup.dart';
import 'db.dart';

class RestoreCheck {
  final bool ok;
  final String message;
  final int books, reads;
  const RestoreCheck.fail(this.message) : ok = false, books = 0, reads = 0;
  const RestoreCheck.pass(this.books, this.reads) : ok = true, message = 'ok';
}

class Exporter {
  /// Export format version, written into JSON so future importers can tell files apart.
  static const formatVersion = 1;

  static Future<File> _tmp(String name) async => File('${(await getTemporaryDirectory()).path}/$name');

  static String _stamp() {
    final n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${p(n.month)}${p(n.day)}-${p(n.hour)}${p(n.minute)}';
  }

  /// Spreadsheet apps execute cells that start with = + - @ ; neutralise them.
  static Object? safeCell(Object? v) {
    if (v is String && v.isNotEmpty && '=+-@\t\r'.contains(v[0])) return "'$v";
    return v;
  }

  static Future<List<Map<String, Object?>>> rows(AppDb db, {bool includeLocked = false}) async {
    final books = await (db.select(db.books)..where((b) => b.deletedAt.isNull())).get();
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

  static String toCsv(List<Map<String, Object?>> rows) {
    final keys = rows.isEmpty ? <String>[] : rows.first.keys.toList();
    final text = csv.encode([keys, ...rows.map((r) => keys.map((k) => safeCell(r[k])).toList())]);
    return '﻿$text'; // BOM so Excel reads UTF-8 accents correctly
  }

  static Future<void> _share(File f, String mime) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: mime)]));
  }

  static Future<void> shareCsv(AppDb db) async {
    final f = await _tmp('pagemark-library-${_stamp()}.csv');
    await f.writeAsString(toCsv(await rows(db)));
    await _share(f, 'text/csv');
  }

  static Future<void> shareJson(AppDb db) async {
    final f = await _tmp('pagemark-library-${_stamp()}.json');
    final doc = {'pagemark_export': formatVersion, 'exported': DateTime.now().toIso8601String(), 'books': await rows(db)};
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(doc));
    await _share(f, 'application/json');
  }

  /// Consistent single-file copy of the whole database (VACUUM INTO).
  static Future<File> snapshotDb(AppDb db, {String name = 'pagemark-backup.sqlite'}) async {
    final f = await _tmp(name);
    if (await f.exists()) await f.delete();
    await db.customStatement("VACUUM INTO '${f.path.replaceAll("'", "''")}'");
    return f;
  }

  /// Share the whole database; with [passphrase] it is encrypted first.
  static Future<void> shareDb(AppDb db, {String? passphrase}) async {
    final snap = await snapshotDb(db, name: 'pagemark-db-${_stamp()}.sqlite');
    if (passphrase == null || passphrase.isEmpty) {
      await _share(snap, 'application/vnd.sqlite3');
      return;
    }
    final enc = await BackupCrypto.encrypt(snap, await _tmp('pagemark-db-${_stamp()}.pgbak'), passphrase);
    await snap.delete();
    await _share(enc, 'application/octet-stream');
  }

  /// Open the candidate read-only and check it really is a healthy Pagemark database.
  static RestoreCheck inspect(File f) {
    sql.Database? d;
    try {
      d = sql.sqlite3.open(f.path, mode: sql.OpenMode.readOnly);
      final integrity = d.select('PRAGMA integrity_check').first.values.first;
      if (integrity != 'ok') return RestoreCheck.fail('Database is damaged ($integrity).');
      final tables = d.select("SELECT name FROM sqlite_master WHERE type='table'").map((r) => r['name']).toSet();
      if (!tables.containsAll(['books', 'reads'])) return const RestoreCheck.fail('This is not a Pagemark database.');
      final ver = d.select('PRAGMA user_version').first.values.first as int;
      if (ver > AppDb.currentSchema) {
        return RestoreCheck.fail('This backup is from a newer Pagemark (schema $ver). Update the app first.');
      }
      final b = d.select('SELECT COUNT(*) c FROM books').first['c'] as int;
      final r = d.select('SELECT COUNT(*) c FROM reads').first['c'] as int;
      return RestoreCheck.pass(b, r);
    } catch (e) {
      return const RestoreCheck.fail('This file is not a readable Pagemark database.');
    } finally {
      d?.close();
    }
  }

  /// Make [src] (already decrypted) the live database. Validates first, keeps a safety copy of the
  /// current library (newest 3 kept in app storage), swaps files, and leaves the app needing a restart.
  static Future<File> restoreDb(AppDb db, File src) async {
    final check = inspect(src);
    if (!check.ok) throw check.message;
    final dest = await AppDb.file();
    final dir = dest.parent;
    final safety = await snapshotDb(db, name: 'pagemark-prerestore.sqlite');
    final kept = File('${dir.path}/pre-restore-${_stamp()}.sqlite');
    await safety.copy(kept.path);
    await safety.delete();
    final old = dir.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('pre-restore-')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(3)) {
      await f.delete();
    }
    await db.close();
    final staged = File('${dest.path}.incoming');
    await src.copy(staged.path);
    for (final ext in ['-wal', '-shm']) {
      final side = File('${dest.path}$ext');
      if (await side.exists()) await side.delete();
    }
    await staged.rename(dest.path);
    return kept;
  }
}
