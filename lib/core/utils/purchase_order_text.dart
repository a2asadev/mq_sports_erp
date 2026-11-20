import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';

/// What the vendor is asked for: the whole order, or only what has not arrived yet on a partly received one.
List<PurchaseOrderItem> _lines(PurchaseOrder po) {
  final bool onlyWhatIsLeft = po.status == PurchaseOrderStatus.partial;
  return <PurchaseOrderItem>[
    for (final PurchaseOrderItem i in po.items)
      if (!onlyWhatIsLeft || i.remaining > 0) i,
  ];
}

int _qty(PurchaseOrder po, PurchaseOrderItem i) => po.status == PurchaseOrderStatus.partial ? i.remaining : i.quantity;

String _itemName(PurchaseOrderItem i) => i.variantLabel.isEmpty || i.variantLabel == i.sku ? i.productName : '${i.productName} (${i.variantLabel})';

double _total(PurchaseOrder po) => _lines(po).fold<double>(0, (double s, PurchaseOrderItem i) => s + _qty(po, i) * i.unitCost);

/// The order as a plain message for the vendor (what the WhatsApp button sends). A partly received order lists
/// only what is still to be delivered.
String purchaseOrderMessage(AppLocalizations l10n, PurchaseOrder po, {required String shopName, String shopPhone = ''}) {
  final StringBuffer out = StringBuffer()
    ..writeln('*$shopName*')
    ..writeln(shopPhone.isEmpty ? '' : l10n.receiptTel(shopPhone))
    ..writeln(l10n.poMsgTitle(po.poNo))
    ..writeln(l10n.poMsgTo(po.vendorName))
    ..writeln(l10n.poMsgDate(ReceiptData.dateText(po.orderDate).split(' ').first));
  if (po.expectedDate.isNotEmpty) {
    out.writeln(l10n.poMsgExpected(po.expectedDate));
  }
  out.writeln('--------------------------');
  if (po.status == PurchaseOrderStatus.partial) {
    out.writeln(l10n.poMsgStillToCome);
  }
  for (final PurchaseOrderItem i in _lines(po)) {
    final int q = _qty(po, i);
    out.writeln(l10n.poMsgLine(q, _itemName(i), ReceiptData.money(i.unitCost), ReceiptData.money(q * i.unitCost)));
  }
  out.writeln('--------------------------');
  out.writeln(l10n.poMsgTotal(ReceiptData.money(_total(po))));
  if (po.note.isNotEmpty) {
    out.writeln(l10n.poMsgNote(po.note));
  }
  out
    ..writeln('')
    ..write(l10n.poMsgClosing);
  return out.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

/// The same order as a table, for the PDF (and a CSV if ever needed).
ReportTable purchaseOrderTable(AppLocalizations l10n, PurchaseOrder po, {required String shopName, String shopPhone = '', String vendorPhone = ''}) {
  return ReportTable(
    title: l10n.poMsgTitle(po.poNo),
    subtitle: shopName + (shopPhone.isEmpty ? '' : ' · ${l10n.receiptTel(shopPhone)}'),
    summary: <ReportSummaryLine>[
      ReportSummaryLine(l10n.poPdfVendor, po.vendorName + (vendorPhone.isEmpty ? '' : ' · $vendorPhone'), type: ReportColumnType.text),
      ReportSummaryLine(l10n.poPdfDate, formatDate(po.orderDate), type: ReportColumnType.text),
      if (po.expectedDate.isNotEmpty) ReportSummaryLine(l10n.poPdfExpected, po.expectedDate, type: ReportColumnType.text),
      if (po.status == PurchaseOrderStatus.partial) ReportSummaryLine(l10n.poMsgStillToCome, '', type: ReportColumnType.text),
      if (po.note.isNotEmpty) ReportSummaryLine(l10n.poPdfNote, po.note, type: ReportColumnType.text),
    ],
    columns: <ReportColumn>[
      ReportColumn(l10n.reportColProduct, ReportColumnType.text),
      ReportColumn(l10n.reportColSku, ReportColumnType.text),
      ReportColumn(l10n.poQuantity, ReportColumnType.integer),
      ReportColumn(l10n.poUnitCost, ReportColumnType.money),
      ReportColumn(l10n.reportTotal, ReportColumnType.money),
    ],
    rows: <List<Object?>>[
      for (final PurchaseOrderItem i in _lines(po)) <Object?>[_itemName(i), i.sku, _qty(po, i), i.unitCost, _qty(po, i) * i.unitCost],
    ],
    totals: <Object?>[l10n.reportTotal, '', null, null, _total(po)],
  );
}
