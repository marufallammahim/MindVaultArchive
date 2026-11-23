import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:mindvault_archive/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _waitFor(
  WidgetTester tester,
  Future<bool> Function() condition, {
  int attempts = 30,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (await condition()) return;
  }
  fail('Timed out waiting for Settings to persist the requested change.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Settings uses shared panels and persists accent and category changes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view
        ..physicalSize = const Size(320, 640)
        ..devicePixelRatio = 1;
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        await database.close();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FeatureHero), findsOneWidget);
      expect(find.text('Your archive, your way'), findsOneWidget);
      expect(find.byType(NeoBrutalistPanel), findsAtLeastNWidgets(2));
      expect(tester.takeException(), isNull);

      final cyanAccent = find.byTooltip('Use accent color #C0F7FE');
      await tester.ensureVisible(cyanAccent);
      await tester.tap(cyanAccent);
      await tester.pump();

      final preferences = await tester.runAsync(SharedPreferences.getInstance);
      expect(preferences?.getInt('primary_accent_color'), 0xFFC0F7FE);

      final addCategory = find.byTooltip('Add category');
      await tester.ensureVisible(addCategory);
      await tester.tap(addCategory);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField).last, 'Research');
      await tester.tap(find.text('Save'));
      await _waitFor(tester, () async {
        final categories = await tester.runAsync(
          () => database.select(database.categories).get(),
        );
        return categories?.length == 1;
      });

      expect(find.text('Research'), findsOneWidget);
      final researchMenu = find.byTooltip('Manage Research');
      await tester.ensureVisible(researchMenu);
      await tester.tap(researchMenu);
      await tester.pump();
      await tester.tap(find.text('Rename'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).last, 'Reading');
      await tester.tap(find.text('Save'));

      await _waitFor(tester, () async {
        final categories = await tester.runAsync(
          () => database.select(database.categories).get(),
        );
        return categories?.length == 1 && categories!.single.name == 'Reading';
      });
      expect(find.text('Reading'), findsOneWidget);

      final readingMenu = find.byTooltip('Manage Reading');
      await tester.ensureVisible(readingMenu);
      await tester.tap(readingMenu);
      await tester.pump();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Delete').last);

      await _waitFor(tester, () async {
        final categories = await tester.runAsync(
          () => database.select(database.categories).get(),
        );
        return categories?.isEmpty ?? false;
      });

      expect(
        find.text('No categories yet. Add one to organize notes.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Settings exposes one selector for the four presets', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byType(DropdownButtonFormField<AppThemePreset>),
      findsOneWidget,
    );
    expect(find.text('Color mode'), findsNothing);
    expect(find.text('AMOLED black'), findsNothing);
    await tester.tap(
      find.byType(DropdownButtonFormField<AppThemePreset>),
    );
    await tester.pumpAndSettle();
    for (final label in ['Light', 'Dark', 'AMOLED', 'Monochrome OLED']) {
      expect(find.text(label), findsWidgets);
    }
    await tester.tap(find.text('Monochrome OLED').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final preferences = await tester.runAsync(SharedPreferences.getInstance);
    expect(preferences?.getString('theme_preset'), 'monochromeOled');
    expect(
      find.textContaining('Accent colors are ignored in this preset'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
