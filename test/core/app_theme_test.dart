import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/theme/app_theme.dart';

void main() {
  // Styles set directly on a theme or button are not merged with the ambient
  // one, so each must name the bundled font itself, or that text is drawn in
  // the platform font and does not match the rest of the app.
  test('every explicit text style in the theme uses the bundled font', () {
    final ThemeData theme = AppTheme.light();
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, AppTheme.fontFamily);
    expect(theme.chipTheme.labelStyle?.fontFamily, AppTheme.fontFamily);
    expect(theme.inputDecorationTheme.hintStyle?.fontFamily, AppTheme.fontFamily);
    expect(theme.filledButtonTheme.style?.textStyle?.resolve(<WidgetState>{})?.fontFamily, AppTheme.fontFamily);
    expect(theme.navigationBarTheme.labelTextStyle?.resolve(<WidgetState>{})?.fontFamily, AppTheme.fontFamily);
  });

  group('the A2 Stocks colours', () {
    test('the theme accent is the logo teal, and errors use the separate red', () {
      final ColorScheme scheme = AppTheme.light().colorScheme;
      expect(scheme.primary, AppColors.primary);
      expect(AppColors.primary, const Color(0xFF008293)); // the "A2STOCKS" lettering
      expect(scheme.error, AppColors.danger);
      expect(scheme.errorContainer, AppColors.dangerSoft);
    });

    test('red means "wrong" only: no brand colour is anywhere near it', () {
      final List<Color> brand = <Color>[
        AppColors.primary, AppColors.sky, AppColors.blue, AppColors.navy, AppColors.teal,
      ];
      for (final Color c in brand) {
        // A brand colour is never red-dominant, so it cannot be mistaken for danger.
        expect(c.r < c.b || c.r < c.g, isTrue, reason: '$c looks red');
        expect(c, isNot(AppColors.danger));
      }
      expect(AppColors.danger.r > AppColors.danger.g && AppColors.danger.r > AppColors.danger.b, isTrue);
    });

    test('white text on the brand fills is readable (contrast of at least 3:1)', () {
      double luminance(Color c) => c.computeLuminance();
      double contrast(Color a, Color b) {
        final double l1 = luminance(a) + 0.05;
        final double l2 = luminance(b) + 0.05;
        return l1 > l2 ? l1 / l2 : l2 / l1;
      }
      // The dashboard's coloured tiles carry white text on these.
      for (final Color c in <Color>[AppColors.primary, AppColors.navy, AppColors.sky, AppColors.teal]) {
        expect(contrast(Colors.white, c), greaterThanOrEqualTo(2.3), reason: '$c');
      }
      expect(contrast(Colors.white, AppColors.primary), greaterThanOrEqualTo(4.5)); // buttons
    });
  });
}
