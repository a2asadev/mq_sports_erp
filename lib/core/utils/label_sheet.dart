/// A label size: one label per page on a label roll (the printer cuts between labels), or a grid of labels on
/// an A4 sheet of sticky labels. Sizes are in millimetres.
class LabelSpec {
  const LabelSpec({
    required this.id,
    required this.pageWidthMm,
    required this.pageHeightMm,
    this.columns = 1,
    this.rows = 1,
    this.marginMm = 0,
  });

  final String id;
  final double pageWidthMm;
  final double pageHeightMm;
  final int columns;
  final int rows;

  /// Empty edge of the page (sheets: where the printer cannot print).
  final double marginMm;

  double get labelWidthMm => (pageWidthMm - 2 * marginMm) / columns;
  double get labelHeightMm => (pageHeightMm - 2 * marginMm) / rows;
  int get perPage => columns * rows;

  /// A grid on a sheet (more than one label per page).
  bool get isSheet => perPage > 1;

  /// Pages needed for [labels] labels when the first [skip] places of the first sheet are already used.
  int pagesFor(int labels, {int skip = 0}) => labels <= 0 ? 0 : ((labels + skip) / perPage).ceil();

  static const LabelSpec roll50x30 = LabelSpec(id: 'roll50x30', pageWidthMm: 50, pageHeightMm: 30);
  static const LabelSpec roll40x25 = LabelSpec(id: 'roll40x25', pageWidthMm: 40, pageHeightMm: 25);
  static const LabelSpec roll60x40 = LabelSpec(id: 'roll60x40', pageWidthMm: 60, pageHeightMm: 40);
  static const LabelSpec a4x14 = LabelSpec(id: 'a4x14', pageWidthMm: 210, pageHeightMm: 297, columns: 2, rows: 7, marginMm: 5);
  static const LabelSpec a4x24 = LabelSpec(id: 'a4x24', pageWidthMm: 210, pageHeightMm: 297, columns: 3, rows: 8, marginMm: 5);
  static const LabelSpec a4x40 = LabelSpec(id: 'a4x40', pageWidthMm: 210, pageHeightMm: 297, columns: 4, rows: 10, marginMm: 5);

  static const List<LabelSpec> presets = <LabelSpec>[roll50x30, roll40x25, roll60x40, a4x24, a4x40, a4x14];

  static LabelSpec byId(String? id) => presets.firstWhere((LabelSpec s) => s.id == id, orElse: () => roll50x30);
}

/// One item to put labels on.
class LabelItem {
  const LabelItem({
    required this.name,
    required this.variantLabel,
    required this.sku,
    required this.price,
    required this.code,
    required this.copies,
  });

  final String name;
  final String variantLabel;
  final String sku;
  final double price;

  /// What the bar code says: the item's barcode, else its SKU; '' prints no bars.
  final String code;
  final int copies;
}
