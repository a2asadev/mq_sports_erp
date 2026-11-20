/// Why an item is suggested: out of stock, at or under its alert level, or selling so fast that it will run out
/// before an order could arrive.
enum ReorderReason {
  out,
  low,
  runningOut;

  static ReorderReason fromName(String? name) {
    switch (name) {
      case 'out':
        return ReorderReason.out;
      case 'low':
        return ReorderReason.low;
      default:
        return ReorderReason.runningOut;
    }
  }
}

/// One item to order, with how much and from whom.
class ReorderSuggestion {
  const ReorderSuggestion({
    required this.variantId,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.variantLabel,
    required this.onHand,
    required this.onOrder,
    required this.alertThreshold,
    required this.sold,
    required this.perDay,
    required this.daysLeft,
    required this.suggestedQty,
    required this.unitCost,
    required this.vendorId,
    required this.vendorName,
    required this.reason,
  });

  final String variantId;
  final String productId;
  final String sku;
  final String productName;
  final String variantLabel;
  final int onHand;

  /// Already ordered from vendors and still to arrive.
  final int onOrder;
  final int alertThreshold;

  /// Units sold in the window the suggestion looked at.
  final int sold;
  final double perDay;

  /// How many days the stock on hand lasts at that speed; null when it does not sell.
  final double? daysLeft;
  final int suggestedQty;

  /// The price of the last purchase of it, else the catalog cost.
  final double unitCost;

  /// The vendor it was last bought from; '' when never bought (or that vendor is switched off).
  final String vendorId;
  final String vendorName;
  final ReorderReason reason;

  bool get hasVendor => vendorId.isNotEmpty;

  factory ReorderSuggestion.fromMap(Map<String, dynamic> m) => ReorderSuggestion(
        variantId: '${m['variantId'] ?? ''}',
        productId: '${m['productId'] ?? ''}',
        sku: '${m['sku'] ?? ''}',
        productName: '${m['productName'] ?? ''}',
        variantLabel: '${m['variantLabel'] ?? ''}',
        onHand: (m['onHand'] as num?)?.toInt() ?? 0,
        onOrder: (m['onOrder'] as num?)?.toInt() ?? 0,
        alertThreshold: (m['alertThreshold'] as num?)?.toInt() ?? 0,
        sold: (m['sold'] as num?)?.toInt() ?? 0,
        perDay: (m['perDay'] as num?)?.toDouble() ?? 0,
        daysLeft: (m['daysLeft'] as num?)?.toDouble(),
        suggestedQty: (m['suggestedQty'] as num?)?.toInt() ?? 1,
        unitCost: (m['unitCost'] as num?)?.toDouble() ?? 0,
        vendorId: '${m['vendorId'] ?? ''}',
        vendorName: '${m['vendorName'] ?? ''}',
        reason: ReorderReason.fromName(m['reason'] as String?),
      );
}

class ReorderReport {
  const ReorderReport({required this.days, required this.coverDays, required this.rows});

  final int days;
  final int coverDays;
  final List<ReorderSuggestion> rows;

  factory ReorderReport.fromMap(Map<String, dynamic> m) {
    final Object? rows = m['rows'];
    return ReorderReport(
      days: (m['days'] as num?)?.toInt() ?? 30,
      coverDays: (m['coverDays'] as num?)?.toInt() ?? 30,
      rows: <ReorderSuggestion>[
        if (rows is List<Object?>)
          for (final Object? r in rows)
            if (r is Map<String, dynamic>) ReorderSuggestion.fromMap(r),
      ],
    );
  }
}
