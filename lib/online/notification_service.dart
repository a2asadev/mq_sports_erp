import 'package:a2_stocks/models/app_notification.dart';
import 'package:a2_stocks/online/api_client.dart';

/// The bell's data: the notifications the server made for this person's role.
/// Needs a connection (like the activity logs); a device that was offline sees
/// what it missed as soon as it is online again.
class NotificationService {
  NotificationService(this._api);

  final ApiClient _api;

  Future<NotificationList> list({int limit = 50}) async {
    final ApiResponse response = await _api.get('/v1/notifications', query: <String, String>{'limit': '$limit'});
    return NotificationList.fromMap(response.asMap);
  }

  /// Everything up to now counts as read for this person.
  Future<NotificationList> markAllRead() async {
    final ApiResponse response = await _api.post('/v1/notifications/read');
    return NotificationList.fromMap(response.asMap);
  }
}
