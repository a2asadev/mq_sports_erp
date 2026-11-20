import 'package:flutter/material.dart';
import 'package:a2_stocks/core/utils/receipt.dart';
import 'package:a2_stocks/core/utils/receipt_pdf.dart';
import 'package:a2_stocks/core/utils/whatsapp.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/widgets/photo_widgets.dart';
import 'package:a2_stocks/widgets/receipt_view.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the receipt on screen with its print, share and WhatsApp buttons.
/// [footer] (for example a "New sale" button) goes under them.
Future<void> showReceiptDialog(
  BuildContext context,
  ReceiptData receipt, {
  String phone = '',
  Widget? header,
  Widget? footer,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) => Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (header != null) header,
              ReceiptView(receipt: receipt),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: <Widget>[
                    ReceiptActions(receipt: receipt, phone: phone, showView: false),
                    if (footer != null) ...<Widget>[const SizedBox(height: 8), footer],
                    if (footer == null)
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.starterPackClose)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Print, share as PDF, or send a receipt on WhatsApp.
///
/// - **PDF**: an 80 mm receipt. "Print / save PDF" opens the system print dialog
///   (any printer, or "save as PDF"); "Share PDF" opens the share sheet, from
///   which it can be sent on WhatsApp as a file.
/// - **WhatsApp**: opens a chat with the receipt as text; a person presses send.
class ReceiptActions extends StatelessWidget {
  const ReceiptActions({super.key, required this.receipt, this.phone = '', this.showView = true});

  final ReceiptData receipt;

  /// Offer "View receipt" (not needed where the receipt is already on screen).
  final bool showView;

  /// The customer's phone, if known (asked for when missing).
  final String phone;

  Future<void> _guard(BuildContext context, Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptActionsThatDidNotWork)));
    }
  }

  Future<void> _print(BuildContext context) async {
    await Printing.layoutPdf(
      name: context.l10n.receiptActionsReceipt(receipt.orderNo),
      onLayout: (_) => buildReceiptPdf(receipt),
    );
  }

  Future<void> _share(BuildContext context) async {
    await Printing.sharePdf(bytes: await buildReceiptPdf(receipt), filename: 'receipt-${receipt.orderNo}.pdf');
  }

  Future<void> _whatsApp(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    String number = phone;
    if (WhatsApp.internationalPhone(number).isEmpty) {
      final String? typed = await _askPhone(context);
      if (typed == null) {
        return;
      }
      number = typed;
    }
    final Uri? link = WhatsApp.link(number, receipt.toText());
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

  Future<String?> _askPhone(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(context.l10n.receiptActionsWhatsappNumber),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: context.l10n.receiptActionsCustomerPhone,
            hintText: '0300 1234567',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.categoriesCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: Text(context.l10n.receiptActionsOpenWhatsapp)),
        ],
      ),
    ).whenComplete(() => disposeControllerLater(controller));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _guard(context, () => _print(context)),
          icon: const Icon(Icons.print_outlined),
          label: Text(context.l10n.receiptActionsPrintReceipt),
        ),
        if (showView)
          OutlinedButton.icon(
            onPressed: () => showReceiptDialog(context, receipt, phone: phone),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(context.l10n.receiptActionsViewReceipt),
          ),
        OutlinedButton.icon(
          onPressed: () => _guard(context, () => _share(context)),
          icon: const Icon(Icons.ios_share),
          label: Text(context.l10n.receiptActionsSharePdf),
        ),
        OutlinedButton.icon(
          onPressed: () => _guard(context, () => _whatsApp(context)),
          icon: const Icon(Icons.chat_outlined),
          label: Text(context.l10n.receiptActionsWhatsapp),
        ),
      ],
    );
  }
}
