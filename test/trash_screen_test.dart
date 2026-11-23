import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:mindvault_archive/features/trash/presentation/trash_screen.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Future<bool> Function() condition, {
  int attempts = 40,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (await condition()) return;
  }
  fail('Timed out waiting for Trash to update.');
}

Future<List<Note>> _readNotes(
  WidgetTester tester,
  AppDatabase database,
) async =>
    await tester.runAsync(() => database.select(database.notes).get()) ??
    <Note>[];

Future<void> _openTrashActions(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Trash actions'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('empty Trash presents the branded empty state', (tester) async {
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
          home: const TrashScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Trash is empty.'), findsOneWidget);
    expect(find.text('Nothing to clean up right now.'), findsOneWidget);
    expect(find.byType(NeoBrutalistPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('restoring a trashed note removes it from Trash and persists', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveNoteContent('restore-note', 'Restore me', 'Body');
    await database.setDeleted('restore-note', true);
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
          home: const TrashScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Restore me'), findsOneWidget);
    await _openTrashActions(tester);
    await tester.tap(find.text('Restore'));
    await _pumpUntil(tester, () async {
      final notes = await _readNotes(tester, database);
      return notes.single.isDeleted == false;
    });

    await tester.pump();
    expect(find.text('Restore me'), findsNothing);
    final notes = await _readNotes(tester, database);
    expect(notes.single.isDeleted, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('canceling permanent deletion keeps the trashed note', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveNoteContent('keep-note', 'Keep me', 'Body');
    await database.setDeleted('keep-note', true);
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
          home: const TrashScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await _openTrashActions(tester);
    await tester.tap(find.text('Delete forever'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Delete permanently?'), findsOneWidget);

    await tester.tap(find.text('Keep note'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final notes = await _readNotes(tester, database);
    expect(notes, hasLength(1));
    expect(notes.single.isDeleted, isTrue);
    expect(find.text('Keep me'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmed permanent deletion cleans linked local records', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveNoteContent('delete-note', 'Delete me', 'Original');
    await database.saveNoteContent('delete-note', 'Delete me', 'Edited');
    await database.saveTag('delete-tag', 'Delete tag');
    await database.setNoteTags('delete-note', ['delete-tag']);
    await database.saveTask(
      id: 'linked-task',
      title: 'Linked task',
      details: '',
      priority: 1,
      noteId: 'delete-note',
    );
    await database
        .into(database.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'linked-attachment',
            noteId: 'delete-note',
            type: 'drawing',
            localPath: '/missing/test/drawing.png',
            filename: 'drawing.png',
          ),
        );
    await database.setDeleted('delete-note', true);
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
          home: const TrashScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await _openTrashActions(tester);
    await tester.tap(find.text('Delete forever'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(FilledButton, 'Delete forever'));
    await _pumpUntil(tester, () async {
      final notes = await _readNotes(tester, database);
      return notes.isEmpty;
    });

    expect(await _readNotes(tester, database), isEmpty);
    expect(
      await tester.runAsync(() => database.select(database.attachments).get()),
      isEmpty,
    );
    expect(
      await tester.runAsync(() => database.select(database.noteTags).get()),
      isEmpty,
    );
    expect(
      await tester.runAsync(
        () => database.select(database.noteRevisions).get(),
      ),
      isEmpty,
    );
    final tasks = await tester.runAsync(
      () => database.select(database.tasks).get(),
    );
    expect(tasks?.single.noteId, isNull);
    expect(
      await tester.runAsync(() => database.select(database.tags).get()),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
}
