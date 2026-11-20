import 'package:a2_stocks/l10n/l10n.dart';
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

/// How much of a starter pack a business already has. Used to suggest the packs
/// that look like the business, never to hide the others.
class StarterPackMatch {
  const StarterPackMatch({
    required this.pack,
    required this.matchedGroups,
    required this.alreadyThere,
    required this.total,
  });

  /// A suggestion needs at least this many of the pack's groups already there...
  static const int minGroups = 2;

  /// ...and at least this share of the pack's groups.
  static const double minShare = 0.15;

  final StarterPack pack;

  /// Names of the pack's groups the business already has, in pack order.
  final List<String> matchedGroups;

  /// Categories of the pack (groups and subcategories) already there.
  final int alreadyThere;

  /// All categories of the pack.
  final int total;

  /// Whether the pack looks like this business.
  bool get isSuggested =>
      pack.groups.isNotEmpty &&
      matchedGroups.length >= minGroups &&
      matchedGroups.length / pack.groups.length >= minShare;

  double get share => pack.groups.isEmpty ? 0 : matchedGroups.length / pack.groups.length;

  static StarterPackMatch compute(StarterPack pack, List<CategoryModel> existing) {
    final StarterPackPlan plan = StarterPackPlan.compute(pack.groups, existing);
    return StarterPackMatch(
      pack: pack,
      matchedGroups: <String>[
        for (final StarterGroup g in pack.groups)
          if (StarterPackPlan.hasGroup(g, existing)) g.name,
      ],
      alreadyThere: plan.alreadyThere,
      total: pack.categoryCount,
    );
  }

  /// Suggested packs (best match first) and the remaining packs (server order).
  static ({List<StarterPackMatch> suggested, List<StarterPackMatch> others}) split(
    List<StarterPack> packs,
    List<CategoryModel> existing,
  ) {
    final List<StarterPackMatch> all = <StarterPackMatch>[
      for (final StarterPack p in packs) compute(p, existing),
    ];
    final List<StarterPackMatch> suggested = all.where((StarterPackMatch m) => m.isSuggested).toList()
      ..sort((StarterPackMatch a, StarterPackMatch b) => b.share.compareTo(a.share));
    return (
      suggested: suggested,
      others: all.where((StarterPackMatch m) => !m.isSuggested).toList(),
    );
  }

  /// "Cricket", "Cricket and Footwear", "Cricket, Footwear and Fitness",
  /// "Cricket, Footwear, Fitness and 2 more".
  String matchedText(AppLocalizations l10n) {
    final List<String> names = matchedGroups;
    switch (names.length) {
      case 0:
        return '';
      case 1:
        return l10n.starterPackMatchedOne(names[0]);
      case 2:
        return l10n.starterPackMatchedTwo(names[0], names[1]);
      case 3:
        return l10n.starterPackMatchedThree(names[0], names[1], names[2]);
      default:
        return l10n.starterPackMatchedMore(names[0], names[1], names[2], names.length - 3);
    }
  }
}
