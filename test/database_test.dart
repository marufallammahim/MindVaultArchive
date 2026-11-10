import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/core/database/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'saveNoteContent inserts a note and updates it on subsequent saves',
    () async {
      await database.saveNoteContent('note-1', 'First title', 'First body');
      await database.saveNoteContent('note-1', 'Updated title', 'Updated body');

      final note = await (database.select(
        database.notes,
      )..where((row) => row.id.equals('note-1')))
          .getSingle();

      expect(note.title, 'Updated title');
      expect(note.documentContent, 'Updated body');
      expect(note.id, 'note-1');
    },
  );

  test('note category assignment validates and persists', () async {
    await database.saveCategory('ideas', 'Ideas');
    await database.setNoteCategory('note-category', 'ideas');
    var note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('note-category')))
        .getSingle();
    expect(note.categoryId, 'ideas');

    await database.setNoteCategory('note-category', null);
    note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('note-category')))
        .getSingle();
    expect(note.categoryId, isNull);
    await expectLater(
      database.setNoteCategory('note-category', 'missing'),
      throwsArgumentError,
    );
  });

  test('note color is persisted and can be reset', () async {
    await database.saveNoteContent('color-note', 'Colored', 'Body');
    await database.setNoteColor('color-note', 0xFFFFF0D8);
    var note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('color-note')))
        .getSingle();
    expect(note.color, 0xFFFFF0D8);

    await database.setNoteColor('color-note', null);
    note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('color-note')))
        .getSingle();
    expect(note.color, isNull);
  });

  test('favorite, archive and trash state persist in SQLite', () async {
    await database.saveNoteContent('note-2', 'Lifecycle', 'Test');
    await database.setFavorite('note-2', true);
    await database.setArchived('note-2', true);
    await database.setDeleted('note-2', true);

    final note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('note-2')))
        .getSingle();

    expect(note.isFavorite, isTrue);
    expect(note.isArchived, isTrue);
    expect(note.isDeleted, isTrue);

    await database.setDeleted('note-2', false);
    final restored = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('note-2')))
        .getSingle();
    expect(restored.isDeleted, isFalse);
  });

  test('category rename/upsert and delete detach notes safely', () async {
    await database.saveNoteContent('note-3', 'Categorized', 'Body');
    await database.saveCategory('work', 'Work');
    await database.saveCategory('work', 'Projects');
    await (database.update(database.notes)
          ..where((row) => row.id.equals('note-3')))
        .write(const NotesCompanion(categoryId: Value('work')));

    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals('work')))
        .getSingle();
    expect(category.name, 'Projects');

    await database.deleteCategory('work');
    final note = await (database.select(
      database.notes,
    )..where((row) => row.id.equals('note-3')))
        .getSingle();
    expect(note.categoryId, isNull);
    expect(await database.select(database.categories).get(), isEmpty);
  });

  test('permanent deletion removes note and its attachment metadata', () async {
    await database.saveNoteContent('note-4', 'With attachment', 'Body');
    await database.into(database.attachments).insert(
          AttachmentsCompanion.insert(
            id: 'attachment-1',
            noteId: 'note-4',
            type: 'drawing',
            localPath: '/tmp/drawing.png',
            filename: 'drawing.png',
          ),
        );

    await database.permanentlyDeleteNote('note-4');

    expect(await database.select(database.notes).get(), isEmpty);
    expect(await database.select(database.attachments).get(), isEmpty);
  });

  test('category names cannot be empty', () async {
    await expectLater(
      database.saveCategory('empty', '   '),
      throwsArgumentError,
    );
  });
}
