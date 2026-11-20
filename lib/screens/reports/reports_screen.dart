import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/report_builders.dart';
import 'package:a2_stocks/core/utils/report_pdf.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/report_models.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/report_providers.dart';
import 'package:a2_stocks/screens/reports/report_table_view.dart';

String _kindLabel(AppLocalizations l10n, ReportKind kind) {
  switch (kind) {
    case ReportKind.sales:
      return l10n.reportKindSales;
    case ReportKind.profit:
      return l10n.reportKindProfit;
    case ReportKind.tax:
      return l10n.reportKindTax;
    case ReportKind.stock:
      return l10n.reportKindStock;
    case ReportKind.receivables:
      return l10n.reportKindReceivables;
    case ReportKind.payables:
      return l10n.reportKindPayables;
  }
}

String _rangeLabel(AppLocalizations l10n, ReportRange range) {
  switch (range) {
    case ReportRange.today:
      return l10n.reportRangeToday;
    case ReportRange.last7:
      return l10n.reportRangeLast7;
    case ReportRange.thisMonth:
      return l10n.reportRangeThisMonth;
    case ReportRange.lastMonth:
      return l10n.reportRangeLastMonth;
    case ReportRange.thisYear:
      return l10n.reportRangeThisYear;
    case ReportRange.custom:
      return l10n.reportRangeCustom;
  }
}

/// Reports for the owner (admin and manager): sales by product, category, customer or cashier,
/// profit and margin, stock that does not sell, who owes the shop and whom the shop owes. Each can
/// be saved as a CSV file (for a spreadsheet) or a PDF. They need a connection: the server works
/// the figures out, so every device shows the same ones.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  /// The table of the report that is open, or null while it loads or failed.
  ReportTable? _table(WidgetRef ref, AppLocalizations l10n, ReportKind kind) {
    switch (kind) {
      case ReportKind.sales:
        final SalesReport? r = ref.watch(salesReportProvider).valueOrNull;
        return r == null ? null : salesTable(l10n, r);
      case ReportKind.profit:
        final ProfitReport? r = ref.watch(profitReportProvider).valueOrNull;
        return r == null ? null : profitTable(l10n, r);
      case ReportKind.tax:
        final TaxReport? r = ref.watch(taxReportProvider).valueOrNull;
        return r == null ? null : taxTable(l10n, r);
      case ReportKind.stock:
        final StockReport? r = ref.watch(stockReportProvider).valueOrNull;
        return r == null ? null : stockTable(l10n, r);
      case ReportKind.receivables:
        final AgeingReport? r = ref.watch(receivablesReportProvider).valueOrNull;
        return r == null ? null : ageingTable(l10n, r, customers: true);
      case ReportKind.payables:
        final AgeingReport? r = ref.watch(payablesReportProvider).valueOrNull;
        return r == null ? null : ageingTable(l10n, r, customers: false);
    }
  }

  AsyncValue<Object?> _state(WidgetRef ref, ReportKind kind) {
    switch (kind) {
      case ReportKind.sales:
        return ref.watch(salesReportProvider);
      case ReportKind.profit:
        return ref.watch(profitReportProvider);
      case ReportKind.tax:
        return ref.watch(taxReportProvider);
      case ReportKind.stock:
        return ref.watch(stockReportProvider);
      case ReportKind.receivables:
        return ref.watch(receivablesReportProvider);
      case ReportKind.payables:
        return ref.watch(payablesReportProvider);
    }
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(salesReportProvider);
    ref.invalidate(profitReportProvider);
    ref.invalidate(taxReportProvider);
    ref.invalidate(stockReportProvider);
    ref.invalidate(receivablesReportProvider);
    ref.invalidate(payablesReportProvider);
  }

  Future<void> _export(BuildContext context, WidgetRef ref, ReportTable table, {required bool pdf}) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations l10n = context.l10n;
    try {
      final Uint8List bytes = pdf
          ? await buildReportPdf(table, author: ref.read(businessProvider).name)
          : Uint8List.fromList(utf8.encode(table.toCsv()));
      final Uri? saved = await FilePicker.saveFile(
        fileName: table.fileName(pdf ? 'pdf' : 'csv'),
        bytes: bytes,
        mimeType: pdf ? 'application/pdf' : 'text/csv',
        dialogTitle: l10n.reportSaveAs,
      );
      if (saved != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportSaved)));
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    }
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final ReportPeriod now = ref.read(reportPeriodProvider);
    final DateTime today = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
      initialDateRange: DateTimeRange(start: now.from, end: now.to.isAfter(today) ? today : now.to),
    );
    if (picked != null) {
      ref.read(reportPeriodProvider.notifier).state = ReportPeriod(range: ReportRange.custom, from: picked.start, to: picked.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ReportKind kind = ref.watch(reportKindProvider);
    final ReportPeriod period = ref.watch(reportPeriodProvider);
    final ReportTable? table = _table(ref, l10n, kind);
    final AsyncValue<Object?> state = _state(ref, kind);
    final bool hasPeriod = kind == ReportKind.sales || kind == ReportKind.profit || kind == ReportKind.tax;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moduleReports),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.reportExportCsv,
            icon: const Icon(Icons.table_chart_outlined),
            onPressed: table == null ? null : () => _export(context, ref, table, pdf: false),
          ),
          IconButton(
            tooltip: l10n.reportExportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: table == null ? null : () => _export(context, ref, table, pdf: true),
          ),
          IconButton(tooltip: l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => _refresh(ref)),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final ReportKind k in ReportKind.values)
                    ChoiceChip(
                      label: Text(_kindLabel(l10n, k)),
                      selected: kind == k,
                      onSelected: (bool _) => ref.read(reportKindProvider.notifier).state = k,
                    ),
                ],
              ),
            ),
          ),
          if (hasPeriod)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    for (final ReportRange r in ReportRange.values.where((ReportRange r) => r != ReportRange.custom))
                      FilterChip(
                        label: Text(_rangeLabel(l10n, r)),
                        selected: period.range == r,
                        onSelected: (bool _) => ref.read(reportPeriodProvider.notifier).state = ReportPeriod.preset(r, DateTime.now()),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.date_range_outlined, size: 18),
                      label: Text(period.range == ReportRange.custom ? '${formatDate(period.from)} - ${formatDate(period.to)}' : l10n.reportRangeCustom),
                      onPressed: () => _pickRange(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          if (kind == ReportKind.sales)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'product', label: Text(l10n.reportColProduct)),
                    ButtonSegment<String>(value: 'category', label: Text(l10n.reportColCategory)),
                    ButtonSegment<String>(value: 'customer', label: Text(l10n.reportColCustomer)),
                    ButtonSegment<String>(value: 'cashier', label: Text(l10n.reportColCashier)),
                  ],
                  selected: <String>{ref.watch(salesGroupProvider)},
                  onSelectionChanged: (Set<String> v) => ref.read(salesGroupProvider.notifier).state = v.first,
                ),
              ),
            ),
          if (kind == ReportKind.stock)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: <ButtonSegment<int>>[
                    for (final int d in const <int>[30, 60, 90, 180]) ButtonSegment<int>(value: d, label: Text(l10n.reportDays(d))),
                  ],
                  selected: <int>{ref.watch(stockDaysProvider)},
                  onSelectionChanged: (Set<int> v) => ref.read(stockDaysProvider.notifier).state = v.first,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) =>
                  Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
              data: (Object? _) => table == null ? const SizedBox.shrink() : ReportTableView(table: table),
            ),
          ),
        ],
      ),
    );
  }
}
