import 'package:a2_stocks/online/api_client.dart';

/// One capability the admin can allow or refuse (`GET /v1/permissions`).
class PermissionInfo {
  const PermissionInfo({required this.key, required this.group, required this.managerDefault, required this.staffDefault});

  final String key;
  final String group;
  final bool managerDefault;
  final bool staffDefault;
}

/// What managers and staff may do now, and what the product gives them before any change.
class PermissionMatrix {
  const PermissionMatrix({required this.permissions, required this.manager, required this.staff});

  final List<PermissionInfo> permissions;
  final Map<String, bool> manager;
  final Map<String, bool> staff;

  bool allowed(String role, String key) => (role == 'manager' ? manager : staff)[key] ?? false;

  bool isDefault(String role, PermissionInfo info) => allowed(role, info.key) == (role == 'manager' ? info.managerDefault : info.staffDefault);

  factory PermissionMatrix.fromMap(Map<String, dynamic> m) {
    Map<String, bool> flags(Object? raw) => <String, bool>{
          if (raw is Map<String, dynamic>)
            for (final MapEntry<String, dynamic> e in raw.entries) e.key: e.value == true,
        };
    final Object? roles = m['roles'];
    final Map<String, dynamic> byRole = roles is Map<String, dynamic> ? roles : <String, dynamic>{};
    return PermissionMatrix(
      permissions: <PermissionInfo>[
        for (final Object? p in (m['permissions'] as List<Object?>? ?? <Object?>[]))
          if (p is Map<String, dynamic>)
            PermissionInfo(
              key: '${p['key']}',
              group: '${p['group']}',
              managerDefault: (p['defaults'] as Map<String, dynamic>?)?['manager'] == true,
              staffDefault: (p['defaults'] as Map<String, dynamic>?)?['staff'] == true,
            ),
      ],
      manager: flags(byRole['manager']),
      staff: flags(byRole['staff']),
    );
  }
}

/// What managers and staff may do (`/v1/permissions`, admin only, needs a connection).
class PermissionsService {
  PermissionsService(this._api);

  final ApiClient _api;

  Future<PermissionMatrix> get() async => PermissionMatrix.fromMap((await _api.get('/v1/permissions')).asMap);

  Future<PermissionMatrix> set(String role, String permission, bool allowed) async =>
      PermissionMatrix.fromMap((await _api.put('/v1/permissions', body: <String, dynamic>{'role': role, 'permission': permission, 'allowed': allowed})).asMap);
}
