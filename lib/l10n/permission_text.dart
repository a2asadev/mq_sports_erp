import 'package:a2_stocks/core/permissions.dart';
import 'package:a2_stocks/l10n/l10n.dart';

/// The name of a capability in the app's language (an unknown key shows as it is).
String permissionTitle(AppLocalizations l10n, String key) => switch (key) {
      Permissions.dashboardView => l10n.permissionDashboardView,
      Permissions.reportsView => l10n.permissionReportsView,
      Permissions.ordersCancel => l10n.permissionOrdersCancel,
      Permissions.returnsManage => l10n.permissionReturnsManage,
      Permissions.promotionsManage => l10n.permissionPromotionsManage,
      Permissions.customersManage => l10n.permissionCustomersManage,
      Permissions.catalogManage => l10n.permissionCatalogManage,
      Permissions.stockAudit => l10n.permissionStockAudit,
      Permissions.purchasingManage => l10n.permissionPurchasingManage,
      Permissions.expensesManage => l10n.permissionExpensesManage,
      _ => key,
    };

/// What the capability lets a person do, in one line.
String permissionHint(AppLocalizations l10n, String key) => switch (key) {
      Permissions.dashboardView => l10n.permissionDashboardViewHint,
      Permissions.reportsView => l10n.permissionReportsViewHint,
      Permissions.ordersCancel => l10n.permissionOrdersCancelHint,
      Permissions.returnsManage => l10n.permissionReturnsManageHint,
      Permissions.promotionsManage => l10n.permissionPromotionsManageHint,
      Permissions.customersManage => l10n.permissionCustomersManageHint,
      Permissions.catalogManage => l10n.permissionCatalogManageHint,
      Permissions.stockAudit => l10n.permissionStockAuditHint,
      Permissions.purchasingManage => l10n.permissionPurchasingManageHint,
      Permissions.expensesManage => l10n.permissionExpensesManageHint,
      _ => '',
    };
