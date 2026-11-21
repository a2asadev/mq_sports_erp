import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/collections.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/ledger_model.dart';
import 'package:a2_stocks/models/order_model.dart';
import 'package:a2_stocks/models/party_enums.dart';
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/purchase_model.dart';
import 'package:a2_stocks/models/stock_audit_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';

void main() {
  late AppDatabase db;
  late LocalCollections local;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = LocalCollections(db);
  });

  tearDown(() async {
    await db.close();
  });

  // Times with milliseconds, in local time (as the sync store produces them).
  final DateTime t1 = DateTime(2026, 11, 14, 9, 30, 15, 123);
  final DateTime t2 = DateTime(2026, 11, 14, 22, 5, 1, 7);

  test('photos are stored: addresses of users, categories, customers and vendors, and a product\'s image list', () async {
    await local.users.upsertAll(<UserModel>[
      UserModel(id: 'u1', email: 'a@b.c', photoUrl: 'http://m/u1.webp', createdAt: t1, updatedAt: t2),
    ]);
    await local.categories.upsertAll(<CategoryModel>[
      CategoryModel(id: 'c1', name: 'Bats', photoUrl: 'http://m/c1.webp', createdAt: t1, updatedAt: t2),
    ]);
    await local.customers.upsertAll(<CustomerModel>[
      CustomerModel(id: 'cu1', name: 'Ali', photoUrl: 'http://m/cu1.webp', createdAt: t1, updatedAt: t2),
    ]);
    await local.vendors.upsertAll(<VendorModel>[
      VendorModel(id: 'v1', name: 'Supplier', photoUrl: 'http://m/v1.webp', createdAt: t1, updatedAt: t2),
    ]);
    final ProductModel product = ProductModel(
      id: 'p1', name: 'Bat', categoryId: 'c1', createdAt: t1, updatedAt: t2,
      images: const <ProductImage>[
        ProductImage(id: 'i1', width: 600, height: 400, thumbUrl: 't1', mediumUrl: 'm1', largeUrl: 'l1'),
        ProductImage(id: 'i2', position: 1, variantId: 'var', mediumUrl: 'm2'),
      ],
    );
    await local.products.upsertAll(<ProductModel>[product]);

    expect((await local.users.byId('u1'))?.photoUrl, 'http://m/u1.webp');
    expect((await local.categories.byId('c1'))?.photoUrl, 'http://m/c1.webp');
    expect((await local.customers.byId('cu1'))?.photoUrl, 'http://m/cu1.webp');
    expect((await local.vendors.byId('v1'))?.photoUrl, 'http://m/v1.webp');
    final ProductModel? back = await local.products.byId('p1');
    expect(back?.toMap(), product.toMap());
    expect(back?.images.map((ProductImage i) => i.id), <String>['i1', 'i2']);

    // Removing the photos clears them.
    await local.products.upsertAll(<ProductModel>[product.copyWith(images: const <ProductImage>[], updatedAt: t2)]);
    expect((await local.products.byId('p1'))?.images, isEmpty);
  });

  test('users keep every field, including the role and the active flag', () async {
    final UserModel user = UserModel(
      id: 'u1', email: 'a@b.c', displayName: 'Ann', phoneNumber: '0300',
      role: UserRole.manager, isActive: false, createdAt: t1, updatedAt: t2,
    );
    await local.users.upsertAll(<UserModel>[user]);
    final UserModel? back = await local.users.byId('u1');
    expect(back?.toMap(), user.toMap());
    expect(back?.role, UserRole.manager);
    expect(back?.isActive, isFalse);
  });

  test('categories: a tree, replaced by id, removed by id', () async {
    await local.categories.upsertAll(<CategoryModel>[
      CategoryModel(id: 'c1', name: 'Cricket', createdAt: t1, updatedAt: t1),
      CategoryModel(id: 'c2', name: 'Bats', parentId: 'c1', description: 'Willow', createdAt: t1, updatedAt: t1),
    ]);
    expect((await local.categories.all()).length, 2);
    expect((await local.categories.byId('c2'))?.parentId, 'c1');
    expect((await local.categories.byId('c1'))?.parentId, '');

    await local.categories.upsertAll(<CategoryModel>[
      CategoryModel(id: 'c2', name: 'Bats (renamed)', parentId: 'c1', createdAt: t1, updatedAt: t2),
    ]);
    expect((await local.categories.all()).length, 2);
    expect((await local.categories.byId('c2'))?.name, 'Bats (renamed)');
    expect((await local.categories.byId('c2'))?.updatedAt, t2);

    await local.categories.deleteIds(<String>['c2', 'does-not-exist']);
    expect((await local.categories.all()).map((CategoryModel c) => c.id), <String>['c1']);
    expect(await local.categories.byId('c2'), isNull);
  });

  test('products keep their variants in order, with attributes in their original order', () async {
    final ProductModel product = ProductModel(
      id: 'p1', name: 'Bat', categoryId: 'c1', brand: 'MQ', description: 'd', createdAt: t1, updatedAt: t2,
      variants: <VariantModel>[
        VariantModel(id: 'v2', sku: 'B-L', attributes: <String, String>{'Size': 'L', 'Grip': 'Rubber'}, costPrice: 60, salePrice: 150.5, isWholesale: true, wholesalePrice: 140, alertThreshold: 3),
        VariantModel(id: 'v1', sku: 'B-S', name: 'Small', isActive: false),
      ],
    );
    await local.products.upsertAll(<ProductModel>[product]);

    final ProductModel? back = await local.products.byId('p1');
    expect(back?.toMap(), product.toMap());
    expect(back?.variants.map((VariantModel v) => v.id), <String>['v2', 'v1']); // not sorted by id
    expect(back?.variants.first.attributes.keys.toList(), <String>['Size', 'Grip']);
    expect(back?.variants.first.label, 'L / Rubber');
    expect(back?.variants.last.isActive, isFalse);
  });

  test('saving a product again replaces its variants instead of adding to them', () async {
    ProductModel product(List<VariantModel> variants) => ProductModel(
        id: 'p1', name: 'Bat', categoryId: 'c1', createdAt: t1, updatedAt: t1, variants: variants);
    await local.products.upsertAll(<ProductModel>[
      product(<VariantModel>[VariantModel(id: 'v1', sku: 'A'), VariantModel(id: 'v2', sku: 'B')]),
    ]);
    await local.products.upsertAll(<ProductModel>[
      product(<VariantModel>[VariantModel(id: 'v2', sku: 'B2'), VariantModel(id: 'v3', sku: 'C')]),
    ]);
    final ProductModel? back = await local.products.byId('p1');
    expect(back?.variants.map((VariantModel v) => v.sku), <String>['B2', 'C']);
    expect((await local.products.all()).single.variants.length, 2);

    await local.products.deleteIds(<String>['p1']);
    expect(await local.products.all(), isEmpty);
    // The variants went with it.
    expect(await db.select(db.productVariants).get(), isEmpty);
  });

  test('vendors and customers', () async {
    final VendorModel vendor = VendorModel(
      id: 'v', name: 'Sialkot', type: VendorType.manufacturer, phone: '1', email: 'x@y.z',
      openingBalance: -25.5, isActive: false, createdAt: t1, updatedAt: t2,
    );
    final CustomerModel customer = CustomerModel(
      id: 'c', name: 'Ali', type: CustomerType.wholesale, creditLimit: 1000, openingBalance: 12.25,
      city: 'Lahore', birthday: '02-29', createdAt: t1, updatedAt: t2,
    );
    await local.vendors.upsertAll(<VendorModel>[vendor]);
    await local.customers.upsertAll(<CustomerModel>[customer]);
    expect((await local.vendors.byId('v'))?.toMap(), vendor.toMap());
    expect((await local.customers.byId('c'))?.toMap(), customer.toMap());
  });

  test('ledger entries keep their links to a purchase or an order', () async {
    final LedgerModel entry = LedgerModel(
      id: 'l1', partyType: PartyType.customer, partyId: 'c', entryType: LedgerEntryType.payment,
      amount: 270.75, entryDate: t1, description: 'Payment', reference: 'ORD-1', orderId: 'o1',
      createdAt: t1, updatedAt: t2,
    );
    await local.ledgers.upsertAll(<LedgerModel>[entry]);
    final LedgerModel? back = await local.ledgers.byId('l1');
    expect(back?.toMap(), entry.toMap());
    expect(back?.orderId, 'o1');
    expect(back?.purchaseId, '');
    expect(back?.signedAmount, -270.75);
  });

  test('purchases keep their items in order', () async {
    final PurchaseModel purchase = PurchaseModel(
      id: 'pu1', purchaseNo: 'PUR-1', vendorId: 'v', vendorName: 'Sialkot', invoiceNo: 'INV', purchaseDate: t1,
      notes: 'n', createdAt: t1, updatedAt: t2,
      items: <PurchaseItem>[
        PurchaseItem(id: 'i2', productId: 'p', variantId: 'v2', productName: 'Bat', variantLabel: 'L', sku: 'B-L', quantity: 5, unitCost: 60),
        PurchaseItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: 10, unitCost: 50.25),
      ],
    );
    await local.purchases.upsertAll(<PurchaseModel>[purchase]);
    final PurchaseModel? back = await local.purchases.byId('pu1');
    expect(back?.toMap(), purchase.toMap());
    expect(back?.items.map((PurchaseItem i) => i.id), <String>['i2', 'i1']);
    expect(back?.totalAmount, 5 * 60 + 10 * 50.25);
    await local.purchases.deleteIds(<String>['pu1']);
    expect(await db.select(db.purchaseItems).get(), isEmpty);
  });

  test('stock movements, and the on-hand total per variant is summed by the database', () async {
    StockLedgerModel move(String id, String variant, int qty, StockMovementType type) => StockLedgerModel(
        id: id, productId: 'p', variantId: variant, sku: 'S', quantity: qty, movementType: type,
        sourceId: 'src', unitCost: 1.5, movementDate: t1, note: 'n', createdAt: t1, updatedAt: t1);
    await local.stockLedgers.upsertAll(<StockLedgerModel>[
      move('m1', 'v1', 10, StockMovementType.purchase),
      move('m2', 'v1', -3, StockMovementType.sale),
      move('m3', 'v2', 4, StockMovementType.adjustment),
      move('m4', 'v1', -9, StockMovementType.sale),
    ]);
    expect(await local.stockLedgers.onHandByVariant(), <String, int>{'v1': -2, 'v2': 4});
    expect((await local.stockLedgers.byId('m3'))?.movementType, StockMovementType.adjustment);
  });

  test('stock audits keep their items', () async {
    final StockAuditModel audit = StockAuditModel(
      id: 'a1', auditNo: 'AUD-1', auditDate: t1, note: 'shelf', countedById: 'u', countedByName: 'Ann',
      createdAt: t1, updatedAt: t2,
      items: <StockAuditItem>[
        const StockAuditItem(productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', systemQuantity: 7, countedQuantity: 5),
        const StockAuditItem(productId: 'p', variantId: 'v2', productName: 'Bat', variantLabel: 'L', sku: 'B-L', systemQuantity: 1, countedQuantity: 4),
      ],
    );
    await local.stockAudits.upsertAll(<StockAuditModel>[audit]);
    final StockAuditModel? back = await local.stockAudits.byId('a1');
    expect(back?.toMap(), audit.toMap());
    expect(back?.totalVariance, 1);
  });

  test('orders keep their items and their status history in order', () async {
    final OrderModel order = OrderModel(
      id: 'o1', orderNo: 'ORD-1', customerId: 'c', customerName: 'Ali', orderDate: t1,
      status: OrderStatus.shipped, saleType: OrderSaleType.wholesale, discount: 10, notes: 'rush',
      shippingFee: 250, shippingAddress: 'Ali, 0300 - House 5, Lahore', channel: 'web',
      createdAt: t1, updatedAt: t2,
      items: <OrderItem>[
        OrderItem(id: 'i1', productId: 'p', variantId: 'v1', productName: 'Bat', variantLabel: 'S', sku: 'B-S', quantity: 3, unitPrice: 100, discount: 20),
        OrderItem(id: 'i0', productId: 'p', variantId: 'v2', productName: 'Bat', variantLabel: 'L', sku: 'B-L', quantity: 1, unitPrice: 150.5),
      ],
      statusHistory: <OrderStatusEntry>[
        OrderStatusEntry(status: OrderStatus.pending, changedAt: t1, byUserId: 'u', byName: 'Ann'),
        OrderStatusEntry(status: OrderStatus.processing, changedAt: t2, byUserId: 'u', byName: 'Ann'),
        OrderStatusEntry(status: OrderStatus.shipped, changedAt: t2.add(const Duration(minutes: 1)), byUserId: 'u2', byName: 'Bo'),
      ],
    );
    await local.orders.upsertAll(<OrderModel>[order]);
    final OrderModel? back = await local.orders.byId('o1');
    expect(back?.toMap(), order.toMap());
    expect(back?.items.map((OrderItem i) => i.id), <String>['i1', 'i0']);
    expect(back?.statusHistory.map((OrderStatusEntry e) => e.status),
        <OrderStatus>[OrderStatus.pending, OrderStatus.processing, OrderStatus.shipped]);
    expect(back?.totalAmount, order.totalAmount);
    expect(back?.shippingFee, 250);
    expect(back?.channel, 'web');

    // A change of status replaces the history rather than adding to it.
    await local.orders.upsertAll(<OrderModel>[
      order.copyWith(status: OrderStatus.delivered, statusHistory: <OrderStatusEntry>[
        ...order.statusHistory,
        OrderStatusEntry(status: OrderStatus.delivered, changedAt: t2.add(const Duration(hours: 1))),
      ]),
    ]);
    expect((await local.orders.byId('o1'))?.statusHistory.length, 4);
    expect((await local.orders.all()).length, 1);

    await local.orders.deleteIds(<String>['o1']);
    expect(await db.select(db.orderItems).get(), isEmpty);
    expect(await db.select(db.orderStatusEntries).get(), isEmpty);
  });

  test('times keep their milliseconds', () async {
    await local.categories.upsertAll(<CategoryModel>[
      CategoryModel(id: 'c', name: 'x', createdAt: t1, updatedAt: t2),
    ]);
    final CategoryModel? back = await local.categories.byId('c');
    expect(back?.createdAt, t1);
    expect(back?.updatedAt, t2);
    expect(back?.createdAt.millisecond, 123);
  });

  test('every collection can be found by the name the API uses', () {
    expect(local.every.map((c) => c.name).toSet(), <String>{
      'users', 'categories', 'products', 'vendors', 'customers', 'ledgers', 'purchases',
      'stock_ledgers', 'stock_audits', 'orders',
    });
    expect(local.named('orders'), isNotNull);
    expect(local.named('nonsense'), isNull);
  });
}
