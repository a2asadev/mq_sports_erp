import 'package:a2_stocks/core/utils/stock_alerts.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_list_item.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/variant_model.dart';

/// Figures for the strip at the top of the list pages. Pure functions, so they
/// are easy to test; cancelled orders never count as sales.

class OrderStats {
  const OrderStats({
    required this.count,
    required this.openCount,
    required this.sales,
    required this.todaySales,
    required this.todayCount,
    required this.toCollect,
  });

  /// Orders that are not cancelled.
  final int count;

  /// Pending, processing or shipped: still to be finished.
  final int openCount;
  final double sales;
  final double todaySales;
  final int todayCount;
  final double toCollect;
}

OrderStats computeOrderStats(List<OrderModel> orders, Map<String, double> paid, DateTime now) {
  int count = 0;
  int open = 0;
  int todayCount = 0;
  double sales = 0;
  double today = 0;
  double due = 0;
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled) {
      continue;
    }
    count++;
    if (o.status != OrderStatus.delivered) {
      open++;
    }
    final double total = o.totalAmount;
    sales += total;
    final DateTime day = o.orderDate.toLocal();
    if (day.year == now.year && day.month == now.month && day.day == now.day) {
      today += total;
      todayCount++;
    }
    final double remaining = total - (paid[o.id] ?? 0);
    due += remaining > 0 ? remaining : 0;
  }
  return OrderStats(
    count: count,
    openCount: open,
    sales: sales,
    todaySales: today,
    todayCount: todayCount,
    toCollect: due,
  );
}

class PurchaseStats {
  const PurchaseStats({
    required this.count,
    required this.total,
    required this.due,
    required this.unpaidCount,
  });

  final int count;
  final double total;
  final double due;

  /// Purchases that are not fully paid.
  final int unpaidCount;
}

PurchaseStats computePurchaseStats(List<PurchaseModel> purchases, Map<String, double> paid) {
  double total = 0;
  double due = 0;
  int unpaid = 0;
  for (final PurchaseModel p in purchases) {
    final double paidNow = paid[p.id] ?? 0;
    total += p.totalAmount;
    final double remaining = p.totalAmount - paidNow;
    due += remaining > 0 ? remaining : 0;
    if (purchaseStatusFor(p.totalAmount, paidNow) != PurchaseStatus.paid) {
      unpaid++;
    }
  }
  return PurchaseStats(count: purchases.length, total: total, due: due, unpaidCount: unpaid);
}

class ProductStats {
  const ProductStats({
    required this.products,
    required this.active,
    required this.variants,
    required this.brands,
  });

  final int products;
  final int active;
  final int variants;
  final int brands;
}

ProductStats computeProductStats(List<ProductModel> products) {
  final Set<String> brands = <String>{};
  int active = 0;
  int variants = 0;
  for (final ProductModel p in products) {
    if (p.isActive) {
      active++;
    }
    variants += p.variants.length;
    final String brand = p.brand.trim().toLowerCase();
    if (brand.isNotEmpty) {
      brands.add(brand);
    }
  }
  return ProductStats(products: products.length, active: active, variants: variants, brands: brands.length);
}

class StockStats {
  const StockStats({
    required this.items,
    required this.units,
    required this.value,
    required this.lowCount,
    required this.outCount,
  });

  final int items;
  final int units;

  /// Units on hand times cost price (negative stock is not counted).
  final double value;
  final int lowCount;

  /// Active items with nothing (or less) on hand.
  final int outCount;
}

StockStats computeStockStats(List<ProductModel> products, Map<String, int> stock) {
  int items = 0;
  int units = 0;
  int low = 0;
  int out = 0;
  double value = 0;
  for (final ProductModel p in products) {
    for (final VariantModel v in p.variants) {
      items++;
      final int onHand = stock[v.id] ?? 0;
      if (onHand > 0) {
        units += onHand;
        value += onHand * v.costPrice;
      }
      if (p.isActive && v.isActive) {
        if (onHand <= 0) {
          out++;
        }
        if (isLowStock(onHand, v.alertThreshold)) {
          low++;
        }
      }
    }
  }
  return StockStats(items: items, units: units, value: value, lowCount: low, outCount: out);
}

class UserStats {
  const UserStats({
    required this.total,
    required this.active,
    required this.admins,
    required this.managers,
    required this.staff,
  });

  final int total;
  final int active;
  final int admins;
  final int managers;
  final int staff;
}

UserStats computeUserStats(List<UserModel> users) {
  int active = 0;
  int admins = 0;
  int managers = 0;
  int staff = 0;
  for (final UserModel u in users) {
    if (u.isActive) {
      active++;
    }
    switch (u.role) {
      case UserRole.admin:
        admins++;
      case UserRole.manager:
        managers++;
      case UserRole.staff:
        staff++;
    }
  }
  return UserStats(total: users.length, active: active, admins: admins, managers: managers, staff: staff);
}

class PartyStats {
  const PartyStats({
    required this.total,
    required this.active,
    required this.outstanding,
    required this.withBalance,
    required this.overLimit,
  });

  final int total;
  final int active;

  /// Sum of the positive balances: owed to us (customers) or by us (vendors).
  final double outstanding;
  final int withBalance;
  final int overLimit;
}

PartyStats computePartyStats(List<PartyListItem> items) {
  int active = 0;
  int withBalance = 0;
  int over = 0;
  double outstanding = 0;
  for (final PartyListItem i in items) {
    if (i.isActive) {
      active++;
    }
    if (i.balance > 0.005) {
      outstanding += i.balance;
      withBalance++;
    }
    if (i.isOverLimit) {
      over++;
    }
  }
  return PartyStats(
    total: items.length,
    active: active,
    outstanding: outstanding,
    withBalance: withBalance,
    overLimit: over,
  );
}
