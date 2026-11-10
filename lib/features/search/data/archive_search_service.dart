import 'package:drift/drift.dart';
import 'package:mindvault_archive/core/database/database.dart';

enum ArchiveSearchKind { note, task }

class ArchiveSearchResult {
  const ArchiveSearchResult({
    required this.kind,
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.category,
    this.tags = const [],
  });

  final ArchiveSearchKind kind;
  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String? category;
  final List<String> tags;
}

/// Offline FTS5 search across note text and task content, with category/tag
/// matching retained as local SQL filters.
class ArchiveSearchService {
  ArchiveSearchService(this._database);

  final AppDatabase _database;

  Future<List<ArchiveSearchResult>> search(
    String rawQuery, {
    int limit = 100,
  }) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return const [];

    final safeLimit = limit.clamp(1, 500).toInt();
    final ftsQuery = _toFtsQuery(query);
    // LIKE treats '%' and '_' as wildcards. Escape user input so metadata
    // searches behave as literal substring matches, just like FTS search.
    final escapedQuery = query
        .toLowerCase()
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
    final likeQuery = '%$escapedQuery%';

    final noteConditions = <String>[];
    final noteVariables = <Variable<Object>>[];
    if (ftsQuery.isNotEmpty) {
      noteConditions.add(
        'notes.id IN (SELECT note_id FROM notes_fts WHERE notes_fts MATCH ?)',
      );
      noteVariables.add(Variable.withString(ftsQuery));
    }
    noteConditions
      ..add('LOWER(categories.name) LIKE ? ESCAPE char(92)')
      ..add('LOWER(tags.name) LIKE ? ESCAPE char(92)');
    noteVariables
      ..add(Variable.withString(likeQuery))
      ..add(Variable.withString(likeQuery));

    final noteRows = await _database
        .customSelect(
          '''
      SELECT DISTINCT notes.id
      FROM notes
      LEFT JOIN categories ON categories.id = notes.category_id
      LEFT JOIN note_tags ON note_tags.note_id = notes.id
      LEFT JOIN tags ON tags.id = note_tags.tag_id
      WHERE notes.is_deleted = 0
        AND (${noteConditions.join(' OR ')})
      ORDER BY notes.updated_at DESC
      LIMIT ?
      ''',
          variables: [...noteVariables, Variable.withInt(safeLimit)],
          readsFrom: {
            _database.notes,
            _database.categories,
            _database.noteTags,
            _database.tags,
          },
        )
        .get();

    final noteIds = noteRows.map((row) => row.read<String>('id')).toList();
    final noteRecords = noteIds.isEmpty
        ? <Note>[]
        : await (_database.select(
            _database.notes,
          )..where((note) => note.id.isIn(noteIds))).get();

    final categories = await _database.select(_database.categories).get();
    final tags = await _database.select(_database.tags).get();
    final noteTags = await _database.select(_database.noteTags).get();
    final categoryById = {for (final item in categories) item.id: item};
    final tagById = {for (final item in tags) item.id: item};
    final tagsByNote = <String, List<String>>{};
    for (final relation in noteTags) {
      if (!noteIds.contains(relation.noteId)) continue;
      final tag = tagById[relation.tagId];
      if (tag != null) {
        (tagsByNote[relation.noteId] ??= []).add(tag.name);
      }
    }

    final results = <ArchiveSearchResult>[];
    for (final note in noteRecords) {
      final category = note.categoryId == null
          ? null
          : categoryById[note.categoryId!];
      results.add(
        ArchiveSearchResult(
          kind: ArchiveSearchKind.note,
          id: note.id,
          title: note.title.trim().isEmpty ? 'Untitled' : note.title,
          preview: _snippet(note.documentContent, query),
          updatedAt: note.updatedAt,
          category: category?.name,
          tags: tagsByNote[note.id] ?? const [],
        ),
      );
    }

    if (ftsQuery.isNotEmpty) {
      final taskRows = await _database
          .customSelect(
            '''
        SELECT task_id
        FROM tasks_fts
        WHERE tasks_fts MATCH ?
        ORDER BY rank
        LIMIT ?
        ''',
            variables: [
              Variable.withString(ftsQuery),
              Variable.withInt(safeLimit),
            ],
            readsFrom: {_database.tasks},
          )
          .get();
      final taskIds = taskRows
          .map((row) => row.read<String>('task_id'))
          .toList();
      if (taskIds.isNotEmpty) {
        final taskRecords = await (_database.select(
          _database.tasks,
        )..where((task) => task.id.isIn(taskIds))).get();
        for (final task in taskRecords) {
          results.add(
            ArchiveSearchResult(
              kind: ArchiveSearchKind.task,
              id: task.id,
              title: task.title,
              preview: _snippet(task.details, query),
              updatedAt: task.updatedAt,
            ),
          );
        }
      }
    }

    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results.length <= safeLimit
        ? results
        : results.sublist(0, safeLimit);
  }

  String _toFtsQuery(String rawQuery) {
    final terms = rawQuery
        .trim()
        .split(RegExp(r'\s+'))
        .map((term) => term.replaceAll('"', '').trim())
        .where(
          (term) =>
              term.isNotEmpty && RegExp(r'[A-Za-z0-9\u0080-\uFFFF]').hasMatch(term),
        )
        .map((term) => '"$term"*');
    return terms.join(' AND ');
  }

  String _snippet(String value, String query) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'No preview text';
    final terms = query.toLowerCase().split(RegExp(r'\s+'));
    final lower = normalized.toLowerCase();
    var index = -1;
    for (final term in terms) {
      final found = lower.indexOf(term);
      if (found >= 0 && (index < 0 || found < index)) index = found;
    }
    final start = index < 0
        ? 0
        : (index - 55).clamp(0, normalized.length).toInt();
    final end = (start + 180).clamp(0, normalized.length).toInt();
    final prefix = start > 0 ? '…' : '';
    final suffix = end < normalized.length ? '…' : '';
    return '$prefix${normalized.substring(start, end)}$suffix';
  }
}
