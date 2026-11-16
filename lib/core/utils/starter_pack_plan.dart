import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/starter_pack.dart';

/// What adding some groups of a starter pack would do to a business's categories,
/// worked out on the device the same way the server does it: a category with the
/// same name under the same parent (ignoring case, active or not) is already
/// there and is left alone; everything else is added.
class StarterPackPlan {
  const StarterPackPlan({required this.toAdd, required this.alreadyThere});

  /// New categories: groups and subcategories.
  final int toAdd;

  /// Categories the business already has under these names.
  final int alreadyThere;

  static StarterPackPlan compute(List<StarterGroup> groups, List<CategoryModel> existing) {
    final Map<String, String> top = <String, String>{};
    final Map<String, Set<String>> kids = <String, Set<String>>{};
    for (final CategoryModel c in existing) {
      final String key = c.name.trim().toLowerCase();
      if (c.parentId.isEmpty) {
        top[key] = c.id;
      } else {
        kids.putIfAbsent(c.parentId, () => <String>{}).add(key);
      }
    }
    int toAdd = 0;
    int there = 0;
    for (final StarterGroup group in groups) {
      final String? id = top[group.name.toLowerCase()];
      if (id == null) {
        toAdd++;
      } else {
        there++;
      }
      final Set<String> have = id == null ? <String>{} : (kids[id] ?? <String>{});
      for (final String child in group.children) {
        if (have.contains(child.toLowerCase())) {
          there++;
        } else {
          toAdd++;
        }
      }
    }
    return StarterPackPlan(toAdd: toAdd, alreadyThere: there);
  }

  /// Whether the business already has this top-level category.
  static bool hasGroup(StarterGroup group, List<CategoryModel> existing) => existing.any(
        (CategoryModel c) => c.parentId.isEmpty && c.name.trim().toLowerCase() == group.name.toLowerCase(),
      );
}
