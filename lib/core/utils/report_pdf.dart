import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:a2_stocks/core/utils/report_table.dart';

/// A report as an A4 PDF (landscape when it has many columns): title, period, summary, table
/// and totals. The built-in PDF font covers Latin letters; names in other scripts (for example
/// Urdu) are not drawn yet, the CSV file has them all.
Future<Uint8List> buildReportPdf(ReportTable table, {String author = ''}) async {
  final pw.Document doc = pw.Document(title: table.title, author: author);
  const PdfColor ink = PdfColor.fromInt(0xFF12304D);
  const PdfColor muted = PdfColor.fromInt(0xFF4B5563);
  const PdfColor band = PdfColor.fromInt(0xFFE7EBEE);

  final List<List<String>> body = <List<String>>[
    for (final List<Object?> row in table.rows)
      <String>[for (int i = 0; i < table.columns.length; i++) ReportTable.show(i < row.length ? row[i] : null, table.columns[i].type)],
  ];
  final List<Object?>? totals = table.totals;
  if (totals != null) {
    body.add(<String>[for (int i = 0; i < table.columns.length; i++) ReportTable.show(i < totals.length ? totals[i] : null, table.columns[i].type)]);
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: table.columns.length > 5 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(table.title, style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: ink)),
          if (table.subtitle.isNotEmpty) pw.Text(table.subtitle, style: const pw.TextStyle(fontSize: 9, color: muted)),
          pw.SizedBox(height: 8),
        ],
      ),
      footer: (pw.Context context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: muted)),
      ),
      build: (pw.Context context) => <pw.Widget>[
        if (table.summary.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              children: <pw.Widget>[
                for (final ReportSummaryLine s in table.summary)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: <pw.Widget>[
                        pw.Text(s.label, style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(ReportTable.show(s.value, s.type), style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (table.columns.isNotEmpty)
          pw.TableHelper.fromTextArray(
            headers: <String>[for (final ReportColumn c in table.columns) c.label],
            data: body,
            headerStyle: const pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: ink),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            headerDecoration: const pw.BoxDecoration(color: band),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: band, width: 0.5)),
            cellAlignments: <int, pw.Alignment>{
              for (int i = 0; i < table.columns.length; i++) i: table.columns[i].numeric ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            },
            headerAlignments: <int, pw.Alignment>{
              for (int i = 0; i < table.columns.length; i++) i: table.columns[i].numeric ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            },
          ),
      ],
    ),
  );
  return doc.save();
}
