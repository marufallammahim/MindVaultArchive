import 'package:material_ui/material_ui.dart';

enum AppThemePreset {
  light,
  dark,
  amoled,
  monochromeOled;

  String get label => switch (this) {
    light => 'Light',
    dark => 'Dark',
    amoled => 'AMOLED',
    monochromeOled => 'Monochrome OLED',
  };

  String get description => switch (this) {
    light => 'Warm cream surfaces and dark text.',
    dark => 'Warm dark surfaces with readable foregrounds.',
    amoled => 'Pure-black canvas with dark OLED-friendly cards.',
    monochromeOled => 'Grayscale interface on a pure-black OLED canvas.',
  };

  Brightness get brightness =>
      this == AppThemePreset.light ? Brightness.light : Brightness.dark;

  bool get isMonochrome => this == AppThemePreset.monochromeOled;
}

/// Semantic, contrast-first palette shared by every MindVault screen.
class AppTheme {
  static const primary = Color(0xFFF7CB46);
  static const secondary = Color(0xFFC0F7FE);
  static const pink = Color(0xFFE9E0E8);
  static const warmYellow = Color(0xFFFFDC8B);
  static const tertiary = Color(0xFF99E885);
  static const lightBackground = Color(0xFFFCEFE8);
  static const lightSurface = Color(0xFFFFFEFA);
  static const darkBackground = Color(0xFF171512);
  static const darkSurface = Color(0xFF24211C);
  static const darkCard = Color(0xFF302B24);
  static const ink = Color(0xFF000000);
  static const oledBlack = Color(0xFF000000);
  static const monochromeCard = Color(0xFF171717);
  static const monochromeOutline = Color(0xFFBDBDBD);

  static const monochromeColorFilter = ColorFilter.matrix([
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  static ThemeData themeFor(AppThemePreset preset, Color accent) =>
      switch (preset) {
        AppThemePreset.light => lightThemeFor(accent),
        AppThemePreset.dark => darkThemeFor(accent),
        AppThemePreset.amoled => amoledThemeFor(accent),
        AppThemePreset.monochromeOled => monochromeOledTheme,
      };

  static ThemeData get lightTheme => lightThemeFor(primary);

  static ThemeData lightThemeFor(Color accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: lightSurface,
    ).copyWith(
      primary: accent,
      onPrimary: _contrastForeground(accent),
      primaryContainer: const Color(0xFFFFE8A6),
      onPrimaryContainer: ink,
      secondary: secondary,
      onSecondary: ink,
      secondaryContainer: const Color(0xFFE4F9FC),
      onSecondaryContainer: ink,
      tertiary: tertiary,
      onTertiary: ink,
      tertiaryContainer: const Color(0xFFE9F8E3),
      onTertiaryContainer: ink,
      error: const Color(0xFFB3261E),
      onError: const Color(0xFFFFFFFF),
      surface: lightSurface,
      onSurface: ink,
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFFF5EC),
      surfaceContainer: const Color(0xFFF4E9E1),
      surfaceContainerHigh: const Color(0xFFEDE1D8),
      surfaceContainerHighest: const Color(0xFFE4D8CF),
      onSurfaceVariant: const Color(0xFF49443F),
      outline: const Color(0xFF51463F),
      outlineVariant: ink,
    );
    return _build(
      scheme,
      lightBackground,
      dark: false,
      cardColor: lightSurface,
    );
  }

  static ThemeData get amoledTheme => amoledThemeFor(primary);

  static ThemeData amoledThemeFor(Color accent) =>
      darkThemeFor(accent, amoled: true);

  static ThemeData get darkTheme => darkThemeFor(primary);

  static ThemeData darkThemeFor(Color accent, {bool amoled = false}) {
    final surface = amoled ? oledBlack : darkSurface;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: surface,
    ).copyWith(
      primary: accent,
      onPrimary: _contrastForeground(accent),
      primaryContainer: const Color(0xFF5A4717),
      onPrimaryContainer: const Color(0xFFFFF1C7),
      secondary: secondary,
      onSecondary: ink,
      secondaryContainer: const Color(0xFF21464B),
      onSecondaryContainer: const Color(0xFFD9FAFF),
      tertiary: tertiary,
      onTertiary: ink,
      tertiaryContainer: const Color(0xFF294B24),
      onTertiaryContainer: const Color(0xFFE2FFDA),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      surface: surface,
      onSurface: const Color(0xFFF5F1EC),
      surfaceContainerLowest: amoled
          ? oledBlack
          : const Color(0xFF151310),
      surfaceContainerLow: amoled
          ? const Color(0xFF0B0B0B)
          : const Color(0xFF201D19),
      surfaceContainer: amoled
          ? const Color(0xFF141414)
          : const Color(0xFF28241F),
      surfaceContainerHigh: amoled
          ? const Color(0xFF1E1E1E)
          : const Color(0xFF302B24),
      surfaceContainerHighest: amoled
          ? const Color(0xFF262626)
          : const Color(0xFF39332B),
      onSurfaceVariant: const Color(0xFFD0CBC4),
      outline: const Color(0xFFC8BFB2),
      outlineVariant: const Color(0xFFE7DFD3),
    );
    return _build(
      scheme,
      amoled ? oledBlack : darkBackground,
      dark: true,
      cardColor: amoled ? monochromeCard : darkCard,
    );
  }

  static ThemeData get monochromeOledTheme {
    const black = Color(0xFF000000);
    const white = Color(0xFFF2F2F2);
    const mid = Color(0xFFBDBDBD);
    const scheme = ColorScheme.dark(
      primary: white,
      onPrimary: black,
      primaryContainer: Color(0xFF292929),
      onPrimaryContainer: white,
      secondary: mid,
      onSecondary: black,
      secondaryContainer: Color(0xFF292929),
      onSecondaryContainer: Color(0xFFE8E8E8),
      tertiary: Color(0xFFD8D8D8),
      onTertiary: black,
      tertiaryContainer: Color(0xFF343434),
      onTertiaryContainer: white,
      error: Color(0xFFE0E0E0),
      onError: black,
      surface: black,
      onSurface: white,
      surfaceContainerLowest: black,
      surfaceContainerLow: Color(0xFF0D0D0D),
      surfaceContainer: Color(0xFF171717),
      surfaceContainerHigh: Color(0xFF242424),
      surfaceContainerHighest: Color(0xFF303030),
      onSurfaceVariant: mid,
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFBDBDBD),
      inverseSurface: white,
      onInverseSurface: black,
      inversePrimary: Color(0xFF8C8C8C),
      shadow: black,
      scrim: black,
      surfaceTint: white,
    );
    return _build(
      scheme,
      black,
      dark: true,
      cardColor: monochromeCard,
      borderColor: monochromeOutline,
    );
  }

  static Color _contrastForeground(Color background) {
    final luminance = background.computeLuminance();
    final blackContrast = (luminance + 0.05) / 0.05;
    final whiteContrast = 1.05 / (luminance + 0.05);
    return blackContrast >= whiteContrast ? ink : Colors.white;
  }

  static ThemeData _build(
    ColorScheme scheme,
    Color background, {
    required bool dark,
    required Color cardColor,
    Color? borderColor,
  }) {
    final borderInk = borderColor ?? scheme.outlineVariant;
    final outline = scheme.outlineVariant;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(7),
      side: BorderSide(color: borderInk, width: 2.5),
    );
    final typography = Typography.material2021();
    final baseTextTheme = dark ? typography.white : typography.black;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      visualDensity: VisualDensity.standard,
      fontFamily: 'Roboto',
      textTheme: baseTextTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? scheme.surface : primary,
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
        color: cardColor,
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
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : scheme.onSurface,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          side: BorderSide(color: borderInk, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.28),
        selectionHandleColor: scheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.onSurface),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
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
        backgroundColor: cardColor,
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
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: cardColor,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          side: BorderSide(color: borderInk, width: 2.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderInk, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cardColor,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: borderInk, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? scheme.surface : lightSurface,
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
      chipTheme: ChipThemeData.fromDefaults(
            primaryColor: scheme.primary,
            secondaryColor: cardColor,
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
