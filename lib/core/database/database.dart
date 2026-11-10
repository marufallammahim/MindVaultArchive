import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

@DriftDatabase(tables: [Notes, Categories, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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
      await (delete(attachments)..where((item) => item.noteId.equals(id))).go();
      await (delete(notes)..where((note) => note.id.equals(id))).go();
    });
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
      )..where((category) => category.id.equals(id))).go();
    });
  }

  Future<void> saveNoteContent(String id, String title, String content) {
    return transaction(() async {
      final existing = await (select(
        notes,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null) {
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
