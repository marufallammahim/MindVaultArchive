import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/search/data/archive_search_service.dart';

void main() {
  late AppDatabase database;
  late ArchiveSearchService search;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    search = ArchiveSearchService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('searches note title and body without case sensitivity', () async {
    await database.saveNoteContent(
      'note-1',
      'Flutter Architecture',
      'A local-first database with offline persistence.',
    );

    final titleResults = await search.search('FLUTTER');
    final bodyResults = await search.search('offline persistence');

    expect(titleResults, hasLength(1));
    expect(titleResults.single.id, 'note-1');
    expect(bodyResults, hasLength(1));
    expect(bodyResults.single.preview, contains('offline persistence'));
  });

  test('searches by category and tag names', () async {
    await database.saveCategory('study', 'University Study');
    await database.saveTag('important', 'Important');
    await database.saveNoteContent('note-2', 'Lecture notes', 'Week one');
    await database.setNoteCategory('note-2', 'study');
    await database.setNoteTags('note-2', ['important']);

    final byCategory = await search.search('university');
    final byTag = await search.search('important');

    expect(byCategory.map((item) => item.id), contains('note-2'));
    expect(byTag.map((item) => item.id), contains('note-2'));
    expect(byTag.single.tags, contains('Important'));
  });

  test('searches task titles and details', () async {
    await database.saveTask(
      id: 'task-1',
      title: 'Review release',
      details: 'Check Android signing workflow',
      priority: 2,
    );

    final results = await search.search('signing workflow');
    expect(results, hasLength(1));
    expect(results.single.kind, ArchiveSearchKind.task);
    expect(results.single.id, 'task-1');
  });

  test('does not return deleted notes and caps results', () async {
    await database.saveNoteContent('deleted', 'Secret keyword', 'Trash');
    await database.setDeleted('deleted', true);
    await database.saveNoteContent('visible', 'Secret keyword', 'Keep');

    final results = await search.search('secret keyword', limit: 1);
    expect(results, hasLength(1));
    expect(results.single.id, 'visible');
    expect(await search.search('   '), isEmpty);
  });
}
