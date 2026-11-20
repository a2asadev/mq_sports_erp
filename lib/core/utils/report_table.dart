import 'package:a2_stocks/core/utils/formatters.dart';

/// How a report column is written: money with the business's currency, whole numbers, a percent,
/// a day, or plain text. The same column is written raw into a CSV file (plain numbers a
/// spreadsheet can add up) and nicely on the screen and in a PDF.
enum ReportColumnType { text, integer, money, percent, date }

class ReportColumn {
  const ReportColumn(this.label, this.type);

  final String label;
  final ReportColumnType type;

  bool get numeric => type == ReportColumnType.integer || type == ReportColumnType.money || type == ReportColumnType.percent;
}

/// A line above the table of a report ("Net profit: Rs 1,200").
class ReportSummaryLine {
  const ReportSummaryLine(this.label, this.value, {this.type = ReportColumnType.money});

  final String label;
  final Object? value;
  final ReportColumnType type;
}

/// Everything a report shows, in one shape: the screen draws it, [toCsv] and the PDF write it.
/// Cells are raw values (a number, a String, or null for "nothing").
class ReportTable {
  const ReportTable({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.rows,
    this.totals,
    this.summary = const <ReportSummaryLine>[],
  });

  final String title;

  /// The period or the setting the report was run with ("2026-11-01 to 2026-11-22").
  final String subtitle;
  final List<ReportColumn> columns;
  final List<List<Object?>> rows;

  /// The last line (same columns), when the report has one.
  final List<Object?>? totals;
  final List<ReportSummaryLine> summary;

  /// A cell as a person reads it.
  static String show(Object? value, ReportColumnType type) {
    if (value == null) {
      return '';
    }
    switch (type) {
      case ReportColumnType.money:
        return value is num ? formatMoney(value.toDouble()) : '$value';
      case ReportColumnType.integer:
        return value is num ? '${value.round()}' : '$value';
      case ReportColumnType.percent:
        return value is num ? '${value.toStringAsFixed(1)}%' : '$value';
      case ReportColumnType.date:
      case ReportColumnType.text:
        return '$value';
    }
  }

  /// A cell as a spreadsheet wants it: numbers with no symbol and no thousands separators.
  static String raw(Object? value, ReportColumnType type) {
    if (value == null) {
      return '';
    }
    if (value is num) {
      return type == ReportColumnType.integer ? '${value.round()}' : value.toStringAsFixed(2);
    }
    return '$value';
  }

  static String _escape(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n') || text.contains('\r')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  /// A CSV file: the title, the period, the summary, then the table. It starts with a byte order
  /// mark so Excel reads names in any language correctly.
  String toCsv() {
    final StringBuffer out = StringBuffer('﻿');
    void line(List<String> cells) => out.write('${cells.map(_escape).join(',')}\r\n');
    line(<String>[title]);
    if (subtitle.isNotEmpty) {
      line(<String>[subtitle]);
    }
    for (final ReportSummaryLine s in summary) {
      line(<String>[s.label, raw(s.value, s.type)]);
    }
    if (summary.isNotEmpty || subtitle.isNotEmpty) {
      line(const <String>[]);
    }
    line(<String>[for (final ReportColumn c in columns) c.label]);
    for (final List<Object?> row in rows) {
      line(<String>[for (int i = 0; i < columns.length; i++) raw(i < row.length ? row[i] : null, columns[i].type)]);
    }
    final List<Object?>? t = totals;
    if (t != null) {
      line(<String>[for (int i = 0; i < columns.length; i++) raw(i < t.length ? t[i] : null, columns[i].type)]);
    }
    return out.toString();
  }

  /// A file name for it: "sales-2026-11-01-2026-11-22.csv" (letters, digits and dashes only).
  String fileName(String extension) {
    final String base = '$title $subtitle'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    return '${base.isEmpty ? 'report' : base}.$extension';
  }
}
