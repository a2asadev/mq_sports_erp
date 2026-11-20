import 'package:a2_stocks/l10n/l10n.dart';

/// A currency a business can use: how its amounts are written. All of them have
/// two decimals, like the server's money columns.
class CurrencyInfo {
  const CurrencyInfo({required this.code, required this.symbol});

  /// ISO 4217 code, as the server stores it ("PKR").
  final String code;

  /// What goes before an amount ("Rs", "$").
  final String symbol;

  /// The currency's name in the language of the app ("Pakistani rupee"); an
  /// unknown code is its own name.
  String get name {
    final AppLocalizations l10n = L10n.current;
    switch (code) {
      case 'PKR':
        return l10n.currencyPkr;
      case 'USD':
        return l10n.currencyUsd;
      case 'EUR':
        return l10n.currencyEur;
      case 'GBP':
        return l10n.currencyGbp;
      case 'AED':
        return l10n.currencyAed;
      case 'SAR':
        return l10n.currencySar;
      case 'QAR':
        return l10n.currencyQar;
      case 'INR':
        return l10n.currencyInr;
      case 'BDT':
        return l10n.currencyBdt;
      case 'CAD':
        return l10n.currencyCad;
      case 'AUD':
        return l10n.currencyAud;
      default:
        return code;
    }
  }

  static const CurrencyInfo pkr = CurrencyInfo(code: 'PKR', symbol: 'Rs');

  /// The currencies a business can choose (the server accepts the same codes).
  static const List<CurrencyInfo> supported = <CurrencyInfo>[
    pkr,
    CurrencyInfo(code: 'USD', symbol: r'$'),
    CurrencyInfo(code: 'EUR', symbol: '€'),
    CurrencyInfo(code: 'GBP', symbol: '£'),
    CurrencyInfo(code: 'AED', symbol: 'AED'),
    CurrencyInfo(code: 'SAR', symbol: 'SAR'),
    CurrencyInfo(code: 'QAR', symbol: 'QAR'),
    CurrencyInfo(code: 'INR', symbol: '₹'),
    CurrencyInfo(code: 'BDT', symbol: '৳'),
    CurrencyInfo(code: 'CAD', symbol: r'C$'),
    CurrencyInfo(code: 'AUD', symbol: r'A$'),
  ];

  /// The currency with this code. A code the app does not know is written as
  /// itself ("XYZ 1,250"), never as the wrong symbol.
  static CurrencyInfo byCode(String code) {
    for (final CurrencyInfo c in supported) {
      if (c.code == code) {
        return c;
      }
    }
    return CurrencyInfo(code: code, symbol: code);
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
