import 'package:a2_stocks/models/register_day.dart';
import 'package:a2_stocks/online/api_client.dart';

/// The cash register (`/v1/register`): the day's cash and its closing. Needs a
/// connection, because the server works out what should be in the drawer from
/// everything it has been told (sales made offline count once they are uploaded).
class RegisterService {
  RegisterService(this._api);

  final ApiClient _api;

  /// One day; today when [date] ("YYYY-MM-DD") is null.
  Future<RegisterDay> day({String? date}) async {
    final ApiResponse response =
        await _api.get('/v1/register/day', query: date == null ? null : <String, String>{'date': date});
    return RegisterDay.fromMap(response.asMap);
  }

  /// Closes [date] with the cash that was counted; closing it again replaces the
  /// closing. [openingCash] is only sent when the person changed it.
  Future<RegisterDay> close({
    required String date,
    required double countedCash,
    double? openingCash,
    String note = '',
  }) async {
    final ApiResponse response = await _api.put('/v1/register/closings/$date', body: <String, dynamic>{
      'countedCash': _round2(countedCash),
      if (openingCash != null) 'openingCash': _round2(openingCash),
      if (note.trim().isNotEmpty) 'note': note.trim(),
    });
    return RegisterDay.fromMap(response.asMap);
  }

  /// Past closings, newest day first (admin and manager).
  Future<List<RegisterClosing>> closings({int limit = 60}) async {
    final ApiResponse response = await _api.get('/v1/register/closings', query: <String, String>{'limit': '$limit'});
    return <RegisterClosing>[
      for (final Object? item in response.asList)
        if (item is Map<String, dynamic>) RegisterClosing.fromMap(item),
    ];
  }

  static double _round2(double value) => (value * 100).roundToDouble() / 100;
}
