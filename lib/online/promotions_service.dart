import 'package:a2_stocks/models/promotion.dart';
import 'package:a2_stocks/online/api_client.dart';

/// What the form sends for a promotion (create or change).
class PromotionDraft {
  const PromotionDraft({
    required this.name,
    required this.kind,
    required this.value,
    required this.scope,
    this.targetId,
    this.minQuantity = 1,
    this.minAmount = 0,
    this.code = '',
    this.channels = const <String>['pos', 'web'],
    this.startsOn,
    this.endsOn,
    this.isActive = true,
  });

  final String name;
  final PromotionKind kind;
  final double value;
  final PromotionScope scope;
  final String? targetId;
  final int minQuantity;
  final double minAmount;
  final String code;
  final List<String> channels;
  final String? startsOn;
  final String? endsOn;
  final bool isActive;

  Map<String, dynamic> toBody({bool forUpdate = false}) => <String, dynamic>{
        'name': name.trim(),
        'kind': kind.name,
        'value': (value * 100).roundToDouble() / 100,
        'scope': scope.name,
        if (scope != PromotionScope.order && targetId != null) 'targetId': targetId,
        if (scope != PromotionScope.order) 'minQuantity': minQuantity,
        if (scope == PromotionScope.order) 'minAmount': (minAmount * 100).roundToDouble() / 100,
        'code': code.trim(),
        'channels': channels,
        // An update sends '' to remove a date; a new promotion just leaves it out.
        if (startsOn != null) 'startsOn': startsOn else if (forUpdate) 'startsOn': '',
        if (endsOn != null) 'endsOn': endsOn else if (forUpdate) 'endsOn': '',
        'isActive': isActive,
      };
}

/// Promotions (`/v1/promotions`). Admin and manager keep the list; everybody signed in reads the open ones, which
/// the counter keeps a copy of so it can apply them without a connection.
class PromotionsService {
  PromotionsService(this._api);

  final ApiClient _api;

  List<Promotion> _parse(ApiResponse r) => <Promotion>[
        for (final Object? i in r.asList)
          if (i is Map<String, dynamic>) Promotion.fromMap(i),
      ];

  /// Every promotion (admin, manager).
  Future<List<Promotion>> list() async => _parse(await _api.get('/v1/promotions'));

  /// The promotions that are on and open today.
  Future<List<Promotion>> active() async => _parse(await _api.get('/v1/promotions/active'));

  Future<Promotion> create(PromotionDraft draft) async => Promotion.fromMap((await _api.post('/v1/promotions', body: draft.toBody())).asMap);

  Future<Promotion> update(String id, PromotionDraft draft) async =>
      Promotion.fromMap((await _api.patch('/v1/promotions/$id', body: draft.toBody(forUpdate: true))).asMap);

  Future<Promotion> setActive(String id, bool on) async =>
      Promotion.fromMap((await _api.patch('/v1/promotions/$id', body: <String, dynamic>{'isActive': on})).asMap);

  Future<void> delete(String id) async {
    await _api.delete('/v1/promotions/$id');
  }
}
