import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/archive/data/archive_transfer_service.dart';

void main() {
  late AppDatabase database;
  late ArchiveTransferService transfer;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    transfer = ArchiveTransferService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('exports notes and categories as a versioned JSON archive', () async {
    await database.saveCategory('work', 'Work');
    await database.saveNoteContent('note-1', 'Research', 'Offline-first notes');
    await database.saveNoteContent(
        'note-1', 'Research updated', 'Updated body');
    await database.saveTag('important', 'Important');
    await database.setNoteTags('note-1', ['important']);
    await database.saveTask(
      id: 'task-1',
      title: 'Review archive',
      details: 'Check export',
      priority: 2,
      noteId: 'note-1',
    );

    final document = jsonDecode(await transfer.exportJson()) as Map;
    expect(document['format'], ArchiveTransferService.formatName);
    expect(document['version'], ArchiveTransferService.formatVersion);
    final contents = document['contents'] as Map;
    expect((contents['categories'] as List).single['name'], 'Work');
    expect(
        (contents['notes'] as List).single['documentContent'], 'Updated body');
    expect((contents['revisions'] as List).single['title'], 'Research');
    expect((contents['tasks'] as List).single['title'], 'Review archive');
    expect((contents['tasks'] as List).single['noteId'], 'note-1');
    expect((contents['tags'] as List).single['name'], 'Important');
    expect((contents['noteTags'] as List).single['tagId'], 'important');
  });

  test('imports archive and skips colliding note IDs without overwriting',
      () async {
    await database.saveNoteContent('same-id', 'Local title', 'Local content');
    final archive = <String, Object?>{
      'format': ArchiveTransferService.formatName,
      'version': ArchiveTransferService.formatVersion,
      'exportedAt': DateTime.utc(2026).toIso8601String(),
      'contents': {
        'categories': [
          {
            'id': 'work',
            'name': 'Work',
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
          }
        ],
        'notes': [
          {
            'id': 'same-id',
            'title': 'Remote title',
            'documentContent': 'Remote content',
            'categoryId': 'work',
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
            'isFavorite': true,
            'isArchived': false,
            'isDeleted': false,
            'color': null,
            'sortOrder': 0,
          },
          {
            'id': 'new-id',
            'title': 'Imported',
            'documentContent': 'New content',
            'categoryId': 'work',
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
            'isFavorite': true,
            'isArchived': false,
            'isDeleted': false,
            'color': null,
            'sortOrder': 2,
          }
        ],
        'tags': [
          {
            'id': 'priority',
            'name': 'Priority',
            'color': null,
            'createdAt': DateTime.utc(2026).toIso8601String(),
          }
        ],
        'revisions': [
          {
            'id': 'revision-1',
            'noteId': 'new-id',
            'title': 'Previous imported title',
            'documentContent': 'Previous imported body',
            'createdAt': DateTime.utc(2026).toIso8601String(),
          }
        ],
        'noteTags': [
          {
            'noteId': 'new-id',
            'tagId': 'priority',
            'createdAt': DateTime.utc(2026).toIso8601String(),
          }
        ],
        'tasks': [
          {
            'id': 'task-imported',
            'title': 'Imported task',
            'details': 'Imported details',
            'noteId': 'new-id',
            'dueAt': null,
            'priority': 2,
            'isCompleted': false,
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
            'completedAt': null,
          }
        ],
      },
    };

    final result = await transfer.importJson(jsonEncode(archive));
    expect(result.imported, 1);
    expect(result.skipped, 1);
    expect(result.importedTasks, 1);
    expect(result.importedTags, 1);
    expect(result.importedRevisions, 1);

    final existing = await (database.select(database.notes)
          ..where((note) => note.id.equals('same-id')))
        .getSingle();
    expect(existing.title, 'Local title');
    final imported = await (database.select(database.notes)
          ..where((note) => note.id.equals('new-id')))
        .getSingle();
    expect(imported.categoryId, 'work');
    expect(imported.isFavorite, isTrue);
    final importedTask = await (database.select(database.tasks)
          ..where((task) => task.id.equals('task-imported')))
        .getSingle();
    expect(importedTask.title, 'Imported task');
    expect(importedTask.noteId, 'new-id');
    final importedTagLink = await (database.select(database.noteTags)
          ..where((link) => link.noteId.equals('new-id')))
        .getSingle();
    expect(importedTagLink.tagId, 'priority');
    final importedRevision = await (database.select(database.noteRevisions)
          ..where((revision) => revision.id.equals('revision-1')))
        .getSingle();
    expect(importedRevision.title, 'Previous imported title');
  });

  test('imports version 4 task records without optional note links', () async {
    final legacy = <String, Object?>{
      'format': ArchiveTransferService.formatName,
      'version': 4,
      'contents': {
        'categories': <Object?>[],
        'notes': <Object?>[],
        'tasks': [
          {
            'id': 'legacy-task',
            'title': 'Legacy task',
            'details': '',
            'dueAt': null,
            'priority': 1,
            'isCompleted': false,
            'createdAt': DateTime.utc(2026).toIso8601String(),
            'updatedAt': DateTime.utc(2026).toIso8601String(),
            'completedAt': null,
          }
        ],
      },
    };
    await transfer.importJson(jsonEncode(legacy));
    final task = await (database.select(database.tasks)
          ..where((item) => item.id.equals('legacy-task')))
        .getSingle();
    expect(task.noteId, isNull);
  });

  test('imports version 3 archives without revision sections', () async {
    final legacy = <String, Object?>{
      'format': ArchiveTransferService.formatName,
      'version': 3,
      'contents': {
        'categories': <Object?>[],
        'notes': <Object?>[],
        'tasks': <Object?>[],
        'tags': <Object?>[],
        'noteTags': <Object?>[],
      },
    };
    final result = await transfer.importJson(jsonEncode(legacy));
    expect(result.importedRevisions, 0);
  });

  test('imports version 1 archives without task or tag sections', () async {
    final legacy = <String, Object?>{
      'format': ArchiveTransferService.formatName,
      'version': 1,
      'contents': {'categories': <Object?>[], 'notes': <Object?>[]},
    };
    final result = await transfer.importJson(jsonEncode(legacy));
    expect(result.imported, 0);
    expect(result.importedTasks, 0);
    expect(result.importedTags, 0);
  });

  test('rejects invalid archive before changing local data', () async {
    await database.saveNoteContent('safe', 'Safe', 'Keep me');
    await expectLater(
      transfer.importJson('{"format":"other","version":1}'),
      throwsFormatException,
    );
    final notes = await database.select(database.notes).get();
    expect(notes.map((note) => note.id), ['safe']);
  });
}
