import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class RevisionHistoryScreen extends ConsumerWidget {
  const RevisionHistoryScreen({super.key, required this.noteId});

  final String noteId;

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    NoteRevision revision,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore this version?'),
        content: const Text(
          'The current note will be kept in history before this version is restored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Restore version'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(databaseProvider).restoreRevision(noteId, revision.id);
      if (context.mounted) context.pop(true);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not restore version: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.noteRevisions)
      ..where((revision) => revision.noteId.equals(noteId))
      ..orderBy([(revision) => OrderingTerm.desc(revision.createdAt)]);
    return Scaffold(
      appBar: AppBar(title: const Text('Version history')),
      body: StreamBuilder<List<NoteRevision>>(
        stream: query.watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load history: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final revisions = snapshot.data!;
          if (revisions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No previous versions yet. MindVault keeps up to 30 earlier versions as you edit a note.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            itemCount: revisions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final revision = revisions[index];
              return Card(
                child: ListTile(
                  title: Text(
                    revision.title.isEmpty ? 'Untitled' : revision.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MaterialLocalizations.of(context)
                            .formatFullDate(revision.createdAt),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revision.documentContent,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Restore this version',
                    icon: const Icon(Icons.restore),
                    onPressed: () => _restore(context, ref, revision),
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
