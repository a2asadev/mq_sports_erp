import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2_stocks/core/utils/promotion_engine.dart';
import 'package:a2_stocks/core/utils/tax.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/promotion.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/promotions_service.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/pos_providers.dart';
import 'package:a2_stocks/models/product_model.dart';

final Provider<PromotionsService> promotionsServiceProvider =
    Provider<PromotionsService>((Ref ref) => PromotionsService(ref.watch(apiClientProvider)));

/// Every promotion, for the page that keeps them (admin and manager; needs a connection).
final AutoDisposeFutureProvider<List<Promotion>> adminPromotionsProvider =
    FutureProvider.autoDispose<List<Promotion>>((Ref ref) => ref.watch(promotionsServiceProvider).list());

/// "YYYY-MM-DD" for today on this device.
String todayKey([DateTime? now]) {
  final DateTime d = now ?? DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// The promotions that are on, for the counter. A copy is kept on the device, so the counter applies them
/// without a connection; it is renewed whenever the server can be reached (at sign-in and after every sync).
class ActivePromotionsNotifier extends AsyncNotifier<List<Promotion>> {
  String get _key => 'promotions_active_${ref.read(businessProvider).id}';

  @override
  Future<List<Promotion>> build() async {
    ref.watch(syncTickProvider);
    final SharedPreferences? prefs = await _prefs();
    final List<Promotion> cached = _read(prefs);
    try {
      final List<Promotion> fresh = await ref.read(promotionsServiceProvider).active();
      await prefs?.setString(_key, jsonEncode(<Map<String, dynamic>>[for (final Promotion p in fresh) p.toMap()]));
      return fresh;
    } catch (_) {
      // No connection (or the server is busy): what was kept is used.
      return cached;
    }
  }

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  List<Promotion> _read(SharedPreferences? prefs) {
    final String? raw = prefs?.getString(_key);
    if (raw == null) {
      return <Promotion>[];
    }
    try {
      final Object? list = jsonDecode(raw);
      return <Promotion>[
        if (list is List<Object?>)
          for (final Object? i in list)
            if (i is Map<String, dynamic>) Promotion.fromMap(i),
      ];
    } catch (_) {
      return <Promotion>[];
    }
  }
}

final AsyncNotifierProvider<ActivePromotionsNotifier, List<Promotion>> activePromotionsProvider =
    AsyncNotifierProvider<ActivePromotionsNotifier, List<Promotion>>(ActivePromotionsNotifier.new);

/// The coupon code typed for the sale at the counter ('' = none).
final StateProvider<String> posCouponProvider = StateProvider<String>((Ref ref) => '');

/// The category of a product and all the categories above it, for promotions on a category.
List<String> categoryChain(String categoryId, List<CategoryModel> categories) {
  final Map<String, String> parent = <String, String>{for (final CategoryModel c in categories) c.id: c.parentId};
  final List<String> out = <String>[];
  String at = categoryId;
  while (at.isNotEmpty && !out.contains(at)) {
    out.add(at);
    at = parent[at] ?? '';
  }
  return out;
}

/// The sale at the counter with its promotions and tax worked out. Promotions take off first (a line one, then an
/// order one), then the cashier's own order discount, then the tax is worked out on what is left.
class PosPricing {
  const PosPricing({required this.cart, required this.promo, required this.taxSettings, this.couponAccepted = false});

  final PosCart cart;
  final PromoResult promo;
  final TaxSettings taxSettings;

  /// The coupon code typed was a good one.
  final bool couponAccepted;

  /// The promotion's discount on a line.
  double lineDiscount(PosLine l) => promo.discountOf(l.variantId);

  double get _afterLinePromos => ((cart.subtotal - promo.lineTotal) * 100).round() / 100;

  /// The cashier's own order discount, never more than is left.
  double get manualOrderDiscount => cart.effectiveOrderDiscount > _afterLinePromos ? _afterLinePromos : cart.effectiveOrderDiscount;

  /// What the order promotion takes off, never more than is left.
  double get orderPromotion {
    final double room = ((_afterLinePromos - manualOrderDiscount) * 100).round() / 100;
    return promo.orderDiscount > room ? room : promo.orderDiscount;
  }

  /// Everything the promotions take off (lines and order).
  double get promoTotal => ((promo.lineTotal + orderPromotion) * 100).round() / 100;

  /// The discount to send as the order's own (the cashier's plus the order promotion).
  double get orderDiscount => ((manualOrderDiscount + orderPromotion) * 100).round() / 100;

  /// The goods after every discount, before tax.
  double get goods => ((_afterLinePromos - orderDiscount) * 100).round() / 100;

  TaxResult get tax => computeTax(goods, taxSettings);

  /// What the customer pays.
  double get payable => ((goods + tax.added) * 100).round() / 100;

  /// The lines with the promotion's discount added to their own, for the order.
  List<OrderItem> items() => <OrderItem>[
        for (final PosLine l in cart.lines)
          () {
            final OrderItem base = l.toOrderItem();
            return OrderItem(
              id: base.id,
              productId: base.productId,
              variantId: base.variantId,
              productName: base.productName,
              variantLabel: base.variantLabel,
              sku: base.sku,
              quantity: base.quantity,
              unitPrice: base.unitPrice,
              discount: ((base.discount + lineDiscount(l)) * 100).round() / 100,
            );
          }(),
      ];

  /// The names of the promotions that took something off, for the order's note.
  List<String> get appliedNames => <String>[for (final AppliedPromotion a in promo.applied) a.name];
}

/// The sale at the counter, priced: promotions (the open ones kept on the device, and the coupon typed), then tax.
final Provider<PosPricing> posPricingProvider = Provider<PosPricing>((Ref ref) {
  final PosCart cart = ref.watch(posCartProvider);
  final List<Promotion> rules = ref.watch(activePromotionsProvider).valueOrNull ?? <Promotion>[];
  final List<CategoryModel> categories = ref.watch(categoriesProvider).valueOrNull ?? <CategoryModel>[];
  final List<ProductModel> products = ref.watch(productsProvider).valueOrNull ?? <ProductModel>[];
  final String coupon = ref.watch(posCouponProvider);
  final TaxSettings tax = ref.watch(businessProvider.select(TaxSettings.of));
  final Map<String, String> categoryOf = <String, String>{for (final ProductModel p in products) p.id: p.categoryId};
  final String today = todayKey();
  final PromoResult promo = evaluatePromotions(
    rules,
    <PromoLine>[
      for (final PosLine l in cart.lines)
        PromoLine(
          key: l.variantId,
          productId: l.productId,
          categoryIds: categoryChain(categoryOf[l.productId] ?? '', categories),
          quantity: l.quantity,
          unitPrice: l.unitPrice,
          discount: l.discount,
        ),
    ],
    today: today,
    channel: 'pos',
    couponCode: coupon,
  );
  return PosPricing(
    cart: cart,
    promo: promo,
    taxSettings: tax,
    couponAccepted: couponIsValid(rules, today: today, channel: 'pos', couponCode: coupon),
  );
});
