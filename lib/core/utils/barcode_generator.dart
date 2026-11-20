import 'dart:math';

/// The check digit of the first 12 digits of an EAN-13 bar code.
int ean13CheckDigit(String first12) {
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    final int digit = first12.codeUnitAt(i) - 48;
    sum += i.isEven ? digit : digit * 3;
  }
  return (10 - sum % 10) % 10;
}

/// Whether [code] is a well-formed EAN-13 (13 digits with the right check digit).
bool isValidEan13(String code) =>
    RegExp(r'^\d{13}$').hasMatch(code) && ean13CheckDigit(code.substring(0, 12)) == code.codeUnitAt(12) - 48;

/// A new bar code for an item that has none: an EAN-13 starting with 2 (the range the standard keeps for a
/// shop's own numbering, so it never clashes with a manufacturer's code), 11 random digits and the check digit.
/// It is not in [taken] (compared in lower case, so letters never matter).
String generateBarcode(Set<String> taken, {Random? random}) {
  final Random rng = random ?? Random.secure();
  while (true) {
    final StringBuffer digits = StringBuffer('2');
    for (int i = 0; i < 11; i++) {
      digits.write(rng.nextInt(10));
    }
    final String first12 = digits.toString();
    final String code = '$first12${ean13CheckDigit(first12)}';
    if (!taken.contains(code.toLowerCase())) {
      return code;
    }
  }
}
