import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/core/utils/receipt_pdf.dart';
import 'package:mq_sports_erp/core/utils/whatsapp.dart';
import 'package:mq_sports_erp/widgets/photo_widgets.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Print, share as PDF, or send a receipt on WhatsApp.
///
/// - **PDF**: an 80 mm receipt. "Print / save PDF" opens the system print dialog
///   (any printer, or "save as PDF"); "Share PDF" opens the share sheet, from
///   which it can be sent on WhatsApp as a file.
/// - **WhatsApp**: opens a chat with the receipt as text; a person presses send.
class ReceiptActions extends StatelessWidget {
  const ReceiptActions({super.key, required this.receipt, this.phone = ''});

  final ReceiptData receipt;

  /// The customer's phone, if known (asked for when missing).
  final String phone;

  Future<void> _guard(BuildContext context, Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('That did not work on this device. Please try again.')));
    }
  }

  Future<void> _print() async {
    await Printing.layoutPdf(
      name: 'Receipt ${receipt.orderNo}',
      onLayout: (_) => buildReceiptPdf(receipt),
    );
  }

  Future<void> _share() async {
    await Printing.sharePdf(bytes: await buildReceiptPdf(receipt), filename: 'receipt-${receipt.orderNo}.pdf');
  }

  Future<void> _whatsApp(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
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
      messenger.showSnackBar(const SnackBar(content: Text('That is not a usable phone number.')));
      return;
    }
    bool opened = false;
    try {
      opened = await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(const SnackBar(content: Text('WhatsApp could not be opened on this device.')));
    }
  }

  Future<String?> _askPhone(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WhatsApp number'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Customer phone',
            hintText: '0300 1234567',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Open WhatsApp')),
        ],
      ),
    ).whenComplete(() => disposeControllerLater(controller));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: () => _guard(context, _print),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print / save PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => _guard(context, _share),
          icon: const Icon(Icons.ios_share),
          label: const Text('Share PDF'),
        ),
        OutlinedButton.icon(
          onPressed: () => _guard(context, () => _whatsApp(context)),
          icon: const Icon(Icons.chat_outlined),
          label: const Text('WhatsApp'),
        ),
      ],
    );
  }
}
