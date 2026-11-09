import 'package:flutter/widgets.dart';
import 'package:mq_sports_erp/models/user_role.dart';

/// Describes one ERP module shown on the home screen. Only users whose role
/// is in [allowedRoles] see the module.
class ErpModule {
  const ErpModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.allowedRoles,
    required this.builder,
  });

  final String id;
  final String title;
  final IconData icon;
  final Set<UserRole> allowedRoles;
  final WidgetBuilder builder;
}
