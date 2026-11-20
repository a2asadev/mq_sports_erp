double _d(Object? v) => v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
int _i(Object? v) => v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? 0);

/// A period of whole days, "YYYY-MM-DD", in the business's own time zone.
class ReportPeriodDays {
  const ReportPeriodDays({required this.from, required this.to});

  final String from;
  final String to;

  factory ReportPeriodDays.fromMap(Object? map) {
    final Map<String, dynamic> m = map is Map<String, dynamic> ? map : const <String, dynamic>{};
    return ReportPeriodDays(from: '${m['from'] ?? ''}', to: '${m['to'] ?? ''}');
  }
}

/// One line of the sales report: a product, category, customer or cashier.
class SalesRow {
  const SalesRow({
    required this.key,
    required this.name,
    required this.units,
    required this.orders,
    required this.revenue,
    required this.returned,
    required this.cost,
    required this.profit,
    this.margin,
  });

  /// Id of what it is about; '' for the online store (cashier) or unknown.
  final String key;
  final String name;
  final int units;
  final int orders;

  /// Sold for after discounts, less what came back.
  final double revenue;
  final double returned;
  final double cost;
  final double profit;

  /// Profit as a percent of revenue; null without revenue.
  final double? margin;

  factory SalesRow.fromMap(Map<String, dynamic> m) => SalesRow(
        key: '${m['key'] ?? ''}',
        name: '${m['name'] ?? ''}',
        units: _i(m['units']),
        orders: _i(m['orders']),
        revenue: _d(m['revenue']),
        returned: _d(m['returned']),
        cost: _d(m['cost']),
        profit: _d(m['profit']),
        margin: m['margin'] is num ? (m['margin'] as num).toDouble() : null,
      );
}

class SalesReport {
  const SalesReport({required this.period, required this.groupBy, required this.rows, required this.totals});

  final ReportPeriodDays period;
  final String groupBy;
  final List<SalesRow> rows;
  final SalesRow totals;

  factory SalesReport.fromMap(Map<String, dynamic> m) {
    final Object? rows = m['rows'];
    return SalesReport(
      period: ReportPeriodDays.fromMap(m['period']),
      groupBy: '${m['groupBy'] ?? 'product'}',
      rows: <SalesRow>[
        if (rows is List<Object?>)
          for (final Object? r in rows)
            if (r is Map<String, dynamic>) SalesRow.fromMap(r),
      ],
      totals: SalesRow.fromMap(m['totals'] is Map<String, dynamic> ? m['totals'] as Map<String, dynamic> : const <String, dynamic>{}),
    );
  }
}

class ProfitDay {
  const ProfitDay({required this.date, required this.revenue, required this.cost, required this.expenses, required this.profit});

  final String date;
  final double revenue;
  final double cost;
  final double expenses;
  final double profit;
}

/// Revenue, cost of goods, gross profit, expenses and net profit of a period.
class ProfitReport {
  const ProfitReport({
    required this.period,
    required this.grossRevenue,
    required this.returned,
    required this.netRevenue,
    required this.costOfGoods,
    required this.grossProfit,
    required this.grossMargin,
    required this.expenses,
    required this.netProfit,
    required this.shippingFees,
    required this.orders,
    required this.byDay,
  });

  final ReportPeriodDays period;
  final double grossRevenue;
  final double returned;
  final double netRevenue;
  final double costOfGoods;
  final double grossProfit;
  final double? grossMargin;
  final double expenses;
  final double netProfit;
  final double shippingFees;
  final int orders;
  final List<ProfitDay> byDay;

  factory ProfitReport.fromMap(Map<String, dynamic> m) {
    final Object? days = m['byDay'];
    return ProfitReport(
      period: ReportPeriodDays.fromMap(m['period']),
      grossRevenue: _d(m['grossRevenue']),
      returned: _d(m['returned']),
      netRevenue: _d(m['netRevenue']),
      costOfGoods: _d(m['costOfGoods']),
      grossProfit: _d(m['grossProfit']),
      grossMargin: m['grossMargin'] is num ? (m['grossMargin'] as num).toDouble() : null,
      expenses: _d(m['expenses']),
      netProfit: _d(m['netProfit']),
      shippingFees: _d(m['shippingFees']),
      orders: _i(m['orders']),
      byDay: <ProfitDay>[
        if (days is List<Object?>)
          for (final Object? d in days)
            if (d is Map<String, dynamic>)
              ProfitDay(
                date: '${d['date'] ?? ''}',
                revenue: _d(d['revenue']),
                cost: _d(d['cost']),
                expenses: _d(d['expenses']),
                profit: _d(d['profit']),
              ),
      ],
    );
  }
}

/// dead = nothing sold in the window although it has been on the shelf longer; slow = sells, but the
/// stock would last more than twice the window; new = stocked within the window; ok.
enum StockStatus {
  dead,
  slow,
  isNew,
  ok;

  static StockStatus fromName(String? name) {
    switch (name) {
      case 'dead':
        return StockStatus.dead;
      case 'slow':
        return StockStatus.slow;
      case 'new':
        return StockStatus.isNew;
      default:
        return StockStatus.ok;
    }
  }
}

class StockRow {
  const StockRow({
    required this.sku,
    required this.productName,
    required this.variantLabel,
    required this.onHand,
    required this.costValue,
    required this.retailValue,
    required this.sold,
    required this.lastSoldAt,
    required this.daysSinceSold,
    required this.status,
  });

  final String sku;
  final String productName;
  final String variantLabel;
  final int onHand;
  final double costValue;
  final double retailValue;
  final int sold;
  final DateTime? lastSoldAt;
  final int? daysSinceSold;
  final StockStatus status;

  factory StockRow.fromMap(Map<String, dynamic> m) => StockRow(
        sku: '${m['sku'] ?? ''}',
        productName: '${m['productName'] ?? ''}',
        variantLabel: '${m['variantLabel'] ?? ''}',
        onHand: _i(m['onHand']),
        costValue: _d(m['costValue']),
        retailValue: _d(m['retailValue']),
        sold: _i(m['sold']),
        lastSoldAt: DateTime.tryParse('${m['lastSoldAt'] ?? ''}')?.toLocal(),
        daysSinceSold: m['daysSinceSold'] is num ? (m['daysSinceSold'] as num).toInt() : null,
        status: StockStatus.fromName(m['status'] as String?),
      );
}

class StockReport {
  const StockReport({
    required this.days,
    required this.rows,
    required this.deadCount,
    required this.deadValue,
    required this.slowCount,
    required this.slowValue,
  });

  final int days;
  final List<StockRow> rows;
  final int deadCount;
  final double deadValue;
  final int slowCount;
  final double slowValue;

  factory StockReport.fromMap(Map<String, dynamic> m) {
    final Object? rows = m['rows'];
    return StockReport(
      days: _i(m['days']),
      rows: <StockRow>[
        if (rows is List<Object?>)
          for (final Object? r in rows)
            if (r is Map<String, dynamic>) StockRow.fromMap(r),
      ],
      deadCount: _i(m['deadCount']),
      deadValue: _d(m['deadValue']),
      slowCount: _i(m['slowCount']),
      slowValue: _d(m['slowValue']),
    );
  }
}

/// Who owes (customers) or is owed (vendors), and how old the debt is.
class AgeingRow {
  const AgeingRow({
    required this.partyId,
    required this.name,
    required this.phone,
    required this.balance,
    required this.current,
    required this.d31to60,
    required this.d61to90,
    required this.over90,
    required this.oldestDays,
  });

  final String partyId;
  final String name;
  final String phone;
  final double balance;
  final double current;
  final double d31to60;
  final double d61to90;
  final double over90;
  final int oldestDays;

  factory AgeingRow.fromMap(Map<String, dynamic> m) => AgeingRow(
        partyId: '${m['partyId'] ?? ''}',
        name: '${m['name'] ?? ''}',
        phone: '${m['phone'] ?? ''}',
        balance: _d(m['balance']),
        current: _d(m['current']),
        d31to60: _d(m['d31to60']),
        d61to90: _d(m['d61to90']),
        over90: _d(m['over90']),
        oldestDays: _i(m['oldestDays']),
      );
}

class AgeingReport {
  const AgeingReport({required this.rows, required this.balance, required this.current, required this.d31to60, required this.d61to90, required this.over90});

  final List<AgeingRow> rows;
  final double balance;
  final double current;
  final double d31to60;
  final double d61to90;
  final double over90;

  factory AgeingReport.fromMap(Map<String, dynamic> m) {
    final Object? rows = m['rows'];
    final Map<String, dynamic> t = m['totals'] is Map<String, dynamic> ? m['totals'] as Map<String, dynamic> : const <String, dynamic>{};
    return AgeingReport(
      rows: <AgeingRow>[
        if (rows is List<Object?>)
          for (final Object? r in rows)
            if (r is Map<String, dynamic>) AgeingRow.fromMap(r),
      ],
      balance: _d(t['balance']),
      current: _d(t['current']),
      d31to60: _d(t['d31to60']),
      d61to90: _d(t['d61to90']),
      over90: _d(t['over90']),
    );
  }
}
