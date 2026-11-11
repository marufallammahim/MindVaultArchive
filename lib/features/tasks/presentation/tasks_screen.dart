import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _completed = false;
  bool _progressMode = false;
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());

  Future<void> _editTask({VaultTask? task}) async {
    final db = ref.read(databaseProvider);
    final noteQuery = db.select(db.notes)
      ..where((note) => note.isDeleted.equals(false))
      ..orderBy([(note) => OrderingTerm.desc(note.updatedAt)]);
    final availableNotes = await noteQuery.get();
    if (!mounted) return;

    final title = TextEditingController(text: task?.title ?? '');
    final details = TextEditingController(text: task?.details ?? '');
    var priority = task?.priority ?? 1;
    DateTime? dueAt = task?.dueAt ?? _selectedDay;
    var linkedNoteId = task?.noteId ?? widget.noteId;
    if (linkedNoteId != null &&
        !availableNotes.any((note) => note.id == linkedNoteId)) {
      linkedNoteId = null;
    }

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
                  decoration: const InputDecoration(labelText: 'Task title'),
                ),
                TextField(
                  controller: details,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Details'),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: linkedNoteId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Linked note',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No linked note'),
                    ),
                    for (final note in availableNotes)
                      DropdownMenuItem<String?>(
                        value: note.id,
                        child: Text(
                          note.title.trim().isEmpty ? 'Untitled' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => refresh(() => linkedNoteId = value),
                ),
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
                  title: Text(
                    dueAt == null
                        ? 'No due date'
                        : 'Due ${MaterialLocalizations.of(context).formatMediumDate(dueAt!)}',
                  ),
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
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
      await db.saveTask(
        id: task?.id ?? const Uuid().v4(),
        title: taskTitle,
        details: taskDetails,
        priority: priority,
        dueAt: dueAt,
        noteId: linkedNoteId,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save task: $error')));
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
      ..where((task) {
        final completion = task.isCompleted.equals(_completed);
        if (widget.noteId == null) return completion;
        return completion & task.noteId.equals(widget.noteId!);
      })
      ..orderBy([
        (task) => OrderingTerm.asc(task.dueAt),
        (task) => OrderingTerm.desc(task.updatedAt),
      ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'To-do list' : 'Note tasks'),
        actions: [
          IconButton(
            tooltip: _progressMode ? 'Back to tasks' : 'Progress calendar',
            onPressed: () => setState(() => _progressMode = !_progressMode),
            icon: Icon(
              _progressMode
                  ? Icons.checklist_rounded
                  : Icons.calendar_month_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editTask(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: _progressMode
          ? _progressView(db)
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    MaterialLocalizations.of(context).formatMonthYear(_selectedDay),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Choose date',
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDay,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _selectedDay = DateUtils.dateOnly(picked));
                    }
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = DateUtils.dateOnly(DateTime.now())
                    .add(Duration(days: index - 3));
                final selected = DateUtils.isSameDay(day, _selectedDay);
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFD65A)
                          : const Color(0xFF1A1A1E),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFFD65A)
                            : Colors.white.withValues(alpha: .08),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          MaterialLocalizations.of(context)
                              .formatShortWeekday(day)
                              .substring(0, 3),
                          style: TextStyle(
                            color: selected ? Colors.black54 : Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: selected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _completed ? 'completed tasks' : 'your next moves',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                  ),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('To-do')),
                    ButtonSegment(value: true, label: Text('Done')),
                  ],
                  selected: {_completed},
                  onSelectionChanged: (value) =>
                      setState(() => _completed = value.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<VaultTask>>(
              stream: query.watch(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load tasks: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.checklist_rounded,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 14),
                          Text(
                            _completed
                                ? 'Nothing completed yet'
                                : 'Nothing on your list',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          const Text('Add a task and make your next move.'),
                        ],
                      ),
                    ),
                  );
                }
                final colors = [
                  const Color(0xFFE97855),
                  const Color(0xFFA8D76D),
                  const Color(0xFFF0C94F),
                  const Color(0xFF4D91F0),
                ];
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final overdue = !item.isCompleted &&
                        item.dueAt != null &&
                        DateUtils.dateOnly(item.dueAt!)
                            .isBefore(DateUtils.dateOnly(DateTime.now()));
                    final color = colors[index % colors.length];
                    final foreground = color.computeLuminance() > 0.48
                        ? const Color(0xFF171717)
                        : Colors.white;
                    return Material(
                      color: color,
                      borderRadius: BorderRadius.circular(19),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _editTask(task: item),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: foreground,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        decoration: item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (item.details.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        item.details,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: foreground.withValues(
                                              alpha: 0.82),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 7,
                                      runSpacing: 5,
                                      children: [
                                        _taskPill(foreground,
                                            _priorityLabel(item.priority)),
                                        if (item.noteId != null)
                                          _taskPill(foreground, 'Linked note'),
                                        if (item.dueAt != null)
                                          _taskPill(
                                            overdue ? Colors.white : foreground,
                                            'Due ${MaterialLocalizations.of(context).formatShortDate(item.dueAt!)}',
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  IconButton.filled(
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF171717),
                                      foregroundColor: Colors.white,
                                    ),
                                    tooltip: item.isCompleted
                                        ? 'Mark incomplete'
                                        : 'Mark complete',
                                    onPressed: () => db.setTaskCompleted(
                                      item.id,
                                      !item.isCompleted,
                                    ),
                                    icon: Icon(
                                      item.isCompleted
                                          ? Icons.check_rounded
                                          : Icons.circle_outlined,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_horiz,
                                        color: foreground),
                                    onSelected: (action) async {
                                      if (action == 'edit') {
                                        await _editTask(task: item);
                                      } else if (action == 'delete') {
                                        await db.deleteTask(item.id);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 10),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF171719).withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _taskDockItem(
                Icons.home_rounded,
                'Home',
                false,
                () => Navigator.of(context).pop(),
              ),
              _taskDockItem(
                Icons.checklist_rounded,
                'List',
                !_progressMode,
                () => setState(() {
                  _progressMode = false;
                  _completed = false;
                }),
              ),
              _taskDockItem(
                Icons.insights_rounded,
                'Stats',
                _progressMode,
                () => setState(() => _progressMode = true),
              ),
              _taskDockItem(
                Icons.settings_rounded,
                'Settings',
                false,
                () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressView(AppDatabase db) {
    final allTasks = db.select(db.tasks)
      ..where((task) {
        if (widget.noteId == null) return const Constant(true);
        return task.noteId.equals(widget.noteId!);
      });
    return StreamBuilder<List<VaultTask>>(
      stream: allTasks.watch(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load progress: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = snapshot.data!;
        final completed = tasks.where((task) => task.isCompleted).length;
        final dueOnDay = tasks.where((task) =>
            task.dueAt != null &&
            DateUtils.isSameDay(task.dueAt, _selectedDay)).length;
        final progress = tasks.isEmpty ? 0.0 : completed / tasks.length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              'Your consistency, one day at a time.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: .07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Task completion',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xFFFFD65A),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFFFFD65A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _progressMetric('Completed', '$completed')),
                      Expanded(child: _progressMetric('Remaining', '${tasks.length - completed}')),
                      Expanded(child: _progressMetric('Total', '${tasks.length}')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              MaterialLocalizations.of(context).formatMonthYear(_selectedDay),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF171719),
                borderRadius: BorderRadius.circular(24),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDay,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (day) => setState(
                  () => _selectedDay = DateUtils.dateOnly(day),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD65A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded,
                      color: Color(0xFF171719), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scheduled for selected day',
                          style: TextStyle(
                            color: Color(0xFF171719),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$dueOnDay tasks',
                          style: const TextStyle(
                            color: Color(0xFF171719),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _progressMetric(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .58),
              fontSize: 11,
            ),
          ),
        ],
      );

  Widget _taskDockItem(
    IconData icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final foreground = selected
        ? const Color(0xFF171719)
        : Colors.white.withValues(alpha: 0.68);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD65A) : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 21),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskPill(Color foreground, String label) => DecoratedBox(
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
