import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _completed = false;

  Future<void> _editTask({VaultTask? task}) async {
    final title = TextEditingController(text: task?.title ?? '');
    final details = TextEditingController(text: task?.details ?? '');
    var priority = task?.priority ?? 1;
    DateTime? dueAt = task?.dueAt;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: Text(task == null ? 'New task' : 'Edit task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: title,
                    autofocus: true,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Task title')),
                TextField(
                    controller: details,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Details')),
                DropdownButtonFormField<int>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Low')),
                    DropdownMenuItem(value: 1, child: Text('Normal')),
                    DropdownMenuItem(value: 2, child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) refresh(() => priority = value);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(dueAt == null
                      ? 'No due date'
                      : 'Due ${MaterialLocalizations.of(context).formatMediumDate(dueAt!)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dueAt ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) refresh(() => dueAt = date);
                    },
                  ),
                ),
                if (dueAt != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => refresh(() => dueAt = null),
                      child: const Text('Clear due date'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    final taskTitle = title.text.trim();
    final taskDetails = details.text;
    title.dispose();
    details.dispose();
    if (saved != true || taskTitle.isEmpty || !mounted) return;

    try {
      await ref.read(databaseProvider).saveTask(
            id: task?.id ?? const Uuid().v4(),
            title: taskTitle,
            details: taskDetails,
            priority: priority,
            dueAt: dueAt,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save task: $error')),
      );
    }
  }

  String _priorityLabel(int value) => value == 2
      ? 'High'
      : value == 0
          ? 'Low'
          : 'Normal';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.tasks)
      ..where((task) => task.isCompleted.equals(_completed))
      ..orderBy([
        (task) => OrderingTerm.asc(task.dueAt),
        (task) => OrderingTerm.desc(task.updatedAt),
      ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTask(),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('To do')),
                ButtonSegment(value: true, label: Text('Completed')),
              ],
              selected: {_completed},
              onSelectionChanged: (value) =>
                  setState(() => _completed = value.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<VaultTask>>(
              stream: query.watch(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Could not load tasks: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.checklist_rounded, size: 64),
                        const SizedBox(height: 12),
                        Text(
                            _completed ? 'No completed tasks' : 'No tasks yet'),
                        const SizedBox(height: 6),
                        const Text('Capture your next step here.'),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final overdue = !item.isCompleted &&
                        item.dueAt != null &&
                        DateUtils.dateOnly(item.dueAt!)
                            .isBefore(DateUtils.dateOnly(DateTime.now()));
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: item.isCompleted,
                          onChanged: (value) =>
                              db.setTaskCompleted(item.id, value ?? false),
                        ),
                        title: Text(item.title,
                            style: item.isCompleted
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough)
                                : null),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.details.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item.details,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 12,
                              children: [
                                Text('Priority: ${_priorityLabel(item.priority)}'),
                                if (item.dueAt != null)
                                  Text(
                                      'Due ${MaterialLocalizations.of(context).formatShortDate(item.dueAt!)}',
                                      style: TextStyle(
                                        color: overdue
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : null,
                                        fontWeight:
                                            overdue ? FontWeight.bold : null,
                                      )),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'edit') {
                              await _editTask(task: item);
                            } else if (action == 'delete') {
                              await db.deleteTask(item.id);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
