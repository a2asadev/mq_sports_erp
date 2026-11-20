import 'package:a2_stocks/models/order_model.dart';

/// Works out, before the person confirms, what goods coming back from an order are
/// worth and how much money is owed back. It follows the server's rule exactly
/// (the server has the final say): a line's worth is its price less its own
/// discount, less its share of the order discount; units returned in several goes
/// never add up to more than the line was worth; the delivery fee is never given back.
class ReturnPlan {
  ReturnPlan({required this.order, Map<String, int> alreadyReturned = const <String, int>{}})
      : _already = alreadyReturned;

  final OrderModel order;
  final Map<String, int> _already;

  static int _cents(double amount) => (amount * 100).round();

  /// Units of [item] that can still come back.
  int remaining(OrderItem item) {
    final int left = item.quantity - (_already[item.id] ?? 0);
    return left < 0 ? 0 : left;
  }

  int _lineNet(OrderItem item) => _cents(item.unitPrice) * item.quantity - _cents(item.discount);

  int _afterOrderDiscount(OrderItem item) {
    final int subtotal = order.items.fold<int>(0, (int sum, OrderItem i) => sum + _lineNet(i));
    if (subtotal <= 0) {
      return 0;
    }
    return ((_lineNet(item) * (subtotal - _cents(order.discount))) / subtotal).round();
  }

  /// The worth, in cents, of the first [units] units of the line.
  int _worth(OrderItem item, int units) => ((_afterOrderDiscount(item) * units) / item.quantity).round();

  /// What returning [units] more units of [item] is worth.
  double valueOf(OrderItem item, int units) {
    final int before = _already[item.id] ?? 0;
    return (_worth(item, before + units) - _worth(item, before)) / 100;
  }

  /// What all the chosen units are worth; [quantities] is units per order line id.
  double totalValue(Map<String, int> quantities) {
    double sum = 0;
    for (final OrderItem item in order.items) {
      final int units = quantities[item.id] ?? 0;
      if (units > 0) {
        sum += valueOf(item, units);
      }
    }
    return (sum * 100).round() / 100;
  }

  /// Money the customer paid beyond what is left of the order once the goods are
  /// counted: the most that can be handed back. [settled] is what the order has
  /// settled so far (payments and earlier returns, less refunds).
  double overpaid({required double settled, required double returnedValue}) {
    final int cents = _cents(settled) + _cents(returnedValue) - _cents(order.totalAmount);
    return cents > 0 ? cents / 100 : 0;
  }
}
