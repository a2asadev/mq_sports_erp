/// Builds readable SKUs such as `sht-sml` from a product name and a variant's
/// option values.
///
/// Each word is shortened by keeping its first letter, dropping the other
/// vowels, and (if still longer than three letters) keeping the first two
/// letters plus the last: shirt -> sht, small -> sml, large -> lrg.
class SkuGenerator {
  const SkuGenerator._();

  static final RegExp _separators = RegExp(r'[^A-Za-z0-9]+');
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');
  static final RegExp _vowels = RegExp(r'[aeiou]');

  static String _abbreviateWord(String word) {
    final String cleaned = word.toLowerCase().replaceAll(_separators, '');
    if (cleaned.isEmpty) {
      return '';
    }
    if (_digitsOnly.hasMatch(cleaned)) {
      return cleaned;
    }
    final String devoweled =
        cleaned.substring(0, 1) + cleaned.substring(1).replaceAll(_vowels, '');
    if (devoweled.length <= 3) {
      return devoweled;
    }
    return devoweled.substring(0, 2) + devoweled.substring(devoweled.length - 1);
  }

  /// Shortens every word of [text] and joins them without a separator.
  static String _abbreviateText(String text) {
    return text
        .split(_separators)
        .where((String word) => word.isNotEmpty)
        .map(_abbreviateWord)
        .join();
  }

  /// Returns a SKU, or an empty string when there is nothing to build it
  /// from. The product part uses the first word of [productName]; the variant
  /// part uses [attributeValues], or [variantName] when there are none. If
  /// the result is already in [existingSkus] (compared ignoring case), a
  /// number is appended.
  static String generate({
    required String productName,
    required String variantName,
    required List<String> attributeValues,
    Set<String> existingSkus = const <String>{},
  }) {
    final List<String> parts = <String>[];
    final List<String> productWords = productName
        .split(_separators)
        .where((String word) => word.isNotEmpty)
        .toList();
    if (productWords.isNotEmpty) {
      parts.add(_abbreviateWord(productWords.first));
    }
    final List<String> variantSources = attributeValues
        .where((String value) => value.trim().isNotEmpty)
        .toList();
    if (variantSources.isEmpty && variantName.trim().isNotEmpty) {
      variantSources.add(variantName);
    }
    for (final String source in variantSources) {
      parts.add(_abbreviateText(source));
    }
    final String base = parts.where((String p) => p.isNotEmpty).join('-');
    if (base.isEmpty) {
      return '';
    }
    final Set<String> taken =
        existingSkus.map((String s) => s.trim().toLowerCase()).toSet();
    String candidate = base;
    int counter = 2;
    while (taken.contains(candidate)) {
      candidate = '$base-$counter';
      counter++;
    }
    return candidate;
  }
}
