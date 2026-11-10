import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

@DataClassName('Note')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get documentContent => text().withDefault(const Constant(''))();
  TextColumn get categoryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('VaultTask')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get details => text().withDefault(const Constant(''))();
  TextColumn get noteId => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Tag')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('NoteTag')
class NoteTags extends Table {
  TextColumn get noteId => text()();
  TextColumn get tagId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DataClassName('NoteRevision')
class NoteRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get title => text()();
  TextColumn get documentContent => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Attachment')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text()();
  TextColumn get type => text()();
  TextColumn get localPath => text()();
  TextColumn get filename => text()();
  IntColumn get duration => integer().nullable()();
  IntColumn get documentPosition => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metadata => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Notes,
    Categories,
    Attachments,
    Tasks,
    Tags,
    NoteTags,
    NoteRevisions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(tasks);
          }
          if (from < 3) {
            await m.createTable(tags);
            await m.createTable(noteTags);
          }
          if (from < 4) {
            await m.createTable(noteRevisions);
          }
          if (from >= 2 && from < 5) {
            await m.addColumn(tasks, tasks.noteId);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> saveTask({
    required String id,
    required String title,
    required String details,
    required int priority,
    DateTime? dueAt,
    String? noteId,
  }) async {
    final normalizedTitle = title.trim();
    if (noteId != null) {
      final linkedNote = await (select(
        notes,
      )..where((note) => note.id.equals(noteId)))
          .getSingleOrNull();
      if (linkedNote == null || linkedNote.isDeleted) {
        throw ArgumentError.value(noteId, 'noteId', 'Linked note not found.');
      }
    }
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }
    final existing = await (select(
      tasks,
    )..where((task) => task.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await into(tasks).insert(
        TasksCompanion.insert(
          id: id,
          title: normalizedTitle,
          details: Value(details.trim()),
          priority: Value(priority.clamp(0, 2).toInt()),
          dueAt: Value(dueAt),
          noteId: Value(noteId),
        ),
      );
    } else {
      await update(tasks).replace(
        existing.copyWith(
          title: normalizedTitle,
          details: details.trim(),
          priority: priority.clamp(0, 2).toInt(),
          dueAt: Value(dueAt),
          noteId: Value(noteId),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> setTaskCompleted(String id, bool completed) {
    return (update(tasks)..where((task) => task.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(completed),
        completedAt: Value(completed ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteTask(String id) {
    return (delete(tasks)..where((task) => task.id.equals(id))).go();
  }

  Future<void> saveTag(String id, String name, {int? color}) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Tag name cannot be empty.');
    }
    await into(tags).insertOnConflictUpdate(
      TagsCompanion.insert(id: id, name: normalizedName, color: Value(color)),
    );
  }

  Future<void> deleteTag(String id) {
    return transaction(() async {
      await (delete(noteTags)..where((item) => item.tagId.equals(id))).go();
      await (delete(tags)..where((tag) => tag.id.equals(id))).go();
    });
  }

  Future<void> setNoteTags(String noteId, List<String> tagIds) async {
    final uniqueIds = tagIds.toSet().toList();
    final available = await (select(
      tags,
    )..where((tag) => tag.id.isIn(uniqueIds)))
        .get();
    if (available.length != uniqueIds.length) {
      throw ArgumentError('One or more selected tags do not exist.');
    }
    await transaction(() async {
      final existingNote = await (select(
        notes,
      )..where((note) => note.id.equals(noteId)))
          .getSingleOrNull();
      if (existingNote == null) {
        await into(notes).insert(NotesCompanion.insert(id: noteId));
      }
      await (delete(
        noteTags,
      )..where((item) => item.noteId.equals(noteId)))
          .go();
      for (final tagId in uniqueIds) {
        await into(noteTags)
            .insert(NoteTagsCompanion.insert(noteId: noteId, tagId: tagId));
      }
      await (update(notes)..where((note) => note.id.equals(noteId))).write(
        NotesCompanion(updatedAt: Value(DateTime.now())),
      );
    });
  }

  Future<void> setNoteCategory(String noteId, String? categoryId) async {
    if (categoryId != null) {
      final category = await (select(
        categories,
      )..where((item) => item.id.equals(categoryId)))
          .getSingleOrNull();
      if (category == null) {
        throw ArgumentError.value(
          categoryId,
          'categoryId',
          'Category not found.',
        );
      }
    }
    final existing = await (select(
      notes,
    )..where((note) => note.id.equals(noteId)))
        .getSingleOrNull();
    if (existing == null) {
      await into(notes).insert(
        NotesCompanion.insert(id: noteId, categoryId: Value(categoryId)),
      );
    } else {
      await (update(notes)..where((note) => note.id.equals(noteId))).write(
        NotesCompanion(
          categoryId: Value(categoryId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> setPinned(String id, bool pinned) {
    return (update(notes)..where((note) => note.id.equals(id))).write(
      NotesCompanion(
        sortOrder: Value(pinned ? 1 : 0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setNoteColor(String id, int? color) async {
    final existing = await (select(
      notes,
    )..where((note) => note.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await into(notes)
          .insert(NotesCompanion.insert(id: id, color: Value(color)));
      return;
    }
    await (update(notes)..where((note) => note.id.equals(id))).write(
      NotesCompanion(color: Value(color), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> setFavorite(String id, bool value) {
    return (update(notes)..where((note) => note.id.equals(id))).write(
      NotesCompanion(
        isFavorite: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setArchived(String id, bool value) {
    return (update(notes)..where((note) => note.id.equals(id))).write(
      NotesCompanion(
        isArchived: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setDeleted(String id, bool value) {
    return (update(notes)..where((note) => note.id.equals(id))).write(
      NotesCompanion(isDeleted: Value(value), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> permanentlyDeleteNote(String id) {
    return transaction(() async {
      await (update(tasks)..where((task) => task.noteId.equals(id))).write(
        const TasksCompanion(noteId: Value(null)),
      );
      await (delete(attachments)..where((item) => item.noteId.equals(id))).go();
      await (delete(noteTags)..where((item) => item.noteId.equals(id))).go();
      await (delete(
        noteRevisions,
      )..where((item) => item.noteId.equals(id)))
          .go();
      await (delete(notes)..where((note) => note.id.equals(id))).go();
    });
  }

  Future<void> restoreRevision(String noteId, String revisionId) async {
    final revision = await (select(noteRevisions)
          ..where(
            (item) => item.id.equals(revisionId) & item.noteId.equals(noteId),
          ))
        .getSingleOrNull();
    if (revision == null) {
      throw ArgumentError.value(
        revisionId,
        'revisionId',
        'Revision not found.',
      );
    }
    await saveNoteContent(noteId, revision.title, revision.documentContent);
  }

  Future<void> saveCategory(String id, String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }
    await into(categories).insertOnConflictUpdate(
      CategoriesCompanion.insert(
        id: id,
        name: normalizedName,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteCategory(String id) {
    return transaction(() async {
      await (update(notes)..where((note) => note.categoryId.equals(id))).write(
        const NotesCompanion(categoryId: Value(null)),
      );
      await (delete(
        categories,
      )..where((category) => category.id.equals(id)))
          .go();
    });
  }

  Future<void> saveNoteContent(String id, String title, String content) {
    return transaction(() async {
      final existing = await (select(
        notes,
      )..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (existing != null) {
        if (existing.title != title || existing.documentContent != content) {
          await into(noteRevisions).insert(
            NoteRevisionsCompanion.insert(
              id: const Uuid().v4(),
              noteId: id,
              title: existing.title,
              documentContent: existing.documentContent,
            ),
          );
          final history = await (select(noteRevisions)
                ..where((revision) => revision.noteId.equals(id))
                ..orderBy([
                  (revision) => OrderingTerm.desc(revision.createdAt),
                ]))
              .get();
          if (history.length > 30) {
            final expiredIds = history.skip(30).map((item) => item.id).toList();
            await (delete(
              noteRevisions,
            )..where((revision) => revision.id.isIn(expiredIds)))
                .go();
          }
        }
        await update(notes).replace(
          existing.copyWith(
            title: title,
            documentContent: content,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await into(notes).insert(
          NotesCompanion.insert(
            id: id,
            title: Value(title),
            documentContent: Value(content),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final folder = await getApplicationDocumentsDirectory();
    final file = File(p.join(folder.path, 'mindvault_archive.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
