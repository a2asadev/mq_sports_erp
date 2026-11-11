import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/models/order_model.dart';

OrderItem _item(int quantity, double price, {double discount = 0}) {
  return OrderItem(
    productId: 'p',
    variantId: 'v',
    productName: 'Bat',
    variantLabel: 'Size 5',
    sku: 'BAT-5',
    quantity: quantity,
    unitPrice: price,
    discount: discount,
  );
}

void main() {
  group('OrderModel totals', () {
    test('applies line discounts, then the order discount', () {
      final OrderModel order = OrderModel(
        orderNo: 'ORD-1',
        customerId: 'c',
        customerName: 'Ali',
        items: <OrderItem>[_item(2, 100, discount: 20), _item(1, 50)],
        discount: 30,
      );
      expect(order.subtotal, 230);
      expect(order.totalAmount, 200);
      expect(order.totalDiscount, 50);
      expect(order.totalUnits, 3);
    });

    test('a discount larger than the amount never gives a negative total', () {
      final OrderModel order = OrderModel(
        orderNo: 'ORD-2',
        customerId: 'c',
        customerName: 'Ali',
        items: <OrderItem>[_item(1, 10, discount: 50)],
        discount: 5,
      );
      expect(order.subtotal, 0);
      expect(order.totalAmount, 0);
    });
  });

  group('OrderModel storage', () {
    test('round-trips through toMap and fromMap', () {
      final OrderModel order = OrderModel(
        orderNo: 'ORD-3',
        customerId: 'c',
        customerName: 'Ali',
        status: OrderStatus.shipped,
        items: <OrderItem>[_item(3, 12.5)],
        statusHistory: <OrderStatusEntry>[
          OrderStatusEntry(status: OrderStatus.pending, byName: 'Sara'),
        ],
      );
      final OrderModel copy = OrderModel.fromMap(order.toMap());
      expect(copy.id, order.id);
      expect(copy.status, OrderStatus.shipped);
      expect(copy.totalAmount, 37.5);
      expect(copy.statusHistory.single.byName, 'Sara');
    });

    test('the retail/wholesale tag round-trips and old orders count as retail', () {
      final OrderModel wholesale = OrderModel(
        orderNo: 'ORD-4',
        customerId: 'c',
        customerName: 'Ali',
        saleType: OrderSaleType.wholesale,
      );
      expect(OrderModel.fromMap(wholesale.toMap()).saleType, OrderSaleType.wholesale);
      expect(wholesale.copyWith(status: OrderStatus.shipped).saleType,
          OrderSaleType.wholesale);

      final Map<String, dynamic> old = wholesale.toMap()..remove('saleType');
      expect(OrderModel.fromMap(old).saleType, OrderSaleType.retail);
      expect(OrderSaleType.fromName('bogus'), OrderSaleType.retail);
    });

    test('an unknown status falls back to pending', () {
      expect(OrderStatus.fromName('bogus'), OrderStatus.pending);
    });
  });

  group('OrderStatus pipeline', () {
    test('moves forward one step at a time and stops at the end', () {
      expect(OrderStatus.pending.next, OrderStatus.processing);
      expect(OrderStatus.processing.next, OrderStatus.shipped);
      expect(OrderStatus.shipped.next, OrderStatus.delivered);
      expect(OrderStatus.delivered.next, isNull);
      expect(OrderStatus.cancelled.next, isNull);
    });

    test('delivered and cancelled are final', () {
      expect(OrderStatus.delivered.isFinal, isTrue);
      expect(OrderStatus.cancelled.isFinal, isTrue);
      expect(OrderStatus.shipped.isFinal, isFalse);
    });
  });
}
