import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/l10n/l10n.dart';

/// A rate without a useless ".0": 17 -> "17", 17.5 -> "17.5", 5.25 -> "5.25".
String formatRate(double rate) {
  final String fixed = rate.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// The tax of a sale as lines a person reads: "GST 17%" with its amount, or "Includes GST 17%" when the
/// price already contained the tax. A tax that was not charged has no line.
List<MapEntry<String, double>> taxLabels(AppLocalizations l10n, TaxResult tax) {
  String label(String name, double rate) =>
      tax.inclusive ? l10n.taxLineIncluded(name, formatRate(rate)) : l10n.taxLine(name, formatRate(rate));
  return <MapEntry<String, double>>[
    if (tax.gstRate > 0 && tax.gst > 0.004) MapEntry<String, double>(label(l10n.taxNameGst, tax.gstRate), tax.gst),
    if (tax.vatRate > 0 && tax.vat > 0.004) MapEntry<String, double>(label(l10n.taxNameVat, tax.vatRate), tax.vat),
  ];
}
