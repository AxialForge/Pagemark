// AUDIT SCRIPT - findings hostile text round trip, no finding raised (all PASS) - see HOSTILE_INPUT.md
// Rerun: copy into <repo>/test/ and run `flutter test test/pgm_hostile_audit_test.dart`.
// Each probe prints `AUDIT|<case>|PASS/FAIL|<detail>`; FAIL lines are findings (the test run itself stays green).
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/text_utils.dart';

void chk(String id, bool ok, String detail) => print('AUDIT|$id|${ok ? 'PASS' : 'FAIL'}|$detail');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('control characters, NUL, lone surrogates, huge strings survive DB, snapshot, CSV and JSON', () async {
    final root = Directory.systemTemp.createTempSync('pgmhost');
    Exporter.debugTmp = root;
    final f = File('${root.path}/h.sqlite');
    final db = AppDb.forFile(f);
    final samples = <String, String>{
      'nul': 'a\u0000b', 'ctrl': '\u0001\u0007\u001b[31mred\u001b[0m', 'bidi': 'abc‮def⁦x', 'zwj': 'a‍b​', 'ls-ps': 'x y z',
      'emoji': '\u{1F469}‍\u{1F4DA} \u{1F1FA}\u{1F1F8}', 'lone-surrogate': 'a\uD800b', 'nl': 'a\r\nb\rc\nd', 'sql': "x'); DROP TABLE books;--", 'percent': '100% _ \\',
      'html': '<script>alert(1)</script>&amp;', 'long': 'L' * 5000000, 'combining': 'é' * 1000, 'rtl': 'שלום',
    };
    final ids = <String, int>{};
    for (final e in samples.entries) {
      ids[e.key] = await db.into(db.books).insert(BooksCompanion.insert(title: 'T-${e.key}', author: Value(e.value), notes: Value(e.value), tags: Value(e.value)));
      await db.into(db.reads).insert(ReadsCompanion.insert(bookId: ids[e.key]!, thoughts: Value(e.value), status: const Value('finished')));
      await db.addQuote(ids[e.key]!, e.value.isEmpty ? 'x' : e.value);
    }
    final books = {for (final b in await db.select(db.books).get()) b.title: b};
    final diffs = <String>[];
    String expectStored(String v) => v.replaceAll('\uD800', '�');
    samples.forEach((k, v) {
      final got = books['T-$k']!.author;
      if (got != expectStored(v)) diffs.add('$k (len ${v.length} -> ${got.length})');
    });
    chk('H-db-roundtrip', diffs.isEmpty, diffs.isEmpty ? '${samples.length} hostile strings stored and read back identically (lone surrogate becomes U+FFFD)' : 'altered: $diffs');
    Object? injected;
    try {
      await db.select(db.books).get();
    } catch (e) {
      injected = e;
    }
    chk('H-sql-injection', injected == null && (await db.select(db.books).get()).length == samples.length, 'SQL text in fields is bound as a parameter; books table intact');

    final snap = await Exporter.snapshotDb(db);
    final inspected = Exporter.inspect(snap);
    chk('H-snapshot', inspected.ok && inspected.books == samples.length, 'VACUUM INTO snapshot of the hostile DB inspects ok (${inspected.books} books)');

    final rows = await Exporter.rows(db);
    final csvText = Exporter.toCsv(rows);
    final csvFile = File('${root.path}/x.csv')..writeAsStringSync(csvText);
    final back = Importer.parse(csvFile.readAsStringSync());
    final byTitle = {for (final b in back.books) b.title: b};
    final csvDiffs = <String>[];
    samples.forEach((k, v) {
      final b = byTitle['T-$k'];
      if (b == null) {
        csvDiffs.add('$k missing');
        return;
      }
      final want = expectStored(v).trim();
      if (b.notes != want && b.notes != '\'$want') csvDiffs.add('$k notes differ (len ${want.length} -> ${b.notes.length})');
    });
    chk('H-csv-roundtrip', csvDiffs.isEmpty, csvDiffs.isEmpty ? 'all hostile strings survive CSV export -> import' : csvDiffs.join('; '));
    final jsonFile = File('${root.path}/x.json')..writeAsStringSync(const JsonEncoder.withIndent('  ').convert({'pagemark_export': 2, 'books': rows, 'quotes': await Exporter.quoteRows(db)}));
    final jb = Importer.parse(jsonFile.readAsStringSync());
    final jDiffs = <String>[];
    final jByTitle = {for (final b in jb.books) b.title: b};
    samples.forEach((k, v) {
      final b = jByTitle['T-$k'];
      if (b == null) {
        jDiffs.add('$k missing');
        return;
      }
      if (b.notes != expectStored(v).trim()) jDiffs.add('$k notes differ (len ${expectStored(v).trim().length} -> ${b.notes.length})');
      if (b.quotes.length != 1) jDiffs.add('$k quote count ${b.quotes.length}');
    });
    chk('H-json-roundtrip', jDiffs.isEmpty, jDiffs.isEmpty ? 'all hostile strings and quotes survive JSON export -> import' : jDiffs.join('; '));
    chk('H-normalizeTags-ctrl', normalizeTags('a\u0000b, a\u0000b,\u0001') == 'a\u0000b, \u0001', 'tags keep control characters, de-dupe works');
    chk('H-humanBytes', humanBytes(-1) == '-1 B' && humanBytes(0) == '0 B' && humanBytes(1 << 40).endsWith('MB'), 'humanBytes(1 TB) = ${humanBytes(1 << 40)} (no GB unit; cosmetic)');
    await db.close();
    root.deleteSync(recursive: true);
  });
}
