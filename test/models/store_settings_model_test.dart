import 'package:flutter_test/flutter_test.dart';
import 'package:a2_stocks/models/category_model.dart';
import 'package:a2_stocks/models/customer_model.dart';
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/models/product_model.dart';
import 'package:a2_stocks/models/store_settings_model.dart';
import 'package:a2_stocks/models/user_model.dart';
import 'package:a2_stocks/models/vendor_model.dart';

void main() {
  test('store settings round-trip and fall back to defaults', () {
    const StoreSettingsModel s = StoreSettingsModel(
      enabled: false,
      storeName: 'Shop',
      contactPhone: '0300',
      notifyEmail: 'a@b.co',
      checkoutNote: 'Hi',
      deliveryFee: 300.5,
      freeDeliveryAbove: 0,
      lowStockBelow: 2,
    );
    expect(StoreSettingsModel.fromMap(s.toMap()).toMap(), s.toMap());
    expect(StoreSettingsModel.fromMap(<String, dynamic>{}).deliveryFee, 250);
    expect(s.copyWith(enabled: true).enabled, isTrue);
    expect(s.copyWith(enabled: true).storeName, 'Shop');
    expect(TestEmailResult.fromMap(<String, dynamic>{'configured': true, 'sent': false}).configured, isTrue);
  });

  test('photo addresses are part of the models and survive copyWith', () {
    final UserModel user = UserModel(id: 'u', email: 'a@b.c', photoUrl: 'http://m/u.webp');
    expect(UserModel.fromMap(user.toMap()).photoUrl, 'http://m/u.webp');
    expect(user.copyWith(displayName: 'Ann').photoUrl, 'http://m/u.webp');
    expect(user.copyWith(photoUrl: '').photoUrl, '');

    final CategoryModel category = CategoryModel(name: 'Bats', photoUrl: 'x');
    expect(CategoryModel.fromMap(category.toMap()).photoUrl, 'x');
    expect(category.copyWith(name: 'B').photoUrl, 'x');
    final CustomerModel customer = CustomerModel(name: 'Ali', photoUrl: 'y');
    expect(CustomerModel.fromMap(customer.toMap()).photoUrl, 'y');
    expect(customer.copyWith(name: 'A').photoUrl, 'y');
    final VendorModel vendor = VendorModel(name: 'V', photoUrl: 'z');
    expect(VendorModel.fromMap(vendor.toMap()).photoUrl, 'z');
    expect(vendor.copyWith(name: 'W').photoUrl, 'z');
    // Records from before photos have none.
    expect(CategoryModel.fromMap(<String, dynamic>{'id': 'c', 'name': 'n'}).photoUrl, '');
  });

  test('a product keeps its photos, main one first, through copyWith and maps', () {
    final ProductModel product = ProductModel(
      name: 'Bat',
      categoryId: 'c',
      images: const <ProductImage>[
        ProductImage(id: 'i1', position: 0, width: 600, height: 400, thumbUrl: 't1', mediumUrl: 'm1', largeUrl: 'l1'),
        ProductImage(id: 'i2', position: 1, variantId: 'v', mediumUrl: 'm2'),
      ],
    );
    final ProductModel back = ProductModel.fromMap(product.toMap());
    expect(back.images.map((ProductImage i) => i.id), <String>['i1', 'i2']);
    expect(back.images.first.largeUrl, 'l1');
    expect(back.images.last.variantId, 'v');
    expect(product.copyWith(name: 'Bat 2').images, hasLength(2));
    expect(product.copyWith(images: const <ProductImage>[]).images, isEmpty);
    expect(ProductModel.fromMap(<String, dynamic>{'id': 'p', 'name': 'n', 'categoryId': 'c'}).images, isEmpty);
  });
}
