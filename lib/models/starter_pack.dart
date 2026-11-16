/// A top-level category of a starter pack, with its subcategories.
class StarterGroup {
  const StarterGroup({required this.name, required this.children});

  final String name;
  final List<String> children;

  /// The group and its subcategories.
  int get categoryCount => 1 + children.length;

  static StarterGroup? tryFromMap(Object? map) {
    if (map is! Map<String, dynamic>) {
      return null;
    }
    final Object? name = map['name'];
    final Object? children = map['children'];
    if (name is! String || name.trim().isEmpty) {
      return null;
    }
    return StarterGroup(
      name: name,
      children: <String>[
        if (children is List<Object?>)
          for (final Object? c in children)
            if (c is String && c.trim().isNotEmpty) c,
      ],
    );
  }
}

/// A ready-made category tree for a type of business (`/v1/starter-packs`).
class StarterPack {
  const StarterPack({
    required this.id,
    required this.name,
    required this.description,
    required this.groups,
  });

  final String id;
  final String name;
  final String description;
  final List<StarterGroup> groups;

  /// Groups plus subcategories.
  int get categoryCount => groups.fold<int>(0, (int sum, StarterGroup g) => sum + g.categoryCount);

  static StarterPack? tryFromMap(Object? map) {
    if (map is! Map<String, dynamic>) {
      return null;
    }
    final Object? id = map['id'];
    final Object? name = map['name'];
    final Object? groups = map['groups'];
    if (id is! String || id.isEmpty || name is! String || name.trim().isEmpty) {
      return null;
    }
    final Object? description = map['description'];
    return StarterPack(
      id: id,
      name: name,
      description: description is String ? description : '',
      groups: <StarterGroup>[
        if (groups is List<Object?>)
          for (final Object? g in groups)
            if (StarterGroup.tryFromMap(g) case final StarterGroup group) group,
      ],
    );
  }
}

/// What applying a pack did.
class StarterPackResult {
  const StarterPackResult({required this.created, required this.skipped});

  /// Categories added.
  final int created;

  /// Categories the business already had, left as they were.
  final int skipped;

  factory StarterPackResult.fromMap(Map<String, dynamic> map) => StarterPackResult(
        created: (map['created'] as num?)?.toInt() ?? 0,
        skipped: (map['skipped'] as num?)?.toInt() ?? 0,
      );
}
