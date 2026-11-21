import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';

/// What a customer has bought: used by the Customer insights page. Pure functions, so they are easy to test.
/// Cancelled orders never count; walk-in and switched-off customers are left out.
class CustomerStat {
  const CustomerStat({required this.customer, required this.spent, required this.orders, required this.lastOrder});

  final CustomerModel customer;

  /// Goods bought, before tax and delivery.
  final double spent;
  final int orders;
  final DateTime lastOrder;
}

double _goodsOf(OrderModel o) {
  final double v = o.totalAmount - o.taxAmount - o.shippingFee;
  return v < 0 ? 0 : v;
}

/// One entry per customer who has a counted order (inside the period, when [since] is given), the biggest spender
/// first (ties: the one who bought most recently).
List<CustomerStat> customerStats(
  List<CustomerModel> customers,
  List<OrderModel> orders, {
  String walkInCustomerId = '',
  DateTime? since,
}) {
  final Map<String, CustomerModel> byId = <String, CustomerModel>{
    for (final CustomerModel c in customers)
      if (c.isActive && c.id != walkInCustomerId) c.id: c,
  };
  final Map<String, List<OrderModel>> mine = <String, List<OrderModel>>{};
  for (final OrderModel o in orders) {
    if (o.status == OrderStatus.cancelled || !byId.containsKey(o.customerId)) {
      continue;
    }
    if (since != null && o.orderDate.isBefore(since)) {
      continue;
    }
    mine.putIfAbsent(o.customerId, () => <OrderModel>[]).add(o);
  }
  final List<CustomerStat> stats = <CustomerStat>[
    for (final MapEntry<String, List<OrderModel>> e in mine.entries)
      CustomerStat(
        customer: byId[e.key]!,
        spent: ((e.value.fold<double>(0, (double s, OrderModel o) => s + _goodsOf(o))) * 100).round() / 100,
        orders: e.value.length,
        lastOrder: e.value.map((OrderModel o) => o.orderDate).reduce((DateTime a, DateTime b) => a.isAfter(b) ? a : b),
      ),
  ];
  stats.sort((CustomerStat a, CustomerStat b) {
    final int bySpent = b.spent.compareTo(a.spent);
    return bySpent != 0 ? bySpent : b.lastOrder.compareTo(a.lastOrder);
  });
  return stats;
}

/// Customers who have bought before but not for at least [days] days, the longest-away first.
List<CustomerStat> lapsedCustomers(List<CustomerStat> allTime, DateTime now, int days) {
  final List<CustomerStat> out = allTime.where((CustomerStat s) => _daysBetween(s.lastOrder, now) >= days).toList();
  out.sort((CustomerStat a, CustomerStat b) => a.lastOrder.compareTo(b.lastOrder));
  return out;
}

/// Whole calendar days from [from] to [to] (a purchase this morning is 0 days ago, whatever the hour).
int _daysBetween(DateTime from, DateTime to) =>
    DateTime(to.year, to.month, to.day).difference(DateTime(from.year, from.month, from.day)).inDays;

/// "MM-DD" as (month, day), or null when it is empty or not a real day (29 February is allowed).
({int month, int day})? parseBirthday(String raw) {
  final RegExpMatch? m = RegExp(r'^(\d{2})-(\d{2})$').firstMatch(raw);
  if (m == null) {
    return null;
  }
  final int month = int.parse(m.group(1)!);
  final int day = int.parse(m.group(2)!);
  if (month < 1 || month > 12 || day < 1 || day > DateTime(2000, month + 1, 0).day) {
    return null;
  }
  return (month: month, day: day);
}

String birthdayKey(int month, int day) => '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

class UpcomingBirthday {
  const UpcomingBirthday({required this.customer, required this.date, required this.daysAway});

  final CustomerModel customer;

  /// The next time the day comes round (29 February is kept on 28 February in years without one).
  final DateTime date;

  /// 0 = today.
  final int daysAway;
}

/// Customers whose birthday comes within [withinDays] days of [today] (today included), soonest first.
List<UpcomingBirthday> upcomingBirthdays(
  List<CustomerModel> customers,
  DateTime today, {
  int withinDays = 30,
  String walkInCustomerId = '',
}) {
  final DateTime start = DateTime(today.year, today.month, today.day);
  final List<UpcomingBirthday> out = <UpcomingBirthday>[];
  for (final CustomerModel c in customers) {
    final ({int month, int day})? b = parseBirthday(c.birthday);
    if (b == null || !c.isActive || c.id == walkInCustomerId) {
      continue;
    }
    DateTime next = _occurrence(start.year, b.month, b.day);
    if (next.isBefore(start)) {
      next = _occurrence(start.year + 1, b.month, b.day);
    }
    final int away = next.difference(start).inDays;
    if (away <= withinDays) {
      out.add(UpcomingBirthday(customer: c, date: next, daysAway: away));
    }
  }
  out.sort((UpcomingBirthday a, UpcomingBirthday b) {
    final int byDay = a.daysAway.compareTo(b.daysAway);
    return byDay != 0 ? byDay : a.customer.name.toLowerCase().compareTo(b.customer.name.toLowerCase());
  });
  return out;
}

DateTime _occurrence(int year, int month, int day) {
  final int last = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day > last ? last : day);
}
