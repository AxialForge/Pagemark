// AUDIT SCRIPT - findings PGM-101 PGM-109 PGM-112 PGM-113 PGM-116 PGM-117 PGM-118 PGM-119 PGM-120 PGM-121 PGM-122 PGM-123 PGM-124 PGM-129 PGM-132 (engine: lockout, importer, round trip, updater, lookup, misc logic)
// Rerun: copy into <repo>/test/ and run `flutter test test/pgm_engine_audit_test.dart` (takes ~1-2 min: PBKDF2 + 10k-row import).
// Each probe prints `AUDIT|<case>|PASS/FAIL|<detail>`; FAIL lines are findings (the test run itself stays green).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' show DetailedApiRequestError;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pagemark/app_lock.dart';
import 'package:pagemark/backup_errors.dart';
import 'package:pagemark/crypto_backup.dart';
import 'package:pagemark/db.dart';
import 'package:pagemark/export.dart';
import 'package:pagemark/features.dart';
import 'package:pagemark/importer.dart';
import 'package:pagemark/isbn.dart';
import 'package:pagemark/lock.dart';
import 'package:pagemark/lookup.dart';
import 'package:pagemark/text_utils.dart';
import 'package:pagemark/updater.dart';

void chk(String id, bool ok, String detail) => print('AUDIT|$id|${ok ? 'PASS' : 'FAIL'}|$detail');

Future<String> outcome(FutureOr<Object?> Function() f) async {
  try {
    await f();
    return 'ok';
  } on ImportException {
    return 'ImportException';
  } catch (e) {
    return 'OTHER:${e.runtimeType}';
  }
}

String isbn13(String body12) {
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(body12[i]) * (i.isEven ? 1 : 3);
  }
  return '$body12${(10 - sum % 10) % 10}';
}

String isbn10(String body9) {
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += int.parse(body9[i]) * (10 - i);
  }
  final c = (11 - sum % 11) % 11;
  return '$body9${c == 10 ? 'X' : c}';
}

const pmHeader = 'title,author,isbn,genre,series,publisher,year,pages,tags,notes,locked,format,status,started,finished,rating,thoughts,narrator,minutes,series_total';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Isbn property tests (seed 42)', () {
    test('checksums, idempotence, X check digit, single-digit errors', () {
      final r = Random(42);
      var bad = 0, xCount = 0, undetected = 0;
      String digits(int n) => List.generate(n, (_) => r.nextInt(10)).join();
      for (var i = 0; i < 5000; i++) {
        final b13 = isbn13('978${digits(9)}');
        if (!Isbn.isValid13(b13) || Isbn.to13(b13) != b13 || Isbn.to13(Isbn.to13(b13)!) != b13) bad++;
        final b10 = isbn10(digits(9));
        if (b10.endsWith('X')) xCount++;
        final c = Isbn.to13(b10);
        if (!Isbn.isValid10(b10) || c == null || !Isbn.isValid13(c) || Isbn.to13(c) != c || !c.startsWith('978') || Isbn.to13(b10.toLowerCase()) != c) bad++;
        if (Isbn.to13('${b10.substring(0, 3)}-${b10.substring(3, 6)} ${b10.substring(6)}') != c) bad++;
        final pos = r.nextInt(13);
        final d = (int.parse(b13[pos]) + 1 + r.nextInt(9)) % 10;
        final mut = b13.substring(0, pos) + d.toString() + b13.substring(pos + 1);
        if (mut != b13 && Isbn.isValid13(mut)) undetected++;
      }
      chk('ISBN-property', bad == 0 && undetected == 0 && xCount > 100, 'bad=$bad single-digit-errors-undetected=$undetected X-check-digit samples=$xCount of 5000');
      final hostile = ['', ' ', '978-0-441-17271-9\u0000', '９７８０４４１１７２７１９', '٩٧٨٠٤٤١١٧٢٧١٩', '0441172717x', '97804411727190', '978044117271', 'X' * 10, '\n9780441172719\n', '9780441172719'.padRight(20000, '0')];
      final res = <String>[];
      for (final h in hostile) {
        try {
          Isbn.to13(h);
          Isbn.looksLikeBookCode(h);
        } catch (e) {
          res.add('${e.runtimeType} for "${h.length > 20 ? h.substring(0, 20) : h}"');
        }
      }
      chk('ISBN-hostile', res.isEmpty, 'no exception for empty/NUL/fullwidth/Arabic-Indic/20k-char inputs ${res.join('; ')}');
      chk('ISBN-newline-trim', Isbn.to13('\n9780441172719\n') == '9780441172719', 'surrounding newlines are stripped by clean()');
    });
  });

  group('Lookup parsing', () {
    setUp(() => Lookup.retryDelay = Duration.zero);
    tearDown(() => Lookup.client = http.Client());

    Future<String> search(Object? body, {int status = 200, Map<String, String>? headers, List<int>? bytes}) async {
      Lookup.client = MockClient((_) async => bytes != null ? http.Response.bytes(bytes, status) : http.Response(body is String ? body : jsonEncode(body), status, headers: headers ?? const {}));
      return outcome(() => Lookup.search('x'));
    }

    test('search shapes', () async {
      final cases = <String, Object?>{
        'list-top-level': [1, 2], 'null': null, 'docs-map': {'docs': {}}, 'docs-string': {'docs': 'x'},
        'doc-is-int': {'docs': [1, 'a', null, []]}, 'title-int': {'docs': [{'title': 5}]},
        'author-string': {'docs': [{'title': 'T', 'author_name': 'Solo'}]}, 'isbn-ints': {'docs': [{'title': 'T', 'isbn': [1, 2, null]}]},
        'cover-obj': {'docs': [{'title': 'T', 'cover_i': {'a': 1}}]}, 'year-text': {'docs': [{'title': 'T', 'first_publish_year': 'abc'}]},
        'year-huge': {'docs': [{'title': 'T', 'first_publish_year': 1e30}]}, 'pages-neg': {'docs': [{'title': 'T', 'number_of_pages_median': -5}]},
        'subject-mixed': {'docs': [{'title': 'T', 'subject': [1, null, 'x' * 100, 'Fiction', 'ok']}]},
      };
      final bad = <String>[];
      for (final e in cases.entries) {
        final o = await search(e.value);
        if (o != 'ok') bad.add('${e.key}=$o');
      }
      chk('L-search-shapes', bad.isEmpty, 'every malformed Open Library shape returns a list or LookupException; offenders: $bad');
      final o = await search(null, bytes: [0xff, 0xfe, 0xfd]);
      chk('L-search-invalid-utf8', o == 'ok' || o == 'OTHER:LookupException', 'invalid UTF-8 body -> $o (UI catches everything; message becomes generic "Lookup failed")');
      chk('L-search-html-200', (await search('<html>captive portal</html>')).startsWith('OTHER:FormatException'), 'HTML (captive portal) with 200 -> FormatException surfaced as generic UI message');
      final sw = Stopwatch()..start();
      final huge = jsonEncode({'docs': List.generate(60000, (i) => {'title': 'Book $i', 'author_name': ['A$i'], 'subject': List.generate(20, (j) => 's$j')})});
      final o2 = await search(huge);
      chk('L-search-huge', sw.elapsedMilliseconds < 8000, '${huge.length ~/ 1024} KB / 60000 docs parsed in ${sw.elapsedMilliseconds} ms -> $o2');
    });

    test('byIsbn shapes, description, retry termination', () async {
      Lookup.client = MockClient((_) async => http.Response('{"ISBN:9780441172719": {"title": "T", "number_of_pages": 1e999}}', 200));
      final o = await outcome(() => Lookup.byIsbn('9780441172719'));
      print('INFO byIsbn with number_of_pages=1e999 (JSON Infinity) -> $o (not guarded by the try/catch that _parseDoc has)');
      chk('L-byIsbn-infinity-pages', o == 'ok', 'byIsbn with non-finite number_of_pages -> $o');
      Lookup.client = MockClient((_) async => http.Response(jsonEncode({'ISBN:9780441172719': {'title': 5, 'authors': 'x', 'works': 'x', 'cover': 'x', 'publish_date': null}}), 200));
      final m = await Lookup.byIsbn('9780441172719');
      chk('L-byIsbn-wrong-types', m != null, 'wrong-typed fields give an (empty-title) result instead of falling back: title="${m?.title}" -> adds a nameless suggestion');
      Lookup.client = MockClient((_) async => http.Response('{}', 200));
      chk('L-byIsbn-empty', await outcome(() => Lookup.byIsbn('9780441172719')) == 'ok', 'empty object -> falls back to search');
      chk('L-byIsbn-bad-isbn', await outcome(() => Lookup.byIsbn('123')) == 'OTHER:LookupException', 'invalid ISBN -> LookupException');
      var calls = 0;
      Lookup.client = MockClient((_) async {
        calls++;
        return http.Response('busy', 503);
      });
      final o3 = await outcome(() => Lookup.search('x'));
      chk('L-retry-503', calls == 3 && o3 == 'OTHER:LookupException', '503 retried $calls times then LookupException');
      calls = 0;
      Lookup.client = MockClient((_) async {
        calls++;
        throw TimeoutException('t');
      });
      await outcome(() => Lookup.search('x'));
      chk('L-retry-timeout', calls == 3, 'timeouts retried $calls times (worst case in production: 3 x 12 s + 0.7 s + 1.4 s = about 38 s before the error shows)');
      calls = 0;
      Lookup.client = MockClient((_) async {
        calls++;
        return http.Response('no', 404);
      });
      await outcome(() => Lookup.search('x'));
      chk('L-no-retry-404', calls == 1, '404 is not retried');
      Lookup.client = MockClient((_) async => http.Response(jsonEncode({'description': {'value': 5}}), 200));
      chk('L-description-shape', await Lookup.description('/works/OL1W') == '', 'weird description shape -> empty');
      chk('L-description-bad-key', await Lookup.description('../../etc') == '', 'non /works/ key ignored');
    });
  });

  group('Importer', () {
    test('numeric / date edge values in cells', () {
      for (final v in ['NaN', 'Infinity', '-Infinity', '1e400', '1e30', '-5', '0', '3.14159', '1,234', 'abc']) {
        String o;
        try {
          Importer.parse('$pmHeader\nT,A,,,,,,,,,,print,finished,,,$v,,,,\n');
          o = 'ok';
        } catch (e) {
          o = '${e.runtimeType}';
        }
        String o2;
        try {
          Importer.parse('$pmHeader\nT,A,,,,,$v,,,,,print,finished,,,,,,,\n');
          o2 = 'ok';
        } catch (e) {
          o2 = '${e.runtimeType}';
        }
        chk('IM-cell[$v]', o == 'ok' && o2 == 'ok', 'rating cell -> $o ; year cell -> $o2 (a single odd cell must not reject the whole file)');
      }
    });

    test('dates', () {
      final cases = {
        '2024-02-29': '2024-02-29', '2023-02-29': 'null', '2023-02-30': 'null', '02/29/2023': 'null', '5/14/2023': '2023-05-14', '14/05/2023': 'null',
        '2023-13-01': 'null', '2023-1-5': '2023-01-05', '2023/05/14 10:00': '2023-05-14', '0000-00-00': 'null', '0001-01-01': '0001-01-01', '9999-12-31': '9999-12-31',
        '2023-05-14T23:30:00-08:00': '2023-05-14', '2023-05-14T23:30:00Z': '2023-05-14', '20230514': 'x', '2023': 'x', '99999-01-01': 'x',
      };
      final out = <String>[];
      final wrong = <String>[];
      cases.forEach((k, v) {
        final d = Importer.parseDate(k);
        final got = d == null ? 'null' : d.toIso8601String().substring(0, 10);
        out.add('$k -> $got');
        if (v != 'x' && v != got) wrong.add('$k expected $v got $got');
      });
      print('INFO dates: ${out.join(' | ')}');
      chk('IM-dates', wrong.isEmpty, wrong.isEmpty ? 'date table as expected' : wrong.join('; '));
      final far = Importer.parseDate('9999-12-31');
      chk('IM-date-absurd-year', far == null, 'ISO dates bypass the 1900..next-year sanity window used for slash dates: "9999-12-31" and "0001-01-01" are accepted (${far?.year})');
    });

    test('formats: BOM, CRLF, embedded newlines/quotes, unicode, control characters', () {
      final rows = [
        ['Title, with "quotes" and\nnewline', 'Au\tthor', '', 'g', '', '', '', '', 'tag1;tag2', 'line1\r\nline2', 'false', 'print', 'finished', '2024-01-05', '2024-02-01', '4.5', 'thoughts \u{1F600} שלום', '', '', ''],
      ];
      String build(String nl, {bool bom = false}) {
        final esc = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join(nl);
        return '${bom ? '﻿' : ''}$pmHeader$nl$esc$nl';
      }

      for (final nl in ['\n', '\r\n']) {
        for (final bom in [false, true]) {
          final p = Importer.parse(build(nl, bom: bom));
          final b = p.books.single;
          chk('IM-format[nl=${nl == '\n' ? 'LF' : 'CRLF'},bom=$bom]', b.title == 'Title, with "quotes" and\nnewline' && b.reads.single.rating == 4.5 && b.reads.single.thoughts.contains('\u{1F600}') && p.source == ImportSource.pagemarkCsv, 'source=${p.source.name} title="${b.title.replaceAll('\n', '\\n')}"');
        }
      }
      final p2 = Importer.parse('$pmHeader\n"unterminated,x,,,,,,,,,,print,finished,,,,,,,\n');
      print('INFO unterminated quote -> books=${p2.books.length} skipped=${p2.skipped.length}');
      final p3 = Importer.parse('$pmHeader\nT,A\nT2\n,\n"",,,,,,,,,,,,,,,,,,,\n');
      chk('IM-ragged-rows', p3.books.length == 2 && p3.skipped.isEmpty, 'ragged rows padded; blank rows ignored; books=${p3.books.length}');
      final p4 = Importer.parse('title,status,format\nOnly,finished,audio\n');
      chk('IM-missing-columns', p4.books.single.reads.single.format == 'audio', 'minimal 3-column Pagemark CSV imports');
      final p5 = Importer.parse('format,status,title,author\nprint,want,Reordered,Z\n');
      chk('IM-reordered-columns', p5.books.single.title == 'Reordered' && p5.books.single.author == 'Z', 'columns in another order are matched by name');
      final p6 = Importer.parse('$pmHeader\nA,x,,,,,,,,,,print,finished,,,,,,,\nB,x,,,,,,,,,,print,finished,,,,,,,\n'.replaceAll('x', 'X'));
      chk('IM-same-author-different-titles', p6.books.length == 2, 'distinct titles kept');
      final dupIsbn = Importer.parse('$pmHeader\nBook One,A,9780441172719,,,,,,,,,print,finished,,,,,,,\nBook Two,B,9780441172719,,,,,,,,,print,finished,,,,,,,\n');
      chk('IM-same-isbn-different-books', dupIsbn.books.length == 2 && dupIsbn.skipped.isEmpty, 'two different titles sharing an ISBN: books after parse=${dupIsbn.books.length} (merged silently into first, 2nd title lost, skipped list empty)');
      final ctrl = Importer.parse('$pmHeader\n"T\u0000itle\u0001",A,,,,,,,,,,print,finished,,,,,,,\n');
      print('INFO NUL/control chars in title survive parse: ${ctrl.books.single.title.codeUnits.take(8).toList()}');
      final long = Importer.parse('$pmHeader\n${'T' * 2000000},A,,,,,,,,,,print,finished,,,,,,,\n');
      chk('IM-2MB-title', long.books.single.title.length == 2000000, '2 MB title parsed (no length cap anywhere)');
    });

    test('Goodreads / StoryGraph shapes', () {
      const gr = 'Book Id,Title,Author,ISBN,ISBN13,My Rating,Publisher,Binding,Number of Pages,Original Publication Year,Year Published,Date Read,Date Added,Bookshelves,Exclusive Shelf,My Review\n';
      final p = Importer.parse('$gr'
          '1,Dune,Frank Herbert,"=""0441172717""","=""9780441172719""",5,Ace,Paperback,412,1965,1990,2023/05/14,2023/01/01,"sf, favs, read",read,"Great<br/>book"\n'
          '2,No Date,A,"","",0,P,Kindle Edition,,,,,2022/03/04,,read,\n'
          '3,Wish,A,"","",0,P,Audio CD,,,,,,,to-read,\n'
          '4,Weird,A,"","",9,P,Hardcover,abc,,,,,,currently-reading,\n'
          '5,Unknown shelf,A,"","",3,P,,,,,,,,custom,\n');
      final b = p.books;
      chk('IM-goodreads-basic', b[0].isbn == '9780441172719' && b[0].reads.single.rating == 5 && b[0].shelves.contains('sf') && b[0].reads.single.thoughts == 'Great\nbook' && b[0].reads.single.finished == DateTime(2023, 5, 14), 'wrapped ISBN, shelves, <br/>, date ok');
      print('INFO read-shelf book with empty Date Read gets finished = Date Added (${b[1].reads.single.finished}); unknown shelf -> no read row (${b[4].reads.length}); rating 9 -> ${b[3].reads.single.rating}');
      chk('IM-goodreads-invented-finish-date', b[1].reads.single.finished == null, 'a book on the "read" shelf with no Date Read is given a finish date equal to the Date Added (a date the user never entered) and counts in that year');
      const sg = 'Title,Authors,Contributors,ISBN/UID,Format,Read Status,Date Added,Last Date Read,Dates Read,Read Count,Moods,Pace,Character- or Plot-Driven?,Strong Character Development?,Loveable Characters?,Diverse Characters?,Flawed Characters?,Star Rating,Review,Content Warnings,Content Warning Description,Tags,Owned?\n';
      final s = Importer.parse('${sg}Dune,"Frank Herbert, Brian",,9780441172719,paperback,read,2023/01/01,2023/02/02,,1,,,,,,,,4.25,"ok",,,"a;b",Yes\n');
      chk('IM-storygraph-basic', s.books.single.reads.single.rating == 4.5 && s.books.single.author == 'Frank Herbert', 'rating 4.25 -> ${s.books.single.reads.single.rating}; tags ${s.books.single.tags}');
    });

    test('JSON shapes', () {
      final cases = <String, String>{
        'books-not-list': '{"pagemark_export":2,"books":5}', 'quotes-garbage': '{"pagemark_export":2,"books":[{"title":"A"}],"quotes":[1,"x",{"quote":5},{"title":"A","quote":"q","page":"x","created":"nope"}]}',
        'export-string': '{"pagemark_export":"99","books":[]}', 'export-double': '{"pagemark_export":9.5,"books":[]}', 'export-null-field': '{"pagemark_export":null,"books":[]}',
        'nested-values': '{"pagemark_export":2,"books":[{"title":{"x":1},"author":[1,2]}]}', 'row-not-map': '{"pagemark_export":2,"books":[1,null,"s"]}',
        'array-top': '[{"pagemark_export":2}]', 'empty': '', 'ws': '   ', 'brace': '{', 'huge-depth': '{"pagemark_export":2,"books":${'[' * 50000}${']' * 50000}}',
      };
      final res = <String, String>{};
      cases.forEach((k, v) {
        try {
          final p = Importer.parse(v);
          res[k] = 'ok(books=${p.books.length},quotes=${p.books.fold<int>(0, (a, b) => a + b.quotes.length)})';
        } on ImportException {
          res[k] = 'ImportException';
        } catch (e) {
          res[k] = 'OTHER:${e.runtimeType}';
        }
      });
      print('INFO JSON shapes: $res');
      final other = res.entries.where((e) => e.value.startsWith('OTHER')).toList();
      chk('IM-json-shapes', other.isEmpty, 'non-ImportException failures: $other');
      chk('IM-json-future-format-string', res['export-string']!.startsWith('ImportException'), 'pagemark_export given as string "99" / double 9.5 bypasses the "newer format" guard: ${res['export-string']} / ${res['export-double']}');
    });

    test('seeded fuzz: random bytes and mutated valid files never hang or throw foreign exceptions', () {
      final r = Random(1337);
      const gr = 'Book Id,Title,Author,ISBN,ISBN13,My Rating,Publisher,Binding,Number of Pages,Original Publication Year,Year Published,Date Read,Date Added,Bookshelves,Exclusive Shelf,My Review\n1,Dune,F,"=""0441172717""","=""9780441172719""",5,Ace,Paperback,412,1965,1990,2023/05/14,2023/01/01,"a, b",read,"x"\n';
      const sg = 'Title,Authors,ISBN/UID,Format,Read Status,Date Added,Last Date Read,Star Rating,Review,Content Warnings,Tags\nDune,F,9780441172719,paperback,read,2023/01/01,2023/02/02,4,ok,,"a;b"\n';
      final pm = '$pmHeader\nDune,F,9780441172719,sf,,,1965,412,a,"n",false,print,finished,2024-01-05,2024-02-01,4.5,"t",,,\n';
      final js = jsonEncode({'pagemark_export': 2, 'books': [{'title': 'Dune', 'author': 'F', 'status': 'finished', 'rating': 4.5}], 'quotes': [{'title': 'Dune', 'author': 'F', 'quote': 'q'}]});
      final seeds = [gr, sg, pm, js];
      final outcomes = <String, int>{};
      final slow = <String>[];
      final others = <String>{};
      String mutate(String s) {
        final b = utf8.encode(s).toList();
        for (var k = 0; k < 1 + r.nextInt(8); k++) {
          if (b.isEmpty) break;
          final i = r.nextInt(b.length);
          switch (r.nextInt(4)) {
            case 0:
              b[i] = r.nextInt(256);
            case 1:
              b.removeAt(i);
            case 2:
              b.insert(i, r.nextInt(256));
            default:
              b.insertAll(i, utf8.encode(['"', ',', '\n', '\r', '\u0000', "'=", '﻿', '{', '[', 'NaN', '1e999'][r.nextInt(11)]));
          }
        }
        return utf8.decode(b, allowMalformed: true);
      }

      var n = 0;
      for (var round = 0; round < 1200; round++) {
        final text = round % 3 == 0 ? utf8.decode(List.generate(r.nextInt(400), (_) => r.nextInt(256)), allowMalformed: true) : mutate(seeds[round % seeds.length]);
        final sw = Stopwatch()..start();
        String o;
        try {
          Importer.parse(text);
          o = 'ok';
        } on ImportException {
          o = 'ImportException';
        } catch (e) {
          o = 'OTHER:${e.runtimeType}';
          others.add(e.toString().split('\n').first);
        }
        if (sw.elapsedMilliseconds > 500) slow.add('${sw.elapsedMilliseconds}ms');
        outcomes[o.startsWith('OTHER') ? o : o] = (outcomes[o] ?? 0) + 1;
        n++;
      }
      print('INFO fuzz outcomes ($n inputs): $outcomes; foreign messages: ${others.take(5).toList()}');
      chk('IM-fuzz', outcomes.keys.every((k) => !k.startsWith('OTHER')) && slow.isEmpty, 'outcomes=$outcomes slow=${slow.length} sample=${others.take(3).toList()}');
    });

    test('10k-row import: parse + plan + run speed', () async {
      final sb = StringBuffer(pmHeader)..write('\n');
      for (var i = 0; i < 10000; i++) {
        sb.write('Book $i,Author ${i % 500},${isbn13('978${(100000000 + i).toString()}')},sf,,,${1900 + i % 120},${100 + i % 700},tag${i % 20},"note $i",false,print,finished,2024-01-05,2024-02-01,${(i % 10 + 1) / 2},"thoughts $i",,,\n');
      }
      final sw = Stopwatch()..start();
      final p = Importer.parse(sb.toString());
      final tParse = sw.elapsedMilliseconds;
      final db = AppDb.memory();
      final plan = await ImportRunner.plan(db, p);
      final res = await ImportRunner.run(db, plan, DuplicatePolicy.skip);
      final tAll = sw.elapsedMilliseconds;
      final t2 = Stopwatch()..start();
      final plan2 = await ImportRunner.plan(db, p);
      final tPlan2 = t2.elapsedMilliseconds;
      chk('IM-10k-rows', res.booksAdded == 10000 && tAll < 60000 && plan2.duplicates.length == 10000, 'parse ${tParse} ms, parse+plan+run ${tAll} ms, replan against full library ${tPlan2} ms; added=${res.booksAdded}');
      await db.close();
    });

    test('export -> import round trip fidelity (CSV and JSON)', () async {
      final db = AppDb.memory();
      final tricky = ['=1+1', '+SUM(A1)', '-5 pages', '@cmd', '\tTabbed', "'=already quoted", 'plain', 'Ünïcödé \u{1F4DA}', 'with "quotes", commas', 'multi\nline'];
      for (var i = 0; i < tricky.length; i++) {
        final id = await db.into(db.books).insert(BooksCompanion.insert(
            title: tricky[i], author: Value(tricky[(i + 1) % tricky.length]), isbn: const Value(''), genre: Value('g$i'), series: Value('S$i'), seriesNumber: Value(i + 0.5), seriesTotal: Value(i + 3),
            publisher: Value(tricky[(i + 2) % tricky.length]), year: Value(1990 + i), pages: Value(100 + i), tags: Value(tricky[(i + 3) % tricky.length]), notes: Value(tricky[(i + 4) % tricky.length]),
            description: const Value('DESC'), coverUrl: const Value('https://example.test/c.jpg')));
        await db.into(db.reads).insert(ReadsCompanion.insert(
            bookId: id, format: const Value('audio'), status: const Value('finished'), started: Value(DateTime(2024, 1, 5)), finished: Value(DateTime(2024, 2, 1)), rating: Value((i % 10 + 1) / 2),
            thoughts: Value(tricky[(i + 5) % tricky.length]), narrator: Value(tricky[(i + 6) % tricky.length]), minutes: Value(60 + i), currentPage: const Value(77)));
        await db.addQuote(id, tricky[(i + 7) % tricky.length], page: i + 1, note: tricky[(i + 8) % tricky.length]);
      }
      final rows = await Exporter.rows(db);
      for (final mode in ['csv', 'json']) {
        final text = mode == 'csv'
            ? Exporter.toCsv(rows)
            : jsonEncode({'pagemark_export': 2, 'books': rows, 'quotes': await Exporter.quoteRows(db)});
        final p = Importer.parse(text);
        final db2 = AppDb.memory();
        final plan = await ImportRunner.plan(db2, p);
        await ImportRunner.run(db2, plan, DuplicatePolicy.skip);
        final got = await db2.select(db2.books).get();
        final orig = await db.select(db.books).get();
        final lostFields = <String>{};
        final diffs = <String>[];
        String norm(String s) => s.trim();
        for (final o in orig) {
          final g = got.where((x) => x.title == o.title && x.author == o.author).firstOrNull;
          if (g == null) {
            diffs.add('book "${o.title}" by "${o.author}" missing/changed after round trip (title/author altered)');
            continue;
          }
          if (g.seriesNumber != o.seriesNumber) lostFields.add('series_number');
          if (g.description != o.description) lostFields.add('description');
          if (g.coverUrl != o.coverUrl) lostFields.add('cover');
          if (g.series != o.series) diffs.add('series ${o.series}->${g.series}');
          if (norm(g.notes) != norm(o.notes)) diffs.add('notes "${o.notes}"->"${g.notes}"');
          if (norm(g.tags) != norm(normalizeTags(o.tags))) diffs.add('tags "${o.tags}"->"${g.tags}"');
          if (g.seriesTotal != o.seriesTotal) diffs.add('series_total');
          if (g.publisher != o.publisher) diffs.add('publisher "${o.publisher}"->"${g.publisher}"');
          if (g.year != o.year || g.pages != o.pages) diffs.add('year/pages');
        }
        final reads = await db2.select(db2.reads).get();
        final origReads = await db.select(db.reads).get();
        if (reads.every((r) => r.currentPage == null) && origReads.any((r) => r.currentPage != null)) lostFields.add('current_page');
        for (final o in origReads) {
          final g = reads.where((r) => r.rating == o.rating && r.minutes == o.minutes).firstOrNull;
          if (g == null || g.finished != o.finished || g.started != o.started || g.format != o.format) diffs.add('read ${o.id} dates/rating/format changed');
        }
        final q = await db2.select(db2.quotes).get();
        if (mode == 'json' && q.length != tricky.length) diffs.add('quotes ${q.length}/${tricky.length}');
        if (mode == 'csv' && q.isNotEmpty) diffs.add('csv carries quotes?');
        chk('RT-$mode-text-fields', diffs.isEmpty, diffs.isEmpty ? 'all tricky text/date/rating fields survive' : diffs.take(6).join(' | '));
        chk('RT-$mode-lossless', lostFields.isEmpty, 'fields NOT carried by the export/import: ${lostFields.toList()..sort()}');
        await db2.close();
      }
      await db.close();
    });
  });

  group('Exporter / text helpers', () {
    test('safeCell and normalizeTags', () {
      final cases = {'=1': "'=1", '+1': "'+1", '-1': "'-1", '@a': "'@a", '\ta': "'\ta", '\ra': "'\ra", ' =1': ' =1', '': '', '|calc': '|calc', '%x': '%x', '\n=1': '\n=1', "'=1": "'=1"};
      final bad = <String>[];
      cases.forEach((k, v) {
        if (Exporter.safeCell(k) != v) bad.add(k);
      });
      chk('E-safeCell', bad.isEmpty, 'table of ${cases.length} cells; unexpected: $bad (leading-space and leading-newline formulas are not neutralised; Excel ignores space-led formulas, newline-led ones render as text)');
      chk('E-safeCell-types', Exporter.safeCell(null) == null && Exporter.safeCell(-5) == -5 && Exporter.safeCell(true) == true, 'non-strings untouched (negative numbers are numeric, not text)');
      final csvOut = Exporter.toCsv([{'a': '=HYPERLINK("http://x","y")', 'b': 'x'}]);
      chk('E-csv-formula', csvOut.contains("'=HYPERLINK"), 'formula cell prefixed in the CSV');
      chk('E-csv-empty', Exporter.toCsv([]).length >= 1, 'empty export is a BOM only, with no header row (an empty library exports a 0-column file)');
      final tags = {'': '', ',,,': '', 'a,A,a ': 'a', 'a;b\nc': 'a, b, c', ' x   y ': 'x y', 'İ,i̇': 'İ, i̇', 'Straße,STRASSE': 'Straße, STRASSE', ' a ': 'a'};
      final tb = <String>[];
      tags.forEach((k, v) {
        if (normalizeTags(k) != v) tb.add('"$k" -> "${normalizeTags(k)}" expected "$v"');
      });
      chk('E-normalizeTags', tb.isEmpty, tb.isEmpty ? 'tag table ok' : tb.join('; '));
      final sw = Stopwatch()..start();
      normalizeTags(List.generate(200000, (i) => 'tag${i % 5000}').join(','));
      chk('E-normalizeTags-speed', sw.elapsedMilliseconds < 3000, '200k tags in ${sw.elapsedMilliseconds} ms');
    });
  });

  group('versions and updater', () {
    test('compareVersions', () {
      final t = <List<Object>>[
        ['0.9.0', '0.10.0', -1], ['0.10.0', '0.9.9', 1], ['1.0', '1.0.0', 0], ['v1.2.3+5', '1.2.3', 0], ['1.2.3-beta', '1.2.3', 0], ['1.2.3.4', '1.2.3', 1],
        ['', '0.0.0', 0], ['abc', '0.0.1', -1], ['1..2', '1.0.2', 0], ['-1.0.0', '0.0.0', 0], ['2.0.0', '10.0.0', -1], ['0.7.0+10', '0.7.0', 0],
        ['99999999999999999999.0.0', '1.0.0', 1],
      ];
      final bad = <String>[];
      for (final c in t) {
        final got = compareVersions(c[0] as String, c[1] as String).sign;
        if (got != c[2]) bad.add('${c[0]} vs ${c[1]} expected ${c[2]} got $got');
      }
      chk('V-compareVersions', bad.isEmpty, bad.isEmpty ? '${t.length} cases ok' : bad.join('; '));
      print('INFO prerelease suffix is ignored: 1.2.3-beta == 1.2.3 (a GitHub release tagged v0.8.0-rc1 but not flagged prerelease would be offered as 0.8.0)');
    });

    test('check() JSON shapes and pickAsset', () async {
      Future<String> chkShape(Object? body, {int status = 200}) async {
        Updater.client = MockClient((_) async => http.Response(body is String ? body : jsonEncode(body), status));
        try {
          final i = await Updater.check(currentVersion: '0.7.0', abis: ['arm64-v8a']);
          return 'ok(latest=${i.latest},available=${i.available},asset=${i.assetName},notes=${i.notes.length})';
        } on UpdateException catch (e) {
          return 'UpdateException';
        } catch (e) {
          return 'OTHER:${e.runtimeType}';
        }
      }

      final shapes = <String, Object?>{
        'empty-list': [], 'map-error': {'message': 'Not Found'}, 'null': null, 'missing-tag': [{'name': 'x'}], 'tag-null-explicit': [{'tag_name': null}],
        'draft-only': [{'tag_name': 'v9.0.0', 'draft': true}], 'prerelease-only': [{'tag_name': 'v9.0.0', 'prerelease': true}],
        'assets-map': [{'tag_name': 'v0.8.0', 'assets': {}}], 'assets-string': [{'tag_name': 'v0.8.0', 'assets': 'x'}], 'assets-null': [{'tag_name': 'v0.8.0', 'assets': null}],
        'asset-name-int': [{'tag_name': 'v0.8.0', 'assets': [{'name': 5}, 7, null]}], 'asset-no-url': [{'tag_name': 'v0.8.0', 'assets': [{'name': 'pagemark-arm64.apk'}]}],
        'size-string': [{'tag_name': 'v0.8.0', 'assets': [{'name': 'pagemark-arm64.apk', 'size': '5', 'browser_download_url': 'https://x/a.apk', 'digest': 5}]}],
        'good': [{'tag_name': 'v0.8.0', 'name': 'x', 'body': null, 'published_at': 'bad', 'assets': [{'name': 'pagemark-arm64-v8a.apk', 'size': 5, 'browser_download_url': 'https://x/a.apk', 'digest': 'sha256:ABC'}]}],
        'name-body-int': [{'tag_name': 'v0.8.0', 'name': 5, 'body': 7}], 'tag-int': [{'tag_name': 8}],
      };
      final res = <String, String>{};
      for (final e in shapes.entries) {
        res[e.key] = await chkShape(e.value);
      }
      print('INFO updater shapes: $res');
      final others = res.entries.where((e) => e.value.startsWith('OTHER')).toList();
      chk('U-check-shapes', others.isEmpty, 'shapes that throw a raw (non-UpdateException) error, shown to the user as a generic failure: ${others.map((e) => '${e.key}=${e.value}').toList()}');
      chk('U-missing-tag-ignored', !res['missing-tag']!.contains('latest=null') && !res['tag-null-explicit']!.contains('latest=null'), 'a release object with no tag_name is treated as a release named "null": missing-tag -> ${res['missing-tag']}');
      chk('U-draft-prerelease', res['draft-only']!.contains('available=false') && res['prerelease-only']!.contains('available=false'), 'drafts and prereleases ignored');
      chk('U-http-errors', await chkShape([], status: 404) == 'UpdateException' && await chkShape([], status: 403) == 'UpdateException' && await chkShape([], status: 500) == 'UpdateException', '404/403/500 -> UpdateException');
      final pick = Updater.pickAsset([
        {'name': 'pagemark-armv7.apk'}, {'name': 'pagemark-x86_64.apk'}, {'name': 'pagemark-arm64-v8a.apk'}, {'name': 'notes.txt'}, {'name': 'PAGEMARK-ARM64.APK'}
      ], ['armeabi-v7a', 'arm64-v8a']);
      print('INFO pickAsset with abis [armeabi-v7a, arm64-v8a] picks ${pick?['name']} (ABI list order respected; uppercase .APK is ignored)');
      chk('U-pickAsset', Updater.pickAsset([], ['arm64-v8a']) == null && Updater.pickAsset([{'name': 'a.apk'}], ['x86']) != null && Updater.pickAsset([{'name': 'a.apk'}, {'name': 'b.apk'}], ['mips']) == null, 'empty -> null; single apk fallback; ambiguous -> null');
      Updater.client = http.Client();
    });

    test('download integrity', () async {
      final dir = Directory.systemTemp.createTempSync('pgmupd');
      final body = Uint8List.fromList(List.generate(4000, (i) => i % 251));
      Updater.client = MockClient.streaming((req, _) async => http.StreamedResponse(Stream.value(body), 200, contentLength: body.length));
      final info = UpdateInfo(current: '0.7.0', latest: '0.8.0', notes: const [], assetName: 'a.apk', assetUrl: 'https://x/a.apk', assetBytes: body.length, sha256: '00' * 32);
      final o = await outcome(() => Updater.download(info, (_) {}, to: File('${dir.path}/a.apk')));
      chk('U-download-bad-sha', o == 'OTHER:UpdateException' && !File('${dir.path}/a.apk').existsSync(), 'wrong sha256 -> $o and file deleted');
      final info2 = UpdateInfo(current: '0.7.0', latest: '0.8.0', notes: const [], assetName: 'a.apk', assetUrl: 'https://x/a.apk', assetBytes: 5000);
      final o2 = await outcome(() => Updater.download(info2, (_) {}, to: File('${dir.path}/b.apk')));
      chk('U-download-short', o2 == 'OTHER:UpdateException' && !File('${dir.path}/b.apk').existsSync(), 'size mismatch -> $o2 and file deleted');
      final info3 = UpdateInfo(current: '0.7.0', latest: '0.8.0', notes: const [], assetName: 'a.apk', assetUrl: 'https://x/a.apk');
      final o3 = await outcome(() => Updater.download(info3, (_) {}, to: File('${dir.path}/c.apk')));
      print('INFO download with neither size nor sha256 in the release metadata -> $o3 (file kept, no integrity check beyond Android signature verification at install)');
      Updater.client = http.Client();
      dir.deleteSync(recursive: true);
    });
  });

  group('lock logic', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('shouldRelock edge values', () {
      chk('K-shouldRelock', shouldRelock(Duration.zero, 0) && !shouldRelock(const Duration(seconds: 59), 60) && shouldRelock(const Duration(seconds: 60), 60) && shouldRelock(Duration.zero, -5), 'normal cases and negative delay');
      chk('K-shouldRelock-negative-away', shouldRelock(const Duration(minutes: -10), 60), 'away = -10 min (device clock moved backwards while backgrounded) with a 60 s delay -> ${shouldRelock(const Duration(minutes: -10), 60)} (app_lock.dart:65 also requires away > 0)');
    });

    test('lockout arithmetic: doubling, cap, and integer overflow of the delay', () async {
      await LockService.setPin('4821');
      final s = const FlutterSecureStorage();
      final seen = <int, int>{};
      for (final failsBefore in [4, 9, 14, 39, 299, 319, 324, 399, 1000]) {
        await s.write(key: 'fails', value: '$failsBefore');
        await s.delete(key: 'lock_until');
        await LockService.checkPin('0000');
        final until = int.parse(await s.read(key: 'lock_until') ?? '0');
        seen[failsBefore + 1] = ((until - DateTime.now().millisecondsSinceEpoch) / 1000).round();
      }
      print('INFO lockout seconds by total failed attempts: $seen');
      final expected = (int n) => min(3600, 30 * pow(2, min(40, (n ~/ 5) - 1)).toInt());
      final wrong = seen.entries.where((e) => e.value < expected(e.key) - 3).map((e) => '${e.key} fails -> ${e.value}s (expected ${expected(e.key)}s)').toList();
      chk('K-lockout-overflow', wrong.isEmpty, wrong.isEmpty ? 'lockout never shrinks' : 'lockout collapses: ${wrong.join('; ')}');
    });

    test('concurrent wrong PINs are all counted', () async {
      await LockService.setPin('4821');
      await Future.wait(List.generate(6, (_) => LockService.checkPin('0000')));
      final fails = await const FlutterSecureStorage().read(key: 'fails');
      final locked = await LockService.lockoutRemaining();
      chk('K-concurrent-checkPin', fails == '6', 'six concurrent wrong guesses recorded as fails=$fails, lockout=${locked.inSeconds}s (read-modify-write race on the counter; the UI only issues one at a time)');
    });

    test('legacy upgrade, recovery reuse, nothing-configured cases', () async {
      FlutterSecureStorage.setMockInitialValues({'pin': '', 'salt': 'abc'});
      final s = const FlutterSecureStorage();
      await s.write(key: 'pin', value: 'x');
      expect(await LockService.mode(), 'pin');
      chk('K-legacy-wrong-pin', await LockService.checkPin('1234') == PinResult.wrong && await s.read(key: 'pin_hash') == null, 'wrong PIN on legacy hash does not upgrade');
      FlutterSecureStorage.setMockInitialValues({});
      final code = await LockService.setPin('4821');
      final fresh = await LockService.resetWithRecovery(code, '1111');
      chk('K-recovery-reuse', fresh != null && await LockService.resetWithRecovery(code, '2222') == null && await LockService.checkPin('1111') == PinResult.ok, 'old recovery code dead after use, new PIN works');
      chk('K-no-config-checkPin', (() async {
        FlutterSecureStorage.setMockInitialValues({});
        return await LockService.checkPin('1') == PinResult.wrong;
      })() is Future, 'checkPin with nothing configured is wrong, not an exception');
      FlutterSecureStorage.setMockInitialValues({'mode': 'pin'});
      chk('K-pin-mode-no-hash', await LockService.checkPin('1') == PinResult.wrong && await LockService.resetWithRecovery('AAAA', '1') == null, 'mode=pin with no hash stored (storage wiped) -> wrong forever, no recovery path');
    });
  });

  group('backup error helpers', () {
    test('shouldNotifyBackupFailure truth table and friendlyBackupError', () {
      final got = [for (var n = 0; n <= 15; n++) shouldNotifyBackupFailure(n, authProblem: false) ? n : -1]..removeWhere((x) => x < 0);
      chk('N-notify-nonauth', got.toString() == '[2, 7, 14]', 'notify on streaks $got');
      chk('N-notify-auth', shouldNotifyBackupFailure(1, authProblem: true) && !shouldNotifyBackupFailure(0, authProblem: true) && !shouldNotifyBackupFailure(-3, authProblem: false), 'auth first failure notifies; 0 and negative do not');
      final msgs = <String>[
        friendlyBackupError('plain'), friendlyBackupError(WrongPassphrase()), friendlyBackupError(const SocketException('x')), friendlyBackupError(TimeoutException('x')),
        friendlyBackupError(http.ClientException('x')), friendlyBackupError(DetailedApiRequestError(403, 'storageQuotaExceeded')), friendlyBackupError(DetailedApiRequestError(null, null)),
        friendlyBackupError(DetailedApiRequestError(503, 'x')), friendlyBackupError(StateError('secret-token-abc123')), friendlyBackupError(const BackupAuthException('reauth')),
      ];
      chk('N-friendly', msgs.every((m) => m.isNotEmpty) && !msgs.any((m) => m.contains('secret-token')), 'all branches return a sentence; arbitrary exception text is not echoed (only runtimeType)');
      chk('N-friendly-null-status', msgs[6].contains('error'), 'status null -> "${msgs[6]}"');
    });
  });

  group('misc logic', () {
    test('series number text, BookRow.progress, avgRating, DST day-of-year', () {
      final f = SeriesPage.fmtNum;
      final res = {for (final v in [2.0, 2.5, 0.5, -1.0, 1000.0, 1e20, double.infinity, double.nan, -0.0]) '$v': f(v)};
      print('INFO fmtNum: $res');
      chk('S-fmtNum-huge', f(1e20) != '9223372036854775807', 'series number 1e20 renders as "${f(1e20)}" (toInt saturates)');
      print('INFO double.tryParse series inputs: ${{for (final s in ['2.5', '.5', '1e3', '-2', 'NaN', 'Infinity', '1,5', ' 3 ', '0x10']) s: double.tryParse(s.trim())}}');
      chk('S-series-nan-inf', !(double.tryParse('NaN')?.isNaN ?? false) && !(double.tryParse('Infinity')?.isInfinite ?? false), 'EditBook stores double.tryParse(text) with no finite/range check: "NaN" parses to NaN, "Infinity" to Infinity (ui.dart:1033)');
      Book book(int? pages) => Book(id: 1, title: 't', author: '', isbn: '', coverUrl: '', genre: '', series: '', seriesNumber: null, seriesTotal: null, publisher: '', year: null, pages: pages, description: '', tags: '', notes: '', locked: false, added: DateTime(2024), deletedAt: null);
      Read rd(int? cur, {String st = 'reading', double? rating}) => Read(id: 1, bookId: 1, format: 'print', status: st, started: null, finished: null, rating: rating, thoughts: '', narrator: '', minutes: null, currentPage: cur, heat: null, contentNotes: '');
      final p = <String, double?>{
        'over': BookRow(book(100), [rd(500)]).progress, 'negative': BookRow(book(100), [rd(-5)]).progress, 'zero-pages': BookRow(book(0), [rd(5)]).progress,
        'neg-pages': BookRow(book(-10), [rd(5)]).progress, 'null-pages': BookRow(book(null), [rd(5)]).progress, 'finished': BookRow(book(100), [rd(5, st: 'finished')]).progress,
        'half': BookRow(book(200), [rd(100)]).progress,
      };
      chk('S-progress-clamp', p['over'] == 1 && p['negative'] == 0 && p['zero-pages'] == null && p['neg-pages'] == null && p['null-pages'] == null && p['finished'] == null && p['half'] == 0.5, 'progress table $p');
      chk('S-avgRating', BookRow(book(1), []).avgRating == null && BookRow(book(1), [rd(1, st: 'dnf', rating: 1.0)]).avgRating == null && BookRow(book(1), [rd(1, st: 'finished', rating: 4.0), rd(1, st: 'finished', rating: 5.0)]).avgRating == 4.5, 'avg of finished reads only; empty -> null');
      // Stats goal-pace expression (features.dart:429): dayOfYear = today.difference(DateTime(year)).inDays + 1
      final offsets = <String>[];
      for (final d in [DateTime(2026, 3, 9, 0, 30), DateTime(2026, 3, 9, 12), DateTime(2026, 11, 2, 0, 30), DateTime(2026, 11, 2, 12), DateTime(2026, 1, 1, 0, 1), DateTime(2026, 12, 31, 23, 59), DateTime(2028, 12, 31, 12)]) {
        final dayOfYear = d.difference(DateTime(d.year)).inDays + 1;
        final calendar = DateTime(d.year, d.month, d.day).difference(DateTime(d.year, 1, 1)).inDays + 1;
        final correct = d.difference(DateTime(d.year)).inDays + 1;
        offsets.add('${d.toIso8601String().substring(0, 16)} app=$dayOfYear (tz=${d.timeZoneName}) calendar-days=${DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(d.year, 1, 1)).inDays + 1}${correct == 0 ? '' : ''}');
        if (calendar < 0) offsets.add('x');
      }
      print('INFO goal-pace day-of-year (runs in the host timezone; DST-observing zones show -1 in the first hour after midnight once DST has started): ${offsets.join(' | ')}');
      print('INFO pace formula uses 365 even in leap years and projects ${(1 / 1 * 365).round()} books/year after one book on day 1');
    });
  });
}
