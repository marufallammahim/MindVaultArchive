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

  test('creates, updates, completes and deletes a task', () async {
    await database.saveTask(
      id: 'task-1',
      title: 'Prepare project plan',
      details: 'Write the first milestone',
      priority: 2,
      dueAt: DateTime.utc(2026, 12, 1),
    );

    var task = await (database.select(database.tasks)
      ..where((row) => row.id.equals('task-1'))).getSingle();
    expect(task.title, 'Prepare project plan');
    expect(task.priority, 2);
    expect(task.isCompleted, isFalse);

    await database.saveTask(
      id: 'task-1',
      title: 'Updated plan',
      details: 'Review milestone',
      priority: 1,
    );
    task = await (database.select(database.tasks)
      ..where((row) => row.id.equals('task-1'))).getSingle();
    expect(task.title, 'Updated plan');
    expect(task.dueAt, isNull);

    await database.setTaskCompleted('task-1', true);
    task = await (database.select(database.tasks)
      ..where((row) => row.id.equals('task-1'))).getSingle();
    expect(task.isCompleted, isTrue);
    expect(task.completedAt, isNotNull);

    await database.deleteTask('task-1');
    expect(await database.select(database.tasks).get(), isEmpty);
  });

  test('rejects empty task titles', () async {
    await expectLater(
      database.saveTask(
        id: 'invalid',
        title: '   ',
        details: '',
        priority: 0,
      ),
      throwsArgumentError,
    );
    expect(await database.select(database.tasks).get(), isEmpty);
  });

  test('clamps task priority to supported range', () async {
    await database.saveTask(
      id: 'task-priority',
      title: 'Priority',
      details: '',
      priority: 99,
    );
    final task = await (database.select(database.tasks)
      ..where((row) => row.id.equals('task-priority'))).getSingle();
    expect(task.priority, 2);
  });
}
