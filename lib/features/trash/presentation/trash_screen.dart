import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  Future<void> _permanentlyDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded,
            color: Theme.of(dialogContext).colorScheme.error, size: 36),
        title: const Text('Delete permanently?'),
        content: Text(
          '"${note.title.trim().isEmpty ? 'Untitled note' : note.title}" '
          'will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep note'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete forever'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).permanentlyDeleteNote(note.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.notes)
      ..where((note) => note.isDeleted.equals(true))
      ..orderBy([(note) => OrderingTerm.desc(note.updatedAt)]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          IconButton(
            tooltip: 'About Trash',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'MindVault Archive',
              children: const [
                Text('Restore notes whenever you need them. Permanently deleted notes cannot be recovered.'),
              ],
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: query.watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load Trash: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 14),
                    Text('Trash is empty',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    const SizedBox(height: 6),
                    Text('Notes you move here can be restored or deleted forever.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                      child: const Icon(Icons.delete_outline_rounded),
                    ),
                    title: Text(
                      note.title.trim().isEmpty ? 'Untitled note' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      note.documentContent.trim().isEmpty
                          ? 'No additional content'
                          : note.documentContent.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Trash actions',
                      onSelected: (value) async {
                        if (value == 'restore') {
                          await db.setDeleted(note.id, false);
                        } else if (value == 'delete') {
                          await _permanentlyDelete(context, ref, note);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'restore',
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.restore_rounded),
                            title: Text('Restore'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            dense: true,
                            leading: Icon(Icons.delete_forever_rounded),
                            title: Text('Delete forever'),
                          ),
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
    );
  }
}
