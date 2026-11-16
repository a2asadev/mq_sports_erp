import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:a2_stocks/core/errors/app_exceptions.dart';
import 'package:a2_stocks/models/product_image.dart';
import 'package:a2_stocks/online/api_client.dart';
import 'package:a2_stocks/online/photo_service.dart';
import 'package:a2_stocks/online/token_store.dart';

const String _userJson =
    '{"id":"u1","email":"a@b.c","displayName":"Ann","phoneNumber":"","role":"admin","isActive":true,'
    '"photoUrl":"","createdAt":"2026-11-01T00:00:00.000Z","updatedAt":"2026-11-01T00:00:00.000Z"}';

http.Response _json(int status, String body) =>
    http.Response(body, status, headers: <String, String>{'content-type': 'application/json'});

Uint8List _png() => Uint8List.fromList(<int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0]);

http.Response _login() =>
    _json(200, '{"accessToken":"a","refreshToken":"r","user":$_userJson}');

void main() {
  group('PhotoRules', () {
    test('recognises JPEG, PNG and WebP by their content, not their name', () {
      expect(PhotoRules.contentTypeOf(Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0, 1])), 'image/jpeg');
      expect(PhotoRules.contentTypeOf(_png()), 'image/png');
      final Uint8List webp = Uint8List.fromList(<int>[...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]);
      expect(PhotoRules.contentTypeOf(webp), 'image/webp');
      expect(PhotoRules.contentTypeOf(Uint8List.fromList('GIF89a....'.codeUnits)), isNull);
      expect(PhotoRules.contentTypeOf(Uint8List(0)), isNull);
      expect(PhotoRules.check('cat.exe', _png()).contentType, 'image/png');
    });

    test('refuses empty, too big and non-image files with a clear message', () {
      expect(() => PhotoRules.check('a.png', Uint8List(0)), throwsA(isA<ValidationException>()));
      expect(() => PhotoRules.check('a.pdf', Uint8List.fromList('%PDF-1.4'.codeUnits)),
          throwsA(isA<ValidationException>()));
      final Uint8List big = Uint8List(PhotoRules.maxBytes + 1)..setRange(0, 8, _png());
      expect(
        () => PhotoRules.check('big.png', big),
        throwsA(isA<ValidationException>().having((ValidationException e) => e.message, 'message', contains('10 MB'))),
      );
    });
  });

  group('PhotoService', () {
    late List<http.Request> requests;
    late int refreshed;
    late PhotoService service;

    ApiClient apiFor(MockClient mock) =>
        ApiClient(httpClient: mock, baseUrl: 'http://api.test', tokens: MemoryTokenStore());

    setUp(() async {
      requests = <http.Request>[];
      refreshed = 0;
      final MockClient server = MockClient((http.Request r) async {
        requests.add(r);
        final String path = r.url.path;
        if (path == '/v1/auth/login') {
          return _login();
        }
        if (path.endsWith('/upload-url')) {
          return _json(
            201,
            '{"photoId":"p1","imageId":"i1","uploadUrl":"http://storage.test/up/p1","method":"PUT",'
            '"headers":{"Content-Type":"image/png"},"expiresAt":"2026-11-16T00:00:00Z"}',
          );
        }
        if (r.url.host == 'storage.test') {
          return http.Response('', 200);
        }
        if (path.endsWith('/complete') && path.contains('/photos/')) {
          return _json(200, '{"photoUrl":"http://media.test/photos/category/c1/p1/medium.webp"}');
        }
        if (path.endsWith('/complete')) {
          return _json(
            200,
            '{"id":"i1","variantId":"","position":0,"width":600,"height":400,'
            '"thumbUrl":"t","mediumUrl":"m","largeUrl":"l"}',
          );
        }
        if (path.endsWith('/order')) {
          return _json(200, '[{"id":"i2","position":0},{"id":"i1","position":1}]');
        }
        return http.Response('', 204);
      });
      final ApiClient api = apiFor(server);
      await api.login('a@b.c', 'x');
      requests.clear();
      service = PhotoService(
        api: api,
        httpClient: server,
        refresh: () async => refreshed++,
        picker: () async => PhotoRules.check('p.png', _png()),
      );
    });

    test('a record photo: link, upload straight to storage, complete, refresh', () async {
      final PickedPhoto? photo = await service.pick();
      final String url = await service.setPhoto(PhotoKind.category, 'c1', photo!);

      expect(url, contains('/photos/category/c1/'));
      expect(requests.map((http.Request r) => '${r.method} ${r.url.host}${r.url.path}').toList(), <String>[
        'POST api.test/v1/photos/category/c1/upload-url',
        'PUT storage.test/up/p1',
        'POST api.test/v1/photos/category/c1/p1/complete',
      ]);
      final Map<String, dynamic> asked = jsonDecode(requests[0].body) as Map<String, dynamic>;
      expect(asked, <String, dynamic>{'contentType': 'image/png', 'sizeBytes': photo.bytes.length});
      expect(requests[1].headers['Content-Type'], 'image/png');
      expect(requests[1].bodyBytes, photo.bytes);
      // The storage upload never carries the sign-in token.
      expect(requests[1].headers.containsKey('Authorization'), isFalse);
      expect(refreshed, 1);
    });

    test('product photos: add, reorder, delete', () async {
      final PickedPhoto photo = PhotoRules.check('p.png', _png());
      final ProductImage added = await service.addProductPhoto('prod1', photo);
      expect(added.id, 'i1');
      expect(added.width, 600);
      final List<ProductImage> order = await service.reorderProductPhotos('prod1', <String>['i2', 'i1']);
      expect(order.map((ProductImage i) => i.id), <String>['i2', 'i1']);
      await service.removeProductPhoto('prod1', 'i1');
      final List<String> calls = requests.map((http.Request r) => '${r.method} ${r.url.path}').toList();
      expect(calls, contains('DELETE /v1/products/prod1/images/i1'));
      expect(calls, contains('PUT /v1/products/prod1/images/order'));
      expect(refreshed, 3);
    });

    test('a failed storage upload is reported and nothing is completed', () async {
      final List<http.Request> after = <http.Request>[];
      final MockClient failing = MockClient((http.Request r) async {
        if (r.url.path == '/v1/auth/login') {
          return _login();
        }
        after.add(r);
        if (r.url.host == 'storage.test') {
          return http.Response('denied', 403);
        }
        if (r.url.path.endsWith('/upload-url')) {
          return _json(201, '{"photoId":"p1","uploadUrl":"http://storage.test/up/p1"}');
        }
        return http.Response('', 204);
      });
      final ApiClient api = apiFor(failing);
      await api.login('a@b.c', 'x');
      final PhotoService broken = PhotoService(api: api, httpClient: failing, refresh: () async => refreshed++);
      await expectLater(
        broken.setPhoto(PhotoKind.vendor, 'v1', PhotoRules.check('p.png', _png())),
        throwsA(isA<RemoteSyncException>()),
      );
      expect(after.where((http.Request r) => r.url.path.endsWith('/complete')), isEmpty);
      expect(refreshed, 0);
    });

    test('a record the server does not know yet gets a helpful message', () async {
      final MockClient unknown = MockClient((http.Request r) async {
        if (r.url.path == '/v1/auth/login') {
          return _login();
        }
        return _json(404, '{"statusCode":404,"message":"Not found"}');
      });
      final ApiClient api = apiFor(unknown);
      await api.login('a@b.c', 'x');
      final PhotoService offline = PhotoService(api: api, httpClient: unknown, refresh: () async {});
      await expectLater(
        offline.setPhoto(PhotoKind.customer, 'c1', PhotoRules.check('p.png', _png())),
        throwsA(isA<ValidationException>().having((ValidationException e) => e.message, 'message', contains('sync'))),
      );
    });
  });
}
