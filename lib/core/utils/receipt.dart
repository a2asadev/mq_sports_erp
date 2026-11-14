import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/payment_method.dart';

String _money(double amount) {
  final String text = amount.toStringAsFixed(2);
  return text.endsWith('.00') ? text.substring(0, text.length - 3) : text;
}

/// One line on a receipt.
class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
  });

  final String name;
  final String label;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;
}

/// One payment on a receipt.
class ReceiptPayment {
  const ReceiptPayment({required this.label, required this.amount, this.reference = ''});

  final String label;
  final double amount;
  final String reference;
}

/// Everything a receipt shows. No tax (for now); the total is items minus
/// discounts, plus delivery for online orders.
class ReceiptData {
  const ReceiptData({
    required this.shopName,
    required this.shopPhone,
    required this.orderNo,
    required this.date,
    required this.cashier,
    required this.customerName,
    required this.lines,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    required this.payments,
    this.change = 0,
  });

  final String shopName;
  final String shopPhone;
  final String orderNo;
  final DateTime date;

  /// Who served the customer ('' = not shown).
  final String cashier;

  /// '' for a walk-in customer.
  final String customerName;
  final List<ReceiptLine> lines;
  final double subtotal;

  /// Line discounts plus the order discount.
  final double discount;
  final double shippingFee;
  final double total;
  final List<ReceiptPayment> payments;

  /// Cash handed back to the customer.
  final double change;

  double get paid => PaymentLine.total(
        payments.map((ReceiptPayment p) => PaymentLine(method: PaymentMethod.cash, amount: p.amount)),
      );

  double get due {
    final double left = ((total - paid) * 100).round() / 100;
    return left > 0 ? left : 0;
  }

  /// Builds the receipt of an order from its payments (the customer ledger
  /// entries that point to it). Entries that are not payments are ignored.
  factory ReceiptData.fromOrder(
    OrderModel order, {
    required List<LedgerModel> ledger,
    required String shopName,
    String shopPhone = '',
    String cashier = '',
    double change = 0,
  }) {
    final List<ReceiptPayment> payments = <ReceiptPayment>[
      for (final LedgerModel e in ledger)
        if (e.orderId == order.id &&
            e.partyType == PartyType.customer &&
            e.entryType == LedgerEntryType.payment &&
            !e.description.startsWith('Cancelled order'))
          ReceiptPayment(
            label: e.paymentMethod.isEmpty ? 'Payment' : PaymentMethod.labelOf(e.paymentMethod),
            amount: e.amount,
            reference: e.paymentRef,
          ),
    ];
    return ReceiptData.fromParts(
      order,
      payments: payments,
      shopName: shopName,
      shopPhone: shopPhone,
      cashier: cashier,
      change: change,
    );
  }

  /// Builds the receipt from payments known at the counter.
  factory ReceiptData.fromParts(
    OrderModel order, {
    required List<ReceiptPayment> payments,
    required String shopName,
    String shopPhone = '',
    String cashier = '',
    double change = 0,
  }) {
    return ReceiptData(
      shopName: shopName,
      shopPhone: shopPhone,
      orderNo: order.orderNo,
      date: order.orderDate,
      cashier: cashier,
      customerName: isWalkIn(order.customerId) ? '' : order.customerName,
      lines: <ReceiptLine>[
        for (final OrderItem i in order.items)
          ReceiptLine(
            name: i.productName,
            label: i.variantLabel,
            quantity: i.quantity,
            unitPrice: i.unitPrice,
            discount: i.discount,
            total: i.lineTotal,
          ),
      ],
      subtotal: order.subtotal,
      discount: order.totalDiscount,
      shippingFee: order.shippingFee,
      total: order.totalAmount,
      payments: payments,
      change: change,
    );
  }

  /// "Rs 1,250" style amounts without thousands separators (simple and printable anywhere).
  static String rs(double amount) => 'Rs ${_money(amount)}';

  /// The receipt as plain text: what the WhatsApp button sends.
  String toText() {
    final StringBuffer out = StringBuffer()
      ..writeln('*$shopName*')
      ..writeln(shopPhone.isEmpty ? '' : 'Tel: $shopPhone')
      ..writeln('Receipt $orderNo')
      ..writeln(_dateText(date));
    if (customerName.isNotEmpty) {
      out.writeln('Customer: $customerName');
    }
    out.writeln('--------------------------');
    for (final ReceiptLine l in lines) {
      out.writeln('${l.quantity} x ${l.name}${l.label.isEmpty ? '' : ' (${l.label})'}');
      out.writeln('   ${rs(l.unitPrice)} = ${rs(l.total)}${l.discount > 0.005 ? '  (discount ${rs(l.discount)})' : ''}');
    }
    out.writeln('--------------------------');
    if (discount > 0.005) {
      out.writeln('Items: ${rs(subtotal)}');
      out.writeln('Discount: -${rs(discount)}');
    }
    if (shippingFee > 0.005) {
      out.writeln('Delivery: ${rs(shippingFee)}');
    }
    out.writeln('*Total: ${rs(total)}*');
    for (final ReceiptPayment p in payments) {
      out.writeln('${p.label}: ${rs(p.amount)}${p.reference.isEmpty ? '' : ' (${p.reference})'}');
    }
    if (change > 0.005) {
      out.writeln('Change: ${rs(change)}');
    }
    if (due > 0.005) {
      out.writeln('Balance due: ${rs(due)}');
    }
    out.writeln('');
    out.write('Thank you for shopping with us!');
    return out.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  static String _dateText(DateTime date) {
    final DateTime d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  static String dateText(DateTime date) => _dateText(date);
}
