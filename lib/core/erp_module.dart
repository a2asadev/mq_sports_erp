import 'package:flutter/widgets.dart';
import 'package:mq_sports_erp/models/user_role.dart';

/// Describes one ERP module shown in the navigation (side bar or drawer). Only
/// users whose role is in [allowedRoles] see the module. [group] is the
/// heading it is listed under.
class ErpModule {
  const ErpModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.allowedRoles,
    required this.builder,
    this.group = 'Main',
  });

  final String id;
  final String title;
  final IconData icon;
  final Set<UserRole> allowedRoles;
  final WidgetBuilder builder;
  final String group;
}
