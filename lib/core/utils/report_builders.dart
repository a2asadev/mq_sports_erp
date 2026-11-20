import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/report_models.dart';

/// Turns each report into a [ReportTable] in the language of the app.

String _period(ReportPeriodDays p) => p.from == p.to ? p.from : '${p.from} - ${p.to}';

String _groupTitle(AppLocalizations l10n, String groupBy) {
  switch (groupBy) {
    case 'category':
      return l10n.reportSalesByCategory;
    case 'customer':
      return l10n.reportSalesByCustomer;
    case 'cashier':
      return l10n.reportSalesByCashier;
    default:
      return l10n.reportSalesByProduct;
  }
}

String _groupLabel(AppLocalizations l10n, String groupBy) {
  switch (groupBy) {
    case 'category':
      return l10n.reportColCategory;
    case 'customer':
      return l10n.reportColCustomer;
    case 'cashier':
      return l10n.reportColCashier;
    default:
      return l10n.reportColProduct;
  }
}

/// Sales, profit and margin by product, category, customer or cashier.
ReportTable salesTable(AppLocalizations l10n, SalesReport r) {
  // An order from the online store has no cashier.
  String name(SalesRow row) => r.groupBy == 'cashier' && row.key.isEmpty ? l10n.reportOnlineStore : row.name;
  return ReportTable(
    title: _groupTitle(l10n, r.groupBy),
    subtitle: _period(r.period),
    columns: <ReportColumn>[
      ReportColumn(_groupLabel(l10n, r.groupBy), ReportColumnType.text),
      ReportColumn(l10n.reportColUnits, ReportColumnType.integer),
      ReportColumn(l10n.reportColOrders, ReportColumnType.integer),
      ReportColumn(l10n.reportColRevenue, ReportColumnType.money),
      ReportColumn(l10n.reportColReturned, ReportColumnType.money),
      ReportColumn(l10n.reportColCost, ReportColumnType.money),
      ReportColumn(l10n.reportColProfit, ReportColumnType.money),
      ReportColumn(l10n.reportColMargin, ReportColumnType.percent),
    ],
    rows: <List<Object?>>[
      for (final SalesRow row in r.rows) <Object?>[name(row), row.units, row.orders, row.revenue, row.returned, row.cost, row.profit, row.margin],
    ],
    totals: <Object?>[l10n.reportTotal, r.totals.units, r.totals.orders, r.totals.revenue, r.totals.returned, r.totals.cost, r.totals.profit, r.totals.margin],
  );
}

/// Revenue, cost of goods, gross profit, expenses and net profit, then the days.
ReportTable profitTable(AppLocalizations l10n, ProfitReport r) => ReportTable(
      title: l10n.reportProfitTitle,
      subtitle: _period(r.period),
      summary: <ReportSummaryLine>[
        ReportSummaryLine(l10n.reportProfitRevenue, r.grossRevenue),
        ReportSummaryLine(l10n.reportProfitReturned, r.returned),
        ReportSummaryLine(l10n.reportProfitNetRevenue, r.netRevenue),
        ReportSummaryLine(l10n.reportProfitCost, r.costOfGoods),
        ReportSummaryLine(l10n.reportProfitGross, r.grossProfit),
        ReportSummaryLine(l10n.reportProfitMargin, r.grossMargin, type: ReportColumnType.percent),
        ReportSummaryLine(l10n.reportProfitExpenses, r.expenses),
        ReportSummaryLine(l10n.reportProfitNet, r.netProfit),
        ReportSummaryLine(l10n.reportProfitShipping, r.shippingFees),
      ],
      columns: <ReportColumn>[
        ReportColumn(l10n.reportColDay, ReportColumnType.date),
        ReportColumn(l10n.reportColRevenue, ReportColumnType.money),
        ReportColumn(l10n.reportColCost, ReportColumnType.money),
        ReportColumn(l10n.reportColExpenses, ReportColumnType.money),
        ReportColumn(l10n.reportColProfit, ReportColumnType.money),
      ],
      rows: <List<Object?>>[
        for (final ProfitDay d in r.byDay) <Object?>[d.date, d.revenue, d.cost, d.expenses, d.profit],
      ],
    );

String stockStatusLabel(AppLocalizations l10n, StockStatus s) {
  switch (s) {
    case StockStatus.dead:
      return l10n.reportStockDead;
    case StockStatus.slow:
      return l10n.reportStockSlow;
    case StockStatus.isNew:
      return l10n.reportStockNew;
    case StockStatus.ok:
      return l10n.reportStockOk;
  }
}

/// Stock that does not sell.
ReportTable stockTable(AppLocalizations l10n, StockReport r) => ReportTable(
      title: l10n.reportStockTitle,
      subtitle: l10n.reportStockWindow(r.days),
      summary: <ReportSummaryLine>[
        ReportSummaryLine(l10n.reportStockDeadLine(r.deadCount), r.deadValue),
        ReportSummaryLine(l10n.reportStockSlowLine(r.slowCount), r.slowValue),
      ],
      columns: <ReportColumn>[
        ReportColumn(l10n.reportColSku, ReportColumnType.text),
        ReportColumn(l10n.reportColProduct, ReportColumnType.text),
        ReportColumn(l10n.reportColOnHand, ReportColumnType.integer),
        ReportColumn(l10n.reportColStockValue, ReportColumnType.money),
        ReportColumn(l10n.reportColSold, ReportColumnType.integer),
        ReportColumn(l10n.reportColLastSold, ReportColumnType.date),
        ReportColumn(l10n.reportColStatus, ReportColumnType.text),
      ],
      rows: <List<Object?>>[
        for (final StockRow row in r.rows)
          <Object?>[
            row.sku,
            row.variantLabel == row.sku || row.variantLabel.isEmpty ? row.productName : '${row.productName} · ${row.variantLabel}',
            row.onHand,
            row.costValue,
            row.sold,
            row.lastSoldAt == null ? l10n.reportNeverSold : formatDate(row.lastSoldAt!),
            stockStatusLabel(l10n, row.status),
          ],
      ],
    );

/// Who owes the business (customers) or is owed (vendors), by age of the debt.
ReportTable ageingTable(AppLocalizations l10n, AgeingReport r, {required bool customers}) => ReportTable(
      title: customers ? l10n.reportReceivablesTitle : l10n.reportPayablesTitle,
      subtitle: formatDate(DateTime.now()),
      columns: <ReportColumn>[
        ReportColumn(customers ? l10n.reportColCustomer : l10n.reportColVendor, ReportColumnType.text),
        ReportColumn(l10n.reportColPhone, ReportColumnType.text),
        ReportColumn(l10n.reportColBalance, ReportColumnType.money),
        ReportColumn(l10n.reportColAge030, ReportColumnType.money),
        ReportColumn(l10n.reportColAge3160, ReportColumnType.money),
        ReportColumn(l10n.reportColAge6190, ReportColumnType.money),
        ReportColumn(l10n.reportColAge90, ReportColumnType.money),
        ReportColumn(l10n.reportColOldestDays, ReportColumnType.integer),
      ],
      rows: <List<Object?>>[
        for (final AgeingRow row in r.rows)
          <Object?>[row.name, row.phone, row.balance, row.current, row.d31to60, row.d61to90, row.over90, row.oldestDays],
      ],
      totals: <Object?>[l10n.reportTotal, '', r.balance, r.current, r.d31to60, r.d61to90, r.over90, null],
    );
