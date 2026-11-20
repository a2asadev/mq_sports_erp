import 'package:a2_stocks/models/promotion.dart';

/// One line of the cart, as the engine sees it.
class PromoLine {
  const PromoLine({
    required this.key,
    required this.productId,
    required this.categoryIds,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  /// Anything that tells the lines apart (the variant id).
  final String key;
  final String productId;

  /// The product's category and all the categories above it.
  final List<String> categoryIds;
  final int quantity;
  final double unitPrice;

  /// The line's own discount (a total, not per unit).
  final double discount;
}

class PromoLineResult {
  const PromoLineResult({required this.key, required this.discount, required this.promotionId});

  final String key;

  /// What the promotion takes off this line (a total for the line).
  final double discount;
  final String promotionId;
}

class AppliedPromotion {
  const AppliedPromotion({required this.promotionId, required this.name, required this.amount});

  final String promotionId;
  final String name;
  final double amount;
}

class PromoResult {
  const PromoResult({
    this.lines = const <PromoLineResult>[],
    this.orderDiscount = 0,
    this.orderPromotionId = '',
    this.total = 0,
    this.applied = const <AppliedPromotion>[],
  });

  static const PromoResult none = PromoResult();

  final List<PromoLineResult> lines;

  /// Off the whole order (after the line promotions).
  final double orderDiscount;
  final String orderPromotionId;

  /// Everything taken off by promotions.
  final double total;
  final List<AppliedPromotion> applied;

  /// What the line promotions take off, all lines together.
  double get lineTotal => ((total - orderDiscount) * 100).round() / 100;

  double discountOf(String key) {
    for (final PromoLineResult l in lines) {
      if (l.key == key) {
        return l.discount;
      }
    }
    return 0;
  }
}

int _cents(double v) => (v * 100).round();

/// Whether the promotion can apply at all: switched on, inside its dates ([today], "YYYY-MM-DD"), for this
/// [channel], and with no code or the code that was entered (any letter case).
bool promotionIsEligible(Promotion p, {required String today, required String channel, String couponCode = ''}) {
  if (!p.isOpenOn(today) || !p.channels.contains(channel)) {
    return false;
  }
  return p.code.isEmpty || p.code.toLowerCase() == couponCode.trim().toLowerCase();
}

/// Whether a promotion with this code exists and is open today (to tell the cashier a coupon is no good).
bool couponIsValid(List<Promotion> rules, {required String today, required String channel, required String couponCode}) {
  final String code = couponCode.trim().toLowerCase();
  return code.isNotEmpty && rules.any((Promotion p) => p.code.isNotEmpty && p.code.toLowerCase() == code && promotionIsEligible(p, today: today, channel: channel, couponCode: couponCode));
}

/// Which promotions apply to a cart and how much they take off. The same rule as the server's
/// (`promotion-engine.ts`), which has the final say, so the counter can apply promotions without a connection:
///
/// - Line promotions (product or category): the units of the target in the cart must reach `minQuantity` (a bulk
///   tier; the units of all matching lines count together). A percent takes that percent off each matching line's
///   price after its own discount; an amount takes that amount off every unit. Each line gets the single BEST
///   promotion (they do not add up).
/// - Order promotions: once the lines are done, the best order promotion whose `minAmount` the subtotal reaches
///   takes a percent of the subtotal, or a flat amount, off the whole order.
/// - A discount never takes a price below zero.
PromoResult evaluatePromotions(
  List<Promotion> rules,
  List<PromoLine> lines, {
  required String today,
  required String channel,
  String couponCode = '',
}) {
  final List<Promotion> eligible = rules.where((Promotion r) => promotionIsEligible(r, today: today, channel: channel, couponCode: couponCode)).toList();
  bool matches(Promotion rule, PromoLine line) => rule.scope == PromotionScope.product
      ? rule.targetId == line.productId
      : rule.scope == PromotionScope.category && rule.targetId != null && line.categoryIds.contains(rule.targetId);

  final List<PromoLineResult> results = <PromoLineResult>[];
  for (final PromoLine line in lines) {
    final int net = (_cents(line.unitPrice) * line.quantity - _cents(line.discount)).clamp(0, 1 << 52);
    int bestCents = 0;
    String bestId = '';
    for (final Promotion rule in eligible) {
      if (rule.scope == PromotionScope.order || !matches(rule, line)) {
        continue;
      }
      final int units = lines.where((PromoLine l) => matches(rule, l)).fold<int>(0, (int s, PromoLine l) => s + l.quantity);
      if (units < (rule.minQuantity < 1 ? 1 : rule.minQuantity)) {
        continue;
      }
      final int off = rule.kind == PromotionKind.percent ? (net * _cents(rule.value) / 10000).round() : (_cents(rule.value) * line.quantity < net ? _cents(rule.value) * line.quantity : net);
      if (off > bestCents || (off == bestCents && off > 0 && rule.id.compareTo(bestId) < 0)) {
        bestCents = off;
        bestId = rule.id;
      }
    }
    results.add(PromoLineResult(key: line.key, discount: bestCents / 100, promotionId: bestId));
  }

  int subtotal = 0;
  for (int i = 0; i < lines.length; i++) {
    final int net = (_cents(lines[i].unitPrice) * lines[i].quantity - _cents(lines[i].discount)).clamp(0, 1 << 52);
    subtotal += net - _cents(results[i].discount);
  }
  int orderCents = 0;
  String orderId = '';
  for (final Promotion rule in eligible) {
    if (rule.scope != PromotionScope.order || subtotal < _cents(rule.minAmount)) {
      continue;
    }
    final int off = rule.kind == PromotionKind.percent ? (subtotal * _cents(rule.value) / 10000).round() : (_cents(rule.value) < subtotal ? _cents(rule.value) : subtotal);
    if (off > orderCents || (off == orderCents && off > 0 && rule.id.compareTo(orderId) < 0)) {
      orderCents = off;
      orderId = rule.id;
    }
  }

  final Map<String, int> byPromo = <String, int>{};
  for (final PromoLineResult r in results) {
    if (r.promotionId.isNotEmpty && r.discount > 0) {
      byPromo[r.promotionId] = (byPromo[r.promotionId] ?? 0) + _cents(r.discount);
    }
  }
  if (orderId.isNotEmpty && orderCents > 0) {
    byPromo[orderId] = (byPromo[orderId] ?? 0) + orderCents;
  }
  final int total = results.fold<int>(0, (int s, PromoLineResult r) => s + _cents(r.discount)) + orderCents;
  return PromoResult(
    lines: results,
    orderDiscount: orderCents / 100,
    orderPromotionId: orderId,
    total: total / 100,
    applied: <AppliedPromotion>[
      for (final MapEntry<String, int> e in byPromo.entries)
        AppliedPromotion(
          promotionId: e.key,
          name: rules.where((Promotion r) => r.id == e.key).map((Promotion r) => r.name).firstOrNull ?? '',
          amount: e.value / 100,
        ),
    ],
  );
}
