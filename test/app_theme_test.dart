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

bool _isGray(Color color) => color.red == color.green && color.green == color.blue;

void main() {
  group('AppTheme', () {
    test('maps the four presets to their expected brightness', () {
      for (final preset in AppThemePreset.values) {
        final theme = AppTheme.themeFor(preset, AppTheme.primary);
        expect(theme.brightness, preset.brightness, reason: preset.label);
        expect(theme.colorScheme.brightness, preset.brightness);
      }
    });

    test('provides Material 3 light and dark themes', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
      expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
    });

    test('keeps the supplied Neo-Brutalist palette', () {
      expect(AppTheme.primary, const Color(0xFFF7CB46));
      expect(AppTheme.secondary, const Color(0xFFC0F7FE));
      expect(AppTheme.tertiary, const Color(0xFF99E885));
      expect(AppTheme.pink, const Color(0xFFE9E0E8));
      expect(AppTheme.lightBackground, const Color(0xFFFCEFE8));
      expect(AppTheme.warmYellow, const Color(0xFFFFDC8B));
      expect(AppTheme.ink, const Color(0xFF000000));
    });

    test('text uses the brightness-correct foreground', () {
      for (final preset in AppThemePreset.values) {
        final theme = AppTheme.themeFor(preset, AppTheme.primary);
        expect(theme.textTheme.bodyLarge?.color, theme.colorScheme.onSurface);
        expect(theme.textTheme.titleLarge?.color, theme.colorScheme.onSurface);
      }
      expect(AppTheme.lightTheme.textTheme.bodyLarge?.color, AppTheme.ink);
      expect(
        AppTheme.darkTheme.textTheme.bodyLarge?.color,
        AppTheme.darkTheme.colorScheme.onSurface,
      );
    });

    test('semantic text has contrast on surface, card and accent containers', () {
      for (final preset in AppThemePreset.values) {
        final theme = AppTheme.themeFor(preset, AppTheme.primary);
        final scheme = theme.colorScheme;
        expect(_contrast(scheme.onPrimary, scheme.primary), greaterThanOrEqualTo(4.5), reason: preset.label);
        expect(_contrast(scheme.onSecondary, scheme.secondary), greaterThanOrEqualTo(4.5), reason: preset.label);
        expect(_contrast(scheme.onPrimaryContainer, scheme.primaryContainer), greaterThanOrEqualTo(4.5), reason: preset.label);
        expect(_contrast(scheme.onSecondaryContainer, scheme.secondaryContainer), greaterThanOrEqualTo(4.5), reason: preset.label);
        expect(_contrast(scheme.onSurface, scheme.surface), greaterThanOrEqualTo(4.5), reason: preset.label);
        expect(_contrast(scheme.onSurface, theme.cardTheme.color!), greaterThanOrEqualTo(4.5), reason: preset.label);
      }
    });

    test('AMOLED has a black canvas and readable elevated cards', () {
      final theme = AppTheme.amoledTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.oledBlack);
      expect(theme.colorScheme.surface, AppTheme.oledBlack);
      expect(theme.cardTheme.color, AppTheme.monochromeCard);
      expect(theme.cardTheme.color, isNot(AppTheme.oledBlack));
    });

    test('Monochrome OLED is grayscale and ignores accents', () {
      final first = AppTheme.themeFor(AppThemePreset.monochromeOled, AppTheme.primary);
      final second = AppTheme.themeFor(
        AppThemePreset.monochromeOled,
        const Color(0xFF5A0719),
      );
      for (final color in [
        first.colorScheme.primary,
        first.colorScheme.secondary,
        first.colorScheme.tertiary,
        first.colorScheme.error,
        first.colorScheme.surface,
        first.colorScheme.onSurface,
        first.colorScheme.primaryContainer,
        first.colorScheme.outline,
        first.colorScheme.outlineVariant,
        first.cardTheme.color!,
      ]) {
        expect(_isGray(color), isTrue, reason: color.toString());
      }
      expect(first.colorScheme.primary, second.colorScheme.primary);
      expect(first.scaffoldBackgroundColor, AppTheme.oledBlack);
      expect(first.colorScheme.surface, AppTheme.oledBlack);
      expect(first.cardTheme.color, AppTheme.monochromeCard);
    });

    test('dark and OLED outlines match input and card borders', () {
      for (final preset in [
        AppThemePreset.dark,
        AppThemePreset.amoled,
        AppThemePreset.monochromeOled,
      ]) {
        final theme = AppTheme.themeFor(preset, AppTheme.primary);
        final card = theme.cardTheme.shape as RoundedRectangleBorder;
        final input = theme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
        expect(card.side.color, theme.colorScheme.outlineVariant);
        expect(input.borderSide.color, card.side.color);
      }
    });
  });
}
