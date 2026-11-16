import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mq_sports_erp/core/constants/walk_in.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/customer_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/catalog_providers.dart';
import 'package:mq_sports_erp/providers/parties_providers.dart';
import 'package:mq_sports_erp/providers/pos_holds.dart';
import 'package:mq_sports_erp/providers/pos_providers.dart';
import 'package:mq_sports_erp/providers/sales_providers.dart';
import 'package:mq_sports_erp/providers/stock_providers.dart';
import 'package:mq_sports_erp/providers/sync_controller.dart';
import 'package:mq_sports_erp/screens/pos/pos_screen.dart';

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

void main() {
  final ProductModel bat = ProductModel(
    id: 'p1',
    name: 'Cricket Bat',
    categoryId: 'c1',
    variants: <VariantModel>[
      VariantModel(id: 'v1', sku: 'BAT-S', name: 'Small', salePrice: 1000, barcode: '8901'),
      VariantModel(id: 'v2', sku: 'BAT-L', name: 'Large', salePrice: 1500),
    ],
  );
  final ProductModel ball = ProductModel(
    id: 'p2',
    name: 'Leather Ball',
    categoryId: 'c2',
    variants: <VariantModel>[VariantModel(id: 'v3', sku: 'BALL-1', name: 'Red', salePrice: 950)],
  );
  final ProductModel shoes = ProductModel(
    id: 'p3',
    name: 'Running Shoes',
    categoryId: 'c2',
    variants: <VariantModel>[VariantModel(id: 'v4', sku: 'SHOE-1', name: '42', salePrice: 6500)],
  );

  Future<ProviderContainer> pump(WidgetTester tester, {Size size = const Size(1200, 900)}) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ProviderContainer container = ProviderContainer(overrides: <Override>[
      productsProvider.overrideWith(() => _Products(<ProductModel>[bat, ball, shoes])),
      categoriesProvider.overrideWith(() => _Categories(<CategoryModel>[
            CategoryModel(id: 'c1', name: 'Cricket'),
            CategoryModel(id: 'c2', name: 'Other'),
          ])),
      customersProvider.overrideWith(() => _Customers(<CustomerModel>[CustomerModel(id: mqSportsWalkInCustomerId, name: 'Walk-in customer')])),
      stockOnHandProvider.overrideWithValue(<String, int>{'v1': 2, 'v2': 5, 'v3': 10, 'v4': 0}),
      canCreateOrdersProvider.overrideWithValue(true),
      syncSummaryProvider.overrideWithValue(const SyncSummary(status: SyncStatus.upToDate, waiting: 0, failed: 0)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PosScreen()),
    ));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows products with prices and stock; sold-out items cannot be added', (WidgetTester tester) async {
    await pump(tester);
    expect(find.text('Cricket Bat'), findsOneWidget);
    expect(find.text('Rs 1000+'), findsOneWidget);
    expect(find.text('Leather Ball'), findsOneWidget);
    expect(find.text('Out of stock'), findsOneWidget); // the shoes
    await tester.tap(find.text('Running Shoes'));
    await tester.pumpAndSettle();
    expect(find.text('No Products Selected'), findsOneWidget);
  });

  testWidgets('a single-variant product is added with one tap; the total and units follow', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester);
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    final PosCart cart = app.read(posCartProvider);
    expect(cart.quantityOf('v3'), 2);
    expect(cart.total, 1900);
    expect(find.text('Place Order · Rs 1900'), findsOneWidget);
    expect(find.text('Walk-in customer'), findsOneWidget);
  });

  testWidgets('a product with options asks which one, and never sells more than the shelf holds', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester);
    await tester.tap(find.text('Cricket Bat').first);
    await tester.pumpAndSettle();
    expect(find.text('2 in stock'), findsOneWidget);
    await tester.tap(find.text('Small'));
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).quantityOf('v1'), 1);

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('Cricket Bat').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();
    }
    expect(app.read(posCartProvider).quantityOf('v1'), 2); // only 2 on the shelf
    expect(find.text('Only 2 of "Cricket Bat · Small" in stock.'), findsOneWidget);
  });

  testWidgets('search narrows the grid; a barcode or SKU plus Enter adds the item', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester);
    await tester.enterText(find.byType(TextField).first, 'ball');
    await tester.pumpAndSettle();
    expect(find.text('Cricket Bat'), findsNothing);
    expect(find.text('Leather Ball'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '8901');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).quantityOf('v1'), 1);

    await tester.enterText(find.byType(TextField).first, 'ball-1');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).quantityOf('v3'), 1);

    await tester.enterText(find.byType(TextField).first, 'nothing-here');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.textContaining('No product with barcode or SKU'), findsOneWidget);
  });

  testWidgets('the category rail filters the grid', (WidgetTester tester) async {
    await pump(tester);
    await tester.tap(find.text('Cricket').first);
    await tester.pumpAndSettle();
    expect(find.text('Cricket Bat'), findsOneWidget);
    expect(find.text('Leather Ball'), findsNothing);
    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();
    expect(find.text('Leather Ball'), findsOneWidget);
  });

  testWidgets('quantity buttons, line discount and sale discount change the total', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester);
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).total, 1900);

    // Sale-level discount through its row.
    await tester.tap(find.byIcon(Icons.edit_outlined).last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '100');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).total, 1800);
    expect(find.text('Place Order · Rs 1800'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove).last);
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).quantityOf('v3'), 1);
  });

  testWidgets('on a phone the products and the sale are two tabs', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester, size: const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    expect(find.text('Sale · Rs 950'), findsOneWidget);
    await tester.tap(find.text('Sale · Rs 950'));
    await tester.pumpAndSettle();
    expect(find.text('Place Order · Rs 950'), findsOneWidget);
    expect(app.read(posCartProvider).units, 1);
  });

  testWidgets('the order panel fits a 1366x768 laptop screen without overflow', (WidgetTester tester) async {
    await pump(tester, size: const Size(1366, 768));
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    expect(find.text('Place Order · Rs 950'), findsOneWidget);
    expect(find.text('Hold'), findsWidgets);
    final Object? problem = tester.takeException();
    expect(problem, isNull, reason: '$problem');
  });

  testWidgets('Hold parks the sale; Resume brings it back and parks the one in progress', (WidgetTester tester) async {
    final ProviderContainer app = await pump(tester);
    await tester.tap(find.text('Leather Ball').first);
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).units, 1);

    // Hold it (the panel's button).
    await tester.tap(find.widgetWithText(OutlinedButton, 'Hold'));
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).isEmpty, isTrue);
    expect(app.read(heldSalesProvider).length, 1);
    expect(find.text('No Products Selected'), findsOneWidget);

    // Serve someone else, then open the held sales and resume the first one.
    await tester.tap(find.text('Cricket Bat').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Small'));
    await tester.pumpAndSettle();
    expect(app.read(posCartProvider).quantityOf('v1'), 1);

    await tester.tap(find.textContaining('Held (1)').first);
    await tester.pumpAndSettle();
    expect(find.text('Held sales'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(app.read(posCartProvider).quantityOf('v3'), 1); // the ball is back
    expect(app.read(posCartProvider).quantityOf('v1'), 0);
    final List<HeldSale> held = app.read(heldSalesProvider);
    expect(held.length, 1); // the bat sale is now the one on hold
    expect(held.single.cart.quantityOf('v1'), 1);
  });

  test('a held sale survives being written and read back', () {
    final HeldSale sale = HeldSale(
      cart: PosCart(
        lines: const <PosLine>[
          PosLine(productId: 'p', variantId: 'v', productName: 'Bat', variantLabel: 'S', sku: 'B', unitPrice: 1000, quantity: 2, discount: 50),
        ],
        orderDiscount: 100,
        customer: CustomerModel(id: 'c1', name: 'Ali'),
      ),
    );
    final HeldSale? back = HeldSale.fromMap(sale.toMap());
    expect(back, isNotNull);
    expect(back!.id, sale.id);
    expect(back.cart.lines.single.quantity, 2);
    expect(back.cart.lines.single.discount, 50);
    expect(back.cart.orderDiscount, 100);
    expect(back.cart.customer?.name, 'Ali');
    expect(back.cart.total, 1850);
    expect(HeldSale.fromMap('garbage'), isNull);
  });
}
