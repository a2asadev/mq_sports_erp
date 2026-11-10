/// dd/MM/yyyy
String formatDate(DateTime date) {
  final DateTime local = date.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}';
}

/// Amount with two decimals, no currency symbol.
String formatAmount(double amount) => amount.toStringAsFixed(2);
