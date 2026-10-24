import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'db.dart';
import 'reading_life.dart';

/// One printable page-or-two PDF for a year: the totals and every finished book. Built on the phone, never uploaded. Only the books
/// handed in are used (the caller passes the main library), so locked books cannot appear.
class ReportPdf {
  /// The built-in PDF fonts only draw Latin-1 letters; anything else becomes "?" rather than an empty box.
  static String clean(String s) => String.fromCharCodes([for (final c in s.runes) c <= 0xFF ? c : 0x3F]);

  static pw.Document build(Iterable<BookRow> rows, int year) {
    final s = yearSummary(rows, year);
    final df = DateFormat.yMMMd();
    final finished = <(DateTime, BookRow, Read)>[];
    for (final r in rows) {
      for (final rd in r.reads) {
        if (rd.status == 'finished' && rd.finished?.year == year) finished.add((rd.finished!, r, rd));
      }
    }
    finished.sort((a, b) => a.$1.compareTo(b.$1));
    String stars(double? v) => v == null ? '' : (v % 1 == 0 ? '${v.toInt()}' : '$v');
    final doc = pw.Document(title: 'My reading in $year');
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      footer: (c) => pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Made with Pagemark · page ${c.pageNumber} of ${c.pagesCount}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
      build: (c) => [
        pw.Text('My reading in $year', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        if (s.isEmpty) pw.Text('No finished books yet.') else ...[
          pw.Text('${s.books} ${s.books == 1 ? 'book' : 'books'} finished${s.pages > 0 ? ', ${NumberFormat.decimalPattern().format(s.pages)} pages' : ''}${s.minutes >= 60 ? ', about ${(s.minutes / 60).round()} hours' : ''}.'),
          if (s.topGenre != null) pw.Text('Favourite genre: ${clean(s.topGenre!)}'),
          if (s.topAuthor != null) pw.Text('Most-read author: ${clean(s.topAuthor!)}'),
          if (s.avgRating != null) pw.Text('Average rating: ${ratingText(s.avgRating!)} of 5'),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: ['Finished', 'Title', 'Author', 'Pages', 'Stars'],
            data: [
              for (final e in finished) [df.format(e.$1), clean(e.$2.book.title), clean(e.$2.book.author), '${e.$2.book.pages ?? ''}', stars(e.$3.rating)],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 10),
            columnWidths: {0: const pw.FixedColumnWidth(70), 1: const pw.FlexColumnWidth(3), 2: const pw.FlexColumnWidth(2), 3: const pw.FixedColumnWidth(36), 4: const pw.FixedColumnWidth(36)},
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight},
          ),
        ],
      ],
    ));
    return doc;
  }

  static Future<File> write(Iterable<BookRow> rows, int year) async {
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/Pagemark-reading-$year.pdf');
    await f.writeAsBytes(await build(rows, year).save(), flush: true);
    return f;
  }
}
