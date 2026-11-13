import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/capture/presentation/quick_capture_screen.dart';
import 'package:mindvault_archive/features/tags/presentation/tags_screen.dart';
import 'package:mindvault_archive/features/tasks/presentation/tasks_screen.dart';

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final notes = await database.select(database.notes).get();
    expect(notes, hasLength(1));
    expect(notes.single.title, 'Captured idea');
    expect(notes.single.documentContent, 'Saved from widget test');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('quick_capture_draft_title'), isNull);
    expect(preferences.getString('quick_capture_draft_content'), isNull);
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final tags = await database.select(database.tags).get();
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final tasks = await database.select(database.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Test task');
    expect(find.text('Test task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
