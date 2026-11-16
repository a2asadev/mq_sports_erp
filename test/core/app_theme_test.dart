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
}
