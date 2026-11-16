import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/core/utils/currency.dart';

/// The free WhatsApp option: a `wa.me` link that opens a chat with a ready
/// message. A person still presses send; nothing is sent automatically.
class WhatsApp {
  const WhatsApp._();

  /// The phone as WhatsApp wants it: country code and number, digits only.
  /// Pakistani numbers (0300 1234567, +92 300 1234567, 0092...) become 923001234567.
  /// Returns '' when it cannot be a phone number.
  static String internationalPhone(String raw, {String countryCode = '92'}) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = '$countryCode${digits.substring(1)}';
    } else if (digits.length == 10 && digits.startsWith('3')) {
      digits = '$countryCode$digits';
    }
    return digits.length >= 11 && digits.length <= 15 ? digits : '';
  }

  /// The chat link, or null when the phone is unusable.
  static Uri? link(String phone, String message) {
    final String number = internationalPhone(phone);
    if (number.isEmpty) {
      return null;
    }
    return Uri.https('wa.me', '/$number', <String, String>{'text': message});
  }

  /// A short, friendly status message for an order.
  static String orderMessage(OrderModel order, {String shopName = 'MQ Sports'}) {
    final String who = order.customerName.trim().isEmpty ? '' : ' ${order.customerName.trim()}';
    final String total = order.totalAmount.toStringAsFixed(order.totalAmount % 1 == 0 ? 0 : 2);
    final String status = switch (order.status) {
      OrderStatus.pending => 'has been received',
      OrderStatus.processing => 'is being prepared',
      OrderStatus.shipped => 'is on its way to you',
      OrderStatus.delivered => 'has been delivered. Thank you for shopping with us!',
      OrderStatus.cancelled => 'has been cancelled',
    };
    return 'Hello$who, your order ${order.orderNo} (${MoneyFormat.withSymbol(total)}) $status. - $shopName';
  }
}
