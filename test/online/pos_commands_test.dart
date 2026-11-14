import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/api_commands.dart';
import 'package:mq_sports_erp/online/token_store.dart';

const String _user =
    '{"id":"u1","email":"a@b.c","displayName":"Ann","phoneNumber":"","role":"staff","isActive":true,'
    '"photoUrl":"","createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"}';

void main() {
  late List<http.Request> sent;
  late ApiCommands commands;

  setUp(() async {
    sent = <http.Request>[];
    final MockClient mock = MockClient((http.Request r) async {
      if (r.url.path == '/v1/auth/login') {
        return http.Response('{"accessToken":"a","refreshToken":"r","user":$_user}', 200,
            headers: <String, String>{'content-type': 'application/json'});
      }
      sent.add(r);
      return http.Response('{}', 200, headers: <String, String>{'content-type': 'application/json'});
    });
    final ApiClient api = ApiClient(httpClient: mock, baseUrl: 'http://api.test', tokens: MemoryTokenStore());
    await api.login('a@b.c', 'x');
    commands = ApiCommands(api);
  });

  Map<String, dynamic> body(int i) => jsonDecode(sent[i].body) as Map<String, dynamic>;

  final OrderModel order = OrderModel(
    id: 'o1',
    orderNo: 'ORD-1',
    customerId: 'c1',
    customerName: 'Ali',
    channel: 'pos',
    items: <OrderItem>[
      OrderItem(id: 'i1', productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 100),
    ],
  );

  test('a POS sale sends its channel and each payment with its method', () async {
    await commands.confirmOrder(
      order,
      100,
      payments: const <PaymentLine>[
        PaymentLine(method: PaymentMethod.cash, amount: 40),
        PaymentLine(method: PaymentMethod.bank, amount: 60, reference: ' HBL 12 '),
      ],
    );
    final Map<String, dynamic> b = body(0);
    expect(b['channel'], 'pos');
    expect(b.containsKey('paidNow'), isFalse);
    expect(b['payments'], <Map<String, dynamic>>[
      <String, dynamic>{'method': 'cash', 'amount': 40},
      <String, dynamic>{'method': 'bank', 'amount': 60, 'reference': 'HBL 12'},
    ]);
  });

  test('an order without payment lines still sends one amount', () async {
    await commands.confirmOrder(order, 25.5);
    final Map<String, dynamic> b = body(0);
    expect(b['paidNow'], 25.5);
    expect(b.containsKey('payments'), isFalse);
  });

  test('a later order payment names its method; one with no method sends none', () async {
    LedgerModel pay({String method = '', String ref = ''}) => LedgerModel(
          partyType: PartyType.customer,
          partyId: 'c1',
          entryType: LedgerEntryType.payment,
          amount: 10,
          orderId: 'o1',
          reference: 'ORD-1',
          paymentMethod: method,
          paymentRef: ref,
        );
    await commands.orderPayment(pay(method: 'easypaisa', ref: 'A1'));
    await commands.orderPayment(pay());
    expect(body(0)['paymentMethod'], 'easypaisa');
    expect(body(0)['paymentRef'], 'A1');
    expect(body(1).containsKey('paymentMethod'), isFalse);
  });

  test('vendor ledger entries never carry a payment method (the server does not take one)', () async {
    await commands.ledgerEntry(LedgerModel(
      partyType: PartyType.vendor,
      partyId: 'v1',
      entryType: LedgerEntryType.payment,
      amount: 10,
      paymentMethod: 'cash',
      paymentRef: 'x',
    ));
    expect(body(0).containsKey('paymentMethod'), isFalse);
    expect(body(0).containsKey('paymentRef'), isFalse);
  });
}
