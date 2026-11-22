import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/home/presentation/home_screen.dart';
import 'package:mindvault_archive/features/insights/presentation/archive_insights_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home renders saved notes without layout errors on phone sizes', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() async {
      await database.saveNoteContent('home-note', 'Saved note', 'A saved body');
      return true;
    });

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final sizes = [
      const Size(320, 640),
      const Size(360, 800),
      const Size(412, 915),
    ];

    for (final size in sizes) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;

      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(database)],
            child: MaterialApp(theme: theme, home: const HomeScreen()),
          ),
        );
        var rendered = false;
        for (var attempt = 0; attempt < 20; attempt++) {
          await tester.pump(const Duration(milliseconds: 50));
          if (find.text('Recent Notes').evaluate().isNotEmpty &&
              find.text('Saved note').evaluate().isNotEmpty) {
            rendered = true;
            break;
          }
        }

        expect(rendered, isTrue, reason: 'Home should render the saved note.');
        expect(find.text('Recent Notes'), findsOneWidget);
        expect(find.text('Saved note'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 1));
      }
    }
  });

  testWidgets('Stats dock opens Archive Insights, not the task list', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/insights',
          builder: (_, _) => const ArchiveInsightsScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (_, _) => const Scaffold(body: Text('To-do list')),
        ),
      ],
    );

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Stats'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Archive insights'), findsWidgets);
    expect(find.text('To-do list'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
