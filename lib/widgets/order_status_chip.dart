import 'package:flutter/material.dart';
import 'package:mq_sports_erp/models/order_model.dart';

/// Colored pipeline label of an order (Pending ... Delivered, Cancelled).
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  static Color colorOf(BuildContext context, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade800;
      case OrderStatus.processing:
        return Colors.blue.shade700;
      case OrderStatus.shipped:
        return Colors.indigo.shade600;
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = colorOf(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
