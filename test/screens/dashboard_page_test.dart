import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';
import 'package:a2_stocks/providers/catalog_providers.dart';
import 'package:a2_stocks/providers/dashboard_providers.dart';
import 'package:a2_stocks/providers/module_registry_provider.dart';
import 'package:a2_stocks/providers/parties_providers.dart';
import 'package:a2_stocks/providers/sales_providers.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';
import 'package:a2_stocks/screens/dashboard/dashboard_page.dart';

class _Orders extends OrdersNotifier {
  _Orders(this.items);
  final List<OrderModel> items;
  @override
  Future<List<OrderModel>> build() async => items;
}

class _Products extends ProductsNotifier {
  _Products(this.items);
  final List<ProductModel> items;
  @override
  Future<List<ProductModel>> build() async => items;
}

class _Categories extends CategoriesNotifier {
  _Categories(this.items);
  final List<CategoryModel> items;
  @override
  Future<List<CategoryModel>> build() async => items;
}

class _Customers extends CustomersNotifier {
  _Customers(this.items);
  final List<CustomerModel> items;
  @override
  Future<List<CustomerModel>> build() async => items;
}

class _Vendors extends VendorsNotifier {
  _Vendors(this.items);
  final List<VendorModel> items;
  @override
  Future<List<VendorModel>> build() async => items;
}

class _Me extends CurrentUserNotifier {
  _Me(this.user);
  final UserModel user;
  @override
  Future<UserModel?> build() async => user;
}

void main() {
  final DateTime now = DateTime.now();
  final ProductModel bat = ProductModel(
    id: 'p1',
    name: 'Cricket Bat',
    categoryId: 'c1',
    variants: <VariantModel>[VariantModel(id: 'v1', sku: 'BAT-S', name: 'Small', salePrice: 1000, costPrice: 600, alertThreshold: 5)],
  );
  final List<OrderModel> orders = <OrderModel>[
    OrderModel(
      orderNo: 'ORD-1',
      customerId: 'cu1',
      customerName: 'Ali Khan',
      orderDate: now,
      items: <OrderItem>[
        OrderItem(productId: 'p1', variantId: 'v1', productName: 'Cricket Bat', variantLabel: 'Small', sku: 'BAT-S', quantity: 2, unitPrice: 1000),
      ],
    ),
  ];

  Future<void> pump(WidgetTester tester, Size size, {UserRole role = UserRole.admin}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final UserModel me = UserModel(id: 'u1', email: 'a@b.pk', displayName: 'Asad Khan', role: role);
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      currentUserProvider.overrideWith(() => _Me(me)),
      ordersProvider.overrideWith(() => _Orders(orders)),
      productsProvider.overrideWith(() => _Products(<ProductModel>[bat])),
      categoriesProvider.overrideWith(() => _Categories(<CategoryModel>[CategoryModel(id: 'c1', name: 'Cricket')])),
      customersProvider.overrideWith(() => _Customers(<CustomerModel>[CustomerModel(id: 'cu1', name: 'Ali Khan')])),
      vendorsProvider.overrideWith(() => _Vendors(<VendorModel>[])),
      stockOnHandProvider.overrideWithValue(<String, int>{'v1': 3}),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(body: DashboardPage(onOpenModule: (_) {})),
      ),
    ));
    await tester.pumpAndSettle();
  }

  for (final Size size in const <Size>[Size(1400, 1000), Size(900, 1000), Size(390, 900)]) {
    testWidgets('the admin dashboard lays out at ${size.width.toInt()} px without overflow', (WidgetTester tester) async {
      await pump(tester, size);
      expect(find.text('Welcome, Asad'), findsOneWidget);
      expect(find.text('Sales today'), findsOneWidget);
      expect(find.text('Top customers'), findsOneWidget);
      expect(find.text('Rs 2,000'), findsWidgets);
      expect(find.textContaining('Running low'), findsOneWidget);
      final Object? problem = tester.takeException();
      expect(problem, isNull, reason: '$problem');
    });
  }

  testWidgets('staff get shortcuts instead of figures', (WidgetTester tester) async {
    await pump(tester, const Size(1000, 900), role: UserRole.staff);
    expect(find.text('Welcome, Asad'), findsOneWidget);
    expect(find.text('Sales today'), findsNothing);
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(canViewDashboardProvider, isNotNull);
    expect(erpModulesProvider, isNotNull);
  });
}
