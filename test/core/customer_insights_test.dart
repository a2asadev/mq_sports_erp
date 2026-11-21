import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/customer_insights.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';

CustomerModel customer(String id, {String birthday = '', bool active = true}) => CustomerModel(id: id, name: 'Customer $id', birthday: birthday, isActive: active);

OrderModel order(String customerId, DateTime date, double total, {OrderStatus status = OrderStatus.delivered, double tax = 0, double shipping = 0}) => OrderModel(
      orderNo: 'ORD-${date.millisecondsSinceEpoch}-$customerId-$total',
      customerId: customerId,
      customerName: 'x',
      orderDate: date,
      status: status,
      taxAmount: tax,
      shippingFee: shipping,
      items: <OrderItem>[OrderItem(productId: 'p', variantId: 'v', productName: 'P', variantLabel: 'L', sku: 'S', quantity: 1, unitPrice: total - tax - shipping)],
    );

void main() {
  final DateTime now = DateTime(2026, 12, 10, 15);

  group('customer stats', () {
    final List<CustomerModel> customers = <CustomerModel>[customer('a'), customer('b'), customer('walk'), customer('off', active: false), customer('none')];

    test('add up what each customer bought, before tax and delivery, biggest first', () {
      final List<CustomerStat> stats = customerStats(
        customers,
        <OrderModel>[
          order('a', DateTime(2026, 12, 1), 1170, tax: 170),
          order('a', DateTime(2026, 12, 5), 500),
          order('b', DateTime(2026, 12, 9), 2000, shipping: 250),
        ],
        walkInCustomerId: 'walk',
      );
      expect(stats.map((CustomerStat s) => s.customer.id).toList(), <String>['b', 'a']);
      expect(stats[0].spent, 1750); // 2000 less the delivery
      expect(stats[1].spent, 1500); // 1000 + 500, the tax left out
      expect(stats[1].orders, 2);
      expect(stats[1].lastOrder, DateTime(2026, 12, 5));
    });

    test('leave out cancelled orders, the walk-in customer, switched-off customers and unknown ones', () {
      final List<CustomerStat> stats = customerStats(
        customers,
        <OrderModel>[
          order('a', DateTime(2026, 12, 1), 900, status: OrderStatus.cancelled),
          order('walk', DateTime(2026, 12, 1), 900),
          order('off', DateTime(2026, 12, 1), 900),
          order('ghost', DateTime(2026, 12, 1), 900),
        ],
        walkInCustomerId: 'walk',
      );
      expect(stats, isEmpty);
    });

    test('can look at one period only', () {
      final List<OrderModel> orders = <OrderModel>[order('a', DateTime(2026, 6, 1), 100), order('a', DateTime(2026, 12, 1), 300)];
      expect(customerStats(customers, orders, since: DateTime(2026, 11, 1)).single.spent, 300);
      expect(customerStats(customers, orders).single.spent, 400);
    });
  });

  group('customers who have not been back', () {
    final List<CustomerModel> customers = <CustomerModel>[customer('a'), customer('b'), customer('c')];
    final List<CustomerStat> all = customerStats(customers, <OrderModel>[
      order('a', DateTime(2026, 10, 1, 9), 100), // 70 days ago
      order('b', DateTime(2026, 11, 10, 23), 100), // 30 days ago, late in the evening
      order('c', DateTime(2026, 12, 9), 100), // yesterday
    ]);

    test('are those whose last order is at least N days old, longest away first', () {
      expect(lapsedCustomers(all, now, 60).map((CustomerStat s) => s.customer.id).toList(), <String>['a']);
      expect(lapsedCustomers(all, now, 30).map((CustomerStat s) => s.customer.id).toList(), <String>['a', 'b']); // whole days, not hours
      expect(lapsedCustomers(all, now, 90), isEmpty);
    });

    test('never include someone who has not bought at all', () {
      expect(lapsedCustomers(customerStats(<CustomerModel>[customer('x')], <OrderModel>[]), now, 1), isEmpty);
    });
  });

  group('birthdays', () {
    test('read "MM-DD" and refuse anything that is not a day', () {
      expect(parseBirthday('03-27'), (month: 3, day: 27));
      expect(parseBirthday('02-29'), (month: 2, day: 29));
      for (final String bad in <String>['', '04-31', '13-01', '00-10', '3-27', '2000-03-27', 'abc']) {
        expect(parseBirthday(bad), isNull, reason: bad);
      }
      expect(birthdayKey(3, 7), '03-07');
    });

    test('list the coming ones soonest first, today included, rolling over the year end', () {
      final List<CustomerModel> customers = <CustomerModel>[
        customer('today', birthday: '12-10'),
        customer('soon', birthday: '12-15'),
        customer('newyear', birthday: '01-02'),
        customer('later', birthday: '03-01'),
        customer('yesterday', birthday: '12-09'), // next one is a year away
        customer('unset'),
        customer('off', birthday: '12-11', active: false),
      ];
      final List<UpcomingBirthday> list = upcomingBirthdays(customers, now, withinDays: 30);
      expect(list.map((UpcomingBirthday b) => b.customer.id).toList(), <String>['today', 'soon', 'newyear']);
      expect(list.map((UpcomingBirthday b) => b.daysAway).toList(), <int>[0, 5, 23]);
      expect(list.last.date, DateTime(2027, 1, 2));
      expect(upcomingBirthdays(customers, now, withinDays: 7).map((UpcomingBirthday b) => b.customer.id).toList(), <String>['today', 'soon']);
    });

    test('keep 29 February on the 28th in a year without one', () {
      final List<UpcomingBirthday> list = upcomingBirthdays(<CustomerModel>[customer('leap', birthday: '02-29')], DateTime(2027, 2, 20), withinDays: 30);
      expect(list.single.date, DateTime(2027, 2, 28));
      final List<UpcomingBirthday> leapYear = upcomingBirthdays(<CustomerModel>[customer('leap', birthday: '02-29')], DateTime(2028, 2, 20), withinDays: 30);
      expect(leapYear.single.date, DateTime(2028, 2, 29));
    });
  });
}
