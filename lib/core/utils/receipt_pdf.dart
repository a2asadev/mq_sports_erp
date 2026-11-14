import 'dart:typed_data';

import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The receipt as a PDF on an 80 mm roll (the usual thermal-printer width), so
/// the same file prints on a receipt printer, an A4 printer or is shared.
///
/// The built-in PDF font covers Latin letters; names in other scripts (for
/// example Urdu) are not drawn yet.
Future<Uint8List> buildReceiptPdf(ReceiptData r) async {
  final pw.Document doc = pw.Document(title: 'Receipt ${r.orderNo}', author: r.shopName);
  const pw.TextStyle base = pw.TextStyle(fontSize: 9);
  const pw.TextStyle bold = pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

  pw.Widget row(String left, String right, {pw.TextStyle? style}) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(child: pw.Text(left, style: style ?? base)),
          pw.SizedBox(width: 6),
          pw.Text(right, style: style ?? base),
        ],
      );

  final pw.Widget line = pw.Divider(thickness: 0.5, height: 8);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80.copyWith(marginLeft: 8, marginRight: 8, marginTop: 10, marginBottom: 10),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Center(child: pw.Text(r.shopName, style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
          if (r.shopPhone.isNotEmpty) pw.Center(child: pw.Text('Tel: ${r.shopPhone}', style: base)),
          pw.SizedBox(height: 4),
          row('Receipt', r.orderNo, style: bold),
          row('Date', ReceiptData.dateText(r.date)),
          if (r.cashier.isNotEmpty) row('Served by', r.cashier),
          if (r.customerName.isNotEmpty) row('Customer', r.customerName),
          line,
          for (final ReceiptLine l in r.lines) ...<pw.Widget>[
            pw.Text('${l.name}${l.label.isEmpty ? '' : ' (${l.label})'}', style: base),
            row('  ${l.quantity} x ${ReceiptData.rs(l.unitPrice)}', ReceiptData.rs(l.total)),
            if (l.discount > 0.005) row('  Discount', '-${ReceiptData.rs(l.discount)}'),
          ],
          line,
          if (r.discount > 0.005) ...<pw.Widget>[
            row('Items', ReceiptData.rs(r.subtotal)),
            row('Discount', '-${ReceiptData.rs(r.discount)}'),
          ],
          if (r.shippingFee > 0.005) row('Delivery', ReceiptData.rs(r.shippingFee)),
          row('TOTAL', ReceiptData.rs(r.total), style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          for (final ReceiptPayment p in r.payments)
            row('${p.label}${p.reference.isEmpty ? '' : ' (${p.reference})'}', ReceiptData.rs(p.amount)),
          if (r.change > 0.005) row('Change', ReceiptData.rs(r.change)),
          if (r.due > 0.005) row('Balance due', ReceiptData.rs(r.due), style: bold),
          line,
          pw.Center(child: pw.Text('Thank you for shopping with us!', style: base)),
        ],
      ),
    ),
  );
  return doc.save();
}
