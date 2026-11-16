import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/models/order_model.dart';

void main() {
  test('reads the server\'s tenant object, trimming and tolerating missing optional parts', () {
    final BusinessInfo? info = BusinessInfo.tryFromMap(<String, dynamic>{
      'id': 't1',
      'name': '  Ali Traders ',
      'phone': ' 0300-1 ',
      'walkInCustomerId': 'w1',
    });
    expect(info, isNotNull);
    expect(info!.name, 'Ali Traders');
    expect(info.phone, '0300-1');
    expect(info.walkInCustomerId, 'w1');

    final BusinessInfo bare = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't2', 'name': 'Bare'})!;
    expect(bare.phone, '');
    expect(bare.walkInCustomerId, '');
  });

  test('says whether the business runs the online store; an answer that is silent means yes', () {
    final BusinessInfo? other = BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali', 'hasOnlineStore': false});
    expect(other!.hasOnlineStore, isFalse);
    expect(BusinessInfo.tryFromMap(other.toMap())!.hasOnlineStore, isFalse);
    // A server or a saved session from before businesses existed does not say.
    expect(BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'MQ'})!.hasOnlineStore, isTrue);
    expect(BusinessInfo.mqSports.hasOnlineStore, isTrue);
  });

  test('reads the currency, defaulting to rupees for an answer that is silent or malformed', () {
    BusinessInfo read(Object? currency) =>
        BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': 'Ali', if (currency != null) 'currency': currency})!;
    expect(read('AED').currency, 'AED');
    expect(read(null).currency, 'PKR');
    expect(read('aed').currency, 'PKR');
    expect(read('DIRHAM').currency, 'PKR');
    expect(read(5).currency, 'PKR');
    expect(BusinessInfo.mqSports.currency, 'PKR');
    expect(BusinessInfo.tryFromMap(read('AED').toMap())!.currency, 'AED');
  });

  test('copyWith changes only what it is given', () {
    const BusinessInfo a = BusinessInfo(id: 't', name: 'Ali', phone: 'p', walkInCustomerId: 'w', hasOnlineStore: false);
    final BusinessInfo b = a.copyWith(name: 'Ali Store', currency: 'USD');
    expect(b.name, 'Ali Store');
    expect(b.currency, 'USD');
    expect(b.phone, 'p');
    expect(b.walkInCustomerId, 'w');
    expect(b.hasOnlineStore, isFalse);
    expect(b.id, 't');
    expect(a.copyWith(), a);
  });

  test('refuses an answer that is not a usable business', () {
    expect(BusinessInfo.tryFromMap(null), isNull);
    expect(BusinessInfo.tryFromMap('x'), isNull);
    expect(BusinessInfo.tryFromMap(<String, dynamic>{'id': '', 'name': 'A'}), isNull);
    expect(BusinessInfo.tryFromMap(<String, dynamic>{'id': 't', 'name': '  '}), isNull);
    expect(BusinessInfo.tryFromMap(<String, dynamic>{'name': 'A'}), isNull);
  });

  test('toMap and tryFromMap round-trip, and equal businesses are equal', () {
    const BusinessInfo a = BusinessInfo(id: 't', name: 'N', phone: 'p', walkInCustomerId: 'w');
    final BusinessInfo? b = BusinessInfo.tryFromMap(a.toMap());
    expect(b, a);
    expect(b.hashCode, a.hashCode);
    expect(a == const BusinessInfo(id: 't', name: 'N', phone: 'p', walkInCustomerId: 'other'), isFalse);
  });

  test('each business has its own walk-in customer; one with none matches nobody', () {
    const BusinessInfo ali = BusinessInfo(id: 't', name: 'Ali', walkInCustomerId: 'walk-ali');
    expect(ali.isWalkIn('walk-ali'), isTrue);
    expect(ali.isWalkIn(mqSportsWalkInCustomerId), isFalse); // MQ's walk-in is not Ali's
    expect(BusinessInfo.mqSports.isWalkIn(mqSportsWalkInCustomerId), isTrue);
    const BusinessInfo none = BusinessInfo(id: 't', name: 'New', walkInCustomerId: '');
    expect(none.isWalkIn(''), isFalse);
  });

  test('a receipt leaves out the customer name only for the business\'s own walk-in', () {
    OrderModel sale(String customerId) => OrderModel(
          orderNo: 'ORD-1',
          customerId: customerId,
          customerName: 'Walk-in customer',
          items: <OrderItem>[
            OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 100),
          ],
        );
    ReceiptData receipt(String customerId, String walkIn) => ReceiptData.fromParts(
          sale(customerId),
          payments: const <ReceiptPayment>[],
          shopName: 'Ali',
          walkInCustomerId: walkIn,
        );
    expect(receipt('walk-ali', 'walk-ali').customerName, '');
    expect(receipt('walk-ali', 'someone-else').customerName, 'Walk-in customer');
    expect(receipt('c1', '').customerName, 'Walk-in customer');
  });
}
