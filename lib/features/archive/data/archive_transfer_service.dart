import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mindvault_archive/core/database/database.dart';

/// Portable, versioned JSON transfer for notes, categories, tags, tasks and revisions.
///
/// Format v4 includes note revision history; attachment file bytes are still excluded. It never
/// serializes private device paths, and import never overwrites existing notes.
class ArchiveTransferService {
  ArchiveTransferService(this._database);

  final AppDatabase _database;

  static const formatName = 'mindvault-archive';
  static const formatVersion = 4;

  Future<String> exportJson() async {
    final categories = await _database.select(_database.categories).get();
    final notes = await _database.select(_database.notes).get();

    final document = <String, Object?>{
      'format': formatName,
      'version': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'contents': <String, Object?>{
        'categories': categories
            .map((item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                  'updatedAt': item.updatedAt.toUtc().toIso8601String(),
                })
            .toList(),
        'notes': notes
            .map((item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'documentContent': item.documentContent,
                  'categoryId': item.categoryId,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                  'updatedAt': item.updatedAt.toUtc().toIso8601String(),
                  'isFavorite': item.isFavorite,
                  'isArchived': item.isArchived,
                  'isDeleted': item.isDeleted,
                  'color': item.color,
                  'sortOrder': item.sortOrder,
                })
            .toList(),
        'tags': (await _database.select(_database.tags).get())
            .map((item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'color': item.color,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                })
            .toList(),
        'revisions': (await _database.select(_database.noteRevisions).get())
            .map((item) => <String, Object?>{
                  'id': item.id,
                  'noteId': item.noteId,
                  'title': item.title,
                  'documentContent': item.documentContent,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                })
            .toList(),
        'noteTags': (await _database.select(_database.noteTags).get())
            .map((item) => <String, Object?>{
                  'noteId': item.noteId,
                  'tagId': item.tagId,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                })
            .toList(),
        'tasks': (await _database.select(_database.tasks).get())
            .map((item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'details': item.details,
                  'dueAt': item.dueAt?.toUtc().toIso8601String(),
                  'priority': item.priority,
                  'isCompleted': item.isCompleted,
                  'createdAt': item.createdAt.toUtc().toIso8601String(),
                  'updatedAt': item.updatedAt.toUtc().toIso8601String(),
                  'completedAt': item.completedAt?.toUtc().toIso8601String(),
                })
            .toList(),
      },
      'limitations': <String>[
        'Attachment file bytes are not included in format version 4.',
      ],
    };

    return const JsonEncoder.withIndent('  ').convert(document);
  }

  /// Validates the complete document before writing anything.
  ///
  /// Existing note IDs are skipped to avoid accidental overwrites. Categories
  /// are upserted by stable ID so imported notes can retain their grouping.
  Future<ArchiveImportResult> importJson(String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != formatName ||
        (decoded['version'] != 1 &&
            decoded['version'] != 2 &&
            decoded['version'] != 3 &&
            decoded['version'] != formatVersion)) {
      throw const FormatException('Unsupported MindVault archive format.');
    }

    final contents = decoded['contents'];
    if (contents is! Map<String, dynamic>) {
      throw const FormatException('Archive contents are missing.');
    }

    final rawCategories = contents['categories'];
    final rawNotes = contents['notes'];
    final rawTasks = contents['tasks'] ?? <Object?>[];
    final rawTags = contents['tags'] ?? <Object?>[];
    final rawNoteTags = contents['noteTags'] ?? <Object?>[];
    final rawRevisions = contents['revisions'] ?? <Object?>[];
    if (rawCategories is! List ||
        rawNotes is! List ||
        rawTasks is! List ||
        rawTags is! List ||
        rawNoteTags is! List ||
        rawRevisions is! List) {
      throw const FormatException('Archive categories or notes are invalid.');
    }

    final parsedCategories = rawCategories.map(_parseCategory).toList();
    final parsedNotes = rawNotes.map(_parseNote).toList();
    final parsedTasks = rawTasks.map(_parseTask).toList();
    final parsedTags = rawTags.map(_parseTag).toList();
    final parsedNoteTags = rawNoteTags.map(_parseNoteTag).toList();
    final parsedRevisions = rawRevisions.map(_parseRevision).toList();

    final categoryIds = parsedCategories.map((item) => item.id).toSet();
    if (categoryIds.length != parsedCategories.length) {
      throw const FormatException('Archive contains duplicate category IDs.');
    }
    final noteIds = parsedNotes.map((item) => item.id).toSet();
    if (noteIds.length != parsedNotes.length) {
      throw const FormatException('Archive contains duplicate note IDs.');
    }

    final tagIds = parsedTags.map((item) => item.id).toSet();
    if (tagIds.length != parsedTags.length) {
      throw const FormatException('Archive contains duplicate tag IDs.');
    }
    final relationKeys =
        parsedNoteTags.map((item) => '${item.noteId}|${item.tagId}').toSet();
    if (relationKeys.length != parsedNoteTags.length) {
      throw const FormatException('Archive contains duplicate note-tag links.');
    }
    for (final link in parsedNoteTags) {
      if (!noteIds.contains(link.noteId) || !tagIds.contains(link.tagId)) {
        throw const FormatException(
            'Archive contains an orphan note-tag link.');
      }
    }

    final revisionIds = parsedRevisions.map((item) => item.id).toSet();
    if (revisionIds.length != parsedRevisions.length) {
      throw const FormatException('Archive contains duplicate revision IDs.');
    }
    for (final revision in parsedRevisions) {
      if (!noteIds.contains(revision.noteId)) {
        throw const FormatException(
            'Archive contains an orphan note revision.');
      }
    }

    final taskIds = parsedTasks.map((item) => item.id).toSet();
    if (taskIds.length != parsedTasks.length) {
      throw const FormatException('Archive contains duplicate task IDs.');
    }

    var imported = 0;
    var skipped = 0;
    var importedTasks = 0;
    var skippedTasks = 0;
    var importedTags = 0;
    var skippedTags = 0;
    var importedRevisions = 0;
    var skippedRevisions = 0;
    final skippedNoteIds = <String>{};
    await _database.transaction(() async {
      for (final category in parsedCategories) {
        await _database.into(_database.categories).insertOnConflictUpdate(
              CategoriesCompanion.insert(
                id: category.id,
                name: category.name,
                createdAt: Value(category.createdAt),
                updatedAt: Value(category.updatedAt),
              ),
            );
      }

      final existingCategoryRows =
          await _database.select(_database.categories).get();
      final availableCategoryIds =
          existingCategoryRows.map((item) => item.id).toSet();

      for (final note in parsedNotes) {
        final existing = await (_database.select(_database.notes)
              ..where((row) => row.id.equals(note.id)))
            .getSingleOrNull();
        if (existing != null) {
          skipped++;
          skippedNoteIds.add(note.id);
          continue;
        }

        final categoryId = note.categoryId != null &&
                availableCategoryIds.contains(note.categoryId)
            ? note.categoryId
            : null;

        await _database.into(_database.notes).insert(
              NotesCompanion.insert(
                id: note.id,
                title: Value(note.title),
                documentContent: Value(note.documentContent),
                categoryId: Value(categoryId),
                createdAt: Value(note.createdAt),
                updatedAt: Value(note.updatedAt),
                isFavorite: Value(note.isFavorite),
                isArchived: Value(note.isArchived),
                isDeleted: Value(note.isDeleted),
                color: Value(note.color),
                sortOrder: Value(note.sortOrder),
              ),
            );
        imported++;
      }

      for (final tag in parsedTags) {
        final existing = await (_database.select(_database.tags)
              ..where((row) => row.id.equals(tag.id)))
            .getSingleOrNull();
        if (existing != null) {
          skippedTags++;
          continue;
        }
        await _database.into(_database.tags).insert(
              TagsCompanion.insert(
                id: tag.id,
                name: tag.name,
                color: Value(tag.color),
                createdAt: Value(tag.createdAt),
              ),
            );
        importedTags++;
      }

      final availableTags = await _database.select(_database.tags).get();
      final availableTagIds = availableTags.map((item) => item.id).toSet();
      for (final link in parsedNoteTags) {
        if (skippedNoteIds.contains(link.noteId) ||
            !availableTagIds.contains(link.tagId)) {
          continue;
        }
        final noteExists = await (_database.select(_database.notes)
              ..where((row) => row.id.equals(link.noteId)))
            .getSingleOrNull();
        if (noteExists == null) continue;
        await _database.into(_database.noteTags).insertOnConflictUpdate(
              NoteTagsCompanion.insert(
                noteId: link.noteId,
                tagId: link.tagId,
                createdAt: Value(link.createdAt),
              ),
            );
      }

      for (final revision in parsedRevisions) {
        if (skippedNoteIds.contains(revision.noteId)) {
          skippedRevisions++;
          continue;
        }
        final exists = await (_database.select(_database.notes)
              ..where((note) => note.id.equals(revision.noteId)))
            .getSingleOrNull();
        if (exists == null) continue;
        final revisionExists = await (_database.select(_database.noteRevisions)
              ..where((row) => row.id.equals(revision.id)))
            .getSingleOrNull();
        if (revisionExists != null) {
          skippedRevisions++;
          continue;
        }
        await _database.into(_database.noteRevisions).insert(
              NoteRevisionsCompanion.insert(
                id: revision.id,
                noteId: revision.noteId,
                title: revision.title,
                documentContent: revision.documentContent,
                createdAt: Value(revision.createdAt),
              ),
            );
        importedRevisions++;
      }

      for (final task in parsedTasks) {
        final existing = await (_database.select(_database.tasks)
              ..where((row) => row.id.equals(task.id)))
            .getSingleOrNull();
        if (existing != null) {
          skippedTasks++;
          continue;
        }
        await _database.into(_database.tasks).insert(
              TasksCompanion.insert(
                id: task.id,
                title: task.title,
                details: Value(task.details),
                dueAt: Value(task.dueAt),
                priority: Value(task.priority),
                isCompleted: Value(task.isCompleted),
                createdAt: Value(task.createdAt),
                updatedAt: Value(task.updatedAt),
                completedAt: Value(task.completedAt),
              ),
            );
        importedTasks++;
      }
    });

    return ArchiveImportResult(
      imported: imported,
      skipped: skipped,
      importedTasks: importedTasks,
      skippedTasks: skippedTasks,
      importedTags: importedTags,
      skippedTags: skippedTags,
      importedRevisions: importedRevisions,
      skippedRevisions: skippedRevisions,
    );
  }

  _ArchiveCategory _parseCategory(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid category.');
    }
    final id = value['id'];
    final name = value['name'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty) {
      throw const FormatException('Archive category ID or name is invalid.');
    }
    return _ArchiveCategory(
      id: id,
      name: name.trim(),
      createdAt: _date(value['createdAt']),
      updatedAt: _date(value['updatedAt']),
    );
  }

  _ArchiveNote _parseNote(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid note.');
    }
    final id = value['id'];
    final title = value['title'];
    final body = value['documentContent'];
    final categoryId = value['categoryId'];
    final favorite = value['isFavorite'];
    final archived = value['isArchived'];
    final deleted = value['isDeleted'];
    final sortOrder = value['sortOrder'];
    final color = value['color'];

    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        body is! String ||
        (categoryId != null && categoryId is! String) ||
        favorite is! bool ||
        archived is! bool ||
        deleted is! bool ||
        sortOrder is! int ||
        (color != null && color is! int)) {
      throw const FormatException('Archive note fields are invalid.');
    }

    return _ArchiveNote(
      id: id,
      title: title,
      documentContent: body,
      categoryId: categoryId as String?,
      createdAt: _date(value['createdAt']),
      updatedAt: _date(value['updatedAt']),
      isFavorite: favorite,
      isArchived: archived,
      isDeleted: deleted,
      color: color as int?,
      sortOrder: sortOrder,
    );
  }

  _ArchiveTag _parseTag(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid tag.');
    }
    final id = value['id'];
    final name = value['name'];
    final color = value['color'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        (color != null && color is! int)) {
      throw const FormatException('Archive tag fields are invalid.');
    }
    return _ArchiveTag(
      id: id,
      name: name.trim(),
      color: color as int?,
      createdAt: _date(value['createdAt']),
    );
  }

  _ArchiveNoteTag _parseNoteTag(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid note-tag link.');
    }
    final noteId = value['noteId'];
    final tagId = value['tagId'];
    if (noteId is! String ||
        noteId.trim().isEmpty ||
        tagId is! String ||
        tagId.trim().isEmpty) {
      throw const FormatException('Archive note-tag link fields are invalid.');
    }
    return _ArchiveNoteTag(
      noteId: noteId,
      tagId: tagId,
      createdAt: _date(value['createdAt']),
    );
  }

  _ArchiveRevision _parseRevision(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid revision.');
    }
    final id = value['id'];
    final noteId = value['noteId'];
    final title = value['title'];
    final body = value['documentContent'];
    if (id is! String ||
        id.trim().isEmpty ||
        noteId is! String ||
        noteId.trim().isEmpty ||
        title is! String ||
        body is! String) {
      throw const FormatException('Archive revision fields are invalid.');
    }
    return _ArchiveRevision(
      id: id,
      noteId: noteId,
      title: title,
      documentContent: body,
      createdAt: _date(value['createdAt']),
    );
  }

  _ArchiveTask _parseTask(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Archive contains an invalid task.');
    }
    final id = value['id'];
    final title = value['title'];
    final details = value['details'];
    final dueAt = value['dueAt'];
    final priority = value['priority'];
    final completed = value['isCompleted'];
    final completedAt = value['completedAt'];
    if (id is! String ||
        id.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        details is! String ||
        (dueAt != null && dueAt is! String) ||
        priority is! int ||
        completed is! bool ||
        (completedAt != null && completedAt is! String)) {
      throw const FormatException('Archive task fields are invalid.');
    }
    return _ArchiveTask(
      id: id,
      title: title,
      details: details,
      dueAt: dueAt == null ? null : _date(dueAt),
      priority: priority.clamp(0, 2).toInt(),
      isCompleted: completed,
      createdAt: _date(value['createdAt']),
      updatedAt: _date(value['updatedAt']),
      completedAt: completedAt == null ? null : _date(completedAt),
    );
  }

  DateTime _date(Object? value) {
    if (value is! String) {
      throw const FormatException('Archive contains an invalid timestamp.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException('Archive contains an invalid timestamp.');
    }
    return parsed.toUtc();
  }
}

class ArchiveImportResult {
  const ArchiveImportResult({
    required this.imported,
    required this.skipped,
    this.importedTasks = 0,
    this.skippedTasks = 0,
    this.importedTags = 0,
    this.skippedTags = 0,
    this.importedRevisions = 0,
    this.skippedRevisions = 0,
  });

  final int imported;
  final int skipped;
  final int importedTasks;
  final int skippedTasks;
  final int importedTags;
  final int skippedTags;
  final int importedRevisions;
  final int skippedRevisions;
}

class _ArchiveCategory {
  const _ArchiveCategory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class _ArchiveNote {
  const _ArchiveNote({
    required this.id,
    required this.title,
    required this.documentContent,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.isArchived,
    required this.isDeleted,
    required this.color,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final String documentContent;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isArchived;
  final bool isDeleted;
  final int? color;
  final int sortOrder;
}

class _ArchiveTask {
  const _ArchiveTask({
    required this.id,
    required this.title,
    required this.details,
    required this.dueAt,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });

  final String id;
  final String title;
  final String details;
  final DateTime? dueAt;
  final int priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
}

class _ArchiveTag {
  const _ArchiveTag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int? color;
  final DateTime createdAt;
}

class _ArchiveNoteTag {
  const _ArchiveNoteTag({
    required this.noteId,
    required this.tagId,
    required this.createdAt,
  });

  final String noteId;
  final String tagId;
  final DateTime createdAt;
}

class _ArchiveRevision {
  const _ArchiveRevision({
    required this.id,
    required this.noteId,
    required this.title,
    required this.documentContent,
    required this.createdAt,
  });

  final String id;
  final String noteId;
  final String title;
  final String documentContent;
  final DateTime createdAt;
}
