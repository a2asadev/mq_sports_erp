import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The receipt as a PDF on an 80 mm roll (the usual thermal-printer width), so
/// the same file prints on a receipt printer, an A4 printer or is shared. The
/// layout follows the on-screen receipt (`ReceiptView`): logo, shop, customer
/// and number, items table, totals, bar code of the receipt number, thank you.
///
/// The built-in PDF font covers Latin letters; names in other scripts (for
/// example Urdu) are not drawn yet.
Future<Uint8List> buildReceiptPdf(ReceiptData r) async {
  final pw.Document doc = pw.Document(title: 'Receipt ${r.orderNo}', author: r.shopName);

  pw.MemoryImage? logo;
  try {
    final ByteData data = await rootBundle.load('assets/images/mq_logo.png');
    logo = pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {
    logo = null; // The receipt is still complete without the logo.
  }

  const PdfColor muted = PdfColor.fromInt(0xFF4B5563);
  const PdfColor navy = PdfColor.fromInt(0xFF12304D);
  const PdfColor rule = PdfColor.fromInt(0xFFB8BFC9);
  const pw.TextStyle base = pw.TextStyle(fontSize: 8.5, color: muted);
  const pw.TextStyle bold = pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold);

  pw.Widget kv(String left, String right) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Expanded(child: pw.Text(left, style: bold)),
            pw.SizedBox(width: 6),
            pw.Text(right, style: base),
          ],
        ),
      );

  pw.Widget solid() => pw.Divider(thickness: 0.5, height: 6, color: rule);
  pw.Widget dashed() => pw.Divider(
        thickness: 0.5,
        height: 6,
        color: rule,
        borderStyle: pw.BorderStyle.dashed,
      );

  pw.Widget info(String label, String value) => pw.RichText(
        text: pw.TextSpan(
          children: <pw.InlineSpan>[
            pw.TextSpan(text: "$label: ", style: const pw.TextStyle(fontSize: 8.5)),
            pw.TextSpan(text: value, style: base),
          ],
        ),
      );

  pw.Widget cell(String text, double width, {pw.TextStyle? style}) => pw.SizedBox(
        width: width,
        child: pw.Text(text, textAlign: pw.TextAlign.right, style: style ?? base),
      );

  final String customer = r.customerName.isEmpty ? 'Walk-in customer' : r.customerName;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80.copyWith(
        marginLeft: 10,
        marginRight: 10,
        marginTop: 12,
        marginBottom: 12,
      ),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          if (logo != null) pw.Center(child: pw.Image(logo, height: 46)),
          pw.SizedBox(height: 3),
          pw.Center(
            child: pw.Text(
              r.shopName,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (r.shopPhone.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Center(child: pw.Text('Phone Number : ${r.shopPhone}', style: base)),
            ),
          pw.SizedBox(height: 8),
          dashed(),
          pw.Center(
            child: pw.Text('Sales Receipt', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
          dashed(),
          pw.SizedBox(height: 4),
          info('Name', customer),
          pw.SizedBox(height: 2),
          info('Receipt No', r.orderNo),
          pw.SizedBox(height: 2),
          info('Date', ReceiptData.dateText(r.date)),
          if (r.cashier.isNotEmpty) ...<pw.Widget>[pw.SizedBox(height: 2), info('Served by', r.cashier)],
          pw.SizedBox(height: 4),
          solid(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: <pw.Widget>[
                pw.Expanded(child: pw.Text('# Item', style: bold)),
                cell('Price', 38, style: bold),
                cell('Qty', 20, style: bold),
                cell('Total', 42, style: bold),
              ],
            ),
          ),
          solid(),
          pw.SizedBox(height: 2),
          for (int i = 0; i < r.lines.length; i++) ...<pw.Widget>[
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      '${i + 1}. ${r.lines[i].name}${r.lines[i].label.isEmpty ? '' : ' (${r.lines[i].label})'}',
                      style: base,
                    ),
                  ),
                  cell(ReceiptData.plain(r.lines[i].unitPrice), 38),
                  cell('${r.lines[i].quantity}', 20),
                  cell(ReceiptData.plain(r.lines[i].total), 42),
                ],
              ),
            ),
            if (r.lines[i].discount > 0.005)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Text('Discount -${ReceiptData.plain(r.lines[i].discount)}', style: base),
              ),
          ],
          pw.SizedBox(height: 2),
          solid(),
          kv('Sub Total :', ReceiptData.rs(r.subtotal)),
          if (r.discount > 0.005) kv('Discount :', '-${ReceiptData.rs(r.discount)}'),
          if (r.shippingFee > 0.005) kv('Delivery :', ReceiptData.rs(r.shippingFee)),
          solid(),
          for (final ReceiptPayment p in r.payments)
            kv('${p.label}${p.reference.isEmpty ? '' : ' (${p.reference})'} :', ReceiptData.rs(p.amount)),
          if (r.change > 0.005) kv('Change :', ReceiptData.rs(r.change)),
          kv('Due :', ReceiptData.rs(r.due)),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text('Total Payable', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                ReceiptData.rs(r.total),
                style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navy),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          dashed(),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(),
              data: r.orderNo.isEmpty ? '0' : r.orderNo,
              width: 130,
              height: 34,
              drawText: false,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Center(child: pw.Text(r.orderNo, style: bold)),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Thank you for shopping with us. Please come again.',
              textAlign: pw.TextAlign.center,
              style: base,
            ),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
