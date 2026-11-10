import 'package:flutter/material.dart';

/// Shared design system inspired by the supplied AMOLED notebook references.
class AppTheme {
  static const defaultBrand = Color(0xFF7A1735);
  static const brandLight = Color(0xFFB64D69);
  static const darkSurface = Color(0xFF101014);
  static const darkCard = Color(0xFF1B1A20);

  static ThemeData get lightTheme => lightThemeFor(defaultBrand);
  static ThemeData lightThemeFor(Color accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: const Color(0xFFF6F3F4),
    );
    return _build(scheme, const Color(0xFFF6F3F4));
  }

  static ThemeData get amoledTheme => amoledThemeFor(defaultBrand);
  static ThemeData amoledThemeFor(Color accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: Colors.black,
    );
    return _build(scheme, Colors.black, amoled: true);
  }

  static ThemeData get darkTheme => darkThemeFor(defaultBrand);
  static ThemeData darkThemeFor(Color accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: darkSurface,
    );
    return _build(scheme, darkSurface);
  }

  static ThemeData _build(
    ColorScheme scheme,
    Color background, {
    bool amoled = false,
  }) {
    final outline = scheme.outlineVariant.withValues(alpha: 0.48);
    final card = amoled ? const Color(0xFF171719) : scheme.surfaceContainerLow;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      visualDensity: VisualDensity.standard,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: amoled ? Colors.white.withValues(alpha: 0.055) : outline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const CircleBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ThemeData.dark().chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: outline),
      ),
    );
  }
}
