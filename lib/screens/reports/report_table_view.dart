import 'package:flutter/material.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/report_table.dart';
import 'package:a2_stocks/l10n/l10n.dart';

/// Draws a [ReportTable]: its summary lines, then the table with the totals row last. It scrolls
/// sideways when the columns do not fit (a phone).
class ReportTableView extends StatelessWidget {
  const ReportTableView({super.key, required this.table});

  final ReportTable table;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Object?>? totals = table.totals;
    DataRow row(List<Object?> cells, {bool bold = false}) => DataRow(
          color: bold ? const WidgetStatePropertyAll<Color>(AppColors.mutedFill) : null,
          cells: <DataCell>[
            for (int i = 0; i < table.columns.length; i++)
              DataCell(
                Text(
                  ReportTable.show(i < cells.length ? cells[i] : null, table.columns[i].type),
                  style: TextStyle(fontWeight: bold ? FontWeight.w700 : null),
                ),
              ),
          ],
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        if (table.summary.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  for (final ReportSummaryLine s in table.summary)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text(s.label)),
                          Text(ReportTable.show(s.value, s.type), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (table.rows.isEmpty)
          Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(context.l10n.reportNothing, style: theme.textTheme.bodyMedium)))
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 52,
                columnSpacing: 20,
                columns: <DataColumn>[
                  for (final ReportColumn c in table.columns) DataColumn(label: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w700)), numeric: c.numeric),
                ],
                rows: <DataRow>[
                  for (final List<Object?> cells in table.rows) row(cells),
                  if (totals != null) row(totals, bold: true),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
