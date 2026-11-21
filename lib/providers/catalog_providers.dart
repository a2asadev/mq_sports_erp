import 'package:a2_stocks/core/permissions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/data/local_repositories.dart';
import 'package:a2_stocks/data/outbox_entry.dart';
import 'package:a2_stocks/data/pending_effects.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/providers/local_data_providers.dart';
import 'package:a2_stocks/repositories/repository.dart';
import 'package:a2_stocks/providers/data_mode.dart';
import 'package:a2_stocks/online/online_providers.dart';
import 'package:a2_stocks/online/online_repositories.dart';
import 'package:a2_stocks/core/constants/storage_keys.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/core/utils/category_tree.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/stock_ledger_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/variant_model.dart';
import 'package:a2_stocks/providers/base_list_notifier.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/providers/stock_providers.dart';
import 'package:a2_stocks/providers/users_providers.dart';

final Provider<Repository<CategoryModel>> categoryRepositoryProvider =
    Provider<Repository<CategoryModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineCategoryRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalRepository<CategoryModel>(
    collection: ref.watch(localCollectionsProvider).categories,
    outbox: ref.watch(outboxStoreProvider),
    entityLabel: L10n.current.categoriesCategory,
    labelOf: (CategoryModel category) => category.name,
    overlay: (List<CategoryModel> base, List<OutboxEntry> entries) =>
        overlayRecords<CategoryModel>(
      collection: StorageKeys.categories,
      base: base,
      entries: entries,
      fromMap: CategoryModel.fromMap,
    ),
    // A category may only be deleted while nothing on this device uses it.
    deleteGuard: (String id) async {
      final List<CategoryModel> categories =
          await ref.read(categoryRepositoryProvider).getLocal();
      if (categories.any((CategoryModel c) => c.parentId == id)) {
        return L10n.current.catalogItHasSubcategories;
      }
      final List<ProductModel> products =
          await ref.read(productRepositoryProvider).getLocal();
      final int used =
          products.where((ProductModel p) => p.categoryId == id).length;
      return used > 0 ? L10n.current.catalogItIsUsedBy(used) : null;
    },
  );
});

final Provider<Repository<ProductModel>> productRepositoryProvider =
    Provider<Repository<ProductModel>>((Ref ref) {
  if (ref.watch(dataModeProvider).isOnline) {
    return OnlineProductRepository(
      ref.watch(apiClientProvider),
      ref.watch(remoteStoreProvider),
    );
  }
  return LocalRepository<ProductModel>(
    collection: ref.watch(localCollectionsProvider).products,
    outbox: ref.watch(outboxStoreProvider),
    entityLabel: L10n.current.productFormProduct,
    labelOf: (ProductModel product) => product.name,
    overlay: (List<ProductModel> base, List<OutboxEntry> entries) =>
        overlayRecords<ProductModel>(
      collection: StorageKeys.products,
      base: base,
      entries: entries,
      fromMap: ProductModel.fromMap,
    ),
    // A product with stock history can only be deactivated, not deleted.
    deleteGuard: (String id) async {
      final List<StockLedgerModel> entries =
          await ref.read(stockLedgerRepositoryProvider).getLocal();
      return entries.any((StockLedgerModel e) => e.productId == id)
          ? L10n.current.catalogItHasStockHistory
          : null;
    },
  );
});

/// Admins and managers may change the catalog; staff can only view it.
final Provider<bool> canManageCatalogProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      user.can(Permissions.catalogManage);
});

String get _noPermissionMessage => L10n.current.catalogOnlyAdminsAndManagers;

class CategoriesNotifier extends BaseListNotifier<CategoryModel> {
  @override
  Repository<CategoryModel> get repository =>
      ref.read(categoryRepositoryProvider);

  List<CategoryModel> get _items => state.valueOrNull ?? <CategoryModel>[];

  String? _validate(CategoryModel category) {
    if (category.name.trim().isEmpty) {
      return L10n.current.catalogCategoryNameIsRequired;
    }
    final bool duplicate = _items.any((CategoryModel other) =>
        other.id != category.id &&
        other.parentId == category.parentId &&
        other.name.trim().toLowerCase() == category.name.trim().toLowerCase());
    if (duplicate) {
      return L10n.current.catalogACategoryNamedAlready(category.name.trim());
    }
    if (category.parentId.isNotEmpty) {
      if (category.parentId == category.id ||
          CategoryTree.descendantIds(category.id, _items)
              .contains(category.parentId)) {
        return L10n.current.catalogACategoryCannotBe;
      }
      final bool parentExists =
          _items.any((CategoryModel other) => other.id == category.parentId);
      if (!parentExists) {
        return L10n.current.catalogTheSelectedParentCategory;
      }
    }
    return null;
  }

  Future<bool> createCategory({
    required String name,
    required String parentId,
    required String description,
    required bool isActive,
  }) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final CategoryModel category = CategoryModel(
      name: name.trim(),
      parentId: parentId,
      description: description.trim(),
      isActive: isActive,
    );
    final String? problem = _validate(category);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await add(category);
    return !state.hasError;
  }

  Future<bool> updateCategory(CategoryModel updated) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final CategoryModel normalized = updated.copyWith(
      name: updated.name.trim(),
      description: updated.description.trim(),
    );
    final String? problem = _validate(normalized);
    if (problem != null) {
      return reportFailure(ValidationException(problem));
    }
    await updateItem(normalized);
    return !state.hasError;
  }

  Future<bool> deleteCategory(String id) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            L10n.current.catalogThisCategoryCannotBe(reason)));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>
    categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
  CategoriesNotifier.new,
);

class ProductsNotifier extends BaseListNotifier<ProductModel> {
  @override
  Repository<ProductModel> get repository =>
      ref.read(productRepositoryProvider);

  List<ProductModel> get _items => state.valueOrNull ?? <ProductModel>[];

  /// Barcodes are optional. When the business requires them, a new item needs one and an item that has one cannot
  /// lose it (older items without one stay editable). A barcode names ONE item: it cannot be used twice, in this
  /// product or by another (checked for a new or changed barcode). The server applies the same rules.
  String? _barcodeProblem(ProductModel product) {
    final bool required = ref.read(businessProvider).requireBarcode;
    final ProductModel? before = _items.where((ProductModel p) => p.id == product.id).firstOrNull;
    final Set<String> seen = <String>{};
    final Set<String> toCheck = <String>{};
    for (final VariantModel variant in product.variants) {
      final String code = variant.barcode.trim().toLowerCase();
      final VariantModel? old = before?.variants.where((VariantModel v) => v.id == variant.id).firstOrNull;
      if (code.isEmpty) {
        if (required && (old == null || old.barcode.trim().isNotEmpty)) {
          return L10n.current.catalogBarcodeRequired(variant.sku.trim());
        }
        continue;
      }
      if (!seen.add(code)) {
        return L10n.current.catalogBarcodeTwice(variant.barcode.trim());
      }
      if (old == null || old.barcode.trim().toLowerCase() != code) {
        toCheck.add(code);
      }
    }
    for (final ProductModel other in _items) {
      if (other.id == product.id) {
        continue;
      }
      for (final VariantModel variant in other.variants) {
        if (toCheck.contains(variant.barcode.trim().toLowerCase())) {
          return L10n.current.catalogBarcodeBelongsTo(variant.barcode.trim(), other.name);
        }
      }
    }
    return null;
  }

  Future<String?> _validate(ProductModel product) async {
    if (product.name.trim().isEmpty) {
      return L10n.current.catalogProductNameIsRequired;
    }
    if (product.categoryId.isEmpty) {
      return L10n.current.productFormChooseACategory;
    }
    if (product.variants.isEmpty) {
      return L10n.current.productFormAddAtLeastOne;
    }
    final Set<String> skus = <String>{};
    for (final VariantModel variant in product.variants) {
      final String sku = variant.sku.trim().toLowerCase();
      if (sku.isEmpty) {
        return L10n.current.catalogEveryVariantNeedsA;
      }
      if (!skus.add(sku)) {
        return L10n.current.catalogSkuIsUsedTwice(variant.sku.trim());
      }
    }
    for (final ProductModel other in _items) {
      if (other.id == product.id) {
        continue;
      }
      for (final VariantModel variant in other.variants) {
        if (skus.contains(variant.sku.trim().toLowerCase())) {
          return L10n.current.catalogSkuAlreadyBelongsTo(variant.sku.trim(), other.name);
        }
      }
    }
    final String? barcodeProblem = _barcodeProblem(product);
    if (barcodeProblem != null) {
      return barcodeProblem;
    }
    final CategoryModel? category = await ref
        .read(categoryRepositoryProvider)
        .getLocalById(product.categoryId);
    if (category == null) {
      return L10n.current.catalogTheSelectedCategoryNo;
    }
    return null;
  }

  Future<bool> createProduct({
    required String name,
    required String categoryId,
    required String brand,
    required String description,
    required bool isActive,
    required List<VariantModel> variants,
    bool isFeatured = false,
  }) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final ProductModel product = ProductModel(
      name: name.trim(),
      categoryId: categoryId,
      brand: brand.trim(),
      description: description.trim(),
      isActive: isActive,
      isFeatured: isFeatured,
      variants: variants,
    );
    try {
      final String? problem = await _validate(product);
      if (problem != null) {
        return reportFailure(ValidationException(problem));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await add(product);
    return !state.hasError;
  }

  Future<bool> updateProduct(ProductModel updated) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    final ProductModel normalized = updated.copyWith(
      name: updated.name.trim(),
      brand: updated.brand.trim(),
      description: updated.description.trim(),
    );
    try {
      final String? problem = await _validate(normalized);
      if (problem != null) {
        return reportFailure(ValidationException(problem));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    final ProductModel? existing = _items
        .where((ProductModel p) => p.id == normalized.id)
        .firstOrNull;
    if (existing != null) {
      final Set<String> keptIds = <String>{
        for (final VariantModel v in normalized.variants) v.id,
      };
      final List<VariantModel> removed = existing.variants
          .where((VariantModel v) => !keptIds.contains(v.id))
          .toList();
      if (removed.isNotEmpty) {
        try {
          final List<StockLedgerModel> entries =
              await ref.read(stockLedgerRepositoryProvider).getLocal();
          final List<VariantModel> withHistory = removed
              .where((VariantModel v) =>
                  entries.any((StockLedgerModel e) => e.variantId == v.id))
              .toList();
          if (withHistory.isNotEmpty) {
            return reportFailure(ValidationException(
                L10n.current.catalogHasStockHistoryAnd(withHistory.first.label)));
          }
        } on AppException catch (e) {
          return reportFailure(e);
        }
      }
    }
    await updateItem(normalized);
    return !state.hasError;
  }

  Future<bool> deleteProduct(String id) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(PermissionDeniedException(_noPermissionMessage));
    }
    try {
      final String? reason = await repository.deleteBlockReason(id);
      if (reason != null) {
        return reportFailure(ValidationException(
            L10n.current.catalogThisProductCannotBe(reason)));
      }
    } on AppException catch (e) {
      return reportFailure(e);
    }
    await remove(id);
    return !state.hasError;
  }
}

final AsyncNotifierProvider<ProductsNotifier, List<ProductModel>>
    productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<ProductModel>>(
  ProductsNotifier.new,
);
