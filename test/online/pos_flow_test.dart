// Real-server check of a POS sale: split payments by method, receipt data and
// the ledger, through the app's own order notifier (as the POS screen calls it).
//
// Needs the API running on an empty database with one admin login:
//
//   flutter test test/online/pos_flow_test.dart \
//     --dart-define=RUN_API_TESTS=true \
//     --dart-define=API_BASE_URL=http://127.0.0.1:3100
//
// Without RUN_API_TESTS the file is skipped.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/core/utils/receipt.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/payment_method.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/providers/auth_controller.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';

const bool _run = bool.fromEnvironment('RUN_API_TESTS');

Future<void> _until(bool Function() condition, String what) async {
  for (int i = 0; i < 100; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $what.');
}

void main() {
  test('a POS sale paid by cash + Easypaisa + bank is recorded per method', () async {
    final ProviderContainer app = ProviderContainer(overrides: <Override>[
      dataModeProvider.overrideWithValue(DataMode.onlineOnly),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ]);
    addTearDown(app.dispose);
    app.listen<AsyncValue<String?>>(authUidProvider, (AsyncValue<String?>? a, AsyncValue<String?> b) {});
    await app.read(authControllerProvider.notifier).signIn(email: 'flow-admin@mq.test', password: 'FlowPass123');
    await _until(() => app.read(authUidProvider).valueOrNull != null, 'the sign-in');
    await app.read(currentUserProvider.future);
    final ApiClient api = app.read(apiClientProvider);

    // Shop data: a product with stock, and the walk-in customer.
    final String categoryId = (await api.post('/v1/categories', body: <String, dynamic>{'name': 'POS test'})).asMap['id'] as String;
    final Map<String, dynamic> product = (await api.post('/v1/products', body: <String, dynamic>{
      'name': 'Test Bat',
      'categoryId': categoryId,
      'variants': <Map<String, dynamic>>[
        <String, dynamic>{'sku': 'POS-1', 'salePrice': 1000, 'costPrice': 600},
      ],
    })).asMap;
    final String variantId = ((product['variants'] as List<Object?>).single as Map<String, dynamic>)['id'] as String;
    final String vendorId = (await api.post('/v1/vendors', body: <String, dynamic>{'name': 'POS vendor'})).asMap['id'] as String;
    await api.post('/v1/purchases/confirm', body: <String, dynamic>{
      'vendorId': vendorId,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{'productId': product['id'], 'variantId': variantId, 'quantity': 10, 'unitCost': 600},
      ],
    });
    try {
      await api.post('/v1/customers', body: <String, dynamic>{'id': walkInCustomerId, 'name': 'Walk-in customer'});
    } catch (_) {
      // Already there (created by the migration).
    }

    await app.read(remoteStoreProvider).refresh();
    await _until(() => (app.read(productsProvider).valueOrNull ?? <ProductModel>[]).isNotEmpty, 'the products');
    await _until(() => (app.read(customersProvider).valueOrNull ?? <CustomerModel>[]).any((CustomerModel c) => c.id == walkInCustomerId), 'the customers');
    await _until(() => app.read(stockOnHandProvider)[variantId] == 10, 'the stock');

    final ProductModel bat = app.read(productsProvider).requireValue.firstWhere((ProductModel p) => p.name == 'Test Bat');
    final VariantModel variant = bat.variants.single;
    final CustomerModel walkIn = app.read(customersProvider).requireValue.firstWhere((CustomerModel c) => c.id == walkInCustomerId);

    // 2 x 1000 - 100 line discount - 50 sale discount = 1850
    final PosCart cart = const PosCart().add(bat, variant, quantity: 2).setLineDiscount(variant.id, 100).withOrderDiscount(50);
    expect(cart.total, 1850);

    final OrdersNotifier orders = app.read(ordersProvider.notifier);
    final bool ok = await orders.confirmOrder(
      customer: walkIn,
      saleType: OrderSaleType.retail,
      orderDate: DateTime.now(),
      notes: '',
      items: cart.toItems(),
      orderDiscount: cart.effectiveOrderDiscount,
      paidNow: 0,
      channel: 'pos',
      payments: const <PaymentLine>[
        PaymentLine(method: PaymentMethod.cash, amount: 850),
        PaymentLine(method: PaymentMethod.easypaisa, amount: 700, reference: 'EP-555'),
        PaymentLine(method: PaymentMethod.bank, amount: 300, reference: 'HBL 99'),
      ],
    );
    expect(ok, isTrue, reason: '${app.read(ordersProvider).error}');
    final OrderModel confirmed = orders.lastConfirmed!;
    expect(confirmed.channel, 'pos');

    await _until(
      () => (app.read(ordersProvider).valueOrNull ?? <OrderModel>[]).any((OrderModel o) => o.id == confirmed.id),
      'the order',
    );
    final OrderModel saved = app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == confirmed.id);
    expect(saved.channel, 'pos');
    expect(saved.totalAmount, 1850);
    expect(app.read(stockOnHandProvider)[variantId], 8);

    await _until(
      () => (app.read(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[]).where((LedgerModel e) => e.orderId == saved.id).length == 4,
      'the ledger',
    );
    final List<LedgerModel> ledger = app.read(ledgerEntriesProvider).requireValue;
    final ReceiptData receipt = ReceiptData.fromOrder(saved, ledger: ledger, shopName: 'Shop');
    expect(receipt.paid, 1850);
    expect(receipt.due, 0);
    expect(receipt.payments.map((ReceiptPayment p) => '${p.label}:${p.amount}:${p.reference}').toList()..sort(), <String>[
      'Bank transfer:300.0:HBL 99',
      'Cash:850.0:',
      'Easypaisa:700.0:EP-555',
    ]);
    expect(receipt.customerName, '');
    // Paid in full: the walk-in owes nothing.
    expect(app.read(ledgerTotalsProvider)[walkInCustomerId] ?? 0, 0);
  }, skip: _run ? false : 'Needs the real API (see the top of this file).');
}
