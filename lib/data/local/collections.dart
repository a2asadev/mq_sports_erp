import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/data/local/app_database.dart';
import 'package:a2_stocks/data/local/tables.dart';
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
import 'package:a2_stocks/models/syncable_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/user_role.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';

/// One collection of server-confirmed records in the local database, read and
/// written as the app's models. A record with lines (a product with variants,
/// an order with items) is written together with them in one transaction.
abstract class LocalCollection<T extends SyncableModel> {
  /// The name shared with the API's sync response and [StorageKeys].
  String get name;

  Future<List<T>> all();

  Future<T?> byId(String id);

  /// Adds or replaces records (and their lines).
  Future<void> upsertAll(List<T> items);

  /// Removes records (and their lines). Ids that are not there are ignored.
  Future<void> deleteIds(List<String> ids);

  /// A record from the server's JSON.
  T fromMap(Map<String, dynamic> map);

  /// Adds or replaces records given as the server's JSON.
  Future<void> upsertMaps(List<Map<String, dynamic>> maps) =>
      upsertAll(maps.map(fromMap).toList());

  /// Removes everything (used to download everything again).
  Future<void> clear() async =>
      deleteIds((await all()).map((T item) => item.id).toList());
}

/// The ten collections of the app, by name.
class LocalCollections {
  LocalCollections(AppDatabase db)
      : users = UsersCollection(db),
        categories = CategoriesCollection(db),
        products = ProductsCollection(db),
        vendors = VendorsCollection(db),
        customers = CustomersCollection(db),
        ledgers = LedgersCollection(db),
        purchases = PurchasesCollection(db),
        stockLedgers = StockMovementsCollection(db),
        stockAudits = StockAuditsCollection(db),
        orders = OrdersCollection(db);

  final UsersCollection users;
  final CategoriesCollection categories;
  final ProductsCollection products;
  final VendorsCollection vendors;
  final CustomersCollection customers;
  final LedgersCollection ledgers;
  final PurchasesCollection purchases;
  final StockMovementsCollection stockLedgers;
  final StockAuditsCollection stockAudits;
  final OrdersCollection orders;

  List<LocalCollection<SyncableModel>> get every => <LocalCollection<SyncableModel>>[
        users, categories, products, vendors, customers, ledgers, purchases,
        stockLedgers, stockAudits, orders,
      ];

  LocalCollection<SyncableModel>? named(String name) {
    for (final LocalCollection<SyncableModel> collection in every) {
      if (collection.name == name) {
        return collection;
      }
    }
    return null;
  }
}

/// Groups child rows by their parent id, keeping the order they were read in.
Map<String, List<R>> _group<R>(Iterable<R> rows, String Function(R row) parentOf) {
  final Map<String, List<R>> grouped = <String, List<R>>{};
  for (final R row in rows) {
    grouped.putIfAbsent(parentOf(row), () => <R>[]).add(row);
  }
  return grouped;
}

// ---- users -----------------------------------------------------------------

class UsersCollection extends LocalCollection<UserModel> {
  UsersCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.users;

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModel.fromMap(map);

  UserModel _model(UserRow r) => UserModel(
        id: r.id,
        email: r.email,
        displayName: r.displayName,
        phoneNumber: r.phoneNumber,
        role: UserRole.fromName(r.role),
        isActive: r.isActive,
        photoUrl: r.photoUrl,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<UserModel>> all() async =>
      (await _db.select(_db.users).get()).map(_model).toList();

  @override
  Future<UserModel?> byId(String id) async {
    final UserRow? row = await (_db.select(_db.users)..where((Users t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<UserModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.users, <UsersCompanion>[
          for (final UserModel u in items)
            UsersCompanion(
              id: Value<String>(u.id),
              email: Value<String>(u.email),
              displayName: Value<String>(u.displayName),
              phoneNumber: Value<String>(u.phoneNumber),
              role: Value<String>(u.role.name),
              isActive: Value<bool>(u.isActive),
              photoUrl: Value<String>(u.photoUrl),
              createdAt: Value<DateTime>(u.createdAt),
              updatedAt: Value<DateTime>(u.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.users)..where((Users t) => t.id.isIn(ids))).go();
}

// ---- categories ------------------------------------------------------------

class CategoriesCollection extends LocalCollection<CategoryModel> {
  CategoriesCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.categories;

  @override
  CategoryModel fromMap(Map<String, dynamic> map) => CategoryModel.fromMap(map);

  CategoryModel _model(CategoryRow r) => CategoryModel(
        id: r.id,
        name: r.name,
        parentId: r.parentId,
        description: r.description,
        isActive: r.isActive,
        photoUrl: r.photoUrl,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<CategoryModel>> all() async =>
      (await _db.select(_db.categories).get()).map(_model).toList();

  @override
  Future<CategoryModel?> byId(String id) async {
    final CategoryRow? row =
        await (_db.select(_db.categories)..where((Categories t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<CategoryModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.categories, <CategoriesCompanion>[
          for (final CategoryModel c in items)
            CategoriesCompanion(
              id: Value<String>(c.id),
              name: Value<String>(c.name),
              parentId: Value<String>(c.parentId),
              description: Value<String>(c.description),
              isActive: Value<bool>(c.isActive),
              photoUrl: Value<String>(c.photoUrl),
              createdAt: Value<DateTime>(c.createdAt),
              updatedAt: Value<DateTime>(c.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.categories)..where((Categories t) => t.id.isIn(ids))).go();
}

// ---- products (with variants) ----------------------------------------------

class ProductsCollection extends LocalCollection<ProductModel> {
  ProductsCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.products;

  @override
  ProductModel fromMap(Map<String, dynamic> map) => ProductModel.fromMap(map);

  VariantModel _variant(VariantRow r) {
    final Object? decoded = jsonDecode(r.attributesJson);
    final Map<String, String> attributes = <String, String>{
      if (decoded is Map<String, dynamic>)
        for (final MapEntry<String, dynamic> e in decoded.entries) e.key: '${e.value}',
    };
    return VariantModel(
      id: r.id,
      sku: r.sku,
      name: r.name,
      barcode: r.barcode,
      attributes: attributes,
      costPrice: r.costPrice,
      salePrice: r.salePrice,
      isWholesale: r.isWholesale,
      wholesalePrice: r.wholesalePrice,
      alertThreshold: r.alertThreshold,
      isActive: r.isActive,
    );
  }

  /// The saved photos; a damaged value never stops the product from loading.
  static List<ProductImage> _images(String json) {
    try {
      final Object? decoded = jsonDecode(json);
      if (decoded is List<Object?>) {
        return decoded.whereType<Map<String, dynamic>>().map(ProductImage.fromMap).toList();
      }
    } on FormatException {
      // fall through
    }
    return const <ProductImage>[];
  }

  ProductModel _model(ProductRow r, List<VariantRow> variants) => ProductModel(
        id: r.id,
        name: r.name,
        categoryId: r.categoryId,
        brand: r.brand,
        description: r.description,
        isActive: r.isActive,
        images: _images(r.imagesJson),
        variants: (List<VariantRow>.of(variants)
              ..sort((VariantRow a, VariantRow b) => a.position.compareTo(b.position)))
            .map(_variant)
            .toList(),
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<ProductModel>> all() async {
    final List<ProductRow> rows = await _db.select(_db.products).get();
    final Map<String, List<VariantRow>> variants =
        _group<VariantRow>(await _db.select(_db.productVariants).get(), (VariantRow v) => v.productId);
    return rows.map((ProductRow r) => _model(r, variants[r.id] ?? <VariantRow>[])).toList();
  }

  @override
  Future<ProductModel?> byId(String id) async {
    final ProductRow? row =
        await (_db.select(_db.products)..where((Products t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final List<VariantRow> variants =
        await (_db.select(_db.productVariants)..where((ProductVariants t) => t.productId.equals(id))).get();
    return _model(row, variants);
  }

  @override
  Future<void> upsertAll(List<ProductModel> items) => _db.transaction(() async {
        final List<String> ids = items.map((ProductModel p) => p.id).toList();
        await (_db.delete(_db.productVariants)..where((ProductVariants t) => t.productId.isIn(ids))).go();
        await _db.batch((Batch b) {
          b.insertAllOnConflictUpdate(_db.products, <ProductsCompanion>[
            for (final ProductModel p in items)
              ProductsCompanion(
                id: Value<String>(p.id),
                name: Value<String>(p.name),
                categoryId: Value<String>(p.categoryId),
                brand: Value<String>(p.brand),
                description: Value<String>(p.description),
                isActive: Value<bool>(p.isActive),
                imagesJson: Value<String>(jsonEncode(p.images.map((ProductImage i) => i.toMap()).toList())),
                createdAt: Value<DateTime>(p.createdAt),
                updatedAt: Value<DateTime>(p.updatedAt),
              ),
          ]);
          b.insertAllOnConflictUpdate(_db.productVariants, <ProductVariantsCompanion>[
            for (final ProductModel p in items)
              for (int i = 0; i < p.variants.length; i++)
                ProductVariantsCompanion(
                  id: Value<String>(p.variants[i].id),
                  productId: Value<String>(p.id),
                  sku: Value<String>(p.variants[i].sku),
                  name: Value<String>(p.variants[i].name),
                  barcode: Value<String>(p.variants[i].barcode),
                  attributesJson: Value<String>(jsonEncode(p.variants[i].attributes)),
                  costPrice: Value<double>(p.variants[i].costPrice),
                  salePrice: Value<double>(p.variants[i].salePrice),
                  isWholesale: Value<bool>(p.variants[i].isWholesale),
                  wholesalePrice: Value<double>(p.variants[i].wholesalePrice),
                  alertThreshold: Value<int>(p.variants[i].alertThreshold),
                  isActive: Value<bool>(p.variants[i].isActive),
                  position: Value<int>(i),
                ),
          ]);
        });
      });

  @override
  Future<void> deleteIds(List<String> ids) => _db.transaction(() async {
        await (_db.delete(_db.productVariants)..where((ProductVariants t) => t.productId.isIn(ids))).go();
        await (_db.delete(_db.products)..where((Products t) => t.id.isIn(ids))).go();
      });
}

// ---- vendors ---------------------------------------------------------------

class VendorsCollection extends LocalCollection<VendorModel> {
  VendorsCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.vendors;

  @override
  VendorModel fromMap(Map<String, dynamic> map) => VendorModel.fromMap(map);

  VendorModel _model(VendorRow r) => VendorModel(
        id: r.id,
        name: r.name,
        type: VendorType.fromName(r.type),
        contactPerson: r.contactPerson,
        phone: r.phone,
        email: r.email,
        address: r.address,
        city: r.city,
        notes: r.notes,
        openingBalance: r.openingBalance,
        isActive: r.isActive,
        photoUrl: r.photoUrl,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<VendorModel>> all() async =>
      (await _db.select(_db.vendors).get()).map(_model).toList();

  @override
  Future<VendorModel?> byId(String id) async {
    final VendorRow? row = await (_db.select(_db.vendors)..where((Vendors t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<VendorModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.vendors, <VendorsCompanion>[
          for (final VendorModel v in items)
            VendorsCompanion(
              id: Value<String>(v.id),
              name: Value<String>(v.name),
              type: Value<String>(v.type.name),
              contactPerson: Value<String>(v.contactPerson),
              phone: Value<String>(v.phone),
              email: Value<String>(v.email),
              address: Value<String>(v.address),
              city: Value<String>(v.city),
              notes: Value<String>(v.notes),
              openingBalance: Value<double>(v.openingBalance),
              isActive: Value<bool>(v.isActive),
              photoUrl: Value<String>(v.photoUrl),
              createdAt: Value<DateTime>(v.createdAt),
              updatedAt: Value<DateTime>(v.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.vendors)..where((Vendors t) => t.id.isIn(ids))).go();
}

// ---- customers -------------------------------------------------------------

class CustomersCollection extends LocalCollection<CustomerModel> {
  CustomersCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.customers;

  @override
  CustomerModel fromMap(Map<String, dynamic> map) => CustomerModel.fromMap(map);

  CustomerModel _model(CustomerRow r) => CustomerModel(
        id: r.id,
        name: r.name,
        type: CustomerType.fromName(r.type),
        contactPerson: r.contactPerson,
        phone: r.phone,
        email: r.email,
        address: r.address,
        city: r.city,
        notes: r.notes,
        birthday: r.birthday,
        creditLimit: r.creditLimit,
        openingBalance: r.openingBalance,
        isActive: r.isActive,
        photoUrl: r.photoUrl,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<CustomerModel>> all() async =>
      (await _db.select(_db.customers).get()).map(_model).toList();

  @override
  Future<CustomerModel?> byId(String id) async {
    final CustomerRow? row =
        await (_db.select(_db.customers)..where((Customers t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<CustomerModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.customers, <CustomersCompanion>[
          for (final CustomerModel c in items)
            CustomersCompanion(
              id: Value<String>(c.id),
              name: Value<String>(c.name),
              type: Value<String>(c.type.name),
              contactPerson: Value<String>(c.contactPerson),
              phone: Value<String>(c.phone),
              email: Value<String>(c.email),
              address: Value<String>(c.address),
              city: Value<String>(c.city),
              notes: Value<String>(c.notes),
              birthday: Value<String>(c.birthday),
              creditLimit: Value<double>(c.creditLimit),
              openingBalance: Value<double>(c.openingBalance),
              isActive: Value<bool>(c.isActive),
              photoUrl: Value<String>(c.photoUrl),
              createdAt: Value<DateTime>(c.createdAt),
              updatedAt: Value<DateTime>(c.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.customers)..where((Customers t) => t.id.isIn(ids))).go();
}

// ---- ledger entries --------------------------------------------------------

class LedgersCollection extends LocalCollection<LedgerModel> {
  LedgersCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.ledgers;

  @override
  LedgerModel fromMap(Map<String, dynamic> map) => LedgerModel.fromMap(map);

  LedgerModel _model(LedgerRow r) => LedgerModel(
        id: r.id,
        partyType: PartyType.fromName(r.partyType),
        partyId: r.partyId,
        entryType: LedgerEntryType.fromName(r.entryType),
        amount: r.amount,
        entryDate: r.entryDate,
        description: r.description,
        reference: r.reference,
        paymentMethod: r.paymentMethod,
        paymentRef: r.paymentRef,
        kind: r.kind,
        purchaseId: r.purchaseId,
        orderId: r.orderId,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<LedgerModel>> all() async =>
      (await _db.select(_db.ledgerEntries).get()).map(_model).toList();

  @override
  Future<LedgerModel?> byId(String id) async {
    final LedgerRow? row =
        await (_db.select(_db.ledgerEntries)..where((LedgerEntries t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<LedgerModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.ledgerEntries, <LedgerEntriesCompanion>[
          for (final LedgerModel e in items)
            LedgerEntriesCompanion(
              id: Value<String>(e.id),
              partyType: Value<String>(e.partyType.name),
              partyId: Value<String>(e.partyId),
              entryType: Value<String>(e.entryType.name),
              amount: Value<double>(e.amount),
              entryDate: Value<DateTime>(e.entryDate),
              description: Value<String>(e.description),
              reference: Value<String>(e.reference),
              paymentMethod: Value<String>(e.paymentMethod),
              paymentRef: Value<String>(e.paymentRef),
              kind: Value<String>(e.kind),
              purchaseId: Value<String>(e.purchaseId),
              orderId: Value<String>(e.orderId),
              createdAt: Value<DateTime>(e.createdAt),
              updatedAt: Value<DateTime>(e.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.ledgerEntries)..where((LedgerEntries t) => t.id.isIn(ids))).go();
}

// ---- purchases (with items) ------------------------------------------------

class PurchasesCollection extends LocalCollection<PurchaseModel> {
  PurchasesCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.purchases;

  @override
  PurchaseModel fromMap(Map<String, dynamic> map) => PurchaseModel.fromMap(map);

  PurchaseModel _model(PurchaseRow r, List<PurchaseItemRow> items) => PurchaseModel(
        id: r.id,
        purchaseNo: r.purchaseNo,
        vendorId: r.vendorId,
        vendorName: r.vendorName,
        invoiceNo: r.invoiceNo,
        purchaseDate: r.purchaseDate,
        items: (List<PurchaseItemRow>.of(items)
              ..sort((PurchaseItemRow a, PurchaseItemRow b) => a.position.compareTo(b.position)))
            .map((PurchaseItemRow i) => PurchaseItem(
                  id: i.id,
                  productId: i.productId,
                  variantId: i.variantId,
                  productName: i.productName,
                  variantLabel: i.variantLabel,
                  sku: i.sku,
                  quantity: i.quantity,
                  unitCost: i.unitCost,
                ))
            .toList(),
        notes: r.notes,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<PurchaseModel>> all() async {
    final List<PurchaseRow> rows = await _db.select(_db.purchases).get();
    final Map<String, List<PurchaseItemRow>> items =
        _group<PurchaseItemRow>(await _db.select(_db.purchaseItems).get(), (PurchaseItemRow i) => i.purchaseId);
    return rows.map((PurchaseRow r) => _model(r, items[r.id] ?? <PurchaseItemRow>[])).toList();
  }

  @override
  Future<PurchaseModel?> byId(String id) async {
    final PurchaseRow? row =
        await (_db.select(_db.purchases)..where((Purchases t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final List<PurchaseItemRow> items =
        await (_db.select(_db.purchaseItems)..where((PurchaseItems t) => t.purchaseId.equals(id))).get();
    return _model(row, items);
  }

  @override
  Future<void> upsertAll(List<PurchaseModel> items) => _db.transaction(() async {
        final List<String> ids = items.map((PurchaseModel p) => p.id).toList();
        await (_db.delete(_db.purchaseItems)..where((PurchaseItems t) => t.purchaseId.isIn(ids))).go();
        await _db.batch((Batch b) {
          b.insertAllOnConflictUpdate(_db.purchases, <PurchasesCompanion>[
            for (final PurchaseModel p in items)
              PurchasesCompanion(
                id: Value<String>(p.id),
                purchaseNo: Value<String>(p.purchaseNo),
                vendorId: Value<String>(p.vendorId),
                vendorName: Value<String>(p.vendorName),
                invoiceNo: Value<String>(p.invoiceNo),
                purchaseDate: Value<DateTime>(p.purchaseDate),
                notes: Value<String>(p.notes),
                totalAmount: Value<double>(p.totalAmount),
                createdAt: Value<DateTime>(p.createdAt),
                updatedAt: Value<DateTime>(p.updatedAt),
              ),
          ]);
          b.insertAllOnConflictUpdate(_db.purchaseItems, <PurchaseItemsCompanion>[
            for (final PurchaseModel p in items)
              for (int i = 0; i < p.items.length; i++)
                PurchaseItemsCompanion(
                  id: Value<String>(p.items[i].id),
                  purchaseId: Value<String>(p.id),
                  productId: Value<String>(p.items[i].productId),
                  variantId: Value<String>(p.items[i].variantId),
                  productName: Value<String>(p.items[i].productName),
                  variantLabel: Value<String>(p.items[i].variantLabel),
                  sku: Value<String>(p.items[i].sku),
                  quantity: Value<int>(p.items[i].quantity),
                  unitCost: Value<double>(p.items[i].unitCost),
                  position: Value<int>(i),
                ),
          ]);
        });
      });

  @override
  Future<void> deleteIds(List<String> ids) => _db.transaction(() async {
        await (_db.delete(_db.purchaseItems)..where((PurchaseItems t) => t.purchaseId.isIn(ids))).go();
        await (_db.delete(_db.purchases)..where((Purchases t) => t.id.isIn(ids))).go();
      });
}

// ---- stock movements -------------------------------------------------------

class StockMovementsCollection extends LocalCollection<StockLedgerModel> {
  StockMovementsCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.stockLedgers;

  @override
  StockLedgerModel fromMap(Map<String, dynamic> map) => StockLedgerModel.fromMap(map);

  StockLedgerModel _model(StockMovementRow r) => StockLedgerModel(
        id: r.id,
        productId: r.productId,
        variantId: r.variantId,
        sku: r.sku,
        quantity: r.quantity,
        movementType: StockMovementType.fromName(r.movementType),
        sourceId: r.sourceId,
        unitCost: r.unitCost,
        movementDate: r.movementDate,
        note: r.note,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<StockLedgerModel>> all() async =>
      (await _db.select(_db.stockMovements).get()).map(_model).toList();

  @override
  Future<StockLedgerModel?> byId(String id) async {
    final StockMovementRow? row =
        await (_db.select(_db.stockMovements)..where((StockMovements t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _model(row);
  }

  @override
  Future<void> upsertAll(List<StockLedgerModel> items) => _db.batch((Batch b) {
        b.insertAllOnConflictUpdate(_db.stockMovements, <StockMovementsCompanion>[
          for (final StockLedgerModel m in items)
            StockMovementsCompanion(
              id: Value<String>(m.id),
              productId: Value<String>(m.productId),
              variantId: Value<String>(m.variantId),
              sku: Value<String>(m.sku),
              quantity: Value<int>(m.quantity),
              movementType: Value<String>(m.movementType.name),
              sourceId: Value<String>(m.sourceId),
              unitCost: Value<double>(m.unitCost),
              movementDate: Value<DateTime>(m.movementDate),
              note: Value<String>(m.note),
              createdAt: Value<DateTime>(m.createdAt),
              updatedAt: Value<DateTime>(m.updatedAt),
            ),
        ]);
      });

  @override
  Future<void> deleteIds(List<String> ids) =>
      (_db.delete(_db.stockMovements)..where((StockMovements t) => t.id.isIn(ids))).go();

  /// Stock on hand per variant: one SQL sum instead of adding up every movement
  /// in memory.
  Future<Map<String, int>> onHandByVariant() async {
    final Expression<int> total = _db.stockMovements.quantity.sum();
    final JoinedSelectStatement<HasResultSet, dynamic> query = _db.selectOnly(_db.stockMovements)
      ..addColumns(<Expression<Object>>[_db.stockMovements.variantId, total])
      ..groupBy(<Expression<Object>>[_db.stockMovements.variantId]);
    final List<TypedResult> rows = await query.get();
    return <String, int>{
      for (final TypedResult row in rows)
        row.read(_db.stockMovements.variantId)!: row.read(total) ?? 0,
    };
  }
}

// ---- stock audits (with items) ---------------------------------------------

class StockAuditsCollection extends LocalCollection<StockAuditModel> {
  StockAuditsCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.stockAudits;

  @override
  StockAuditModel fromMap(Map<String, dynamic> map) => StockAuditModel.fromMap(map);

  StockAuditModel _model(StockAuditRow r, List<StockAuditItemRow> items) => StockAuditModel(
        id: r.id,
        auditNo: r.auditNo,
        auditDate: r.auditDate,
        items: (List<StockAuditItemRow>.of(items)
              ..sort((StockAuditItemRow a, StockAuditItemRow b) => a.position.compareTo(b.position)))
            .map((StockAuditItemRow i) => StockAuditItem(
                  productId: i.productId,
                  variantId: i.variantId,
                  productName: i.productName,
                  variantLabel: i.variantLabel,
                  sku: i.sku,
                  systemQuantity: i.systemQuantity,
                  countedQuantity: i.countedQuantity,
                ))
            .toList(),
        note: r.note,
        countedById: r.countedById,
        countedByName: r.countedByName,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<StockAuditModel>> all() async {
    final List<StockAuditRow> rows = await _db.select(_db.stockAudits).get();
    final Map<String, List<StockAuditItemRow>> items =
        _group<StockAuditItemRow>(await _db.select(_db.stockAuditItems).get(), (StockAuditItemRow i) => i.auditId);
    return rows.map((StockAuditRow r) => _model(r, items[r.id] ?? <StockAuditItemRow>[])).toList();
  }

  @override
  Future<StockAuditModel?> byId(String id) async {
    final StockAuditRow? row =
        await (_db.select(_db.stockAudits)..where((StockAudits t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final List<StockAuditItemRow> items =
        await (_db.select(_db.stockAuditItems)..where((StockAuditItems t) => t.auditId.equals(id))).get();
    return _model(row, items);
  }

  @override
  Future<void> upsertAll(List<StockAuditModel> items) => _db.transaction(() async {
        final List<String> ids = items.map((StockAuditModel a) => a.id).toList();
        await (_db.delete(_db.stockAuditItems)..where((StockAuditItems t) => t.auditId.isIn(ids))).go();
        await _db.batch((Batch b) {
          b.insertAllOnConflictUpdate(_db.stockAudits, <StockAuditsCompanion>[
            for (final StockAuditModel a in items)
              StockAuditsCompanion(
                id: Value<String>(a.id),
                auditNo: Value<String>(a.auditNo),
                auditDate: Value<DateTime>(a.auditDate),
                note: Value<String>(a.note),
                countedById: Value<String>(a.countedById),
                countedByName: Value<String>(a.countedByName),
                createdAt: Value<DateTime>(a.createdAt),
                updatedAt: Value<DateTime>(a.updatedAt),
              ),
          ]);
          b.insertAllOnConflictUpdate(_db.stockAuditItems, <StockAuditItemsCompanion>[
            for (final StockAuditModel a in items)
              for (int i = 0; i < a.items.length; i++)
                StockAuditItemsCompanion(
                  auditId: Value<String>(a.id),
                  position: Value<int>(i),
                  productId: Value<String>(a.items[i].productId),
                  variantId: Value<String>(a.items[i].variantId),
                  productName: Value<String>(a.items[i].productName),
                  variantLabel: Value<String>(a.items[i].variantLabel),
                  sku: Value<String>(a.items[i].sku),
                  systemQuantity: Value<int>(a.items[i].systemQuantity),
                  countedQuantity: Value<int>(a.items[i].countedQuantity),
                ),
          ]);
        });
      });

  @override
  Future<void> deleteIds(List<String> ids) => _db.transaction(() async {
        await (_db.delete(_db.stockAuditItems)..where((StockAuditItems t) => t.auditId.isIn(ids))).go();
        await (_db.delete(_db.stockAudits)..where((StockAudits t) => t.id.isIn(ids))).go();
      });
}

// ---- orders (with items and status history) --------------------------------

class OrdersCollection extends LocalCollection<OrderModel> {
  OrdersCollection(this._db);

  final AppDatabase _db;

  @override
  String get name => StorageKeys.orders;

  @override
  OrderModel fromMap(Map<String, dynamic> map) => OrderModel.fromMap(map);

  OrderModel _model(OrderRow r, List<OrderItemRow> items, List<OrderStatusRow> history) => OrderModel(
        id: r.id,
        orderNo: r.orderNo,
        customerId: r.customerId,
        customerName: r.customerName,
        orderDate: r.orderDate,
        status: OrderStatus.fromName(r.status),
        saleType: OrderSaleType.fromName(r.saleType),
        items: (List<OrderItemRow>.of(items)
              ..sort((OrderItemRow a, OrderItemRow b) => a.position.compareTo(b.position)))
            .map((OrderItemRow i) => OrderItem(
                  id: i.id,
                  productId: i.productId,
                  variantId: i.variantId,
                  productName: i.productName,
                  variantLabel: i.variantLabel,
                  sku: i.sku,
                  quantity: i.quantity,
                  unitPrice: i.unitPrice,
                  discount: i.discount,
                ))
            .toList(),
        discount: r.discount,
        shippingFee: r.shippingFee,
        shippingAddress: r.shippingAddress,
        taxAmount: r.taxAmount,
        gstAmount: r.gstAmount,
        vatAmount: r.vatAmount,
        gstRate: r.gstRate,
        vatRate: r.vatRate,
        taxInclusive: r.taxInclusive,
        channel: r.channel,
        notes: r.notes,
        statusHistory: (List<OrderStatusRow>.of(history)
              ..sort((OrderStatusRow a, OrderStatusRow b) => a.position.compareTo(b.position)))
            .map((OrderStatusRow h) => OrderStatusEntry(
                  status: OrderStatus.fromName(h.status),
                  changedAt: h.changedAt,
                  byUserId: h.byUserId,
                  byName: h.byName,
                ))
            .toList(),
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  @override
  Future<List<OrderModel>> all() async {
    final List<OrderRow> rows = await _db.select(_db.orders).get();
    final Map<String, List<OrderItemRow>> items =
        _group<OrderItemRow>(await _db.select(_db.orderItems).get(), (OrderItemRow i) => i.orderId);
    final Map<String, List<OrderStatusRow>> history =
        _group<OrderStatusRow>(await _db.select(_db.orderStatusEntries).get(), (OrderStatusRow h) => h.orderId);
    return rows
        .map((OrderRow r) => _model(r, items[r.id] ?? <OrderItemRow>[], history[r.id] ?? <OrderStatusRow>[]))
        .toList();
  }

  @override
  Future<OrderModel?> byId(String id) async {
    final OrderRow? row = await (_db.select(_db.orders)..where((Orders t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final List<OrderItemRow> items =
        await (_db.select(_db.orderItems)..where((OrderItems t) => t.orderId.equals(id))).get();
    final List<OrderStatusRow> history =
        await (_db.select(_db.orderStatusEntries)..where((OrderStatusEntries t) => t.orderId.equals(id))).get();
    return _model(row, items, history);
  }

  @override
  Future<void> upsertAll(List<OrderModel> items) => _db.transaction(() async {
        final List<String> ids = items.map((OrderModel o) => o.id).toList();
        await (_db.delete(_db.orderItems)..where((OrderItems t) => t.orderId.isIn(ids))).go();
        await (_db.delete(_db.orderStatusEntries)..where((OrderStatusEntries t) => t.orderId.isIn(ids))).go();
        await _db.batch((Batch b) {
          b.insertAllOnConflictUpdate(_db.orders, <OrdersCompanion>[
            for (final OrderModel o in items)
              OrdersCompanion(
                id: Value<String>(o.id),
                orderNo: Value<String>(o.orderNo),
                customerId: Value<String>(o.customerId),
                customerName: Value<String>(o.customerName),
                orderDate: Value<DateTime>(o.orderDate),
                status: Value<String>(o.status.name),
                saleType: Value<String>(o.saleType.name),
                discount: Value<double>(o.discount),
                shippingFee: Value<double>(o.shippingFee),
                shippingAddress: Value<String>(o.shippingAddress),
                taxAmount: Value<double>(o.taxAmount),
                gstAmount: Value<double>(o.gstAmount),
                vatAmount: Value<double>(o.vatAmount),
                gstRate: Value<double>(o.gstRate),
                vatRate: Value<double>(o.vatRate),
                taxInclusive: Value<bool>(o.taxInclusive),
                channel: Value<String>(o.channel),
                notes: Value<String>(o.notes),
                createdAt: Value<DateTime>(o.createdAt),
                updatedAt: Value<DateTime>(o.updatedAt),
              ),
          ]);
          b.insertAllOnConflictUpdate(_db.orderItems, <OrderItemsCompanion>[
            for (final OrderModel o in items)
              for (int i = 0; i < o.items.length; i++)
                OrderItemsCompanion(
                  id: Value<String>(o.items[i].id),
                  orderId: Value<String>(o.id),
                  productId: Value<String>(o.items[i].productId),
                  variantId: Value<String>(o.items[i].variantId),
                  productName: Value<String>(o.items[i].productName),
                  variantLabel: Value<String>(o.items[i].variantLabel),
                  sku: Value<String>(o.items[i].sku),
                  quantity: Value<int>(o.items[i].quantity),
                  unitPrice: Value<double>(o.items[i].unitPrice),
                  discount: Value<double>(o.items[i].discount),
                  position: Value<int>(i),
                ),
          ]);
          b.insertAllOnConflictUpdate(_db.orderStatusEntries, <OrderStatusEntriesCompanion>[
            for (final OrderModel o in items)
              for (int i = 0; i < o.statusHistory.length; i++)
                OrderStatusEntriesCompanion(
                  orderId: Value<String>(o.id),
                  position: Value<int>(i),
                  status: Value<String>(o.statusHistory[i].status.name),
                  changedAt: Value<DateTime>(o.statusHistory[i].changedAt),
                  byUserId: Value<String>(o.statusHistory[i].byUserId),
                  byName: Value<String>(o.statusHistory[i].byName),
                ),
          ]);
        });
      });

  @override
  Future<void> deleteIds(List<String> ids) => _db.transaction(() async {
        await (_db.delete(_db.orderItems)..where((OrderItems t) => t.orderId.isIn(ids))).go();
        await (_db.delete(_db.orderStatusEntries)..where((OrderStatusEntries t) => t.orderId.isIn(ids))).go();
        await (_db.delete(_db.orders)..where((Orders t) => t.id.isIn(ids))).go();
      });
}
