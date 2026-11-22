import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/theme.dart';

double _contrast(Color foreground, Color background) {
  final first = foreground.computeLuminance();
  final second = background.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppTheme', () {
    test('provides Material 3 light and dark themes', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
      expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
    });

    test('exposes the uploaded Neo-Brutalist reference palette', () {
      expect(AppTheme.primary, const Color(0xFFF7CB46));
      expect(AppTheme.secondary, const Color(0xFFC0F7FE));
      expect(AppTheme.tertiary, const Color(0xFF99E885));
      expect(AppTheme.pink, const Color(0xFFE9E0E8));
      expect(AppTheme.lightBackground, const Color(0xFFFCEFE8));
      expect(AppTheme.warmYellow, const Color(0xFFFFDC8B));
      expect(AppTheme.ink, const Color(0xFF000000));
    });

    test('uses readable app bar foregrounds in both brightness modes', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;
      expect(light.appBarTheme.foregroundColor, AppTheme.ink);
      expect(dark.appBarTheme.foregroundColor, dark.colorScheme.onSurface);
      expect(
        dark.appBarTheme.titleTextStyle?.color,
        dark.colorScheme.onSurface,
      );
    });

    test('semantic foregrounds keep strong contrast on branded containers', () {
      final themes = [AppTheme.lightTheme, AppTheme.darkTheme];
      for (final theme in themes) {
        final scheme = theme.colorScheme;
        expect(
          _contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.onSecondary, scheme.secondary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.onSecondaryContainer, scheme.secondaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          theme.textButtonTheme.style?.foregroundColor?.resolve({}),
          scheme.onSurface,
        );
      }
    });

    test('dark theme keeps strong visible component outlines', () {
      final shape =
          AppTheme.darkTheme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.side.color, const Color(0xFFF5F1EC));
      final input =
          AppTheme.darkTheme.inputDecorationTheme.enabledBorder
              as OutlineInputBorder;
      expect(input.borderSide.color, const Color(0xFFF5F1EC));
    });

    test('AMOLED theme uses a pure black scaffold', () {
      expect(
        AppTheme.amoledTheme.scaffoldBackgroundColor,
        const Color(0xFF000000),
      );
    });
  });
}
