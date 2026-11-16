import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';

/// The receipt as it looks on screen: shop, customer and number, the
/// items in a table, the totals, a bar code of the receipt number and a thank
/// you. [buildReceiptPdf] draws the same layout for printing.
class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key, required this.receipt});

  final ReceiptData receipt;

  static const TextStyle _base = TextStyle(fontSize: 13, color: AppColors.textMuted);
  static const TextStyle _strong = TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w700);

  Widget _kv(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: _strong),
            const SizedBox(width: 12),
            Flexible(child: Text(value, textAlign: TextAlign.end, style: _base)),
          ],
        ),
      );

  Widget _info(String label, String value) => Text.rich(
        TextSpan(children: <InlineSpan>[
          TextSpan(text: '$label: ', style: const TextStyle(color: AppColors.text, fontSize: 13)),
          TextSpan(text: value, style: _base),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final String customer = receipt.customerName.isEmpty ? 'Walk-in customer' : receipt.customerName;
    return Container(
      width: 380,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (receipt.logoUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Center(
                child: Image.network(
                  receipt.logoUrl,
                  height: 56,
                  fit: BoxFit.contain,
                  // Offline, or a picture that cannot be loaded: the receipt is complete without it.
                  errorBuilder: (BuildContext context, Object error, StackTrace? stack) => const SizedBox.shrink(),
                ),
              ),
            ),
          Center(
            child: Text(
              receipt.shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (receipt.shopPhone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(child: Text('Phone Number : ${receipt.shopPhone}', style: _base)),
            ),
          const SizedBox(height: 14),
          const _Dashed(label: 'Sales Receipt'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _info('Name', customer),
                    const SizedBox(height: 8),
                    if (receipt.cashier.isNotEmpty) _info('Served by', receipt.cashier),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _info('Receipt No', receipt.orderNo),
                    const SizedBox(height: 8),
                    _info('Date', ReceiptData.dateText(receipt.date)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _Solid(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Text('# Item', style: _strong)),
                SizedBox(width: 64, child: Text('Price', textAlign: TextAlign.end, style: _strong)),
                SizedBox(width: 34, child: Text('Qty', textAlign: TextAlign.end, style: _strong)),
                SizedBox(width: 68, child: Text('Total', textAlign: TextAlign.end, style: _strong)),
              ],
            ),
          ),
          const _Solid(),
          const SizedBox(height: 6),
          for (int i = 0; i < receipt.lines.length; i++) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${i + 1}. ${receipt.lines[i].name}'
                      '${receipt.lines[i].label.isEmpty ? '' : ' (${receipt.lines[i].label})'}',
                      style: _base,
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(ReceiptData.plain(receipt.lines[i].unitPrice), textAlign: TextAlign.end, style: _base),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text('${receipt.lines[i].quantity}', textAlign: TextAlign.end, style: _base),
                  ),
                  SizedBox(
                    width: 68,
                    child: Text(ReceiptData.plain(receipt.lines[i].total), textAlign: TextAlign.end, style: _base),
                  ),
                ],
              ),
            ),
            if (receipt.lines[i].discount > 0.005)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Discount -${ReceiptData.plain(receipt.lines[i].discount)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.danger),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 6),
          const _Solid(),
          const SizedBox(height: 6),
          _kv('Sub Total :', ReceiptData.money(receipt.subtotal)),
          if (receipt.discount > 0.005) _kv('Discount :', '-${ReceiptData.money(receipt.discount)}'),
          if (receipt.shippingFee > 0.005) _kv('Delivery :', ReceiptData.money(receipt.shippingFee)),
          const SizedBox(height: 4),
          const _Solid(),
          const SizedBox(height: 6),
          for (final ReceiptPayment p in receipt.payments)
            _kv(
              '${p.label}${p.reference.isEmpty ? '' : ' (${p.reference})'} :',
              ReceiptData.money(p.amount),
            ),
          if (receipt.change > 0.005) _kv('Change :', ReceiptData.money(receipt.change)),
          _kv('Due :', ReceiptData.money(receipt.due)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Flexible(child: Text('Total Payable', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                Text(
                  ReceiptData.money(receipt.total),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const _Dashed(),
          const SizedBox(height: 16),
          Center(
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: receipt.orderNo.isEmpty ? '0' : receipt.orderNo,
              width: 190,
              height: 54,
              drawText: false,
              color: AppColors.navy,
              errorBuilder: (BuildContext context, String error) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Text(receipt.orderNo, style: _strong)),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Thank you for shopping with us. Please come again.',
              textAlign: TextAlign.center,
              style: _base,
            ),
          ),
        ],
      ),
    );
  }
}

class _Solid extends StatelessWidget {
  const _Solid();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: AppColors.border);
}

/// A dotted rule, optionally with a centred title on it.
class _Dashed extends StatelessWidget {
  const _Dashed({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final Widget line = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final int count = (box.maxWidth / 6).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            count,
            (int i) => const SizedBox(width: 3, height: 1, child: ColoredBox(color: AppColors.border)),
          ),
        );
      },
    );
    if (label == null) {
      return line;
    }
    return Row(
      children: <Widget>[
        Expanded(child: line),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: line),
      ],
    );
  }
}
