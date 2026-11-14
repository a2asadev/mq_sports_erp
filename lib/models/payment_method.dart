/// How a customer paid. Bank transfer covers any bank account; Easypaisa and
/// JazzCash are listed separately because shops handle them every day.
enum PaymentMethod {
  cash('Cash', false),
  easypaisa('Easypaisa', true),
  jazzcash('JazzCash', true),
  bank('Bank transfer', true);

  const PaymentMethod(this.label, this.hasReference);

  final String label;

  /// Non-cash payments carry a transaction number (and for banks, the bank name).
  final bool hasReference;

  /// The method with this name, or null for '' / unknown (a payment made
  /// before methods were recorded).
  static PaymentMethod? fromName(String? name) {
    for (final PaymentMethod method in PaymentMethod.values) {
      if (method.name == name) {
        return method;
      }
    }
    return null;
  }

  /// What to show for a stored method name ('' = not recorded).
  static String labelOf(String? name) => fromName(name)?.label ?? 'Payment';
}

/// One part of what a customer paid at the counter.
class PaymentLine {
  const PaymentLine({required this.method, required this.amount, this.reference = ''});

  final PaymentMethod method;
  final double amount;

  /// Transaction number or bank name.
  final String reference;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'method': method.name,
        'amount': amount,
        'reference': reference,
      };

  static PaymentLine? fromMap(Object? map) {
    if (map is! Map<String, dynamic>) {
      return null;
    }
    final PaymentMethod? method = PaymentMethod.fromName(map['method'] as String?);
    final double amount = (map['amount'] as num?)?.toDouble() ?? 0;
    if (method == null || amount <= 0) {
      return null;
    }
    return PaymentLine(method: method, amount: amount, reference: map['reference'] as String? ?? '');
  }

  static List<PaymentLine> listFrom(Object? list) => <PaymentLine>[
        if (list is List<Object?>)
          for (final Object? item in list)
            if (PaymentLine.fromMap(item) case final PaymentLine line) line,
      ];

  /// Sum in whole cents, so 0.1 + 0.2 never drifts.
  static double total(Iterable<PaymentLine> lines) =>
      lines.fold<int>(0, (int s, PaymentLine l) => s + (l.amount * 100).round()) / 100;
}
