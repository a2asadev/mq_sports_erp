import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mq_sports_erp/core/utils/currency.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/core/utils/whatsapp.dart';
import 'package:mq_sports_erp/models/business_info.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/providers/business_provider.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';

class _FakeCurrentUser extends CurrentUserNotifier {
  @override
  Future<UserModel?> build() async => UserModel(id: 'u1', email: 'a@b.c');
}

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

void main() {
  // The currency is process-wide: every test starts and ends in rupees.
  setUp(() => MoneyFormat.use('PKR'));
  tearDown(() => MoneyFormat.use('PKR'));

  group('CurrencyInfo', () {
    test('knows its supported currencies, each by its ISO code', () {
      expect(CurrencyInfo.supported.map((CurrencyInfo c) => c.code), contains('PKR'));
      expect(CurrencyInfo.supported.map((CurrencyInfo c) => c.code).toSet().length, CurrencyInfo.supported.length);
      expect(CurrencyInfo.byCode('USD').symbol, r'$');
      expect(CurrencyInfo.byCode('PKR'), CurrencyInfo.pkr);
    });

    test('a symbol of letters is followed by a space, a sign is attached', () {
      expect(CurrencyInfo.byCode('PKR').prefix, 'Rs ');
      expect(CurrencyInfo.byCode('AED').prefix, 'AED ');
      expect(CurrencyInfo.byCode('USD').prefix, r'$');
      expect(CurrencyInfo.byCode('EUR').prefix, '€');
      expect(CurrencyInfo.byCode('CAD').prefix, r'C$');
    });

    test('a code the app does not know is written as itself, never as the wrong symbol', () {
      final CurrencyInfo odd = CurrencyInfo.byCode('XYZ');
      expect(odd.code, 'XYZ');
      expect(odd.prefix, 'XYZ ');
    });
  });

  group('amounts follow the business\'s currency', () {
    test('formatMoney, receipts and the WhatsApp message all switch', () {
      expect(formatMoney(12500), 'Rs 12,500');
      MoneyFormat.use('USD');
      expect(formatMoney(12500), r'$12,500');
      expect(formatMoney(12500.5), r'$12,500.50');
      expect(formatMoney(-40), r'-$40');
      expect(ReceiptData.money(1250), r'$1250');
      MoneyFormat.use('AED');
      expect(formatMoney(12500), 'AED 12,500');
      expect(ReceiptData.money(99.5), 'AED 99.50');
      expect(formatAmount(12500), '12500.00'); // plain figures carry no currency
    });

    test('a receipt prints the currency of the moment it is made', () {
      final OrderModel order = OrderModel(
        orderNo: 'ORD-1',
        customerId: 'c1',
        customerName: 'Bilal',
        shippingFee: 250,
        items: <OrderItem>[
          OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 1000),
        ],
      );
      ReceiptData receipt() => ReceiptData.fromParts(order, payments: const <ReceiptPayment>[], shopName: 'Ali', walkInCustomerId: '');
      expect(receipt().toText(), contains('Delivery: Rs 250'));
      MoneyFormat.use('USD');
      expect(receipt().toText(), contains(r'Delivery: $250'));
      expect(receipt().toText(), isNot(contains('Rs')));
    });

    test('the WhatsApp text names the amount in the business\'s currency', () {
      final OrderModel order = OrderModel(
        orderNo: 'ORD-7',
        customerId: 'c1',
        customerName: 'Bilal',
        items: <OrderItem>[
          OrderItem(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', quantity: 1, unitPrice: 800),
        ],
      );
      MoneyFormat.use('GBP');
      final String text = WhatsApp.orderMessage(order, shopName: 'Ali');
      expect(text, contains('£800'));
      expect(text, isNot(contains('Rs')));
    });
  });

  group('businessProvider', () {
    ProviderContainer containerFor(ApiClient api) {
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        currentUserProvider.overrideWith(_FakeCurrentUser.new),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    Future<ApiClient> signedIn(String currency) async {
      final ApiClient api = ApiClient(
        httpClient: MockClient((http.Request r) async => _json(
              200,
              '{"accessToken":"a","refreshToken":"r","user":{"id":"u1","email":"a@b.c","displayName":"A","role":"admin","isActive":true,'
              '"createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"},'
              '"tenant":{"id":"t1","name":"Ali","phone":"","walkInCustomerId":"w1","hasOnlineStore":false,"currency":"$currency"}}',
            )),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      );
      await api.login('a@b.c', 'x');
      return api;
    }

    test('reading it points every amount at the business\'s currency', () async {
      final ProviderContainer c = containerFor(await signedIn('AED'));
      expect(MoneyFormat.current.code, 'PKR');
      expect(c.read(businessProvider).currency, 'AED');
      expect(formatMoney(5), 'AED 5');
    });

    test('a change made in the app is applied at once and kept with the session', () async {
      final ApiClient api = await signedIn('AED');
      final ProviderContainer c = containerFor(api);
      final BusinessInfo before = c.read(businessProvider);

      await c.read(businessUpdaterProvider)(before.copyWith(currency: 'USD', name: 'Ali Store'));

      expect(c.read(businessProvider).currency, 'USD');
      expect(c.read(businessProvider).name, 'Ali Store');
      expect(api.currentBusiness?.currency, 'USD');
      expect(formatMoney(5), r'$5');
    });

    test('with no session the business is MQ Sports, in rupees', () {
      final ProviderContainer c = containerFor(ApiClient(
        httpClient: MockClient((http.Request _) async => _json(500, '{}')),
        baseUrl: 'http://api.test',
        tokens: MemoryTokenStore(),
      ));
      expect(c.read(businessProvider), BusinessInfo.mqSports);
      expect(formatMoney(5), 'Rs 5');
    });
  });
}
