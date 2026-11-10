import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class ArchiveTimelineScreen extends ConsumerWidget {
  const ArchiveTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Memory timeline')),
      body: StreamBuilder<List<Note>>(
        stream: (db.select(db.notes)..where((n) => n.isDeleted.equals(false)))
            .watch(),
        builder: (context, noteSnapshot) {
          if (noteSnapshot.hasError)
            return _TimelineMessage(
                'Could not load notes: ${noteSnapshot.error}');
          if (!noteSnapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return StreamBuilder<List<VaultTask>>(
            stream: db.select(db.tasks).watch(),
            builder: (context, taskSnapshot) {
              if (taskSnapshot.hasError)
                return _TimelineMessage(
                    'Could not load tasks: ${taskSnapshot.error}');
              if (!taskSnapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final entries = <_TimelineEntry>[
                for (final note in noteSnapshot.data!)
                  _TimelineEntry(
                      date: note.updatedAt,
                      title: note.title.trim().isEmpty
                          ? 'Untitled note'
                          : note.title,
                      detail:
                          note.isArchived ? 'Archived note' : 'Note updated',
                      icon: Icons.note_alt_outlined,
                      noteId: note.id),
                for (final task in taskSnapshot.data!)
                  _TimelineEntry(
                      date: task.updatedAt,
                      title: task.title,
                      detail:
                          task.isCompleted ? 'Task completed' : 'Task updated',
                      icon: task.isCompleted
                          ? Icons.task_alt
                          : Icons.pending_actions_outlined),
              ]..sort((a, b) => b.date.compareTo(a.date));
              if (entries.isEmpty) {
                return const _TimelineMessage(
                    'Your timeline will appear here as you create notes and tasks.');
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 52),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Icon(entry.icon)),
                    title: Text(entry.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${entry.detail} • ${MaterialLocalizations.of(context).formatMediumDate(entry.date)}'),
                    trailing: entry.noteId == null
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: entry.noteId == null
                        ? null
                        : () => context.push('/editor/${entry.noteId}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry(
      {required this.date,
      required this.title,
      required this.detail,
      required this.icon,
      this.noteId});
  final DateTime date;
  final String title;
  final String detail;
  final IconData icon;
  final String? noteId;
}

class _TimelineMessage extends StatelessWidget {
  const _TimelineMessage(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center)));
}
