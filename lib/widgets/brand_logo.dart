import 'package:flutter/material.dart';
import 'package:a2_stocks/core/theme/app_theme.dart';

/// The A2 Stocks logo. The full logo (assets/images/a2stocks_logo.png) has the
/// name and tagline under the "A"; with [markOnly] it is just the "A" with its
/// bars (a2stocks_mark.png), for small places where the lettering would be too
/// small to read.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 40, this.markOnly = false});

  final double height;
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      markOnly ? 'assets/images/a2stocks_mark.png' : 'assets/images/a2stocks_logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'A2 Stocks',
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          Text('A2 STOCKS', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// The mark followed by the name in text, for headers (side bar, counter screen).
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markHeight = 34});

  final double markHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BrandLogo(height: markHeight, markOnly: true),
        SizedBox(width: markHeight * 0.3),
        Text(
          'A2 Stocks',
          style: TextStyle(
            fontSize: markHeight * 0.52,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
