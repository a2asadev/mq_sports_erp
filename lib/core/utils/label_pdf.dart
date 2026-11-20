import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:a2_stocks/core/utils/label_sheet.dart';
import 'package:a2_stocks/core/utils/receipt.dart';

/// What a label shows besides the bar code.
class LabelOptions {
  const LabelOptions({this.showName = true, this.showPrice = true, this.showSku = false});

  final bool showName;
  final bool showPrice;
  final bool showSku;
}

/// Whether Code 128 can draw [code] (plain printable characters only).
bool canDrawBars(String code) => code.isNotEmpty && code.codeUnits.every((int c) => c >= 32 && c <= 126);

/// The labels as a PDF. On a roll every label is a page of its own size (the printer cuts there); on a sheet the
/// labels fill a grid page after page, leaving the first [skip] places empty (a sheet that is already part used).
/// The built-in PDF font covers Latin letters only.
Future<Uint8List> buildLabelsPdf(
  List<LabelItem> items,
  LabelSpec spec, {
  LabelOptions options = const LabelOptions(),
  int skip = 0,
}) async {
  final List<LabelItem> labels = <LabelItem>[
    for (final LabelItem item in items)
      for (int i = 0; i < item.copies; i++) item,
  ];
  final pw.Document doc = pw.Document(title: 'Labels');
  const double mm = PdfPageFormat.mm;

  pw.Widget label(LabelItem item) {
    final bool small = spec.labelHeightMm < 30;
    final double nameSize = small ? 6.5 : 8.5;
    final double priceSize = small ? 9 : 12;
    return pw.Container(
      width: spec.labelWidthMm * mm,
      height: spec.labelHeightMm * mm,
      padding: pw.EdgeInsets.all((small ? 1.2 : 2) * mm),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          if (options.showName)
            pw.Text(
              item.variantLabel.isEmpty || item.variantLabel == item.sku ? item.name : '${item.name} · ${item.variantLabel}',
              maxLines: 2,
              style: pw.TextStyle(fontSize: nameSize, fontWeight: pw.FontWeight.bold),
            ),
          if (options.showPrice) pw.Text(ReceiptData.money(item.price), style: pw.TextStyle(fontSize: priceSize, fontWeight: pw.FontWeight.bold)),
          if (options.showSku) pw.Text(item.sku, style: pw.TextStyle(fontSize: small ? 5.5 : 7)),
          pw.Spacer(),
          if (canDrawBars(item.code))
            pw.Expanded(
              flex: 4,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: item.code,
                drawText: true,
                textStyle: pw.TextStyle(fontSize: small ? 5.5 : 7),
              ),
            ),
        ],
      ),
    );
  }

  if (!spec.isSheet) {
    final PdfPageFormat format = PdfPageFormat(spec.pageWidthMm * mm, spec.pageHeightMm * mm);
    for (final LabelItem item in labels) {
      doc.addPage(pw.Page(pageFormat: format, margin: pw.EdgeInsets.zero, build: (pw.Context context) => label(item)));
    }
  } else {
    final PdfPageFormat format = PdfPageFormat(spec.pageWidthMm * mm, spec.pageHeightMm * mm);
    // Places on the sheets: empty ones first (skipped), then the labels.
    final List<LabelItem?> places = <LabelItem?>[for (int i = 0; i < skip % spec.perPage; i++) null, ...labels];
    for (int start = 0; start < places.length; start += spec.perPage) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.all(spec.marginMm * mm),
          build: (pw.Context context) => pw.Column(
            children: <pw.Widget>[
              for (int r = 0; r < spec.rows; r++)
                pw.Row(
                  children: <pw.Widget>[
                    for (int c = 0; c < spec.columns; c++)
                      () {
                        final int index = start + r * spec.columns + c;
                        final LabelItem? item = index < places.length ? places[index] : null;
                        return item == null ? pw.SizedBox(width: spec.labelWidthMm * mm, height: spec.labelHeightMm * mm) : label(item);
                      }(),
                  ],
                ),
            ],
          ),
        ),
      );
    }
  }
  if (labels.isEmpty) {
    doc.addPage(pw.Page(build: (pw.Context context) => pw.SizedBox()));
  }
  return doc.save();
}
