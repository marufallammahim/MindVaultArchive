import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/theme.dart';

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
      expect(AppTheme.pink, const Color(0xFFFE90E8));
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

    test('AMOLED theme uses a pure black scaffold', () {
      expect(
        AppTheme.amoledTheme.scaffoldBackgroundColor,
        const Color(0xFF000000),
      );
    });
  });
}
