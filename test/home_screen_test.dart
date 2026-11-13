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

  testWidgets('home renders saved notes in light and dark themes', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveNoteContent('home-note', 'Saved note', 'A saved body');

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(theme: theme, home: const HomeScreen()),
        ),
      );

      // Home contains continuously animated decorative elements. Pump a
      // bounded number of frames instead of pumpAndSettle, which can wait
      // forever when an animation intentionally keeps scheduling frames.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Recent Notes'), findsOneWidget);
      expect(find.text('Saved note'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Stats dock opens Archive Insights, not the task list', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
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
    addTearDown(router.dispose);

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
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Archive insights'), findsWidgets);
    expect(find.text('To-do list'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
