import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/editor/presentation/editor_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editor accepts title and body typing and autosaves both', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveNoteContent('editor-note', 'Starting title', 'Starting body');
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const EditorScreen(noteId: 'editor-note'),
        ),
      ),
    );

    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byType(TextField).evaluate().length >= 2) break;
    }
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), 'Typed title');
    await tester.enterText(find.byType(TextField).at(1), 'Typed body content');
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      final note = await (database.select(database.notes)
            ..where((item) => item.id.equals('editor-note')))
          .getSingle();
      if (note.title == 'Typed title' &&
          note.documentContent == 'Typed body content') {
        break;
      }
    }

    final saved = await (database.select(database.notes)
          ..where((item) => item.id.equals('editor-note')))
        .getSingle();
    expect(saved.title, 'Typed title');
    expect(saved.documentContent, 'Typed body content');
    expect(tester.takeException(), isNull);
  });
}
