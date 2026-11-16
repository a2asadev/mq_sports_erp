import 'package:flutter/material.dart';

/// Brand colours taken from the A2 Stocks logo: the teal of the lettering, the
/// emerald green and bright blue of the gradient "A", the steel and dark blue of
/// the bars. The accent (`primary`) can be replaced per business; the other
/// colours are the same for everyone. Red is kept apart as `danger`: it only ever means something is
/// wrong (cancelled, unpaid, out of stock, delete).
class AppColors {
  const AppColors._();

  /// The teal of the "A2STOCKS" lettering: the default accent.
  static const Color a2Primary = Color(0xFF008293);
  static const Color _a2PrimaryDark = Color(0xFF00697A);
  static const Color _a2PrimarySoft = Color(0xFFE0F1F4);

  static Color _primary = a2Primary;
  static Color _primaryDark = _a2PrimaryDark;
  static Color _primarySoft = _a2PrimarySoft;

  /// The accent of the business using the app: buttons, selection, charts. It is
  /// the A2 Stocks teal until the business picks its own colour (see [useBrand]).
  /// Not a constant, because it changes with the business.
  static Color get primary => _primary;
  static Color get primaryDark => _primaryDark;
  static Color get primarySoft => _primarySoft;

  /// Switches the accent to a business's own colour, or back to the A2 Stocks
  /// teal with null. A colour too light for white text is darkened until it is
  /// readable; the darker and softer shades are derived from it.
  static void useBrand(Color? brand) {
    if (brand == null) {
      _primary = a2Primary;
      _primaryDark = _a2PrimaryDark;
      _primarySoft = _a2PrimarySoft;
      return;
    }
    final Color readable = readableOnWhite(brand);
    _primary = readable;
    _primaryDark = _shade(readable, -0.12);
    _primarySoft = Color.alphaBlend(readable.withValues(alpha: 0.12), surface);
  }

  /// [color], darkened until white text on it has a contrast of at least 4.5:1.
  static Color readableOnWhite(Color color) {
    Color c = color;
    for (int i = 0; i < 20 && _contrastWithWhite(c) < 4.5; i++) {
      c = _shade(c, -0.03);
    }
    return c;
  }

  static double _contrastWithWhite(Color c) => 1.05 / (c.computeLuminance() + 0.05);

  static Color _shade(Color c, double lightnessChange) {
    final HSLColor hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + lightnessChange).clamp(0.0, 1.0)).toColor();
  }

  /// Reads "#RRGGBB" (the server's form); null when it is not one.
  static Color? tryParseHex(String? hex) {
    if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
      return null;
    }
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }

  /// The colour as "#RRGGBB".
  static String toHex(Color color) {
    final int rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// The steel blue of the bars and arrow.
  static const Color sky = Color(0xFF2D8BBA);
  static const Color skySoft = Color(0xFFE2EFF6);

  /// The bright blue at the foot of the logo's "A".
  static const Color blue = Color(0xFF3B82F6);

  /// The dark blue bar: strong surfaces, tooltips, headings.
  static const Color navy = Color(0xFF2F5F98);

  /// The emerald green at the top of the logo's "A": success, growth, "new".
  static const Color teal = Color(0xFF10B981);
  static const Color tealSoft = Color(0xFFDDF5EC);

  /// Something is wrong or removed. Not a brand colour.
  static const Color danger = Color(0xFFC4414E);
  static const Color dangerSoft = Color(0xFFF4E6E8);

  static const Color amber = Color(0xFFC08A3E);
  static const Color amberSoft = Color(0xFFF3EADB);
  static const Color violet = Color(0xFF6E649F);

  static const Color background = Color(0xFFEFF2F4);
  static const Color surface = Color(0xFFFAFBFB);
  static const Color border = Color(0xFFDADFE3);
  static const Color mutedFill = Color(0xFFE7EBEE);
  static const Color text = Color(0xFF263238);
  static const Color textMuted = Color(0xFF62707A);

  /// The logo's green-to-blue sweep, for the few places that want a flourish.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[teal, blue],
  );
}

/// The single light theme of the app (mobile, desktop and web).
class AppTheme {
  const AppTheme._();

  static const double radius = 10;

  /// The bundled font. Styles set directly on a theme or button (not merged
  /// with the ambient one) must name it, or they fall back to the platform font.
  static const String fontFamily = 'Inter';

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.sky,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.skySoft,
      onSecondaryContainer: AppColors.navy,
      tertiary: AppColors.navy,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.mutedFill,
      surfaceContainerHigh: AppColors.mutedFill,
      surfaceContainerHighest: AppColors.mutedFill,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.compact,
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: AppColors.border)),
        titleTextStyle: TextStyle(fontFamily: fontFamily, color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: scheme.error, width: 1.4)),
        hintStyle: const TextStyle(fontFamily: fontFamily, color: AppColors.textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(fontFamily: fontFamily, color: AppColors.text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        showCheckmark: false,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}
