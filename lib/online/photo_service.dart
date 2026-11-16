import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mq_sports_erp/core/errors/app_exceptions.dart';
import 'package:mq_sports_erp/models/product_image.dart';
import 'package:mq_sports_erp/online/api_client.dart';

/// What a one-photo record can be. The name is the address part the server uses.
enum PhotoKind {
  user,
  category,
  customer,
  vendor,
  business;

  String get path => name;
}

/// A photo the person chose, checked and ready to upload.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.contentType, required this.name});

  final Uint8List bytes;
  final String contentType;
  final String name;
}

/// The checks done on the device before anything is uploaded. The server checks
/// again (it only trusts the real content of the file).
class PhotoRules {
  const PhotoRules._();

  static const int maxBytes = 10 * 1024 * 1024;

  /// The image type from the first bytes of the file, or null when it is not a
  /// JPEG, PNG or WebP picture (the file name is not trusted).
  static String? contentTypeOf(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  /// Returns the photo, or throws a [ValidationException] saying what is wrong.
  static PickedPhoto check(String name, Uint8List bytes) {
    if (bytes.isEmpty) {
      throw const ValidationException('That file is empty.');
    }
    if (bytes.length > maxBytes) {
      throw const ValidationException('That photo is bigger than 10 MB. Please choose a smaller one.');
    }
    final String? type = contentTypeOf(bytes);
    if (type == null) {
      throw const ValidationException('Only JPEG, PNG or WebP photos can be used.');
    }
    return PickedPhoto(bytes: bytes, contentType: type, name: name);
  }
}

/// Choosing and uploading photos.
///
/// The file goes straight to the photo storage with a short-lived link the API
/// signs; the API then checks it is a real image, makes the sizes and publishes
/// them. Photos need a connection and a record the server already knows (a
/// record created offline has to be synced first).
class PhotoService {
  PhotoService({
    required ApiClient api,
    required http.Client httpClient,
    required Future<void> Function() refresh,
    Future<PickedPhoto?> Function()? picker,
  })  : _api = api,
        _http = httpClient,
        _refresh = refresh,
        _picker = picker ?? _pickFromDevice;

  final ApiClient _api;
  final http.Client _http;

  /// Brings the changed record (with its new photo address) onto this device.
  final Future<void> Function() _refresh;
  final Future<PickedPhoto?> Function() _picker;

  /// Opens the system picker. Null when the person cancels.
  Future<PickedPhoto?> pick() => _picker();

  static Future<PickedPhoto?> _pickFromDevice() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.image,
      dialogTitle: 'Choose a photo',
    );
    if (file == null) {
      return null;
    }
    return PhotoRules.check(file.name, await file.readAsBytes());
  }

  // ---- one photo per record ----------------------------------------------

  /// Sets the photo of a user, category, customer or vendor; returns its new address.
  Future<String> setPhoto(PhotoKind kind, String id, PickedPhoto photo) async {
    final ApiResponse link = await _request(
      () => _api.post(
        '/v1/photos/${kind.path}/$id/upload-url',
        body: <String, dynamic>{'contentType': photo.contentType, 'sizeBytes': photo.bytes.length},
      ),
    );
    await _putToStorage(link.asMap, photo);
    final ApiResponse done = await _api.post(
      '/v1/photos/${kind.path}/$id/${link.asMap['photoId']}/complete',
    );
    await _refresh();
    return done.asMap['photoUrl'] as String? ?? '';
  }

  Future<void> removePhoto(PhotoKind kind, String id) async {
    await _api.delete('/v1/photos/${kind.path}/$id');
    await _refresh();
  }

  // ---- several photos per product ------------------------------------------

  Future<ProductImage> addProductPhoto(String productId, PickedPhoto photo, {String variantId = ''}) async {
    final ApiResponse link = await _request(
      () => _api.post(
        '/v1/products/$productId/images/upload-url',
        body: <String, dynamic>{
          'contentType': photo.contentType,
          'sizeBytes': photo.bytes.length,
          if (variantId.isNotEmpty) 'variantId': variantId,
        },
      ),
    );
    await _putToStorage(link.asMap, photo);
    final ApiResponse done = await _api.post(
      '/v1/products/$productId/images/${link.asMap['imageId']}/complete',
    );
    await _refresh();
    return ProductImage.fromMap(done.asMap);
  }

  Future<void> removeProductPhoto(String productId, String imageId) async {
    await _api.delete('/v1/products/$productId/images/$imageId');
    await _refresh();
  }

  /// Sets the order of the photos (the first is the main one).
  Future<List<ProductImage>> reorderProductPhotos(String productId, List<String> imageIds) async {
    final ApiResponse response = await _api.put(
      '/v1/products/$productId/images/order',
      body: <String, dynamic>{'imageIds': imageIds},
    );
    await _refresh();
    return response.asList
        .whereType<Map<String, dynamic>>()
        .map(ProductImage.fromMap)
        .toList();
  }

  // ---- shared -------------------------------------------------------------

  /// A record that is not on the server yet answers 404: say what to do.
  Future<ApiResponse> _request(Future<ApiResponse> Function() call) async {
    try {
      return await call();
    } on ValidationException catch (error) {
      if (error.message.toLowerCase().contains('not found')) {
        throw const ValidationException(
          'This item has not reached the server yet. Wait for it to sync, then add the photo.',
        );
      }
      rethrow;
    }
  }

  Future<void> _putToStorage(Map<String, dynamic> link, PickedPhoto photo) async {
    final String? url = link['uploadUrl'] as String?;
    if (url == null) {
      throw const RemoteSyncException('The server did not give an upload link.');
    }
    try {
      // The file length is set by the HTTP client from the bytes; the link was
      // signed for exactly this length and type.
      final http.Response response = await _http
          .put(Uri.parse(url), headers: <String, String>{'Content-Type': photo.contentType}, body: photo.bytes)
          .timeout(const Duration(minutes: 2));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RemoteSyncException('The photo could not be uploaded (${response.statusCode}). Please try again.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const RemoteSyncException('The photo could not be uploaded. Check your connection and try again.');
    }
  }
}
