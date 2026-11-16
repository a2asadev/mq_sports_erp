import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/core/utils/whatsapp.dart';
import 'package:a2_stocks/models/order_model.dart';

void main() {
  test('Pakistani numbers in any common format become international digits', () {
    for (final String raw in <String>[
      '0300 1234567',
      '0300-1234567',
      '+92 300 1234567',
      '0092 300 1234567',
      '923001234567',
      '3001234567',
    ]) {
      expect(WhatsApp.internationalPhone(raw), '923001234567', reason: raw);
    }
    expect(WhatsApp.internationalPhone('+44 7700 900123'), '447700900123');
    expect(WhatsApp.internationalPhone(''), '');
    expect(WhatsApp.internationalPhone('12345'), '');
    expect(WhatsApp.internationalPhone('call me'), '');
  });

  test('the chat link carries the number and the encoded message', () {
    final Uri? link = WhatsApp.link('0300 1234567', 'Hello & thanks, 100%');
    expect(link, isNotNull);
    expect(link!.host, 'wa.me');
    expect(link.path, '/923001234567');
    expect(link.queryParameters['text'], 'Hello & thanks, 100%');
    expect(WhatsApp.link('nope', 'x'), isNull);
  });

  test('the message follows the order status', () {
    OrderModel order(OrderStatus status) => OrderModel(
          orderNo: 'ORD-1',
          customerId: 'c',
          customerName: 'Bilal',
          status: status,
          items: <OrderItem>[
            OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 2, unitPrice: 1000),
          ],
          shippingFee: 250,
        );
    expect(WhatsApp.orderMessage(order(OrderStatus.pending)),
        'Hello Bilal, your order ORD-1 (Rs 2250) has been received. - MQ Sports');
    expect(WhatsApp.orderMessage(order(OrderStatus.shipped)), contains('on its way'));
    expect(WhatsApp.orderMessage(order(OrderStatus.delivered)), contains('delivered'));
    expect(WhatsApp.orderMessage(order(OrderStatus.cancelled)), contains('cancelled'));
  });
}
