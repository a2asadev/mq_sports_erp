enum PromotionKind {
  percent,
  amount;

  static PromotionKind fromName(String? name) => name == 'amount' ? PromotionKind.amount : PromotionKind.percent;
}

/// order = off the whole order; category = off the items of a category (and its sub-categories);
/// product = off the items of one product.
enum PromotionScope {
  order,
  category,
  product;

  static PromotionScope fromName(String? name) {
    for (final PromotionScope s in PromotionScope.values) {
      if (s.name == name) {
        return s;
      }
    }
    return PromotionScope.order;
  }
}

/// A discount the business offers (`/v1/promotions`). See `evaluatePromotions` for the rule.
class Promotion {
  const Promotion({
    required this.id,
    required this.name,
    required this.kind,
    required this.value,
    required this.scope,
    this.targetId,
    this.targetName = '',
    this.minQuantity = 1,
    this.minAmount = 0,
    this.code = '',
    this.channels = const <String>['pos', 'web'],
    this.startsOn,
    this.endsOn,
    this.isActive = true,
    this.byName = '',
  });

  final String id;
  final String name;
  final PromotionKind kind;

  /// A percent (1 to 100), or an amount of money.
  final double value;
  final PromotionScope scope;

  /// The category or the product; null for a whole-order promotion.
  final String? targetId;

  /// The target's name when the promotion was saved.
  final String targetName;

  /// Bulk tier: units of the target needed (1 = no minimum).
  final int minQuantity;

  /// Order promotions: the least the order must come to.
  final double minAmount;

  /// A coupon the customer has to name; '' = applies by itself.
  final String code;
  final List<String> channels;

  /// "YYYY-MM-DD", or null.
  final String? startsOn;
  final String? endsOn;
  final bool isActive;
  final String byName;

  bool get isCoupon => code.isNotEmpty;

  /// Open today: switched on and inside its dates ([today] is "YYYY-MM-DD").
  bool isOpenOn(String today) => isActive && (startsOn == null || startsOn!.compareTo(today) <= 0) && (endsOn == null || endsOn!.compareTo(today) >= 0);

  factory Promotion.fromMap(Map<String, dynamic> m) {
    final Object? channels = m['channels'];
    return Promotion(
      id: '${m['id'] ?? ''}',
      name: '${m['name'] ?? ''}',
      kind: PromotionKind.fromName(m['kind'] as String?),
      value: (m['value'] as num?)?.toDouble() ?? 0,
      scope: PromotionScope.fromName(m['scope'] as String?),
      targetId: m['targetId'] is String ? m['targetId'] as String : null,
      targetName: '${m['targetName'] ?? ''}',
      minQuantity: (m['minQuantity'] as num?)?.toInt() ?? 1,
      minAmount: (m['minAmount'] as num?)?.toDouble() ?? 0,
      code: '${m['code'] ?? ''}',
      channels: channels is List<Object?> ? <String>[for (final Object? c in channels) '$c'] : const <String>['pos', 'web'],
      startsOn: m['startsOn'] is String && (m['startsOn'] as String).isNotEmpty ? m['startsOn'] as String : null,
      endsOn: m['endsOn'] is String && (m['endsOn'] as String).isNotEmpty ? m['endsOn'] as String : null,
      isActive: m['isActive'] != false,
      byName: '${m['byName'] ?? ''}',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'kind': kind.name,
        'value': value,
        'scope': scope.name,
        'targetId': targetId,
        'targetName': targetName,
        'minQuantity': minQuantity,
        'minAmount': minAmount,
        'code': code,
        'channels': channels,
        'startsOn': startsOn,
        'endsOn': endsOn,
        'isActive': isActive,
        'byName': byName,
      };
}
