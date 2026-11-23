import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates the old Light mode preference', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'amoled_theme_enabled': true,
    });
    final notifier = ThemePresetNotifier();
    await notifier.initialized;
    expect(notifier.state, AppThemePreset.light);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('theme_preset'), 'light');
    expect(preferences.containsKey('theme_mode'), isFalse);
    expect(preferences.containsKey('amoled_theme_enabled'), isFalse);
    notifier.dispose();
  });

  test('migrates old Dark and AMOLED settings independently', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'amoled_theme_enabled': false,
    });
    final dark = ThemePresetNotifier();
    await dark.initialized;
    expect(dark.state, AppThemePreset.dark);
    dark.dispose();

    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'amoled_theme_enabled': true,
    });
    final amoled = ThemePresetNotifier();
    await amoled.initialized;
    expect(amoled.state, AppThemePreset.amoled);
    amoled.dispose();
  });

  test('new installations default to AMOLED and persist selection', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = ThemePresetNotifier();
    await notifier.initialized;
    expect(notifier.state, AppThemePreset.amoled);
    await notifier.setPreset(AppThemePreset.monochromeOled);
    expect(notifier.state, AppThemePreset.monochromeOled);
    notifier.dispose();

    final restored = ThemePresetNotifier();
    await restored.initialized;
    expect(restored.state, AppThemePreset.monochromeOled);
    restored.dispose();
  });
}
