import 'package:a2_stocks/models/payment_method.dart';

/// How the customer pays for a sale: several payments by different methods,
/// cash that may be more than what is left (the rest is given back as change),
/// and non-cash payments that must not be more than what is left.
class PosPaymentPlan {
  PosPaymentPlan(this.total);

  final double total;
  final List<PaymentLine> _lines = <PaymentLine>[];
  final List<double> _changes = <double>[];

  List<PaymentLine> get lines => List<PaymentLine>.unmodifiable(_lines);

  /// What has been paid (change not counted).
  double get paid => PaymentLine.total(_lines);

  double get remaining {
    final double left = ((total - paid) * 100).round() / 100;
    return left > 0 ? left : 0;
  }

  /// Cash to hand back.
  double get change => ((_changes.fold<double>(0, (double s, double c) => s + c)) * 100).round() / 100;

  bool get isFullyPaid => remaining < 0.005;

  /// Adds a payment. Returns a message when it cannot be added, else null.
  String? add(PaymentMethod method, double entered, {String reference = ''}) {
    if (entered.isNaN || entered <= 0) {
      return 'Enter an amount above zero.';
    }
    final double rounded = (entered * 100).round() / 100;
    if (isFullyPaid) {
      return 'The sale is already fully paid.';
    }
    final String ref = reference.trim();
    if (method.hasReference && ref.isEmpty) {
      return method == PaymentMethod.bank
          ? 'Enter the bank and transaction number.'
          : 'Enter the ${method.label} transaction number.';
    }
    double change = 0;
    double amount = rounded;
    if (rounded > remaining + 0.005) {
      if (method != PaymentMethod.cash) {
        return 'That is more than what is left to pay (${remaining.toStringAsFixed(2)}).';
      }
      amount = remaining;
      change = ((rounded - remaining) * 100).round() / 100;
    }
    _lines.add(PaymentLine(method: method, amount: amount, reference: ref));
    _changes.add(change);
    return null;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _lines.length) {
      return;
    }
    _lines.removeAt(index);
    _changes.removeAt(index);
  }
}
