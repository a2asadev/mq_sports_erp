// Real-server check of photo upload: the app's PhotoService against the actual
// API and photo storage (no mocks).
//
// Needs the API AND the storage running, on an empty database with one admin:
//
//   flutter test test/online/photo_flow_test.dart \
//     --dart-define=RUN_API_TESTS=true \
//     --dart-define=API_BASE_URL=http://127.0.0.1:3100
//
// Without RUN_API_TESTS the file is skipped.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/api_config.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/online/token_store.dart';

const bool _run = bool.fromEnvironment('RUN_API_TESTS');

/// A real 1x1 PNG.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

void main() {
  test('photos of every kind go through the real API and storage', () async {
    final http.Client client = http.Client();
    final ApiClient api = ApiClient(httpClient: client, baseUrl: apiBaseUrl, tokens: MemoryTokenStore());
    final String adminId = (await api.login('flow-admin@mq.test', 'FlowPass123')).id;
    int refreshes = 0;
    final PhotoService photos = PhotoService(
      api: api,
      httpClient: client,
      refresh: () async => refreshes++,
      picker: () async => PhotoRules.check('dot.png', _png),
    );
    final PickedPhoto photo = (await photos.pick())!;

    Future<Map<String, dynamic>> get(String path) async => (await api.get(path)).asMap;
    Future<int> fetchStatus(String url) async => (await client.get(Uri.parse(url))).statusCode;

    // one photo per record
    final String categoryId = (await api.post('/v1/categories', body: <String, dynamic>{'name': 'Cricket'})).asMap['id'] as String;
    final String customerId = (await api.post('/v1/customers', body: <String, dynamic>{'name': 'Ali'})).asMap['id'] as String;
    final String vendorId = (await api.post('/v1/vendors', body: <String, dynamic>{'name': 'Supplier'})).asMap['id'] as String;
    final Map<PhotoKind, String> ids = <PhotoKind, String>{
      PhotoKind.category: categoryId,
      PhotoKind.customer: customerId,
      PhotoKind.vendor: vendorId,
      PhotoKind.user: adminId,
    };
    final Map<PhotoKind, String> paths = <PhotoKind, String>{
      PhotoKind.category: '/v1/categories/$categoryId',
      PhotoKind.customer: '/v1/customers/$customerId',
      PhotoKind.vendor: '/v1/vendors/$vendorId',
      PhotoKind.user: '/v1/users/$adminId',
    };
    for (final PhotoKind kind in PhotoKind.values) {
      final String url = await photos.setPhoto(kind, ids[kind]!, photo);
      expect(url, contains('/photos/${kind.path}/${ids[kind]}/'));
      expect((await get(paths[kind]!))['photoUrl'], url);
      expect(await fetchStatus(url), 200, reason: kind.name);
    }
    expect(refreshes, 4);

    // replacing then removing
    final String first = (await get(paths[PhotoKind.category]!))['photoUrl'] as String;
    final String second = await photos.setPhoto(PhotoKind.category, categoryId, photo);
    expect(second, isNot(first));
    expect(await fetchStatus(first), 404);
    await photos.removePhoto(PhotoKind.category, categoryId);
    expect((await get(paths[PhotoKind.category]!))['photoUrl'], '');

    // several photos of a product
    final Map<String, dynamic> product = (await api.post('/v1/products', body: <String, dynamic>{
      'name': 'Bat',
      'categoryId': categoryId,
      'variants': <Map<String, dynamic>>[
        <String, dynamic>{'sku': 'BAT-1', 'salePrice': 100},
      ],
    })).asMap;
    final String productId = product['id'] as String;
    final ProductImage a = await photos.addProductPhoto(productId, photo);
    final ProductImage b = await photos.addProductPhoto(productId, photo);
    expect(await fetchStatus(a.thumbUrl), 200);
    expect(await fetchStatus(b.largeUrl), 200);
    final List<ProductImage> reordered = await photos.reorderProductPhotos(productId, <String>[b.id, a.id]);
    expect(reordered.map((ProductImage i) => i.id), <String>[b.id, a.id]);
    final List<Object?> images = (await get('/v1/products/$productId'))['images'] as List<Object?>;
    expect(images.map((Object? i) => (i as Map<String, dynamic>)['id']), <String>[b.id, a.id]);
    await photos.removeProductPhoto(productId, a.id);
    expect(((await get('/v1/products/$productId'))['images'] as List<Object?>).length, 1);
    expect(await fetchStatus(a.thumbUrl), 404);

    client.close();
  }, skip: _run ? false : 'Needs the real API and storage (see the top of this file).');
}
