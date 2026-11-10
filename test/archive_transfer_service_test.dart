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

    final document = jsonDecode(await transfer.exportJson()) as Map;
    expect(document['format'], ArchiveTransferService.formatName);
    expect(document['version'], ArchiveTransferService.formatVersion);
    final contents = document['contents'] as Map;
    expect((contents['categories'] as List).single['name'], 'Work');
    expect((contents['notes'] as List).single['documentContent'],
        'Offline-first notes');
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
      },
    };

    final result = await transfer.importJson(jsonEncode(archive));
    expect(result.imported, 1);
    expect(result.skipped, 1);

    final existing = await (database.select(database.notes)
          ..where((note) => note.id.equals('same-id')))
        .getSingle();
    expect(existing.title, 'Local title');
    final imported = await (database.select(database.notes)
          ..where((note) => note.id.equals('new-id')))
        .getSingle();
    expect(imported.categoryId, 'work');
    expect(imported.isFavorite, isTrue);
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
