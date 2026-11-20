import 'package:a2_stocks/models/business_info.dart';

/// The tax rules of a business: GST and/or VAT as percentages (0 = not charged), both applied to
/// the SAME goods price, added on top of it or already inside it.
class TaxSettings {
  const TaxSettings({this.enabled = false, this.gstRate = 0, this.vatRate = 0, this.pricesIncludeTax = false});

  /// No tax at all (what a business has until its admin switches tax on).
  static const TaxSettings none = TaxSettings();

  final bool enabled;
  final double gstRate;
  final double vatRate;

  /// The shelf price already contains the tax (the tax is worked out from it); else it is added on top.
  final bool pricesIncludeTax;

  factory TaxSettings.of(BusinessInfo business) => TaxSettings(
        enabled: business.taxEnabled,
        gstRate: business.gstRate,
        vatRate: business.vatRate,
        pricesIncludeTax: business.pricesIncludeTax,
      );

  /// Whether any tax is charged.
  bool get charges => enabled && gstRate + vatRate > 0;

  @override
  bool operator ==(Object other) =>
      other is TaxSettings &&
      other.enabled == enabled &&
      other.gstRate == gstRate &&
      other.vatRate == vatRate &&
      other.pricesIncludeTax == pricesIncludeTax;

  @override
  int get hashCode => Object.hash(enabled, gstRate, vatRate, pricesIncludeTax);
}

/// The tax on a sale: GST and VAT amounts, the rates they were charged at, and whether the prices
/// already contained them.
class TaxResult {
  const TaxResult({this.gst = 0, this.vat = 0, this.gstRate = 0, this.vatRate = 0, this.inclusive = false});

  static const TaxResult none = TaxResult();

  final double gst;
  final double vat;
  final double gstRate;
  final double vatRate;
  final bool inclusive;

  double get total => ((gst + vat) * 100).round() / 100;

  /// What the tax adds to the price: nothing when the price already contains it.
  double get added => inclusive ? 0 : total;

  bool get isNone => total <= 0.004 && gst <= 0.004 && vat <= 0.004;
}

/// The tax on goods worth [goodsAfterDiscounts] (line and order discounts already taken off; never the
/// delivery fee). This follows the server's rule to the cent, because the server has the final say:
/// rates in hundredths of a percent; added on top it is `base x rate / 100`; inside the price each share is
/// `base x rate / (100 + gst + vat)`.
TaxResult computeTax(double goodsAfterDiscounts, TaxSettings settings) {
  if (!settings.charges) {
    return TaxResult.none;
  }
  final int base = (goodsAfterDiscounts * 100).round();
  final int gstBp = (settings.gstRate * 100).round();
  final int vatBp = (settings.vatRate * 100).round();
  final int divisor = settings.pricesIncludeTax ? 10000 + gstBp + vatBp : 10000;
  return TaxResult(
    gst: (base * gstBp / divisor).round() / 100,
    vat: (base * vatBp / divisor).round() / 100,
    gstRate: gstBp / 100,
    vatRate: vatBp / 100,
    inclusive: settings.pricesIncludeTax,
  );
}
