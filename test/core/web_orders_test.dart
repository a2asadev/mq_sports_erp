import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/web_orders.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';

OrderModel order(String no, DateTime at, {OrderStatus status = OrderStatus.pending, String channel = 'web', String customerId = 'c', String address = ''}) => OrderModel(
      id: no,
      orderNo: no,
      customerId: customerId,
      customerName: 'x',
      orderDate: at,
      createdAt: at,
      status: status,
      channel: channel,
      shippingAddress: address,
    );

void main() {
  final DateTime now = DateTime(2026, 12, 10, 12);

  group('the board', () {
    test('holds only online orders, one column per step', () {
      final Map<OrderStatus, List<OrderModel>> board = webOrderBoard(<OrderModel>[
        order('w1', now.subtract(const Duration(hours: 1))),
        order('w2', now.subtract(const Duration(hours: 2)), status: OrderStatus.processing),
        order('w3', now, status: OrderStatus.shipped),
        order('shop', now, channel: 'pos'),
        order('gone', now, status: OrderStatus.cancelled),
      ], now);
      expect(board.keys.toList(), webOrderColumns);
      expect(board[OrderStatus.pending]!.map((OrderModel o) => o.orderNo).toList(), <String>['w1']);
      expect(board[OrderStatus.processing]!.map((OrderModel o) => o.orderNo).toList(), <String>['w2']);
      expect(board[OrderStatus.shipped]!.map((OrderModel o) => o.orderNo).toList(), <String>['w3']);
      expect(board[OrderStatus.delivered], isEmpty);
    });

    test('lists the order that has waited longest first, and delivered ones newest first for a week only', () {
      final Map<OrderStatus, List<OrderModel>> board = webOrderBoard(<OrderModel>[
        order('new', now.subtract(const Duration(minutes: 5))),
        order('old', now.subtract(const Duration(hours: 5))),
        order('d1', now.subtract(const Duration(days: 1)), status: OrderStatus.delivered),
        order('d3', now.subtract(const Duration(days: 3)), status: OrderStatus.delivered),
        order('d9', now.subtract(const Duration(days: 9)), status: OrderStatus.delivered),
      ], now);
      expect(board[OrderStatus.pending]!.map((OrderModel o) => o.orderNo).toList(), <String>['old', 'new']);
      expect(board[OrderStatus.delivered]!.map((OrderModel o) => o.orderNo).toList(), <String>['d1', 'd3']);
    });
  });

  test('says how long ago in the biggest fitting unit', () {
    expect(ageOf(now.subtract(const Duration(seconds: 20)), now).unit, AgeUnit.justNow);
    expect(ageOf(now.subtract(const Duration(minutes: 12)), now), (unit: AgeUnit.minutes, count: 12));
    expect(ageOf(now.subtract(const Duration(hours: 5, minutes: 30)), now), (unit: AgeUnit.hours, count: 5));
    expect(ageOf(now.subtract(const Duration(days: 2, hours: 3)), now), (unit: AgeUnit.days, count: 2));
  });

  group('the phone of an order', () {
    test('comes from the customer record, else from the delivery details', () {
      final List<CustomerModel> customers = <CustomerModel>[CustomerModel(id: 'c', name: 'A', phone: '0311 1111111'), CustomerModel(id: 'nophone', name: 'B')];
      expect(orderPhone(order('o', now), customers), '0311 1111111');
      expect(orderPhone(order('o', now, customerId: 'nophone', address: 'Bilal Khan, 03001234567\nHouse 5, Lahore'), customers), '03001234567');
      expect(orderPhone(order('o', now, customerId: 'nophone', address: 'Bilal, +92 300 1234567\nHouse 5'), customers), '+92 300 1234567');
      expect(orderPhone(order('o', now, customerId: 'nophone', address: 'House 5, Lahore'), customers), '');
    });
  });
}
