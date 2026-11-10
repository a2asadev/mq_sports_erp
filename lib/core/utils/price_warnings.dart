/// Soft pricing checks for a variant. The result is shown as warnings and
/// never blocks saving.
///
/// - Wholesale variant: retail must not be below wholesale, and wholesale
///   must not be below cost.
/// - Normal variant: the sale price must not be below cost.
List<String> priceWarnings({
  required bool isWholesale,
  required double costPrice,
  required double wholesalePrice,
  required double salePrice,
}) {
  final List<String> warnings = <String>[];
  if (isWholesale) {
    if (salePrice < wholesalePrice) {
      warnings.add('Retail price is less than the wholesale price.');
    }
    if (wholesalePrice < costPrice) {
      warnings.add('Wholesale price is less than the cost price.');
    }
  } else if (salePrice < costPrice) {
    warnings.add('Sale price is less than the cost price.');
  }
  return warnings;
}
