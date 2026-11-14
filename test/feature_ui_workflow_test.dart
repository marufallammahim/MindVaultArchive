import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/capture/presentation/quick_capture_screen.dart';
import 'package:mindvault_archive/features/editor/presentation/editor_screen.dart';
import 'package:mindvault_archive/features/tags/presentation/tags_screen.dart';
import 'package:mindvault_archive/features/tasks/presentation/tasks_screen.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Future<bool> Function() condition, {
  int attempts = 40,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    // Advance the fake clock before awaiting database/plugin futures. This
    // lets queued frame work and stream notifications make progress.
    await tester.pump(const Duration(milliseconds: 50));
    if (await condition()) return;
  }
  fail('Timed out waiting for the widget workflow to complete.');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Quick Capture saves a note to the local archive', (
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
          home: const QuickCaptureScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField).at(0), 'Captured idea');
    await tester.enterText(
      find.byType(TextField).at(1),
      'Saved from widget test',
    );
    await tester.tap(find.text('Save'));
    await _pumpUntil(tester, () async {
      final notes =
          await tester.runAsync(() => database.select(database.notes).get()) ??
          <Note>[];
      final preferences =
          await tester.runAsync(SharedPreferences.getInstance);
      return notes.length == 1 &&
          preferences?.getString('quick_capture_draft_title') == null &&
          preferences?.getString('quick_capture_draft_content') == null;
    });

    final notes =
        await tester.runAsync(() => database.select(database.notes).get()) ??
        <Note>[];
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Captured idea');
    expect(notes.single.documentContent, 'Saved from widget test');
    final preferences =
        await tester.runAsync(SharedPreferences.getInstance);
    expect(preferences?.getString('quick_capture_draft_title'), isNull);
    expect(preferences?.getString('quick_capture_draft_content'), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quick Capture saves and opens the canonical editor route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    final router = GoRouter(
      initialLocation: '/capture',
      routes: [
        GoRoute(
          path: '/capture',
          builder: (context, state) => const QuickCaptureScreen(),
        ),
        GoRoute(
          path: '/editor/:id',
          builder: (context, state) =>
              EditorScreen(noteId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      router.dispose();
      await tester.pump(const Duration(milliseconds: 1));
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
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).at(0), 'Continue editing');
    await tester.enterText(find.byType(TextField).at(1), 'Captured body');
    await tester.tap(find.text('Save and continue editing'));
    await _pumpUntil(tester, () async {
      final notes =
          await tester.runAsync(() => database.select(database.notes).get()) ??
          <Note>[];
      return notes.length == 1 &&
          find.text('Create a Note').evaluate().isNotEmpty;
    });
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Create a Note'), findsOneWidget);
    final notes =
        await tester.runAsync(() => database.select(database.notes).get()) ??
        <Note>[];
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Continue editing');
    expect(notes.single.documentContent, 'Captured body');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quick Capture restores an unfinished draft after remount', (
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

    Widget buildCapture() => ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const QuickCaptureScreen(),
      ),
    );

    await tester.pumpWidget(buildCapture());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).at(0), 'Recovered thought');
    await tester.enterText(find.byType(TextField).at(1), 'Draft body');
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpWidget(buildCapture());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Recovered thought'), findsOneWidget);
    expect(find.text('Draft body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tags screen creates a tag and persists it', (tester) async {
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
          home: const TagsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('New tag'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.enterText(find.byType(TextField), 'Research');
    await tester.tap(find.text('Save'));
    await _pumpUntil(tester, () async {
      final tags =
          await tester.runAsync(() => database.select(database.tags).get());
      return tags?.length == 1;
    });

    await tester.pump();
    final tags =
        await tester.runAsync(() => database.select(database.tags).get()) ??
        <Tag>[];
    expect(tags, hasLength(1));
    expect(tags.single.name, 'Research');
    expect(find.text('Research'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tasks screen creates a task and persists it', (tester) async {
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
          home: const TasksScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.enterText(find.byType(TextField).first, 'Test task');
    await tester.tap(find.text('Save'));
    await _pumpUntil(tester, () async {
      final tasks =
          await tester.runAsync(() => database.select(database.tasks).get());
      return tasks?.length == 1;
    });

    await tester.pump();
    final tasks =
        await tester.runAsync(() => database.select(database.tasks).get()) ??
        <VaultTask>[];
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Test task');
    expect(find.text('Test task'), findsOneWidget);

    await tester.tap(find.text('Test task'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Edit task'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Updated task');
    await tester.enterText(find.byType(TextField).at(1), 'Updated details');
    await tester.tap(find.text('Save'));
    await _pumpUntil(tester, () async {
      final updated = await tester.runAsync(
        () => database.select(database.tasks).getSingle(),
      );
      return updated != null &&
          updated.title == 'Updated task' &&
          updated.details == 'Updated details';
    });

    await tester.tap(find.byTooltip('Mark complete'));
    await _pumpUntil(tester, () async {
      final updated = await tester.runAsync(
        () => database.select(database.tasks).getSingle(),
      );
      return updated?.isCompleted == true;
    });
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Updated task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
