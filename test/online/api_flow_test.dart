// End-to-end check of the online (web) app against the REAL backend API.
//
// It runs the app's own notifiers in online mode, exactly as the screens do, so
// it proves the web admin and the server agree on every action.
//
// Needs the API running on an empty database that has one admin login:
//
//   flutter test test/online/api_flow_test.dart \
//     --dart-define=RUN_API_TESTS=true \
//     --dart-define=API_BASE_URL=http://127.0.0.1:3100
//
// Without RUN_API_TESTS the whole file is skipped, so a plain `flutter test`
// stays green on a computer where the API is not running.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/activity_log_model.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/ledger_model.dart';
import 'package:mq_sports_erp/models/order_model.dart';
import 'package:mq_sports_erp/models/party_enums.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/models/vendor_model.dart';
import 'package:mq_sports_erp/online/api_client.dart';
import 'package:mq_sports_erp/online/online_providers.dart';
import 'package:mq_sports_erp/online/token_store.dart';
import 'package:mq_sports_erp/providers/activity_log_providers.dart';
import 'package:mq_sports_erp/providers/auth_controller.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/dashboard_providers.dart';
import 'package:mq_sports_erp/providers/data_mode.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/purchasing_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_audit_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';

const bool runApiTests = bool.fromEnvironment('RUN_API_TESTS');
const String adminEmail =
    String.fromEnvironment('FLOW_ADMIN_EMAIL', defaultValue: 'flow-admin@mq.test');
const String adminPassword =
    String.fromEnvironment('FLOW_ADMIN_PASSWORD', defaultValue: 'FlowPass123');

ProviderContainer _app(TokenStore tokens) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      dataModeProvider.overrideWithValue(DataMode.onlineOnly),
      tokenStoreProvider.overrideWithValue(tokens),
    ],
  );
  // The sign-in gate watches this from the first frame, before anybody signs in.
  container.listen<AsyncValue<String?>>(
      authUidProvider, (AsyncValue<String?>? a, AsyncValue<String?> b) {});
  return container;
}

/// The lists reload a moment after an action finishes (as screens would).
Future<void> until(bool Function() condition, [String what = 'the screen data']) async {
  for (int i = 0; i < 100; i++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  fail('Timed out waiting for $what.');
}

Future<void> signIn(ProviderContainer app, String email, String password) async {
  await app.read(authControllerProvider.notifier).signIn(email: email, password: password);
  await until(() => app.read(authUidProvider).valueOrNull != null, 'the sign-in');
  await app.read(currentUserProvider.future);
}

T lastError<T extends Object>(AsyncValue<Object?> value) {
  final Object? error = value.error;
  expect(error, isA<T>());
  return error! as T;
}

void main() {
  group('Online app against the real API', skip: runApiTests ? false : 'Set RUN_API_TESTS=true with the API running.', () {
    final MemoryTokenStore sharedTokens = MemoryTokenStore();
    late ProviderContainer app;

    late CategoryModel bats;
    late ProductModel product;
    late VariantModel small;
    late VariantModel large;
    late VendorModel vendor;
    late CustomerModel customer;
    late PurchaseModel purchase;
    late OrderModel order;

    setUpAll(() {
      app = _app(sharedTokens);
    });

    tearDownAll(() {
      app.dispose();
    });

    int onHand(VariantModel variant) => app.read(stockOnHandProvider)[variant.id] ?? 0;
    double customerBalance() =>
        customer.openingBalance + (app.read(ledgerTotalsProvider)[customer.id] ?? 0);

    group('signing in', () {
      test('a wrong password is refused with the server message', () async {
        await app.read(authControllerProvider.notifier).signIn(email: adminEmail, password: 'not-the-password');
        final AuthFailureException error = lastError<AuthFailureException>(app.read(authControllerProvider));
        expect(error.message, 'Invalid email or password');
        expect(app.read(authUidProvider).valueOrNull, isNull);
      });

      test('the right password signs in and the server says who this is', () async {
        await signIn(app, adminEmail, adminPassword);
        final UserModel? user = app.read(currentUserProvider).valueOrNull;
        expect(user?.email, adminEmail);
        expect(user?.role, UserRole.admin);
        expect(user?.isActive, isTrue);
      });
    });

    group('catalog', () {
      test('categories: a tree, and duplicates are refused by the server rule', () async {
        final CategoriesNotifier notifier = app.read(categoriesProvider.notifier);
        expect(await notifier.createCategory(name: 'Cricket', parentId: '', description: '', isActive: true), isTrue);
        await until(() => (app.read(categoriesProvider).valueOrNull ?? <CategoryModel>[]).length == 1, 'the category');
        final CategoryModel root = app.read(categoriesProvider).requireValue.single;

        expect(await notifier.createCategory(name: 'Bats', parentId: root.id, description: 'Willow', isActive: true), isTrue);
        await until(() => app.read(categoriesProvider).requireValue.length == 2, 'the subcategory');
        bats = app.read(categoriesProvider).requireValue.firstWhere((CategoryModel c) => c.name == 'Bats');
        expect(bats.parentId, root.id);
        expect(bats.description, 'Willow');

        expect(await notifier.createCategory(name: 'bats', parentId: root.id, description: '', isActive: true), isFalse);
        expect(lastError<ValidationException>(app.read(categoriesProvider)).message, contains('already exists'));
      });

      test('a category in use cannot be deleted; the server explains why', () async {
        final CategoryModel root = app.read(categoriesProvider).requireValue.firstWhere((CategoryModel c) => c.parentId.isEmpty);
        expect(await app.read(categoriesProvider.notifier).deleteCategory(root.id), isFalse);
        expect(lastError<ValidationException>(app.read(categoriesProvider)).message, contains('subcategories'));
      });

      test('products keep their variants, prices and ids', () async {
        final ProductsNotifier notifier = app.read(productsProvider.notifier);
        final bool created = await notifier.createProduct(
          name: 'Cricket Bat',
          categoryId: bats.id,
          brand: 'MQ',
          description: 'Kashmir willow',
          isActive: true,
          variants: <VariantModel>[
            VariantModel(sku: 'BAT-S', name: 'Small', costPrice: 40, salePrice: 100, alertThreshold: 5),
            VariantModel(sku: 'BAT-L', attributes: <String, String>{'Size': 'L', 'Grip': 'Rubber'}, costPrice: 60, salePrice: 150.5),
          ],
        );
        expect(created, isTrue);
        await until(() => (app.read(productsProvider).valueOrNull ?? <ProductModel>[]).length == 1, 'the product');
        product = app.read(productsProvider).requireValue.single;
        small = product.variants.firstWhere((VariantModel v) => v.sku == 'BAT-S');
        large = product.variants.firstWhere((VariantModel v) => v.sku == 'BAT-L');
        expect(product.brand, 'MQ');
        expect(large.salePrice, 150.5);
        expect(large.label, 'L / Rubber'); // the order of the attributes is kept
        expect(small.alertThreshold, 5);
      });

      test('a SKU that exists already is refused', () async {
        final bool again = await app.read(productsProvider.notifier).createProduct(
          name: 'Another bat',
          categoryId: bats.id,
          brand: '',
          description: '',
          isActive: true,
          variants: <VariantModel>[VariantModel(sku: 'bat-s')],
        );
        expect(again, isFalse);
        expect(lastError<ValidationException>(app.read(productsProvider)).message, contains('BAT-S'));
      });

      test('vendors and customers', () async {
        expect(await app.read(vendorsProvider.notifier).createVendor(VendorModel(name: 'Sialkot Works', phone: '0300-1')), isTrue);
        expect(
          await app.read(customersProvider.notifier).createCustomer(
              CustomerModel(name: 'Ali Traders', type: CustomerType.wholesale, creditLimit: 1000)),
          isTrue,
        );
        await until(() => (app.read(vendorsProvider).valueOrNull ?? <VendorModel>[]).isNotEmpty, 'the vendor');
        await until(() => (app.read(customersProvider).valueOrNull ?? <CustomerModel>[]).isNotEmpty, 'the customer');
        vendor = app.read(vendorsProvider).requireValue.single;
        customer = app.read(customersProvider).requireValue.single;
        expect(customer.creditLimit, 1000);
        expect(customer.type, CustomerType.wholesale);

        expect(await app.read(vendorsProvider.notifier).createVendor(VendorModel(name: 'Other', phone: '0300-1')), isFalse);
        expect(lastError<ValidationException>(app.read(vendorsProvider)).message, contains('phone'));
      });
    });

    group('purchasing', () {
      test('confirming a purchase adds the stock and charges the vendor', () async {
        final bool ok = await app.read(purchasesProvider.notifier).confirmPurchase(
          vendor: vendor,
          purchaseDate: DateTime.now(),
          invoiceNo: 'INV-1',
          notes: '',
          paidNow: 200,
          items: <PurchaseItem>[
            PurchaseItem(productId: product.id, variantId: small.id, productName: 'Cricket Bat', variantLabel: 'Small', sku: 'BAT-S', quantity: 10, unitCost: 50),
            PurchaseItem(productId: product.id, variantId: large.id, productName: 'Cricket Bat', variantLabel: 'L / Rubber', sku: 'BAT-L', quantity: 5, unitCost: 60),
          ],
        );
        expect(ok, isTrue);
        await until(() => onHand(small) == 10 && onHand(large) == 5, 'the stock');
        await until(() => (app.read(purchasesProvider).valueOrNull ?? <PurchaseModel>[]).length == 1, 'the purchase');
        purchase = app.read(purchasesProvider).requireValue.single;
        expect(purchase.totalAmount, 800);
        expect(purchase.items.length, 2);
        // The ledger list loads the first time it is needed, like on a screen.
        await until(() => app.read(purchasePaidProvider)[purchase.id] == 200, 'the payment on the purchase');
        // We owe the vendor 800 - 200.
        expect(app.read(ledgerTotalsProvider)[vendor.id], 600);
      });

      test('a payment settles it, and paying more than is due is refused', () async {
        final PurchasesNotifier notifier = app.read(purchasesProvider.notifier);
        expect(await notifier.addPayment(purchase: purchase, amount: 600, date: DateTime.now(), note: ''), isTrue);
        await until(() => app.read(purchasePaidProvider)[purchase.id] == 800, 'the payment');
        expect(app.read(ledgerTotalsProvider)[vendor.id], 0);
        expect(await notifier.addPayment(purchase: purchase, amount: 1, date: DateTime.now(), note: ''), isFalse);
      });
    });

    group('sales', () {
      OrderItem line(VariantModel variant, int quantity, {double discount = 0}) => OrderItem(
            productId: product.id,
            variantId: variant.id,
            productName: 'Cricket Bat',
            variantLabel: variant.label,
            sku: variant.sku,
            quantity: quantity,
            unitPrice: variant.salePrice,
            discount: discount,
          );

      test('confirming an order takes the stock out and charges the customer', () async {
        final bool ok = await app.read(ordersProvider.notifier).confirmOrder(
          customer: customer,
          saleType: OrderSaleType.wholesale,
          orderDate: DateTime.now(),
          notes: 'first',
          items: <OrderItem>[line(small, 3, discount: 20)],
          orderDiscount: 10,
          paidNow: 100,
        );
        expect(ok, isTrue);
        await until(() => (app.read(ordersProvider).valueOrNull ?? <OrderModel>[]).length == 1, 'the order');
        order = app.read(ordersProvider).requireValue.single;
        expect(order.totalAmount, 270); // 300 - 20 line discount - 10 order discount
        expect(order.status, OrderStatus.pending);
        expect(order.statusHistory.single.byName, isNotEmpty);
        await until(() => onHand(small) == 7, 'the stock to drop');
        expect(customerBalance(), 170);
        expect(app.read(orderPaidProvider)[order.id], 100);
      });

      test('selling more than is in stock is refused and nothing changes', () async {
        final bool ok = await app.read(ordersProvider.notifier).confirmOrder(
          customer: customer,
          saleType: OrderSaleType.retail,
          orderDate: DateTime.now(),
          notes: '',
          items: <OrderItem>[line(small, 99)],
          orderDiscount: 0,
          paidNow: 0,
        );
        expect(ok, isFalse);
        expect(lastError<ValidationException>(app.read(ordersProvider)).message, contains('Not enough stock'));
        expect(onHand(small), 7);
      });

      test('the order moves through the pipeline and then stays put', () async {
        final OrdersNotifier notifier = app.read(ordersProvider.notifier);
        for (final OrderStatus expected in <OrderStatus>[OrderStatus.processing, OrderStatus.shipped, OrderStatus.delivered]) {
          final OrderModel current = app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == order.id);
          expect(await notifier.advanceStatus(current), isTrue);
          await until(
            () => app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == order.id).status == expected,
            'the order to become ${expected.label}',
          );
        }
        final OrderModel delivered = app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == order.id);
        expect(delivered.statusHistory.map((OrderStatusEntry e) => e.status), <OrderStatus>[
          OrderStatus.pending, OrderStatus.processing, OrderStatus.shipped, OrderStatus.delivered,
        ]);
        expect(await notifier.advanceStatus(delivered), isFalse);
      });

      test('a payment on the delivered order', () async {
        expect(
          await app.read(ordersProvider.notifier).addPayment(order: order, amount: 170, date: DateTime.now(), note: ''),
          isTrue,
        );
        await until(() => app.read(orderPaidProvider)[order.id] == 270, 'the payment');
        expect(customerBalance(), 0);
      });

      test('cancelling an order returns the stock and reverses the charge', () async {
        expect(
          await app.read(ordersProvider.notifier).confirmOrder(
            customer: customer,
            saleType: OrderSaleType.retail,
            orderDate: DateTime.now(),
            notes: '',
            items: <OrderItem>[line(large, 2)],
            orderDiscount: 0,
            paidNow: 0,
          ),
          isTrue,
        );
        await until(() => onHand(large) == 3, 'the stock to drop');
        final OrderModel second = app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id != order.id);
        expect(customerBalance(), 301);

        expect(await app.read(ordersProvider.notifier).cancelOrder(second), isTrue);
        await until(() => onHand(large) == 5, 'the stock to come back');
        await until(
          () => app.read(ordersProvider).requireValue.firstWhere((OrderModel o) => o.id == second.id).status == OrderStatus.cancelled,
          'the order to be cancelled',
        );
        expect(customerBalance(), 0);
      });

      test('the credit limit is enforced by the server', () async {
        // 1000 limit, balance 0: a 1100 order must be refused.
        final bool ok = await app.read(ordersProvider.notifier).confirmOrder(
          customer: customer,
          saleType: OrderSaleType.retail,
          orderDate: DateTime.now(),
          notes: '',
          items: <OrderItem>[line(small, 7, discount: 0), line(large, 3)],
          orderDiscount: 0,
          paidNow: 0,
        );
        expect(ok, isFalse);
        expect(lastError<ValidationException>(app.read(ordersProvider)).message, contains('credit limit'));
        expect(onHand(small), 7);
      });
    });

    group('stock count', () {
      test('a count adjusts the stock to what was counted', () async {
        final bool ok = await app.read(stockAuditsProvider.notifier).confirmAudit(
          counts: <CountedVariant>[CountedVariant(variantId: small.id, countedQuantity: 5)],
          note: 'shelf check',
          auditDate: DateTime.now(),
        );
        expect(ok, isTrue);
        await until(() => onHand(small) == 5, 'the adjustment');
        final List<LedgerModel> ledger = app.read(ledgerEntriesProvider).valueOrNull ?? <LedgerModel>[];
        expect(ledger, isNotEmpty);
      });

      test('a count that matches the system is refused', () async {
        final bool ok = await app.read(stockAuditsProvider.notifier).confirmAudit(
          counts: <CountedVariant>[CountedVariant(variantId: small.id, countedQuantity: 5)],
          note: '',
          auditDate: DateTime.now(),
        );
        expect(ok, isFalse);
      });
    });

    group('dashboard', () {
      test('the figures the app shows match the server\'s own dashboard', () async {
        final ApiResponse server = await app.read(apiClientProvider).get('/v1/dashboard');
        final JsonMap s = server.asMap;
        final DashboardStats local = app.read(dashboardStatsProvider);

        expect(local.stockUnits, s['stockUnits']);
        expect(local.stockCostValue, s['stockCostValue']);
        expect(local.stockRetailValue, s['stockRetailValue']);
        expect(local.lowStockCount, s['lowStockCount']);
        expect(local.pendingOrders, s['pendingOrders']);
        expect(local.processingOrders, s['processingOrders']);
        expect(local.shippedOrders, s['shippedOrders']);
        expect(local.salesMonth, s['salesMonth']);
        expect(local.ordersMonth, s['ordersMonth']);
        // BAT-S: 5 left (alert at 5), BAT-L: 5 left.
        expect(local.stockUnits, 10);
        expect(local.stockCostValue, 5 * 40 + 5 * 60);
        expect(local.lowStockCount, 1);
        expect(local.salesMonth, 270);
      });
    });

    group('users', () {
      test('an admin adds a login, changes its role and turns it off', () async {
        final UsersNotifier notifier = app.read(usersProvider.notifier);
        expect(
          await notifier.createUser(
            email: 'flow-staff@mq.test',
            password: 'StaffPass123',
            displayName: 'Flow Staff',
            phoneNumber: '0300',
            role: UserRole.manager,
          ),
          isTrue,
        );
        await until(
          () => (app.read(usersProvider).valueOrNull ?? <UserModel>[]).any((UserModel u) => u.email == 'flow-staff@mq.test'),
          'the new user',
        );
        final UserModel created = app.read(usersProvider).requireValue.firstWhere((UserModel u) => u.email == 'flow-staff@mq.test');
        expect(created.role, UserRole.manager);
        expect(created.phoneNumber, '0300');

        expect(await notifier.updateUser(created.copyWith(role: UserRole.staff)), isTrue);
        await until(
          () => app.read(usersProvider).requireValue.firstWhere((UserModel u) => u.id == created.id).role == UserRole.staff,
          'the role change',
        );
        // The admin cannot change their own role.
        final UserModel self = app.read(usersProvider).requireValue.firstWhere((UserModel u) => u.email == adminEmail);
        expect(await notifier.updateUser(self.copyWith(role: UserRole.staff)), isFalse);
      });

      test('a staff member signs in and sees only what staff may see', () async {
        final ProviderContainer staff = _app(MemoryTokenStore());
        addTearDown(staff.dispose);
        await signIn(staff, 'flow-staff@mq.test', 'StaffPass123');
        expect(staff.read(currentUserProvider).valueOrNull?.role, UserRole.staff);

        // Staff may sell: the catalog and customers load, vendors and purchases do not.
        expect((await staff.read(productsProvider.future)).length, 1);
        expect((await staff.read(customersProvider.future)).length, 1);
        expect(await staff.read(vendorsProvider.future), isEmpty);
        expect(await staff.read(purchasesProvider.future), isEmpty);

        final bool sold = await staff.read(ordersProvider.notifier).confirmOrder(
          customer: customer,
          saleType: OrderSaleType.retail,
          orderDate: DateTime.now(),
          notes: 'sold by staff',
          items: <OrderItem>[OrderItem(
            productId: product.id, variantId: small.id, productName: 'Cricket Bat',
            variantLabel: 'Small', sku: 'BAT-S', quantity: 1, unitPrice: 100)],
          orderDiscount: 0,
          paidNow: 100,
        );
        expect(sold, isTrue);

        // The SERVER refuses staff the admin actions, whatever the app lets through.
        await expectLater(
          staff.read(apiClientProvider).post('/v1/categories', body: <String, dynamic>{'name': 'Sneaky'}),
          throwsA(isA<PermissionDeniedException>()),
        );
        await expectLater(
          staff.read(apiClientProvider).get('/v1/dashboard'),
          throwsA(isA<PermissionDeniedException>()),
        );
        await expectLater(
          staff.read(apiClientProvider).get('/v1/logs'),
          throwsA(isA<PermissionDeniedException>()),
        );
      });

      test('a turned-off login can no longer sign in', () async {
        final UserModel staffUser = app.read(usersProvider).requireValue.firstWhere((UserModel u) => u.email == 'flow-staff@mq.test');
        expect(await app.read(usersProvider.notifier).setActive(staffUser.id, isActive: false), isTrue);
        final ProviderContainer blocked = _app(MemoryTokenStore());
        addTearDown(blocked.dispose);
        await blocked.read(authControllerProvider.notifier).signIn(email: 'flow-staff@mq.test', password: 'StaffPass123');
        expect(lastError<PermissionDeniedException>(blocked.read(authControllerProvider)).message, contains('disabled'));
      });
    });

    group('activity log', () {
      test('the server wrote a log for what was done, with the real user', () async {
        final ProviderContainer logs = app;
        logs.listen<AsyncValue<ActivityLogsState>>(
            activityLogsProvider, (AsyncValue<ActivityLogsState>? a, AsyncValue<ActivityLogsState> b) {});
        final ActivityLogsState state = await logs.read(activityLogsProvider.future);
        final List<String> actions = state.logs.map((ActivityLogModel l) => l.action).toList();
        expect(actions, containsAll(<String>['order_confirmed', 'order_cancelled', 'purchase_confirmed', 'stock_audit_applied', 'login']));
        final ActivityLogModel confirmed = state.logs.firstWhere((ActivityLogModel l) => l.action == 'order_confirmed' && l.userRole == 'admin');
        expect(confirmed.userName, isNotEmpty);
        expect(confirmed.groupId, isNotEmpty);
      });
    });

    group('sessions', () {
      test('a page reload signs in again without a password', () async {
        final ProviderContainer reloaded = _app(sharedTokens);
        addTearDown(reloaded.dispose);
        await until(() => reloaded.read(authUidProvider).valueOrNull != null, 'the restored session');
        final UserModel? user = await reloaded.read(currentUserProvider.future);
        expect(user?.email, adminEmail);
        // The data loads again for the new page.
        expect((await reloaded.read(productsProvider.future)).length, 1);
      });

      test('signing out ends the session and forgets the data', () async {
        await app.read(authControllerProvider.notifier).signOut();
        await until(() => app.read(authUidProvider).valueOrNull == null, 'the sign-out');
        expect(app.read(remoteStoreProvider).list('products'), isEmpty);
        expect(app.read(apiClientProvider).isSignedIn, isFalse);

        // Its saved session is gone too: another page load finds nobody signed in.
        final ProviderContainer later = _app(sharedTokens);
        addTearDown(later.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 400));
        expect(later.read(authUidProvider).valueOrNull, isNull);
      });
    });
  });
}
