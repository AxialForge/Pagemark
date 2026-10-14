import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:archive/archive_io.dart';
import 'covers.dart';
import 'crypto_backup.dart';
import 'db.dart';

class RestoreCheck {
  final bool ok;
  final String message;
  final int books, reads, lockedBooks, covers;
  const RestoreCheck.fail(this.message) : ok = false, books = 0, reads = 0, lockedBooks = 0, covers = 0;
  const RestoreCheck.pass(this.books, this.reads, {this.lockedBooks = 0, this.covers = 0}) : ok = true, message = 'ok';
}

/// A restore candidate opened for inspection. [db] is always a plain sqlite file; [dir] is a temp folder to delete.
class Unpacked {
  final File db;
  final Directory? covers, dir;
  Unpacked(this.db, this.covers, this.dir);
  Future<void> cleanup() async {
    try {
      if (dir != null && await dir!.exists()) await dir!.delete(recursive: true);
    } catch (_) {}
  }
}

class Exporter {
  /// Export format version, written into JSON so future importers can tell files apart.
  static const formatVersion = 2; // 2 adds quotes (and optional heat / content notes)

  /// Tests point exports at a temp folder (the path plugin has no implementation on the test VM).
  static Directory? debugTmp;

  static Future<File> _tmp(String name) async => File('${(debugTmp ?? await getTemporaryDirectory()).path}/$name');

  static String _stamp({bool seconds = false}) {
    final n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${p(n.month)}${p(n.day)}-${p(n.hour)}${p(n.minute)}${seconds ? p(n.second) : ''}';
  }

  /// Spreadsheet apps execute cells that start with = + - @ ; neutralise them.
  static Object? safeCell(Object? v) {
    if (v is String && v.isNotEmpty && '=+-@\t\r'.contains(v[0])) return "'$v";
    return v;
  }

  /// Quotes of the same books [rows] would export, keyed by title/author/ISBN so an import can match them to books.
  static Future<List<Map<String, Object?>>> quoteRows(AppDb db, {bool includeLocked = false}) async {
    final books = {for (final b in await (db.select(db.books)..where((b) => b.deletedAt.isNull())).get()) b.id: b};
    final out = <Map<String, Object?>>[];
    for (final q in await db.select(db.quotes).get()) {
      final b = books[q.bookId];
      if (b == null || (b.locked && !includeLocked)) continue;
      out.add({'title': b.title, 'author': b.author, 'isbn': b.isbn, 'quote': q.body, 'page': q.page, 'note': q.note, 'rating': q.rating, 'created': q.created.toIso8601String()});
    }
    return out;
  }

  static Future<List<Map<String, Object?>>> rows(AppDb db, {bool includeLocked = false, bool includePrivateFields = false}) async {
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
          'series_total': b.seriesTotal, 'series_number': b.seriesNumber, 'description': b.description,
          'rating_story': r?.ratingStory, 'rating_characters': r?.ratingCharacters, 'rating_writing': r?.ratingWriting,
          'rating_pace': r?.ratingPace, 'rating_feeling': r?.ratingFeeling, 'rating_narrator': r?.ratingNarrator,
          if (includePrivateFields) ...{'heat': r?.heat, 'content_notes': r?.contentNotes},
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

  /// Set by the app: called after something was saved or shared (restarts the "time to back up" countdown).
  static Future<void> Function()? onSaved;

  static Future<void> _share(File f, String mime) async {
    final r = await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: mime)]));
    if (r.status != ShareResultStatus.dismissed) await onSaved?.call();
  }

  static Future<void> shareCsv(AppDb db, {bool includePrivateFields = false}) async {
    final f = await _tmp('pagemark-library-${_stamp()}.csv');
    await f.writeAsString(toCsv(await rows(db, includePrivateFields: includePrivateFields)));
    await _share(f, 'text/csv');
  }

  static Future<void> shareJson(AppDb db, {bool includePrivateFields = false}) async {
    final f = await _tmp('pagemark-library-${_stamp()}.json');
    final doc = {
      'pagemark_export': formatVersion, 'exported': DateTime.now().toIso8601String(),
      'books': await rows(db, includePrivateFields: includePrivateFields), 'quotes': await quoteRows(db),
    };
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

  /// The sqlite snapshot plus the saved covers: a zip (`pagemark.sqlite` + `covers/*`) when there are covers, otherwise just
  /// the snapshot. Backups and database exports use this so covers come back after a restore.
  static Future<File> bundle(File sqlite, {required String baseName}) async {
    final covers = await CoverStore.allFiles();
    if (covers.isEmpty) return sqlite;
    final out = await _tmp('$baseName.zip');
    if (await out.exists()) await out.delete();
    final z = ZipFileEncoder()..create(out.path);
    await z.addFile(sqlite, 'pagemark.sqlite');
    for (final c in covers) {
      await z.addFile(c, 'covers/${c.uri.pathSegments.last}');
    }
    await z.close();
    await sqlite.delete();
    return out;
  }

  static Future<bool> isZip(File f) async {
    final raf = await f.open();
    try {
      final h = await raf.read(4);
      return h.length == 4 && h[0] == 0x50 && h[1] == 0x4B && h[2] == 3 && h[3] == 4;
    } finally {
      await raf.close();
    }
  }

  /// Opens a restore candidate: a plain sqlite file, or a bundle zip. Only the database and plain-named cover files are
  /// ever extracted (anything else in the zip, or any path trickery, is ignored). Caller deletes [Unpacked.dir] when done.
  static const maxDbBytes = 500 * 1024 * 1024, maxCoverBytes = 25 * 1024 * 1024, maxUnpackBytes = 1024 * 1024 * 1024;

  static Future<Unpacked> unpack(File f) async {
    if (!await isZip(f)) return Unpacked(f, null, null);
    final tmp = await Directory.systemTemp.createTemp('pgm-unpack');
    final input = InputFileStream(f.path);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(input);
    } catch (_) {
      await input.close();
      await tmp.delete(recursive: true);
      throw 'This backup file could not be opened (it may be damaged).';
    }
    File? dbFile;
    Directory? covers;
    var total = 0;
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final isDb = entry.name == 'pagemark.sqlite';
      final n = entry.name.startsWith('covers/') ? entry.name.substring(7) : null;
      if (!isDb && !(n != null && CoverStore.safeName(n))) continue; // ignored entries are never decompressed
      if (entry.size > (isDb ? maxDbBytes : maxCoverBytes) || (total += entry.size) > maxUnpackBytes) {
        await input.close();
        await tmp.delete(recursive: true);
        throw 'This backup is larger than Pagemark expects, so it was not opened.';
      }
      final bytes = entry.readBytes();
      if (bytes == null) continue;
      if (isDb) {
        dbFile = await File('${tmp.path}/pagemark.sqlite').writeAsBytes(bytes);
      } else {
        covers ??= await Directory('${tmp.path}/covers').create();
        await File('${covers.path}/$n').writeAsBytes(bytes);
      }
    }
    await input.close(); // release the file handle (Windows cannot delete an open file)
    if (dbFile == null) {
      await tmp.delete(recursive: true);
      throw 'This backup file does not contain a Pagemark library.';
    }
    return Unpacked(dbFile, covers, tmp);
  }

  /// Like [inspect] but understands bundles, and reports how many covers come with it.
  static Future<RestoreCheck> inspectBackup(File f) async {
    Unpacked? u;
    try {
      u = await unpack(f);
      final c = inspect(u.db);
      if (!c.ok) return c;
      final n = u.covers == null ? 0 : u.covers!.listSync().length;
      return RestoreCheck.pass(c.books, c.reads, lockedBooks: c.lockedBooks, covers: n);
    } catch (e) {
      return RestoreCheck.fail(e is String ? e : 'This file is not a readable Pagemark backup.');
    } finally {
      await u?.cleanup();
    }
  }

  /// Share the whole database; with [passphrase] it is encrypted first.
  static Future<void> shareDb(AppDb db, {String? passphrase}) async {
    final base = 'pagemark-db-${_stamp()}';
    final file = await bundle(await snapshotDb(db, name: '$base.sqlite'), baseName: base);
    if (passphrase == null || passphrase.isEmpty) {
      await _share(file, file.path.endsWith('.zip') ? 'application/zip' : 'application/vnd.sqlite3');
      return;
    }
    final enc = await BackupCrypto.encrypt(file, await _tmp('$base.pgbak'), passphrase);
    await file.delete();
    await _share(enc, 'application/octet-stream');
  }

  /// Open the candidate read-only and check it really is a healthy Pagemark database.
  static RestoreCheck inspect(File f) {
    sql.Database? d;
    try {
      d = sql.sqlite3.open(f.path, mode: sql.OpenMode.readOnly);
      final integrity = d.select('PRAGMA integrity_check').first.values.first;
      if (integrity != 'ok') return RestoreCheck.fail('This backup file is damaged.');
      final tables = d.select("SELECT name FROM sqlite_master WHERE type='table'").map((r) => r['name']).toSet();
      if (!tables.containsAll(['books', 'reads'])) return const RestoreCheck.fail('This is not a Pagemark backup.');
      final ver = d.select('PRAGMA user_version').first.values.first as int;
      Set<Object?> cols(String t) => d!.select('PRAGMA table_info($t)').map((r) => r['name']).toSet();
      if (ver < 1 || !cols('books').containsAll(['id', 'title']) || !cols('reads').containsAll(['id', 'book_id', 'status'])) {
        return const RestoreCheck.fail('This is not a Pagemark backup.');
      }
      if (ver > AppDb.currentSchema) {
        return RestoreCheck.fail('This backup was made by a newer version of Pagemark. Update the app first.');
      }
      final b = d.select('SELECT COUNT(*) c FROM books').first['c'] as int;
      final r = d.select('SELECT COUNT(*) c FROM reads').first['c'] as int;
      var l = 0;
      try {
        l = d.select('SELECT COUNT(*) c FROM books WHERE locked = 1').first['c'] as int;
      } catch (_) {/* very old/odd file without the column: just don't mention the vault */}
      return RestoreCheck.pass(b, r, lockedBooks: l);
    } catch (e) {
      return const RestoreCheck.fail('This file is not a readable Pagemark backup.');
    } finally {
      d?.close();
    }
  }

  /// A restore point of the live library before something big (restore, import): kept in app storage, newest 3 per [tag].
  static Future<File> safetyCopy(AppDb db, String tag) async {
    final dir = (await AppDb.file()).parent;
    final snap = await snapshotDb(db, name: 'pagemark-$tag.sqlite');
    final kept = File('${dir.path}/$tag-${_stamp(seconds: true)}.sqlite');
    await snap.copy(kept.path);
    await snap.delete();
    final old = dir.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('$tag-')).toList()..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(3)) {
      await f.delete();
    }
    return kept;
  }

  /// Restore points kept in app storage (before a restore or an import), newest first.
  static Future<List<File>> restorePoints() async {
    final dir = (await AppDb.file()).parent;
    final all = dir.listSync().whereType<File>().where((f) {
      final n = f.uri.pathSegments.last;
      return n.endsWith('.sqlite') && (n.startsWith('pre-restore-') || n.startsWith('pre-import-'));
    }).toList()
      ..sort((a, b) => b.uri.pathSegments.last.split('-').skip(2).join('-').compareTo(a.uri.pathSegments.last.split('-').skip(2).join('-')));
    return all;
  }

  /// Make [src] (already decrypted) the live database. Validates first, keeps a safety copy of the
  /// current library (newest 3 kept in app storage), swaps files, and leaves the app needing a restart.
  static Future<File> restoreDb(AppDb db, File original) async {
    final unpacked = await unpack(original);
    final src = unpacked.db;
    final check = inspect(src);
    if (!check.ok) {
      await unpacked.cleanup();
      throw check.message;
    }
    final dest = await AppDb.file();
    final dir = dest.parent;
    final safety = await snapshotDb(db, name: 'pagemark-prerestore.sqlite');
    final kept = File('${dir.path}/pre-restore-${_stamp(seconds: true)}.sqlite');
    await safety.copy(kept.path);
    await safety.delete();
    final old = dir.listSync().whereType<File>().where((f) => f.uri.pathSegments.last.startsWith('pre-restore-')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(3)) {
      await f.delete();
    }
    if (unpacked.covers != null && CoverStore.ready) {
      try {
        await CoverStore.importFrom(unpacked.covers!); // before the swap: a failure here can no longer leave a half-restored library
      } catch (_) {/* covers can be re-downloaded; never block the restore on them */}
    }
    await db.close();
    final staged = File('${dest.path}.incoming');
    await src.copy(staged.path);
    for (final ext in ['-wal', '-shm']) {
      final side = File('${dest.path}$ext');
      if (await side.exists()) await side.delete();
    }
    await staged.rename(dest.path);
    await unpacked.cleanup();
    return kept;
  }
}
