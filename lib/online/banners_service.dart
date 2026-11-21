import 'package:a2_stocks/models/store_banner.dart';
import 'package:a2_stocks/online/api_client.dart';

/// The online store's banners (`/v1/banners`, admin and manager; needs a connection). The picture is set with the
/// photo upload (`PhotoKind.banner`).
class BannersService {
  BannersService(this._api);

  final ApiClient _api;

  List<StoreBanner> _parse(ApiResponse r) => <StoreBanner>[
        for (final Object? i in r.asList)
          if (i is Map<String, dynamic>) StoreBanner.fromMap(i),
      ];

  Future<List<StoreBanner>> list() async => _parse(await _api.get('/v1/banners'));

  Map<String, dynamic> _body({required String title, required String subtitle, required String buttonText, required String linkUrl, bool? isActive}) => <String, dynamic>{
        'title': title.trim(),
        'subtitle': subtitle.trim(),
        'buttonText': buttonText.trim(),
        'linkUrl': linkUrl.trim(),
        if (isActive != null) 'isActive': isActive,
      };

  Future<StoreBanner> create({required String title, String subtitle = '', String buttonText = '', String linkUrl = ''}) async =>
      StoreBanner.fromMap((await _api.post('/v1/banners', body: _body(title: title, subtitle: subtitle, buttonText: buttonText, linkUrl: linkUrl))).asMap);

  Future<StoreBanner> update(String id, {required String title, String subtitle = '', String buttonText = '', String linkUrl = ''}) async =>
      StoreBanner.fromMap((await _api.patch('/v1/banners/$id', body: _body(title: title, subtitle: subtitle, buttonText: buttonText, linkUrl: linkUrl))).asMap);

  Future<StoreBanner> setActive(String id, bool on) async => StoreBanner.fromMap((await _api.patch('/v1/banners/$id', body: <String, dynamic>{'isActive': on})).asMap);

  Future<void> delete(String id) async {
    await _api.delete('/v1/banners/$id');
  }

  /// Puts every banner in this order.
  Future<List<StoreBanner>> reorder(List<String> ids) async => _parse(await _api.post('/v1/banners/order', body: <String, dynamic>{'ids': ids}));
}
