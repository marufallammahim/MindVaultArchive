import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/editor/providers/editor_provider.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'reload cancels a pending autosave before loading restored content',
    () async {
      await database.saveNoteContent(
        'history-note',
        'Original title',
        'Original content',
      );
      final notifier = EditorNotifier(database, 'history-note');
      addTearDown(notifier.dispose);

      for (var attempt = 0;
          attempt < 20 && !notifier.state.isLoaded;
          attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      expect(notifier.state.isLoaded, isTrue);

      notifier.updateContent(
        'Pending edit',
        'This must not overwrite a restore.',
      );
      await database.saveNoteContent(
        'history-note',
        'Restored revision',
        'Restored content',
      );

      await notifier.reloadFromDatabase();
      await Future<void>.delayed(const Duration(milliseconds: 750));

      final note = await (database.select(
        database.notes,
      )..where((item) => item.id.equals('history-note')))
          .getSingle();

      expect(note.title, 'Restored revision');
      expect(note.documentContent, 'Restored content');
      expect(notifier.state.title, 'Restored revision');
      expect(notifier.state.content, 'Restored content');
      expect(notifier.state.isSaving, isFalse);
    },
  );
}
