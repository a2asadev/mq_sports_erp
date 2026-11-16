import 'package:flutter/material.dart';

/// The MQ Sports logo (assets/images/mq_logo.png).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mq_logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'MQ Sports',
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          Text('MQ SPORTS', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
