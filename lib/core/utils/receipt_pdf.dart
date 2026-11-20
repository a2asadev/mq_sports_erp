import 'dart:typed_data';

import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The receipt as a PDF on an 80 mm roll (the usual thermal-printer width), so
/// the same file prints on a receipt printer, an A4 printer or is shared. The
/// layout follows the on-screen receipt (`ReceiptView`): shop, customer
/// and number, items table, totals, bar code of the receipt number, thank you.
///
/// The built-in PDF font covers Latin letters; names in other scripts (for
/// example Urdu) are not drawn yet.
///
/// The business's logo is downloaded when there is one ([fetchLogo] is for
/// tests); a logo that cannot be fetched or read is simply left off.
Future<Uint8List> buildReceiptPdf(
  ReceiptData r, {
  Future<Uint8List?> Function(String url)? fetchLogo,
}) async {
  final pw.Document doc = pw.Document(title: L10n.current.receiptReceipt(r.orderNo), author: r.shopName);
  final pw.MemoryImage? logo = await _logoImage(r.logoUrl, fetchLogo ?? _downloadLogo);

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

  final String customer = r.customerName.isEmpty ? L10n.current.dashboardWalkInCustomer : r.customerName;

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
          if (logo != null) ...<pw.Widget>[
            pw.Center(child: pw.Image(logo, height: 44)),
            pw.SizedBox(height: 4),
          ],
          pw.Center(
            child: pw.Text(
              r.shopName,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (r.taxNumber.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Center(child: pw.Text(L10n.current.receiptTaxNumber(r.taxNumber), style: base)),
            ),
          if (r.shopPhone.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 3),
              child: pw.Center(child: pw.Text(L10n.current.receiptPdfPhoneNumber(r.shopPhone), style: base)),
            ),
          pw.SizedBox(height: 8),
          dashed(),
          pw.Center(
            child: pw.Text(L10n.current.receiptSalesReceipt, style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ),
          dashed(),
          pw.SizedBox(height: 4),
          info(L10n.current.categoryFormName, customer),
          pw.SizedBox(height: 2),
          info(L10n.current.receiptReceiptNo, r.orderNo),
          pw.SizedBox(height: 2),
          info(L10n.current.ledgerEntryDate, ReceiptData.dateText(r.date)),
          if (r.cashier.isNotEmpty) ...<pw.Widget>[pw.SizedBox(height: 2), info(L10n.current.receiptServedBy, r.cashier)],
          pw.SizedBox(height: 4),
          solid(),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(
              children: <pw.Widget>[
                pw.Expanded(child: pw.Text('# Item', style: bold)),
                cell(L10n.current.receiptPrice, 38, style: bold),
                cell(L10n.current.receiptQty, 20, style: bold),
                cell(L10n.current.orderReceiptCardTotal, 42, style: bold),
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
                child: pw.Text(L10n.current.receiptPdfDiscount(ReceiptData.plain(r.lines[i].discount)), style: base),
              ),
          ],
          pw.SizedBox(height: 2),
          solid(),
          kv(L10n.current.receiptSubTotal, ReceiptData.money(r.subtotal)),
          if (r.discount > 0.005) kv(L10n.current.receiptDiscount2, '-${ReceiptData.money(r.discount)}'),
          for (final ReceiptTaxLine t in r.taxLines) kv(t.label, ReceiptData.money(t.amount)),
          if (r.shippingFee > 0.005) kv(L10n.current.receiptDelivery, ReceiptData.money(r.shippingFee)),
          solid(),
          for (final ReceiptPayment p in r.payments)
            kv('${p.label}${p.reference.isEmpty ? '' : ' (${p.reference})'} :', ReceiptData.money(p.amount)),
          if (r.change > 0.005) kv(L10n.current.receiptChange, ReceiptData.money(r.change)),
          kv(L10n.current.receiptDue, ReceiptData.money(r.due)),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: <pw.Widget>[
              pw.Text(L10n.current.posTotalPayable, style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                ReceiptData.money(r.total),
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
              L10n.current.receiptThankYouForShopping,
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

Future<Uint8List?> _downloadLogo(String url) async {
  try {
    final http.Response response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
    return response.statusCode == 200 ? response.bodyBytes : null;
  } catch (_) {
    return null;
  }
}

/// The logo as an image the PDF can embed. The server keeps logos as WebP, which
/// the PDF library cannot draw, so it is decoded and written again as PNG
/// (keeping its transparency). Null when there is none or it cannot be read.
Future<pw.MemoryImage?> _logoImage(String url, Future<Uint8List?> Function(String url) fetch) async {
  if (url.isEmpty) {
    return null;
  }
  try {
    final Uint8List? bytes = await fetch(url);
    if (bytes == null) {
      return null;
    }
    final img.Image? decoded = img.decodeImage(bytes);
    return decoded == null ? null : pw.MemoryImage(Uint8List.fromList(img.encodePng(decoded)));
  } catch (_) {
    return null;
  }
}
