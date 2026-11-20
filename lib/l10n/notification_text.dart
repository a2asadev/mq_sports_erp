import 'package:flutter/material.dart';
import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/app_notification.dart';

/// A notification as the person reads it: a headline, a line under it, an icon.
class NotificationText {
  const NotificationText({required this.title, required this.detail, required this.icon});

  final String title;
  final String detail;
  final IconData icon;
}

/// Writes a notification in the language of the app from its type and values.
/// A type this version does not know still gets a plain line, so a newer server
/// never leaves an empty bell entry.
NotificationText notificationText(AppLocalizations l10n, AppNotification n) {
  switch (n.type) {
    case 'order.web_placed':
      return NotificationText(
        title: l10n.notificationNewOrder(n.text('orderNo')),
        detail: l10n.notificationNewOrderDetail(n.text('customerName'), formatMoney(n.number('total').toDouble())),
        icon: Icons.shopping_bag_outlined,
      );
    case 'stock.low':
      return NotificationText(
        title: l10n.notificationLowStock(_product(n)),
        detail: l10n.notificationLowStockDetail(n.number('onHand').toInt(), n.number('threshold').toInt()),
        icon: Icons.warning_amber_rounded,
      );
    case 'stock.out':
      return NotificationText(
        title: l10n.notificationOutOfStock(_product(n)),
        detail: l10n.notificationOutOfStockDetail(n.number('threshold').toInt()),
        icon: Icons.production_quantity_limits,
      );
    default:
      return NotificationText(title: l10n.notificationUnknown, detail: '', icon: Icons.notifications_none);
  }
}

/// "Cricket Bat · Small", or just the product when its variant has no name.
String _product(AppNotification n) {
  final String product = n.text('productName');
  final String variant = n.text('variantName');
  return variant.isEmpty ? product : '$product · $variant';
}
