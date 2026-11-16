import 'package:flutter/material.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';

/// One figure shown above a list: a big value, a label and a tinted icon.
class StatItem {
  const StatItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.caption = '',
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  /// Small line under the label (optional).
  final String caption;
}

/// A row of summary cards for the top of a list page. Two per row on a phone,
/// up to one row of all of them on a wide screen.
class StatStrip extends StatelessWidget {
  const StatStrip({super.key, required this.items});

  final List<StatItem> items;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final int perRow = (box.maxWidth / 210).floor().clamp(1, items.length).toInt();
          final double width = (box.maxWidth - _gap * (perRow - 1)) / perRow;
          return Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: <Widget>[
              for (final StatItem item in items) SizedBox(width: width, child: _StatCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.value,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                  ),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  if (item.caption.isNotEmpty)
                    Text(
                      item.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: item.color, fontWeight: FontWeight.w600),
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
