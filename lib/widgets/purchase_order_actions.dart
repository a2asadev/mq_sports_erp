import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:a2_stocks/core/utils/purchase_order_text.dart';
import 'package:a2_stocks/core/utils/report_pdf.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/core/utils/whatsapp.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/purchase_order.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/pos_providers.dart';

/// "Send to vendor": the order as a WhatsApp message, or as a PDF to share or print. Nothing is sent
/// automatically: WhatsApp opens a chat with the message ready and the person presses send.
class SendPurchaseOrderButton extends ConsumerWidget {
  const SendPurchaseOrderButton({super.key, required this.order});

  final PurchaseOrder order;

  String _vendorPhone(WidgetRef ref) {
    final List<VendorModel> vendors = ref.read(vendorsProvider).valueOrNull ?? <VendorModel>[];
    for (final VendorModel v in vendors) {
      if (v.id == order.vendorId) {
        return v.phone;
      }
    }
    return '';
  }

  Future<ReportTable> _table(BuildContext context, WidgetRef ref) async {
    final ShopInfo shop = await ref.read(shopInfoProvider.future);
    if (!context.mounted) {
      throw StateError('gone');
    }
    return purchaseOrderTable(context.l10n, order, shopName: shop.name, shopPhone: shop.phone, vendorPhone: _vendorPhone(ref));
  }

  Future<void> _guard(BuildContext context, Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptActionsThatDidNotWork)));
    }
  }

  Future<void> _whatsApp(BuildContext context, WidgetRef ref) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    final ShopInfo shop = await ref.read(shopInfoProvider.future);
    String number = _vendorPhone(ref);
    if (WhatsApp.internationalPhone(number).isEmpty) {
      if (!context.mounted) {
        return;
      }
      final String? typed = await showDialog<String>(context: context, builder: (BuildContext context) => const _AskPhoneDialog());
      if (typed == null) {
        return;
      }
      number = typed;
    }
    final Uri? link = WhatsApp.link(number, purchaseOrderMessage(l10n, order, shopName: shop.name, shopPhone: shop.phone));
    if (link == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptActionsThatIsNotA)));
      return;
    }
    bool opened = false;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderDetailWhatsappCouldNotBe)));
    }
  }

  Future<void> _sharePdf(BuildContext context, WidgetRef ref) async {
    final ReportTable table = await _table(context, ref);
    await Printing.sharePdf(
      bytes: await buildReportPdf(table, author: ref.read(businessProvider).name),
      filename: 'purchase-order-${order.poNo}.pdf',
    );
  }

  Future<void> _printPdf(BuildContext context, WidgetRef ref) async {
    final ReportTable table = await _table(context, ref);
    final String author = ref.read(businessProvider).name;
    await Printing.layoutPdf(name: table.title, onLayout: (_) => buildReportPdf(table, author: author));
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(context.l10n.poSendWhatsApp),
              subtitle: Text(context.l10n.poSendWhatsAppHint),
              onTap: () {
                Navigator.of(sheet).pop();
                _guard(context, () => _whatsApp(context, ref));
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(context.l10n.poSendSharePdf),
              onTap: () {
                Navigator.of(sheet).pop();
                _guard(context, () => _sharePdf(context, ref));
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: Text(context.l10n.poSendPrintPdf),
              onTap: () {
                Navigator.of(sheet).pop();
                _guard(context, () => _printPdf(context, ref));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => OutlinedButton.icon(
        onPressed: () => _open(context, ref),
        icon: const Icon(Icons.send_outlined),
        label: Text(context.l10n.poSendToVendor),
      );
}

/// Asks for the vendor's WhatsApp number when the vendor has none on record. It owns its text field.
class _AskPhoneDialog extends StatefulWidget {
  const _AskPhoneDialog();

  @override
  State<_AskPhoneDialog> createState() => _AskPhoneDialogState();
}

class _AskPhoneDialogState extends State<_AskPhoneDialog> {
  final TextEditingController _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.receiptActionsWhatsappNumber),
      content: TextField(
        controller: _phone,
        autofocus: true,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(labelText: context.l10n.poSendVendorPhone, hintText: '0300 1234567', border: const OutlineInputBorder()),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.categoriesCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(_phone.text.trim()), child: Text(context.l10n.receiptActionsOpenWhatsapp)),
      ],
    );
  }
}
