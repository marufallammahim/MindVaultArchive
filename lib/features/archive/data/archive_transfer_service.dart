import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mindvault_archive/core/database/database.dart';

/// Portable, versioned JSON transfer for notes and categories.
///
/// This first format intentionally excludes attachment file bytes. It never
/// serializes private device paths, and import never overwrites existing notes.
class ArchiveTransferService {
  ArchiveTransferService(this._database);

  final AppDatabase _database;

  static const formatName = 'mindvault-archive';
  static const formatVersion = 1;

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
      },
      'limitations': <String>[
        'Attachment file bytes are not included in format version 1.',
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
        decoded['version'] != formatVersion) {
      throw const FormatException('Unsupported MindVault archive format.');
    }

    final contents = decoded['contents'];
    if (contents is! Map<String, dynamic>) {
      throw const FormatException('Archive contents are missing.');
    }

    final rawCategories = contents['categories'];
    final rawNotes = contents['notes'];
    if (rawCategories is! List || rawNotes is! List) {
      throw const FormatException('Archive categories or notes are invalid.');
    }

    final parsedCategories = rawCategories.map(_parseCategory).toList();
    final parsedNotes = rawNotes.map(_parseNote).toList();

    final categoryIds = parsedCategories.map((item) => item.id).toSet();
    if (categoryIds.length != parsedCategories.length) {
      throw const FormatException('Archive contains duplicate category IDs.');
    }
    final noteIds = parsedNotes.map((item) => item.id).toSet();
    if (noteIds.length != parsedNotes.length) {
      throw const FormatException('Archive contains duplicate note IDs.');
    }

    var imported = 0;
    var skipped = 0;
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
    });

    return ArchiveImportResult(imported: imported, skipped: skipped);
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
  const ArchiveImportResult({required this.imported, required this.skipped});

  final int imported;
  final int skipped;
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
