import 'package:a2_stocks/core/utils/formatters.dart';
import 'package:a2_stocks/core/utils/tax_text.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/promotion.dart';

/// A promotion in one sentence: what it takes off, from what, and from when it applies.
/// "10% off Cricket · from 5 units", "Rs 100 off the order · orders of Rs 1,000 or more".
String promotionRuleText(AppLocalizations l10n, Promotion p) {
  final String percent = formatRate(p.value);
  final String amount = formatMoney(p.value);
  final String target = p.targetName.isEmpty ? '?' : p.targetName;
  final String main;
  switch (p.scope) {
    case PromotionScope.order:
      main = p.kind == PromotionKind.percent ? l10n.promoDescOrderPercent(percent) : l10n.promoDescOrderAmount(amount);
    case PromotionScope.category:
    case PromotionScope.product:
      main = p.kind == PromotionKind.percent ? l10n.promoDescLinePercent(percent, target) : l10n.promoDescLineAmount(amount, target);
  }
  final List<String> parts = <String>[
    main,
    if (p.scope != PromotionScope.order && p.minQuantity > 1) l10n.promoDescMinQuantity(p.minQuantity),
    if (p.scope == PromotionScope.order && p.minAmount > 0) l10n.promoDescMinAmount(formatMoney(p.minAmount)),
  ];
  return parts.join(' · ');
}

enum PromotionState { off, scheduled, ended, on }

/// Whether a promotion is working today: [PromotionState.on]; or it is switched off, has not started or has ended.
PromotionState promotionState(Promotion p, String today) {
  if (!p.isActive) {
    return PromotionState.off;
  }
  if (p.startsOn != null && p.startsOn!.compareTo(today) > 0) {
    return PromotionState.scheduled;
  }
  if (p.endsOn != null && p.endsOn!.compareTo(today) < 0) {
    return PromotionState.ended;
  }
  return PromotionState.on;
}
