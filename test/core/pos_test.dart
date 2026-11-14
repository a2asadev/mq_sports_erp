import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/core/utils/pos_payment_plan.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/core/utils/receipt_pdf.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';

ProductModel _bat() => ProductModel(
      id: 'p1',
      name: 'Cricket Bat',
      categoryId: 'c',
      variants: <VariantModel>[
        VariantModel(id: 'v1', sku: 'BAT-S', name: 'Small', salePrice: 1000),
        VariantModel(id: 'v2', sku: 'BAT-L', name: 'Large', salePrice: 1500, barcode: '8901'),
      ],
    );

void main() {
  group('PosCart', () {
    test('the same variant is one line; quantities and totals add up exactly', () {
      final ProductModel p = _bat();
      PosCart cart = const PosCart().add(p, p.variants[0]).add(p, p.variants[0]).add(p, p.variants[1]);
      expect(cart.lines, hasLength(2));
      expect(cart.quantityOf('v1'), 2);
      expect(cart.units, 3);
      expect(cart.subtotal, 3500);
      cart = cart.setQuantity('v1', 5);
      expect(cart.total, 6500);
      expect(cart.setQuantity('v1', 0).lines, hasLength(1));
      expect(cart.remove('v2').lines.single.variantId, 'v1');
    });

    test('discounts never go below zero or above what they discount', () {
      final ProductModel p = _bat();
      PosCart cart = const PosCart().add(p, p.variants[0], quantity: 2); // 2000
      cart = cart.setLineDiscount('v1', 500);
      expect(cart.subtotal, 1500);
      expect(cart.setLineDiscount('v1', 99999).subtotal, 0);
      expect(cart.setLineDiscount('v1', -5).subtotal, 2000);
      cart = cart.withOrderDiscount(200);
      expect(cart.total, 1300);
      expect(cart.withOrderDiscount(99999).total, 0);
      expect(cart.withOrderDiscount(-1).orderDiscount, 0);
      // Lowering the quantity keeps the line discount within the line.
      expect(cart.setLineDiscount('v1', 1900).setQuantity('v1', 1).lines.single.discount, 1000);
    });

    test('a named customer or the walk-in, kept through changes', () {
      final CustomerModel ali = CustomerModel(id: 'c1', name: 'Ali');
      final ProductModel p = _bat();
      final PosCart cart = const PosCart().withCustomer(ali).add(p, p.variants[0]);
      expect(cart.customer?.name, 'Ali');
      expect(cart.withCustomer(null).customer, isNull);
      expect(isWalkIn(walkInCustomerId), isTrue);
      expect(isWalkIn('c1'), isFalse);
    });

    test('becomes order items with the prices and discounts', () {
      final ProductModel p = _bat();
      final List<OrderItem> items = const PosCart().add(p, p.variants[1]).setLineDiscount('v2', 100).toItems();
      expect(items.single.unitPrice, 1500);
      expect(items.single.discount, 100);
      expect(items.single.lineTotal, 1400);
      expect(items.single.sku, 'BAT-L');
    });
  });

  group('PosPaymentPlan', () {
    test('several methods add up to the total', () {
      final PosPaymentPlan plan = PosPaymentPlan(1000);
      expect(plan.add(PaymentMethod.cash, 400), isNull);
      expect(plan.remaining, 600);
      expect(plan.add(PaymentMethod.easypaisa, 350, reference: 'EP-1'), isNull);
      expect(plan.add(PaymentMethod.bank, 250, reference: 'HBL 77'), isNull);
      expect(plan.isFullyPaid, isTrue);
      expect(plan.change, 0);
      expect(plan.lines.map((PaymentLine l) => l.method), <PaymentMethod>[
        PaymentMethod.cash,
        PaymentMethod.easypaisa,
        PaymentMethod.bank,
      ]);
      expect(plan.lines[1].reference, 'EP-1');
    });

    test('cash above what is left gives change; only the owed part is recorded', () {
      final PosPaymentPlan plan = PosPaymentPlan(850);
      expect(plan.add(PaymentMethod.cash, 1000), isNull);
      expect(plan.lines.single.amount, 850);
      expect(plan.change, 150);
      expect(plan.isFullyPaid, isTrue);
      plan.removeAt(0);
      expect(plan.change, 0);
      expect(plan.remaining, 850);
    });

    test('non-cash cannot be more than what is left, and needs a reference', () {
      final PosPaymentPlan plan = PosPaymentPlan(500);
      expect(plan.add(PaymentMethod.jazzcash, 600, reference: 'J1'), contains('more than'));
      expect(plan.add(PaymentMethod.jazzcash, 100), contains('transaction number'));
      expect(plan.add(PaymentMethod.bank, 100), contains('bank'));
      expect(plan.add(PaymentMethod.cash, 0), contains('above zero'));
      expect(plan.add(PaymentMethod.cash, double.nan), isNotNull);
      expect(plan.lines, isEmpty);
      expect(plan.add(PaymentMethod.cash, 500), isNull);
      expect(plan.add(PaymentMethod.cash, 10), contains('already'));
    });

    test('cents do not drift', () {
      final PosPaymentPlan plan = PosPaymentPlan(0.3);
      expect(plan.add(PaymentMethod.cash, 0.1), isNull);
      expect(plan.add(PaymentMethod.cash, 0.2), isNull);
      expect(plan.isFullyPaid, isTrue);
    });
  });

  group('PaymentMethod and PaymentLine', () {
    test('names, labels and storage', () {
      expect(PaymentMethod.fromName('easypaisa'), PaymentMethod.easypaisa);
      expect(PaymentMethod.fromName(''), isNull);
      expect(PaymentMethod.fromName('cheque'), isNull);
      expect(PaymentMethod.labelOf('bank'), 'Bank transfer');
      expect(PaymentMethod.labelOf(''), 'Payment');
      final List<PaymentLine> back = PaymentLine.listFrom(<Object?>[
        const PaymentLine(method: PaymentMethod.jazzcash, amount: 40, reference: 'J9').toMap(),
        <String, dynamic>{'method': 'cheque', 'amount': 5},
        <String, dynamic>{'method': 'cash', 'amount': 0},
        'junk',
      ]);
      expect(back, hasLength(1));
      expect(back.single.reference, 'J9');
      expect(PaymentLine.listFrom(null), isEmpty);
    });

    test('ledger entries remember how they were paid', () {
      final LedgerModel e = LedgerModel(
        partyType: PartyType.customer,
        partyId: 'c',
        entryType: LedgerEntryType.payment,
        amount: 10,
        paymentMethod: 'bank',
        paymentRef: 'HBL 1',
      );
      final LedgerModel back = LedgerModel.fromMap(e.toMap());
      expect(back.paymentMethod, 'bank');
      expect(back.paymentRef, 'HBL 1');
      expect(back.copyWith(amount: 5).paymentMethod, 'bank');
      expect(LedgerModel.fromMap(<String, dynamic>{'id': 'x'}).paymentMethod, '');
    });
  });

  group('receipts', () {
    final OrderModel order = OrderModel(
      orderNo: 'ORD-20261117-AB12',
      customerId: walkInCustomerId,
      customerName: 'Walk-in customer',
      orderDate: DateTime(2026, 11, 17, 14, 5),
      channel: 'pos',
      discount: 50,
      items: <OrderItem>[
        OrderItem(productId: 'p', variantId: 'v', productName: 'Cricket Bat', variantLabel: 'Small', sku: 'B', quantity: 2, unitPrice: 1000, discount: 100),
        OrderItem(productId: 'p', variantId: 'w', productName: 'Ball', variantLabel: 'Red', sku: 'R', quantity: 1, unitPrice: 950.5),
      ],
    ); // 1900 + 950.5 - 50 = 2800.5

    ReceiptData receipt({double change = 0, List<ReceiptPayment>? payments}) => ReceiptData.fromParts(
          order,
          payments: payments ??
              const <ReceiptPayment>[
                ReceiptPayment(label: 'Cash', amount: 1800.5),
                ReceiptPayment(label: 'Easypaisa', amount: 1000, reference: 'EP-9'),
              ],
          shopName: 'MQ Sports',
          shopPhone: '0300 1112223',
          cashier: 'Sara',
          change: change,
        );

    test('totals follow the order, and a walk-in has no customer line', () {
      final ReceiptData r = receipt();
      expect(r.total, 2800.5);
      expect(r.discount, 150);
      expect(r.paid, 2800.5);
      expect(r.due, 0);
      expect(r.customerName, '');
      expect(r.lines.first.total, 1900);
    });

    test('the WhatsApp text lists items, payments, change and balance', () {
      final String text = receipt(change: 200).toText();
      expect(text, contains('*MQ Sports*'));
      expect(text, contains('Receipt ORD-20261117-AB12'));
      expect(text, contains('2 x Cricket Bat (Small)'));
      expect(text, contains('*Total: Rs 2800.50*'));
      expect(text, contains('Discount: -Rs 150'));
      expect(text, contains('Easypaisa: Rs 1000 (EP-9)'));
      expect(text, contains('Change: Rs 200'));
      expect(text, isNot(contains('Balance due')));
      expect(text, isNot(contains('Customer:')));

      final String credit = receipt(payments: const <ReceiptPayment>[ReceiptPayment(label: 'Cash', amount: 800)]).toText();
      expect(credit, contains('Balance due: Rs 2000.50'));
    });

    test('built from an order and its ledger, cancelled-order reversals are not payments', () {
      final List<LedgerModel> ledger = <LedgerModel>[
        LedgerModel(partyType: PartyType.customer, partyId: 'x', entryType: LedgerEntryType.payment, amount: 500, orderId: order.id, paymentMethod: 'jazzcash', paymentRef: 'J1'),
        LedgerModel(partyType: PartyType.customer, partyId: 'x', entryType: LedgerEntryType.payment, amount: 100, orderId: order.id),
        LedgerModel(partyType: PartyType.customer, partyId: 'x', entryType: LedgerEntryType.charge, amount: 2800.5, orderId: order.id),
        LedgerModel(partyType: PartyType.customer, partyId: 'x', entryType: LedgerEntryType.payment, amount: 7, orderId: 'other-order'),
        LedgerModel(partyType: PartyType.customer, partyId: 'x', entryType: LedgerEntryType.payment, amount: 2800.5, orderId: order.id, description: 'Cancelled order ORD'),
      ];
      final ReceiptData r = ReceiptData.fromOrder(order, ledger: ledger, shopName: 'Shop');
      expect(r.payments.map((ReceiptPayment p) => '${p.label}:${p.amount}'), <String>['JazzCash:500.0', 'Payment:100.0']);
      expect(r.due, 2200.5);
    });

    test('a named customer is printed, and online orders show delivery', () {
      final OrderModel web = OrderModel(
        orderNo: 'ORD-W',
        customerId: 'c1',
        customerName: 'Bilal',
        channel: 'web',
        shippingFee: 250,
        items: <OrderItem>[OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 1000)],
      );
      final ReceiptData r = ReceiptData.fromParts(web, payments: const <ReceiptPayment>[], shopName: 'Shop');
      expect(r.customerName, 'Bilal');
      expect(r.total, 1250);
      expect(r.toText(), contains('Delivery: Rs 250'));
      expect(r.toText(), contains('Customer: Bilal'));
    });

    test('the PDF is a real PDF', () async {
      final Uint8List bytes = await buildReceiptPdf(receipt(change: 200));
      expect(bytes.length, greaterThan(800));
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    });
  });
}
