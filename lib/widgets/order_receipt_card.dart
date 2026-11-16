import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';
import 'package:mq_sports_erp/core/utils/formatters.dart';
import 'package:mq_sports_erp/models/order_model.dart';

/// An order drawn like a paper receipt: header with number, date and status,
/// a perforated tear line, the first few items, and a totals footer with the
/// payment state. Used by the Sales & Orders list.
class OrderReceiptCard extends StatelessWidget {
  const OrderReceiptCard({
    super.key,
    required this.order,
    required this.paid,
    required this.onTap,
  });

  final OrderModel order;

  /// What has been paid on the order so far.
  final double paid;
  final VoidCallback onTap;

  static const int _maxLines = 3;

  static Color statusColor(OrderStatus status) => switch (status) {
        OrderStatus.pending => AppColors.amber,
        OrderStatus.processing => AppColors.violet,
        OrderStatus.shipped => AppColors.sky,
        OrderStatus.delivered => AppColors.teal,
        OrderStatus.cancelled => AppColors.primary,
      };

  String get _channel => switch (order.channel) {
        'pos' => 'POS',
        'web' => 'Online store',
        _ => order.saleType.label,
      };

  @override
  Widget build(BuildContext context) {
    final bool cancelled = order.status == OrderStatus.cancelled;
    final double due = ((order.totalAmount - paid) * 100).round() / 100;
    final Color status = statusColor(order.status);
    final List<OrderItem> shown = order.items.take(_maxLines).toList();
    final int more = order.items.length - shown.length;

    final (String, Color) payment = cancelled
        ? ('Cancelled', AppColors.primary)
        : due <= 0.005
            ? ('Paid', AppColors.teal)
            : (paid > 0.005 ? ('Partly paid', AppColors.amber) : ('Unpaid', AppColors.primary));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Coloured edge that shows the status at a glance.
            Container(height: 4, color: status),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          order.orderNo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                      _Pill(text: order.status.label, color: status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDate(order.orderDate)} · $_channel',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.customerName.isEmpty ? 'Walk-in customer' : order.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const _TearLine(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final OrderItem item in shown)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${item.quantity} × ${item.productName}'
                                '${item.variantLabel.isEmpty ? '' : ' (${item.variantLabel})'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatMoney(item.lineTotal),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    if (more > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+ $more more item${more == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.sky, fontWeight: FontWeight.w600),
                        ),
                      ),
                    if (order.items.isEmpty)
                      const Text('No items', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
            const _TearLine(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Total', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          formatMoney(order.totalAmount),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                            decoration: cancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      _Pill(text: payment.$1, color: payment.$2),
                      if (!cancelled && due > 0.005)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            'Due ${formatMoney(due)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

/// The perforated line across a paper receipt: a dashed rule with a notch
/// bitten out of each side.
class _TearLine extends StatelessWidget {
  const _TearLine();

  static const double _notch = 18;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _notch,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) {
                  final int count = (box.maxWidth / 8).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.generate(
                      count,
                      (int i) => const SizedBox(width: 4, height: 1.2, child: ColoredBox(color: AppColors.border)),
                    ),
                  );
                },
              ),
            ),
          ),
          for (final bool left in const <bool>[true, false])
            Positioned(
              left: left ? -_notch / 2 : null,
              right: left ? null : -_notch / 2,
              top: 0,
              child: Container(
                width: _notch,
                height: _notch,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.border),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
