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

/// Offline search across note text, categories, tags, and task content.
class ArchiveSearchService {
  ArchiveSearchService(this._database);

  final AppDatabase _database;

  Future<List<ArchiveSearchResult>> search(
    String rawQuery, {
    int limit = 100,
  }) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final notesQuery = _database.select(_database.notes)
      ..where((note) => note.isDeleted.equals(false));
    final notes = await notesQuery.get();
    final categories = await _database.select(_database.categories).get();
    final tags = await _database.select(_database.tags).get();
    final noteTags = await _database.select(_database.noteTags).get();
    final tasks = await _database.select(_database.tasks).get();

    final categoryById = {for (final item in categories) item.id: item};
    final tagById = {for (final item in tags) item.id: item};
    final tagsByNote = <String, List<String>>{};
    for (final relation in noteTags) {
      final tag = tagById[relation.tagId];
      if (tag != null) {
        (tagsByNote[relation.noteId] ??= []).add(tag.name);
      }
    }

    final matchedCategoryIds = categories
        .where((item) => _contains(item.name, query))
        .map((item) => item.id)
        .toSet();
    final matchedTagIds = tags
        .where((item) => _contains(item.name, query))
        .map((item) => item.id)
        .toSet();
    final matchedNoteIdsFromTags = noteTags
        .where((item) => matchedTagIds.contains(item.tagId))
        .map((item) => item.noteId)
        .toSet();

    final results = <ArchiveSearchResult>[];
    for (final note in notes) {
      final category =
          note.categoryId == null ? null : categoryById[note.categoryId!];
      final noteTagNames = tagsByNote[note.id] ?? const <String>[];
      final matches = _contains(note.title, query) ||
          _contains(note.documentContent, query) ||
          (category != null && matchedCategoryIds.contains(category.id)) ||
          matchedNoteIdsFromTags.contains(note.id);
      if (!matches) continue;

      final preview = _snippet(note.documentContent, query);
      results.add(
        ArchiveSearchResult(
          kind: ArchiveSearchKind.note,
          id: note.id,
          title: note.title.trim().isEmpty ? 'Untitled' : note.title,
          preview: preview,
          updatedAt: note.updatedAt,
          category: category?.name,
          tags: noteTagNames,
        ),
      );
    }

    for (final task in tasks) {
      if (!_contains(task.title, query) && !_contains(task.details, query)) {
        continue;
      }
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

    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final safeLimit = limit.clamp(1, 500).toInt();
    return results.length <= safeLimit
        ? results
        : results.sublist(0, safeLimit);
  }

  bool _contains(String value, String query) =>
      value.toLowerCase().contains(query);

  String _snippet(String value, String query) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'No preview text';
    final index = normalized.toLowerCase().indexOf(query);
    final start =
        index < 0 ? 0 : (index - 55).clamp(0, normalized.length).toInt();
    final end = (start + 180).clamp(0, normalized.length).toInt();
    final prefix = start > 0 ? '…' : '';
    final suffix = end < normalized.length ? '…' : '';
    return '$prefix${normalized.substring(start, end)}$suffix';
  }
}
