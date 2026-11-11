import 'package:flutter/material.dart';
import 'package:mq_sports_erp/models/purchase_model.dart';

/// Colored Paid / Partial / Pending label.
class PurchaseStatusChip extends StatelessWidget {
  const PurchaseStatusChip({super.key, required this.status});

  final PurchaseStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (status) {
      case PurchaseStatus.paid:
        color = Colors.green.shade700;
      case PurchaseStatus.partial:
        color = Colors.orange.shade800;
      case PurchaseStatus.pending:
        color = Theme.of(context).colorScheme.error;
    }
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
