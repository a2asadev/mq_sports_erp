import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';
import 'package:a2_stocks/l10n/l10n.dart';
import 'package:a2_stocks/models/business_info.dart';
import 'package:a2_stocks/providers/business_provider.dart';
import 'package:a2_stocks/widgets/brand_logo.dart';

/// The signed-in business's logo; the A2 Stocks mark while it has none (or the
/// picture cannot be loaded, for example offline).
class BusinessLogo extends ConsumerWidget {
  const BusinessLogo({super.key, this.height = 34});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BusinessInfo business = ref.watch(businessProvider);
    final Widget fallback = BrandLogo(height: height, markOnly: true);
    if (business.logoUrl.isEmpty) {
      return fallback;
    }
    return Image.network(
      business.logoUrl,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: business.name,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) => fallback,
    );
  }
}

/// The business's logo followed by its name, for headers.
class BusinessLockup extends ConsumerWidget {
  const BusinessLockup({super.key, this.markHeight = 34, this.showName = true});

  final double markHeight;
  final bool showName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BusinessInfo business = ref.watch(businessProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BusinessLogo(height: markHeight),
        if (showName) ...<Widget>[
          SizedBox(width: markHeight * 0.3),
          Flexible(
            child: Text(
              business.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: markHeight * 0.48,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Powered by A2 Stocks · Crafted with love by A2 Devs": the product's own
/// credit, shown at the foot of the app whatever business is using it.
class PoweredByFooter extends StatelessWidget {
  const PoweredByFooter({super.key});

  static const String productName = 'A2 Stocks';
  static const String makerName = 'A2 Devs';

  @override
  Widget build(BuildContext context) {
    const TextStyle plain = TextStyle(fontSize: 11.5, color: AppColors.textMuted);
    final TextStyle strong = plain.copyWith(fontWeight: FontWeight.w700, color: AppColors.a2Primary);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 2,
        children: <Widget>[
          Text(context.l10n.businessBrandPoweredBy, style: plain),
          Text(productName, style: strong),
          const Text('·', style: plain),
          const Icon(Icons.favorite, size: 12, color: Color(0xFFE0566A)),
          Text(context.l10n.businessBrandCraftedWithLoveBy, style: plain),
          Text(makerName, style: strong),
        ],
      ),
    );
  }
}
