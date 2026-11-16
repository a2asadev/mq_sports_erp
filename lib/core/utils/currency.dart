/// A currency a business can use: how its amounts are written. All of them have
/// two decimals, like the server's money columns.
class CurrencyInfo {
  const CurrencyInfo({required this.code, required this.symbol, required this.name});

  /// ISO 4217 code, as the server stores it ("PKR").
  final String code;

  /// What goes before an amount ("Rs", "$").
  final String symbol;
  final String name;

  static const CurrencyInfo pkr = CurrencyInfo(code: 'PKR', symbol: 'Rs', name: 'Pakistani rupee');

  /// The currencies a business can choose (the server accepts the same codes).
  static const List<CurrencyInfo> supported = <CurrencyInfo>[
    pkr,
    CurrencyInfo(code: 'USD', symbol: r'$', name: 'US dollar'),
    CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencyInfo(code: 'GBP', symbol: '£', name: 'British pound'),
    CurrencyInfo(code: 'AED', symbol: 'AED', name: 'UAE dirham'),
    CurrencyInfo(code: 'SAR', symbol: 'SAR', name: 'Saudi riyal'),
    CurrencyInfo(code: 'QAR', symbol: 'QAR', name: 'Qatari riyal'),
    CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian rupee'),
    CurrencyInfo(code: 'BDT', symbol: '৳', name: 'Bangladeshi taka'),
    CurrencyInfo(code: 'CAD', symbol: r'C$', name: 'Canadian dollar'),
    CurrencyInfo(code: 'AUD', symbol: r'A$', name: 'Australian dollar'),
  ];

  /// The currency with this code. A code the app does not know is written as
  /// itself ("XYZ 1,250"), never as the wrong symbol.
  static CurrencyInfo byCode(String code) {
    for (final CurrencyInfo c in supported) {
      if (c.code == code) {
        return c;
      }
    }
    return CurrencyInfo(code: code, symbol: code, name: code);
  }

  /// A symbol made of letters is followed by a space ("Rs 5", "AED 5"); a sign
  /// is attached ("$5", "€5").
  bool get _isWord => RegExp(r'[A-Za-z]$').hasMatch(symbol);

  /// What goes right before the digits: "Rs " or "$".
  String get prefix => _isWord ? '$symbol ' : symbol;

  @override
  bool operator ==(Object other) => other is CurrencyInfo && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// The currency of the business the signed-in user works for, used wherever an
/// amount is written (screens, receipts, messages). The app sets it when the
/// business is known (see `businessProvider`); until then it is rupees, the
/// currency of the first business.
///
/// A plain holder, not provider state, because amounts are written in many
/// places that have no access to providers (receipt text, PDFs).
class MoneyFormat {
  const MoneyFormat._();

  static CurrencyInfo current = CurrencyInfo.pkr;

  /// Switches to the currency with this code.
  static void use(String code) {
    current = CurrencyInfo.byCode(code);
  }

  /// "Rs ", "$" … for a text field's prefix.
  static String get prefix => current.prefix;

  /// The symbol alone ("Rs", "$").
  static String get symbol => current.symbol;

  /// [digits] ("1,250") with the currency in front: "Rs 1,250", "$1,250".
  static String withSymbol(String digits) => '${current.prefix}$digits';
}
