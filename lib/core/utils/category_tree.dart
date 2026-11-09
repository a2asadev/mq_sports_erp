import 'package:mq_sports_erp/models/category_model.dart';

/// A category together with its depth in the tree (0 = top level).
class CategoryNode {
  const CategoryNode(this.category, this.depth);

  final CategoryModel category;
  final int depth;
}

/// Helpers for the category tree, which is stored as a flat list with
/// `parentId` links.
class CategoryTree {
  const CategoryTree._();

  static int _byName(CategoryModel a, CategoryModel b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  /// Depth-first, name-sorted list. Categories whose parent is missing (or
  /// that sit in a cycle) are shown at the top level so nothing disappears.
  static List<CategoryNode> flatten(List<CategoryModel> all) {
    final Set<String> ids = <String>{for (final CategoryModel c in all) c.id};
    final Map<String, List<CategoryModel>> children =
        <String, List<CategoryModel>>{};
    final List<CategoryModel> roots = <CategoryModel>[];
    for (final CategoryModel category in all) {
      final bool isRoot = category.parentId.isEmpty ||
          category.parentId == category.id ||
          !ids.contains(category.parentId);
      if (isRoot) {
        roots.add(category);
      } else {
        children
            .putIfAbsent(category.parentId, () => <CategoryModel>[])
            .add(category);
      }
    }
    final List<CategoryNode> result = <CategoryNode>[];
    final Set<String> visited = <String>{};

    void visit(CategoryModel category, int depth) {
      if (!visited.add(category.id)) {
        return;
      }
      result.add(CategoryNode(category, depth));
      final List<CategoryModel> kids = <CategoryModel>[
        ...(children[category.id] ?? <CategoryModel>[]),
      ]..sort(_byName);
      for (final CategoryModel kid in kids) {
        visit(kid, depth + 1);
      }
    }

    roots.sort(_byName);
    for (final CategoryModel root in roots) {
      visit(root, 0);
    }
    for (final CategoryModel category in all) {
      visit(category, 0);
    }
    return result;
  }

  /// Ids of every category below [id], at any depth.
  static Set<String> descendantIds(String id, List<CategoryModel> all) {
    final Set<String> result = <String>{};
    final List<String> queue = <String>[id];
    while (queue.isNotEmpty) {
      final String current = queue.removeLast();
      for (final CategoryModel category in all) {
        if (category.parentId == current && result.add(category.id)) {
          queue.add(category.id);
        }
      }
    }
    result.remove(id);
    return result;
  }

  /// Full path such as `Cricket > Bats > Kashmir Willow`; empty if unknown.
  static String pathOf(String id, List<CategoryModel> all) {
    final Map<String, CategoryModel> byId = <String, CategoryModel>{
      for (final CategoryModel c in all) c.id: c,
    };
    final List<String> names = <String>[];
    final Set<String> seen = <String>{};
    String? currentId = id;
    while (currentId != null && currentId.isNotEmpty && seen.add(currentId)) {
      final CategoryModel? category = byId[currentId];
      if (category == null) {
        break;
      }
      names.insert(0, category.name);
      currentId = category.parentId;
    }
    return names.join(' > ');
  }

  /// Dropdown options (id -> path) in tree order, skipping [exclude].
  static List<MapEntry<String, String>> options(
    List<CategoryModel> all, {
    Set<String> exclude = const <String>{},
  }) {
    return <MapEntry<String, String>>[
      for (final CategoryNode node in flatten(all))
        if (!exclude.contains(node.category.id))
          MapEntry<String, String>(
            node.category.id,
            pathOf(node.category.id, all),
          ),
    ];
  }
}
