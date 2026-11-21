import 'package:flutter/widgets.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/user_role.dart';

/// The headings the modules are listed under in the navigation, in the order they appear.
enum ModuleGroup {
  main,
  inventory,
  sales,
  purchasing,
  system;

  /// The heading in the language of the app.
  String label(AppLocalizations l10n) {
    switch (this) {
      case ModuleGroup.main:
        return l10n.moduleGroupMain;
      case ModuleGroup.inventory:
        return l10n.moduleGroupInventory;
      case ModuleGroup.sales:
        return l10n.moduleGroupSales;
      case ModuleGroup.purchasing:
        return l10n.moduleGroupPurchasing;
      case ModuleGroup.system:
        return l10n.moduleGroupSystem;
    }
  }
}

/// Describes one ERP module shown in the navigation (side bar or drawer). Only
/// users whose role is in [allowedRoles] see the module. [group] is the
/// heading it is listed under; [title] gives its name in the app's language.
class ErpModule {
  const ErpModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.allowedRoles,
    required this.builder,
    this.group = ModuleGroup.main,
    this.needsRegister = false,
    this.needsOnlineStore = false,
    this.permission,
  });

  final String id;
  final String Function(AppLocalizations l10n) title;
  final IconData icon;
  final Set<UserRole> allowedRoles;
  final WidgetBuilder builder;
  final ModuleGroup group;

  /// Listed only for a business that keeps a cash register (see `BusinessInfo.usesRegister`).
  final bool needsRegister;

  /// Listed only for the business that runs the public online store (see `BusinessInfo.hasOnlineStore`).

  /// When set, the module is listed for whoever holds this permission (see `Permissions`), instead of by role.
  final String? permission;
  final bool needsOnlineStore;
}
