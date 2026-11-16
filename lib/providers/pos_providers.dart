import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/business_provider.dart';

double _round2(double v) => (v * 100).round() / 100;

/// One line of the sale being rung up.
class PosLine {
  const PosLine({
    required this.productId,
    required this.variantId,
    required this.productName,
    required this.variantLabel,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
    this.discount = 0,
    this.imageUrl = '',
  });

  final String productId;
  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final double unitPrice;
  final int quantity;

  /// Discount on the whole line (an amount).
  final double discount;
  final String imageUrl;

  double get gross => unitPrice * quantity;

  double get total {
    final double net = gross - discount;
    return _round2(net > 0 ? net : 0);
  }

  PosLine copyWith({int? quantity, double? discount}) => PosLine(
        productId: productId,
        variantId: variantId,
        productName: productName,
        variantLabel: variantLabel,
        sku: sku,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
        discount: discount ?? this.discount,
        imageUrl: imageUrl,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'productName': productName,
        'variantLabel': variantLabel,
        'sku': sku,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'discount': discount,
        'imageUrl': imageUrl,
      };

  factory PosLine.fromMap(Map<String, dynamic> map) => PosLine(
        productId: map['productId'] as String? ?? '',
        variantId: map['variantId'] as String? ?? '',
        productName: map['productName'] as String? ?? '',
        variantLabel: map['variantLabel'] as String? ?? '',
        sku: map['sku'] as String? ?? '',
        unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 0,
        discount: (map['discount'] as num?)?.toDouble() ?? 0,
        imageUrl: map['imageUrl'] as String? ?? '',
      );

  OrderItem toOrderItem() => OrderItem(
        productId: productId,
        variantId: variantId,
        productName: productName,
        variantLabel: variantLabel,
        sku: sku,
        quantity: quantity,
        unitPrice: unitPrice,
        discount: discount,
      );
}

/// The sale being rung up: lines, an order discount and an optional named
/// customer (null = walk-in). Plain and immutable, so it is easy to test.
class PosCart {
  const PosCart({
    this.lines = const <PosLine>[],
    this.orderDiscount = 0,
    this.customer,
  });

  final List<PosLine> lines;
  final double orderDiscount;

  /// null = walk-in customer.
  final CustomerModel? customer;

  bool get isEmpty => lines.isEmpty;

  int get units => lines.fold<int>(0, (int s, PosLine l) => s + l.quantity);

  double get subtotal => _round2(lines.fold<double>(0, (double s, PosLine l) => s + l.total));

  /// The order discount never takes the total below zero.
  double get effectiveOrderDiscount => orderDiscount > subtotal ? subtotal : orderDiscount;

  double get total => _round2(subtotal - effectiveOrderDiscount);

  int quantityOf(String variantId) =>
      lines.where((PosLine l) => l.variantId == variantId).fold<int>(0, (int s, PosLine l) => s + l.quantity);

  /// Adds one unit of the variant (or [quantity]); the same variant stays one line.
  PosCart add(ProductModel product, VariantModel variant, {int quantity = 1}) {
    final int index = lines.indexWhere((PosLine l) => l.variantId == variant.id);
    if (index >= 0) {
      return setQuantity(variant.id, lines[index].quantity + quantity);
    }
    return PosCart(
      lines: <PosLine>[
        ...lines,
        PosLine(
          productId: product.id,
          variantId: variant.id,
          productName: product.name,
          variantLabel: variant.label,
          sku: variant.sku,
          unitPrice: variant.salePrice,
          quantity: quantity,
          imageUrl: product.images.isEmpty ? '' : product.images.first.thumbUrl,
        ),
      ],
      orderDiscount: orderDiscount,
      customer: customer,
    );
  }

  PosCart setQuantity(String variantId, int quantity) {
    if (quantity <= 0) {
      return remove(variantId);
    }
    return PosCart(
      lines: <PosLine>[
        for (final PosLine l in lines)
          if (l.variantId == variantId)
            l.copyWith(quantity: quantity, discount: l.discount > l.unitPrice * quantity ? l.unitPrice * quantity : l.discount)
          else
            l,
      ],
      orderDiscount: orderDiscount,
      customer: customer,
    );
  }

  PosCart remove(String variantId) => PosCart(
        lines: lines.where((PosLine l) => l.variantId != variantId).toList(),
        orderDiscount: orderDiscount,
        customer: customer,
      );

  /// Sets the discount of one line, kept between 0 and the line amount.
  PosCart setLineDiscount(String variantId, double discount) => PosCart(
        lines: <PosLine>[
          for (final PosLine l in lines)
            if (l.variantId == variantId)
              l.copyWith(discount: _round2(discount.clamp(0, l.gross).toDouble()))
            else
              l,
        ],
        orderDiscount: orderDiscount,
        customer: customer,
      );

  PosCart withOrderDiscount(double discount) => PosCart(
        lines: lines,
        orderDiscount: discount < 0 ? 0 : _round2(discount),
        customer: customer,
      );

  PosCart withCustomer(CustomerModel? value) => PosCart(lines: lines, orderDiscount: orderDiscount, customer: value);

  List<OrderItem> toItems() => lines.map((PosLine l) => l.toOrderItem()).toList();
}

class PosCartNotifier extends Notifier<PosCart> {
  @override
  PosCart build() => const PosCart();

  void set(PosCart cart) => state = cart;

  void clear() => state = const PosCart();
}

/// The sale being rung up on this device.
final NotifierProvider<PosCartNotifier, PosCart> posCartProvider =
    NotifierProvider<PosCartNotifier, PosCart>(PosCartNotifier.new);

/// The shop's name and phone for receipts and messages: those of the business
/// the user works for (named by the server at sign-in, so it works offline).
class ShopInfo {
  const ShopInfo({this.name = 'MQ Sports', this.phone = ''});

  final String name;
  final String phone;
}

final FutureProvider<ShopInfo> shopInfoProvider = FutureProvider<ShopInfo>((Ref ref) async {
  final BusinessInfo business = ref.watch(businessProvider);
  return ShopInfo(name: business.name, phone: business.phone);
});
