import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/time_ago.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/l10n/notification_text.dart';
import 'package:a2_stocks/models/app_notification.dart';
import 'package:a2_stocks/providers/notification_providers.dart';
import 'package:a2_stocks/screens/sales/order_detail_screen.dart';
import 'package:a2_stocks/screens/stock/stock_screen.dart';

/// Opens the thing a notification is about: the order, or the stock that ran low.
void openNotification(NavigatorState navigator, AppNotification n) {
  switch (n.entityType) {
    case 'order':
      navigator.push(MaterialPageRoute<void>(builder: (BuildContext context) => OrderDetailScreen(orderId: n.entityId)));
    case 'variant':
      navigator.push(MaterialPageRoute<void>(builder: (BuildContext context) => const StockScreen(showLowStockOnly: true)));
  }
}

/// The bell in the header: the number of unread notifications, and a list that opens on tap.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final NavigatorState navigator = Navigator.of(context);
    final NotificationsNotifier notifier = ref.read(notificationsProvider.notifier);
    // Look at the latest when opening, whatever the timer says.
    unawaited(notifier.refresh());
    final bool narrow = MediaQuery.sizeOf(context).width < 600;
    void open(AppNotification n) {
      Navigator.of(context).pop();
      openNotification(navigator, n);
    }

    if (narrow) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext sheet) => SizedBox(
          height: MediaQuery.sizeOf(sheet).height * 0.75,
          child: NotificationsPanel(onOpen: open),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext dialog) => Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.sizeOf(dialog).height * 0.7),
            child: NotificationsPanel(onOpen: open),
          ),
        ),
      );
    }
    // Looking at them is reading them.
    await notifier.markAllRead();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int unread = ref.watch(notificationsProvider.select((NotificationsState s) => s.unread));
    return IconButton(
      tooltip: context.l10n.notificationsTitle,
      onPressed: () => _open(context, ref),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}

/// The list itself: newest first, unread ones marked, tap to open what it is about.
class NotificationsPanel extends ConsumerWidget {
  const NotificationsPanel({super.key, required this.onOpen});

  final void Function(AppNotification notification) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificationsState state = ref.watch(notificationsProvider);
    final AppLocalizations l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(l10n.notificationsTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (state.unread > 0)
                TextButton(
                  onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
                  child: Text(l10n.notificationsMarkAllRead),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(child: _body(context, ref, state)),
      ],
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, NotificationsState state) {
    final AppLocalizations l10n = context.l10n;
    if (!state.loaded && state.failed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.notificationsLoadError, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => ref.read(notificationsProvider.notifier).refresh(), child: Text(l10n.notificationsRetry)),
          ],
        ),
      );
    }
    if (!state.loaded) {
      return const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
    }
    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.notificationsEmpty, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.items.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final AppNotification n = state.items[index];
        final NotificationText text = notificationText(l10n, n);
        final bool isNew = index < state.unread;
        return ListTile(
          onTap: () => onOpen(n),
          tileColor: isNew ? AppColors.primarySoft : null,
          leading: CircleAvatar(
            backgroundColor: isNew ? AppColors.primary : AppColors.border,
            foregroundColor: isNew ? Colors.white : AppColors.textMuted,
            child: Icon(text.icon, size: 20),
          ),
          title: Text(text.title, style: TextStyle(fontWeight: isNew ? FontWeight.w700 : FontWeight.w500)),
          subtitle: Text(<String>[if (text.detail.isNotEmpty) text.detail, timeAgo(l10n, n.createdAt)].join(' · ')),
        );
      },
    );
  }
}
