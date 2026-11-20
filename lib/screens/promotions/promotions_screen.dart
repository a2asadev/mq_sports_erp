import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/core/utils/error_text.dart';
import 'package:a2_stocks/core/utils/promotion_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/promotion.dart';
import 'package:a2_stocks/providers/promotion_providers.dart';
import 'package:a2_stocks/screens/promotions/promotion_form_screen.dart';

/// Promotions: percent or amount offers on the whole order, a category or a product, with bulk tiers (a minimum
/// number of units), optional coupon codes and dates. They apply at the counter by themselves (a coupon when its code
/// is entered). Admin and manager; needs a connection (the counter keeps a copy of the open ones for offline sales).
class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {Promotion? promotion}) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (BuildContext context) => PromotionFormScreen(promotion: promotion)),
    );
    if (saved == true) {
      ref.invalidate(adminPromotionsProvider);
      ref.invalidate(activePromotionsProvider);
    }
  }

  Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(adminPromotionsProvider);
      ref.invalidate(activePromotionsProvider);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessageOf(error))));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Promotion p) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text(context.l10n.promoDeleteConfirm(p.name)),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.expensesCancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.categoriesDelete)),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      await _run(context, ref, () => ref.read(promotionsServiceProvider).delete(p.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Promotion>> list = ref.watch(adminPromotionsProvider);
    final String today = todayKey();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.modulePromotions),
        actions: <Widget>[IconButton(tooltip: context.l10n.registerRefresh, icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(adminPromotionsProvider))],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(context, ref), icon: const Icon(Icons.add), label: Text(context.l10n.promoNew)),
      body: list.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(errorMessageOf(error), textAlign: TextAlign.center))),
        data: (List<Promotion> items) => items.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(context.l10n.promoNone, textAlign: TextAlign.center)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: <Widget>[for (final Promotion p in items) _card(context, ref, p, today)],
              ),
      ),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, Promotion p, String today) {
    final PromotionState state = promotionState(p, today);
    final Color color = state == PromotionState.on ? AppColors.teal : (state == PromotionState.scheduled ? AppColors.sky : AppColors.textMuted);
    final String status = switch (state) {
      PromotionState.on => context.l10n.promoStatusOn,
      PromotionState.off => context.l10n.promoStatusOff,
      PromotionState.scheduled => context.l10n.promoStatusScheduled(p.startsOn ?? ''),
      PromotionState.ended => context.l10n.promoStatusEnded,
    };
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () => _edit(context, ref, promotion: p),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                          child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(promotionRuleText(context.l10n, p)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        if (p.isCoupon) _tag(Icons.confirmation_number_outlined, context.l10n.promoCodeTag(p.code)),
                        if (p.channels.contains('pos')) _tag(Icons.point_of_sale, context.l10n.promoChannelPos),
                        if (p.channels.contains('web')) _tag(Icons.storefront_outlined, context.l10n.promoChannelWeb),
                        if (p.startsOn != null || p.endsOn != null) _tag(Icons.event_outlined, '${p.startsOn ?? '…'} – ${p.endsOn ?? '…'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Switch(value: p.isActive, onChanged: (bool on) => _run(context, ref, () => ref.read(promotionsServiceProvider).setActive(p.id, on))),
                IconButton(tooltip: context.l10n.categoriesDelete, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, p)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.mutedFill, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, size: 13, color: AppColors.textMuted), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12))]),
      );
}
