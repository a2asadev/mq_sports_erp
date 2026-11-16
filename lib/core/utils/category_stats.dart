import 'package:a2_stocks/core/utils/category_tree.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_model.dart';

/// What a category table row shows about one category.
class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.depth,
    required this.parentName,
    required this.directProducts,
    required this.totalProducts,
    required this.children,
  });

  final CategoryModel category;

  /// 0 = top level.
  final int depth;

  /// '' for a top-level category.
  final String parentName;

  /// Products placed directly in this category.
  final int directProducts;

  /// Products in this category and in everything below it.
  final int totalProducts;

  /// Direct subcategories, by name.
  final List<CategoryModel> children;

  int get subcategoryCount => children.length;

  int get productsInSubcategories => totalProducts - directProducts;
}

/// Counts for every category: direct and total products and the direct
/// subcategories. Result is in tree order (parents before their children).
List<CategoryStat> computeCategoryStats({
  required List<CategoryModel> categories,
  required List<ProductModel> products,
}) {
  final Map<String, int> direct = <String, int>{};
  for (final ProductModel p in products) {
    direct[p.categoryId] = (direct[p.categoryId] ?? 0) + 1;
  }
  final Map<String, String> names = <String, String>{
    for (final CategoryModel c in categories) c.id: c.name,
  };
  final Map<String, List<CategoryModel>> childrenOf = <String, List<CategoryModel>>{};
  for (final CategoryModel c in categories) {
    if (c.parentId.isNotEmpty && c.parentId != c.id && names.containsKey(c.parentId)) {
      childrenOf.putIfAbsent(c.parentId, () => <CategoryModel>[]).add(c);
    }
  }
  for (final List<CategoryModel> list in childrenOf.values) {
    list.sort((CategoryModel a, CategoryModel b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  int totalOf(String id) {
    int sum = direct[id] ?? 0;
    for (final String below in CategoryTree.descendantIds(id, categories)) {
      sum += direct[below] ?? 0;
    }
    return sum;
  }

  return <CategoryStat>[
    for (final CategoryNode node in CategoryTree.flatten(categories))
      CategoryStat(
        category: node.category,
        depth: node.depth,
        parentName: names[node.category.parentId] ?? '',
        directProducts: direct[node.category.id] ?? 0,
        totalProducts: totalOf(node.category.id),
        children: childrenOf[node.category.id] ?? const <CategoryModel>[],
      ),
  ];
}
