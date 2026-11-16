// A day without internet, against the REAL backend API.
//
// Two simulated devices (each with its own database) use the app's own
// notifiers, the real sync engine and the real server:
//   - device A goes offline and keeps working (sales, a payment, edits, a count);
//   - device B stays online and sells the same stock;
//   - device A comes back and everything must end up the same everywhere, with
//     nothing lost, nothing counted twice and nothing silently overwritten.
//
// Needs the API running on an EMPTY database that has one admin login:
//
//   flutter test test/data/offline_flow_test.dart \
//     --dart-define=RUN_API_TESTS=true \
//     --dart-define=API_BASE_URL=http://127.0.0.1:3100
//
// Without RUN_API_TESTS the whole file is skipped.

import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/token_store.dart';
import 'package:a2_stocks/providers/auth_controller.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/core_providers.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/purchasing_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/sync_controller.dart';
import 'package:a2_stocks/providers/users_providers.dart';

const bool runApiTests = bool.fromEnvironment('RUN_API_TESTS');
const String adminEmail = String.fromEnvironment('FLOW_ADMIN_EMAIL', defaultValue: 'flow-admin@mq.test');
const String adminPassword = String.fromEnvironment('FLOW_ADMIN_PASSWORD', defaultValue: 'FlowPass123');

/// The device's network: it can be switched off, and it can lose the answer to
/// a request AFTER the server has done the work (the nastiest kind of failure).
class FlakyNetwork extends http.BaseClient {
  FlakyNetwork(this._real);

  final http.Client _real;
  bool online = true;
  String? loseAnswerOfPathContaining;
  int answersLost = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!online) {
      throw http.ClientException('no network (simulated)');
    }
    final http.StreamedResponse response = await _real.send(request);
    final String? target = loseAnswerOfPathContaining;
    if (target != null && request.method == 'POST' && request.url.path.contains(target)) {
      loseAnswerOfPathContaining = null;
      answersLost++;
      await response.stream.drain<void>();
      throw http.ClientException('connection lost after sending (simulated)');
    }
    return response;
  }
}

class Device {
  Device(this.network, this.db, this.app);

  final FlakyNetwork network;
  final AppDatabase db;
  final ProviderContainer app;

  SyncController get sync => app.read(syncControllerProvider.notifier);

  /// Syncs and waits until that (and any sync it overlapped with) is finished.
  Future<void> syncNow() async {
    await sync.syncNow(manual: true);
    await until(() => !app.read(syncControllerProvider).isSyncing, 'the sync to finish');
  }

  List<OutboxEntry> get queue => app.read(outboxEntriesProvider).valueOrNull ?? <OutboxEntry>[];

  int onHand(VariantModel variant) => app.read(stockOnHandProvider)[variant.id] ?? 0;
}

Future<Device> signedInDevice() async {
  final FlakyNetwork network = FlakyNetwork(http.Client());
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final ProviderContainer app = ProviderContainer(overrides: <Override>[
    databaseProvider.overrideWithValue(db),
    httpClientProvider.overrideWithValue(network),
    tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    isOnlineProvider.overrideWith((Ref ref) => Stream<bool>.value(true)),
  ]);
  app.listen<AsyncValue<String?>>(authUidProvider, (AsyncValue<String?>? a, AsyncValue<String?> b) {});
  await app.read(authControllerProvider.notifier).signIn(email: adminEmail, password: adminPassword);
  await until(() => app.read(authUidProvider).valueOrNull != null, 'the sign-in');
  await app.read(currentUserProvider.future);
  // The app keeps the sync running while someone is signed in.
  app.listen<SyncUiState>(syncControllerProvider, (SyncUiState? a, SyncUiState b) {});
  final Device device = Device(network, db, app);
  await device.syncNow();
  return device;
}

Future<void> until(bool Function() condition, [String what = 'the screen data']) async {
  for (int i = 0; i < 160; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $what.');
}

void main() {
  group('A day without internet', skip: runApiTests ? false : 'Set RUN_API_TESTS=true with the API running.', () {
    late Device a;
    late Device b;
    late ProductModel product;
    late VariantModel small;
    late CustomerModel ali;
    late VendorModel vendor;
    late CategoryModel cricket;

    setUpAll(() async {
      a = await signedInDevice();
      b = await signedInDevice();
    });

    tearDownAll(() async {
      for (final Device d in <Device>[a, b]) {
        d.app.dispose();
        await d.db.close();
      }
    });

    OrderItem line(int quantity, {double price = 100}) => OrderItem(
          productId: product.id,
          variantId: small.id,
          productName: 'Cricket Bat',
          variantLabel: 'Small',
          sku: 'BAT-S',
          quantity: quantity,
          unitPrice: price,
        );

    Future<bool> sell(Device d, int quantity, {double paidNow = 0, String notes = ''}) {
      return d.app.read(ordersProvider.notifier).confirmOrder(
            customer: ali,
            saleType: OrderSaleType.retail,
            orderDate: DateTime.now(),
            notes: notes,
            items: <OrderItem>[line(quantity)],
            orderDiscount: 0,
            paidNow: paidNow,
          );
    }

    group('while online', () {
      test('work is saved on the device first and uploaded by itself', () async {
        expect(await a.app.read(categoriesProvider.notifier).createCategory(name: 'Cricket', parentId: '', description: '', isActive: true), isTrue);
        await until(() => (a.app.read(categoriesProvider).valueOrNull ?? <CategoryModel>[]).length == 1, 'the category');
        cricket = a.app.read(categoriesProvider).requireValue.single;
        // It shows on the device straight away; the sync then uploads it by itself.
        await a.syncNow();

        expect(a.queue, isEmpty); // uploaded, downloaded back, tidied away
        expect((await a.app.read(apiClientProvider).get('/v1/categories')).asList.length, 1);
        // The record on the device is now the server's own.
        expect((await a.app.read(localCollectionsProvider).categories.byId(cricket.id))?.name, 'Cricket');
      });

      test('a catalog, a vendor, a customer and a first purchase', () async {
        expect(
          await a.app.read(productsProvider.notifier).createProduct(
            name: 'Cricket Bat', categoryId: cricket.id, brand: 'MQ', description: '', isActive: true,
            variants: <VariantModel>[VariantModel(sku: 'BAT-S', name: 'Small', costPrice: 40, salePrice: 100)],
          ),
          isTrue,
        );
        expect(await a.app.read(vendorsProvider.notifier).createVendor(VendorModel(name: 'Sialkot Works')), isTrue);
        expect(await a.app.read(customersProvider.notifier).createCustomer(CustomerModel(name: 'Ali', creditLimit: 0)), isTrue);
        await until(() => (a.app.read(productsProvider).valueOrNull ?? <ProductModel>[]).isNotEmpty, 'the product');
        await until(() => (a.app.read(vendorsProvider).valueOrNull ?? <VendorModel>[]).isNotEmpty, 'the vendor');
        await until(() => (a.app.read(customersProvider).valueOrNull ?? <CustomerModel>[]).isNotEmpty, 'the customer');
        product = a.app.read(productsProvider).requireValue.single;
        small = product.variants.single;
        vendor = a.app.read(vendorsProvider).requireValue.single;
        ali = a.app.read(customersProvider).requireValue.single;

        await a.syncNow(); // the purchase below needs the vendor and the product on the server
        expect(
          await a.app.read(purchasesProvider.notifier).confirmPurchase(
            vendor: vendor, purchaseDate: DateTime.now(), invoiceNo: 'INV-1', notes: '', paidNow: 0,
            items: <PurchaseItem>[
              PurchaseItem(productId: product.id, variantId: small.id, productName: 'Cricket Bat', variantLabel: 'Small', sku: 'BAT-S', quantity: 10, unitCost: 40),
            ],
          ),
          isTrue,
        );
        await until(() => a.onHand(small) == 10, 'the stock to show on device A');
        await a.syncNow();

        // Device B, which knows nothing yet, downloads the whole thing.
        await b.syncNow();
        await until(() => b.onHand(small) == 10, 'the stock to reach device B');
        await until(() => (b.app.read(customersProvider).valueOrNull ?? <CustomerModel>[]).length == 1, 'the customers on B');
        expect(b.queue, isEmpty);
      });
    });

    group('device A loses its connection', () {
      test('keeps working: sells, takes a payment and a stock count, all visible at once', () async {
        a.network.online = false;

        expect(await sell(a, 3, paidNow: 100, notes: 'first offline sale'), isTrue);
        expect(await sell(a, 4, notes: 'second offline sale'), isTrue);

        // Everything shows immediately, from the queue.
        await until(() => a.onHand(small) == 3, 'the stock to drop on A');
        await until(() => (a.app.read(ordersProvider).valueOrNull ?? <OrderModel>[]).length == 2, 'the orders on A');
        await until(() => (a.app.read(ledgerTotalsProvider)[ali.id] ?? 0) == 300 + 400 - 100, 'what Ali owes');
        await until(() => a.queue.length == 2, 'both sales to be queued');
        expect(a.queue.map((OutboxEntry e) => e.kind), <OutboxKind>[OutboxKind.orderConfirm, OutboxKind.orderConfirm]);

        // A payment on the first order.
        final OrderModel first = a.app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.notes == 'first offline sale');
        expect(await a.app.read(ordersProvider.notifier).addPayment(order: first, amount: 50, date: DateTime.now(), note: ''), isTrue);
        await until(() => (a.app.read(ledgerTotalsProvider)[ali.id] ?? 0) == 300 + 400 - 100 - 50, 'the payment to show');

        // And the order is moved on.
        expect(await a.app.read(ordersProvider.notifier).advanceStatus(first), isTrue);
        await until(
          () => a.app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == first.id).status == OrderStatus.processing,
          'the order to move on',
        );

        // Trying to sync changes nothing and loses nothing.
        await a.syncNow();
        expect(a.app.read(syncSummaryProvider).status, SyncStatus.offline);
        await until(() => a.queue.length == 4, 'the four actions');
        expect(a.queue.every((OutboxEntry e) => e.state == OutboxState.pending), isTrue);
      });

      test('the work survives closing the app: it is in the database, not in memory', () async {
        final List<OutboxEntry> fromDisk = await a.app.read(outboxStoreProvider).all();
        expect(fromDisk.length, 4);
        expect(fromDisk.map((OutboxEntry e) => e.opId).toSet().length, 4);
      });
    });

    group('meanwhile device B sells the same stock', () {
      test('and the server accepts it', () async {
        expect(await sell(b, 8, paidNow: 800, notes: 'sold by B'), isTrue);
        await b.syncNow();
        expect(b.queue, isEmpty);
        // The server has 10 - 8 = 2 left, while A believes 3 are left.
        await until(() => b.onHand(small) == 2, 'B to show 2');
      });

      test('B makes a catalog change that A will conflict with', () async {
        expect(await b.app.read(categoriesProvider.notifier).createCategory(name: 'Balls', parentId: '', description: '', isActive: true), isTrue);
        await b.syncNow();
      });
    });

    group('device A comes back', () {
      test('queues one more change that the server will refuse (a duplicate name)', () async {
        // A does not know about "Balls" yet, so it lets this through locally.
        expect(await a.app.read(categoriesProvider.notifier).createCategory(name: 'Balls', parentId: '', description: 'from A', isActive: true), isTrue);
        await until(() => a.queue.length == 5, 'the fifth action');
      });

      test('the answer to the first upload is lost on the way back', () async {
        a.network.online = true;
        a.network.loseAnswerOfPathContaining = '/orders/confirm';

        await a.syncNow();

        // The server DID record that sale, but A never heard so: the upload stopped there.
        expect(a.network.answersLost, 1);
        expect(a.app.read(syncSummaryProvider).status, anyOf(SyncStatus.offline, SyncStatus.pending));
        final int onServer = (await a.app.read(apiClientProvider).get('/v1/orders')).asMap['total'] as int;
        expect(onServer, 2); // B's sale + A's first sale
      });

      test('the retry does not sell twice, and everything else goes through', () async {
        await a.syncNow();
        await a.syncNow(); // the second one downloads and tidies up

        // The server holds exactly one copy of each order: B's and A's two.
        final JsonMap orders = (await a.app.read(apiClientProvider).get('/v1/orders')).asMap;
        expect(orders['total'], 3);
        final List<Object?> numbers = (orders['items'] as List<Object?>).map((Object? o) => (o! as Map<String, dynamic>)['notes']).toList();
        expect(numbers..sort((Object? x, Object? y) => '$x'.compareTo('$y')), <Object?>['first offline sale', 'second offline sale', 'sold by B']);

        // The sale made with no connection was recorded even though B sold the
        // last of the stock in the meantime: stock is now negative, and flagged.
        final JsonMap stock = (await a.app.read(apiClientProvider).get('/v1/stock')).asMap;
        final Map<String, dynamic> row = (stock['items'] as List<Object?>).single! as Map<String, dynamic>;
        expect(row['onHand'], 10 - 8 - 3 - 4);
        expect(row['isNegative'], isTrue);
        expect(stock['negativeCount'], 1);
      });

      test('A now shows exactly what the server has: no duplicates, no leftovers', () async {
        await until(() => a.onHand(small) == -5, 'A to show the server\'s stock');
        final List<OrderModel> orders = a.app.read(ordersProvider).requireValue;
        expect(orders.length, 3);
        expect(orders.map((OrderModel o) => o.id).toSet().length, 3);

        // Ali owes: 300 + 400 + 800 charged, 100 + 50 + 800 paid.
        await until(() => (a.app.read(ledgerTotalsProvider)[ali.id] ?? 0) == 550, 'the balance');
        final List<LedgerModel> ledger = a.app.read(ledgerEntriesProvider).requireValue.where((LedgerModel e) => e.partyId == ali.id).toList();
        expect(ledger.map((LedgerModel e) => e.id).toSet().length, ledger.length); // no entry twice

        // The first order moved on to Processing on the server too.
        final OrderModel first = orders.firstWhere((OrderModel o) => o.notes == 'first offline sale');
        expect(first.status, OrderStatus.processing);
        expect(first.statusHistory.length, 2);

        // The queue holds only the refused change.
        final List<OutboxEntry> left = a.queue.where((OutboxEntry e) => e.state != OutboxState.sent).toList();
        expect(left.length, 1);
        expect(left.single.state, OutboxState.failed);
        expect(left.single.error, contains('already exists'));
        expect(a.app.read(syncSummaryProvider).status, SyncStatus.needsAttention);
      });

      test('the refused change is explained, can be discarded, and the list shows the server\'s truth', () async {
        final OutboxEntry refused = a.queue.firstWhere((OutboxEntry e) => e.state == OutboxState.failed);
        expect(refused.label, contains('Balls'));
        // While refused it does not pretend to exist; the server's own "Balls" (B's) is what shows.
        final List<CategoryModel> shown = a.app.read(categoriesProvider).requireValue;
        expect(shown.where((CategoryModel c) => c.name == 'Balls').length, 1);
        expect(shown.firstWhere((CategoryModel c) => c.name == 'Balls').description, isNot('from A'));

        await a.sync.discard(refused.opId);
        await until(() => a.queue.isEmpty, 'the queue to empty');
        expect(a.app.read(syncSummaryProvider).status, SyncStatus.upToDate);
      });
    });

    group('afterwards', () {
      test('device B catches up with everything A did', () async {
        await b.syncNow();
        await until(() => b.onHand(small) == -5, 'B to show the same stock');
        await until(() => (b.app.read(ordersProvider).valueOrNull ?? <OrderModel>[]).length == 3, 'B to show all three orders');
        expect(b.queue, isEmpty);
      });

      test('both devices show the same dashboard as the server', () async {
        final JsonMap server = (await a.app.read(apiClientProvider).get('/v1/dashboard')).asMap;
        for (final Device d in <Device>[a, b]) {
          final DashboardStats stats = d.app.read(dashboardStatsProvider);
          expect(stats.pendingOrders, server['pendingOrders']);
          expect(stats.processingOrders, server['processingOrders']);
          expect(stats.salesMonth, server['salesMonth']);
          expect(stats.stockUnits, server['stockUnits']);
        }
      });

      test('an edit made offline overwrites the server only when the device syncs, and is applied once', () async {
        a.network.online = false;
        final ProductModel current = a.app.read(productsProvider).requireValue.single;
        final ProductModel repriced = current.copyWith(variants: <VariantModel>[current.variants.single.copyWith(salePrice: 120)]);
        expect(await a.app.read(productsProvider.notifier).updateProduct(repriced), isTrue);
        await until(() => a.app.read(productsProvider).requireValue.single.variants.single.salePrice == 120, 'the new price on A');
        // The server still has the old price.
        a.network.online = true;
        expect(((await a.app.read(apiClientProvider).get('/v1/products')).asMap['items'] as List<Object?>).length, 1);
        a.network.online = false;

        a.network.online = true;
        await a.syncNow();
        await b.syncNow();
        await until(() => b.app.read(productsProvider).requireValue.single.variants.single.salePrice == 120, 'the price to reach B');
        expect(a.queue, isEmpty);
      });

      test('a device that is signed out keeps its unsent work for the next sign-in', () async {
        a.network.online = false;
        expect(await a.app.read(customersProvider.notifier).createCustomer(CustomerModel(name: 'Added just before signing out')), isTrue);
        await until(() => a.queue.length == 1, 'the action to be queued');
        final String opId = a.queue.single.opId;
        await a.app.read(authControllerProvider.notifier).signOut();
        await until(() => a.app.read(authUidProvider).valueOrNull == null, 'the sign-out');
        // The work is still in the user's database file.
        expect((await a.db.select(a.db.outbox).get()).map((OutboxRow r) => r.opId), contains(opId));
      });
    });
  });
}
