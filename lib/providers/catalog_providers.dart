import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mq_sports_erp/core/constants/storage_keys.dart';
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/core/utils/category_tree.dart';
import 'package:mq_sports_erp/models/category_model.dart';
import 'package:mq_sports_erp/models/product_model.dart';
import 'package:mq_sports_erp/models/user_model.dart';
import 'package:mq_sports_erp/models/user_role.dart';
import 'package:mq_sports_erp/models/variant_model.dart';
import 'package:mq_sports_erp/providers/base_list_notifier.dart';
import 'package:mq_sports_erp/providers/core_providers.dart';
import 'package:mq_sports_erp/providers/users_providers.dart';
import 'package:mq_sports_erp/repositories/base_repository.dart';
import 'package:mq_sports_erp/services/hive_local_repository.dart';

final Provider<BaseRepository<CategoryModel>> categoryRepositoryProvider =
    Provider<BaseRepository<CategoryModel>>((Ref ref) {
  return BaseRepository<CategoryModel>(
    collectionName: StorageKeys.categories,
    local: HiveLocalRepository<CategoryModel>(
      boxName: StorageKeys.categories,
      fromMap: CategoryModel.fromMap,
    ),
    remote: ref.watch(firestoreServiceProvider),
    fromMap: CategoryModel.fromMap,
  );
});

final Provider<BaseRepository<ProductModel>> productRepositoryProvider =
    Provider<BaseRepository<ProductModel>>((Ref ref) {
  return BaseRepository<ProductModel>(
    collectionName: StorageKeys.products,
    local: HiveLocalRepository<ProductModel>(
      boxName: StorageKeys.products,
      fromMap: ProductModel.fromMap,
    ),
    remote: ref.watch(firestoreServiceProvider),
    fromMap: ProductModel.fromMap,
  );
});

/// Admins and managers may change the catalog; staff can only view it.
final Provider<bool> canManageCatalogProvider = Provider<bool>((Ref ref) {
  final UserModel? user = ref.watch(currentUserProvider).valueOrNull;
  return user != null &&
      user.isActive &&
      (user.role == UserRole.admin || user.role == UserRole.manager);
});

const String _noPermissionMessage =
    'Only admins and managers can change the catalog.';

class CategoriesNotifier extends BaseListNotifier<CategoryModel> {
  @override
  BaseRepository<CategoryModel> get repository =>
      ref.read(categoryRepositoryProvider);

  List<CategoryModel> get _items => state.valueOrNull ?? <CategoryModel>[];

  String? _validate(CategoryModel category) {
    if (category.name.trim().isEmpty) {
      return 'Category name is required.';
    }
    final bool duplicate = _items.any((CategoryModel other) =>
        other.id != category.id &&
        other.parentId == category.parentId &&
        other.name.trim().toLowerCase() == category.name.trim().toLowerCase());
    if (duplicate) {
      return 'A category named "${category.name.trim()}" already exists here.';
    }
    if (category.parentId.isNotEmpty) {
      if (category.parentId == category.id ||
          CategoryTree.descendantIds(category.id, _items)
              .contains(category.parentId)) {
        return 'A category cannot be placed inside itself or its subcategories.';
      }
      final bool parentExists =
          _items.any((CategoryModel other) => other.id == category.parentId);
      if (!parentExists) {
        return 'The selected parent category no longer exists.';
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    if (_items.any((CategoryModel other) => other.parentId == id)) {
      return reportFailure(const ValidationException(
          'This category has subcategories. Delete or move them first.'));
    }
    try {
      final List<ProductModel> products =
          await ref.read(productRepositoryProvider).getLocal();
      final int used =
          products.where((ProductModel p) => p.categoryId == id).length;
      if (used > 0) {
        return reportFailure(ValidationException(
            'This category is used by $used product(s). Move or delete them first.'));
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
  BaseRepository<ProductModel> get repository =>
      ref.read(productRepositoryProvider);

  List<ProductModel> get _items => state.valueOrNull ?? <ProductModel>[];

  Future<String?> _validate(ProductModel product) async {
    if (product.name.trim().isEmpty) {
      return 'Product name is required.';
    }
    if (product.categoryId.isEmpty) {
      return 'Choose a category.';
    }
    if (product.variants.isEmpty) {
      return 'Add at least one variant.';
    }
    final Set<String> skus = <String>{};
    for (final VariantModel variant in product.variants) {
      final String sku = variant.sku.trim().toLowerCase();
      if (sku.isEmpty) {
        return 'Every variant needs a SKU.';
      }
      if (!skus.add(sku)) {
        return 'SKU "${variant.sku.trim()}" is used twice in this product.';
      }
    }
    for (final ProductModel other in _items) {
      if (other.id == product.id) {
        continue;
      }
      for (final VariantModel variant in other.variants) {
        if (skus.contains(variant.sku.trim().toLowerCase())) {
          return 'SKU "${variant.sku.trim()}" already belongs to "${other.name}".';
        }
      }
    }
    final CategoryModel? category = await ref
        .read(categoryRepositoryProvider)
        .getLocalById(product.categoryId);
    if (category == null) {
      return 'The selected category no longer exists.';
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
  }) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
    }
    final ProductModel product = ProductModel(
      name: name.trim(),
      categoryId: categoryId,
      brand: brand.trim(),
      description: description.trim(),
      isActive: isActive,
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
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
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
    await updateItem(normalized);
    return !state.hasError;
  }

  Future<bool> deleteProduct(String id) async {
    if (!ref.read(canManageCatalogProvider)) {
      return reportFailure(const PermissionDeniedException(_noPermissionMessage));
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
