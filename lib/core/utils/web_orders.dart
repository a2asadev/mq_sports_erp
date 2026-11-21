import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';

/// The statuses that have a column on the online-orders board, in pipeline order.
const List<OrderStatus> webOrderColumns = <OrderStatus>[
  OrderStatus.pending,
  OrderStatus.processing,
  OrderStatus.shipped,
  OrderStatus.delivered,
];

/// The online-store orders (channel `web`) sorted into the board's columns. Open columns list the order that has
/// waited longest first; Delivered lists the newest first and only keeps the last [deliveredDays] days, so the
/// board stays about work still to do. Cancelled orders have no column.
Map<OrderStatus, List<OrderModel>> webOrderBoard(List<OrderModel> orders, DateTime now, {int deliveredDays = 7}) {
  final Map<OrderStatus, List<OrderModel>> board = <OrderStatus, List<OrderModel>>{
    for (final OrderStatus s in webOrderColumns) s: <OrderModel>[],
  };
  final DateTime since = now.subtract(Duration(days: deliveredDays));
  for (final OrderModel o in orders) {
    if (o.channel != 'web' || !board.containsKey(o.status)) {
      continue;
    }
    if (o.status == OrderStatus.delivered && o.createdAt.isBefore(since)) {
      continue;
    }
    board[o.status]!.add(o);
  }
  for (final OrderStatus s in webOrderColumns) {
    board[s]!.sort((OrderModel a, OrderModel b) => s == OrderStatus.delivered ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));
  }
  return board;
}

enum AgeUnit { justNow, minutes, hours, days }

/// How long ago something happened, as a number and a unit (the words come from the language files).
({AgeUnit unit, int count}) ageOf(DateTime from, DateTime now) {
  final Duration d = now.difference(from);
  if (d.inMinutes < 1) {
    return (unit: AgeUnit.justNow, count: 0);
  }
  if (d.inMinutes < 60) {
    return (unit: AgeUnit.minutes, count: d.inMinutes);
  }
  if (d.inHours < 24) {
    return (unit: AgeUnit.hours, count: d.inHours);
  }
  return (unit: AgeUnit.days, count: d.inDays);
}

/// The customer's phone: from their record, else the number written in the delivery details of a web order
/// ("Name, 03001234567\nStreet, City"). '' when there is none.
String orderPhone(OrderModel order, List<CustomerModel> customers) {
  for (final CustomerModel c in customers) {
    if (c.id == order.customerId && c.phone.trim().isNotEmpty) {
      return c.phone;
    }
  }
  final Match? found = RegExp(r'\+?\d[\d\s-]{8,}\d').firstMatch(order.shippingAddress);
  return found?.group(0) ?? '';
}
