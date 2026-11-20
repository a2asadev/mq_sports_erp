import 'package:a2_stocks/l10n/l10n.dart';
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
      warnings.add(L10n.current.priceWarningsRetailPriceIsLess);
    }
    if (wholesalePrice < costPrice) {
      warnings.add(L10n.current.priceWarningsWholesalePriceIsLess);
    }
  } else if (salePrice < costPrice) {
    warnings.add(L10n.current.priceWarningsSalePriceIsLess);
  }
  return warnings;
}
