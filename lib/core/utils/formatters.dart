import 'package:mq_sports_erp/core/utils/currency.dart';

/// dd/MM/yyyy
String formatDate(DateTime date) {
  final DateTime local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}

/// Amount with two decimals, no currency symbol.
String formatAmount(double amount) => amount.toStringAsFixed(2);

/// "Rs 12,500" or "Rs 12,500.50" (the business's currency in front): thousands
/// separators, decimals only when there are some.
String formatMoney(double amount) {
  final bool negative = amount < 0;
  final double abs = amount.abs();
  final String fixed = abs.toStringAsFixed(2);
  final List<String> parts = fixed.split('.');
  final String whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (Match m) => ',',
  );
  final String decimals = parts[1] == '00' ? '' : '.${parts[1]}';
  return '${negative ? '-' : ''}${MoneyFormat.withSymbol('$whole$decimals')}';
}

/// Short form for chart axes: 1.2K, 3.4M.
String formatCompact(double value) {
  final double abs = value.abs();
  if (abs >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
  }
  if (abs >= 1000) {
    return '${(value / 1000).toStringAsFixed(abs >= 10000 ? 0 : 1)}K';
  }
  return value.toStringAsFixed(0);
}
