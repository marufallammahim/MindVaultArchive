import 'package:material_ui/material_ui.dart';

/// Semantic, contrast-first palette shared by every MindVault screen.
class AppTheme {
  static const primary = Color(0xFFF7CB46);
  static const secondary = Color(0xFFC0F7FE);
  static const pink = Color(0xFFFE90E8);
  static const warmYellow = Color(0xFFFFDC8B);
  static const tertiary = Color(0xFF99E885);
  static const lightBackground = Color(0xFFFFFDF2);
  static const lightSurface = Color(0xFFFFFEFA);
  static const darkBackground = Color(0xFF171512);
  static const darkSurface = Color(0xFF24211C);
  static const darkCard = Color(0xFF302B24);
  static const ink = Color(0xFF000000);

  static ThemeData get lightTheme => lightThemeFor(primary);
  static ThemeData lightThemeFor(Color accent) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          surface: lightSurface,
        ).copyWith(
          primary: accent,
          onPrimary: ink,
          secondary: secondary,
          onSecondary: ink,
          tertiary: tertiary,
          onTertiary: ink,
          error: const Color(0xFFE64B3C),
          surface: lightSurface,
          onSurface: ink,
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFFFF5EC),
          surfaceContainer: const Color(0xFFF4E9E1),
          surfaceContainerHigh: const Color(0xFFEDE1D8),
          onSurfaceVariant: const Color(0xFF49443F),
          outline: ink,
          outlineVariant: const Color(0xFF000000),
        );
    return _build(scheme, lightBackground, dark: false);
  }

  static ThemeData get amoledTheme => amoledThemeFor(primary);
  static ThemeData amoledThemeFor(Color accent) =>
      darkThemeFor(accent, amoled: true);
  static ThemeData get darkTheme => darkThemeFor(primary);

  static ThemeData darkThemeFor(Color accent, {bool amoled = false}) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: darkSurface,
        ).copyWith(
          primary: accent,
          onPrimary: ink,
          secondary: secondary,
          onSecondary: ink,
          tertiary: tertiary,
          onTertiary: ink,
          surface: darkSurface,
          onSurface: const Color(0xFFF5F1EC),
          surfaceContainerLowest: const Color(0xFF101114),
          surfaceContainerLow: const Color(0xFF202329),
          surfaceContainer: const Color(0xFF272B31),
          surfaceContainerHigh: const Color(0xFF30353D),
          onSurfaceVariant: const Color(0xFFD0CBC4),
          outline: const Color(0xFFE7DFD3),
          outlineVariant: const Color(0xFFE7DFD3),
        );
    return _build(
      scheme,
      amoled ? const Color(0xFF000000) : darkBackground,
      dark: true,
    );
  }

  static ThemeData _build(
    ColorScheme scheme,
    Color background, {
    required bool dark,
  }) {
    final card = dark ? darkCard : lightSurface;
    final outline = scheme.outlineVariant;
    final borderInk = dark ? const Color(0xFFF5F1EC) : ink;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(7),
      side: BorderSide(color: borderInk, width: 2.5),
    );
    final text = dark ? scheme.onSurface : ink;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      visualDensity: VisualDensity.standard,
      fontFamily: 'Roboto',
      textTheme: Typography.material2021().black.apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? darkSurface : primary,
        foregroundColor: dark ? scheme.onSurface : ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 62,
        titleTextStyle: TextStyle(
          color: dark ? scheme.onSurface : ink,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.55,
        ),
        iconTheme: IconThemeData(
          color: dark ? scheme.onSurface : ink,
          size: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: shape,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        minVerticalPadding: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: borderInk, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: borderInk, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: borderInk, width: 3),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderInk, width: 2.5),
        ),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: card,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          side: BorderSide(color: borderInk, width: 2.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderInk, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: card,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderInk, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? darkSurface : lightSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.28),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: borderInk, width: 2.5),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(color: borderInk, width: 2),
          ),
          side: BorderSide(color: borderInk, width: 2),
        ),
      ),
      chipTheme:
          ChipThemeData.fromDefaults(
            primaryColor: scheme.primary,
            secondaryColor: card,
            labelStyle: TextStyle(color: scheme.onSurface),
          ).copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: borderInk, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(outline),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
