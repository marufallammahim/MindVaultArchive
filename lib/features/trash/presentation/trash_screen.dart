import 'package:drift/drift.dart' hide Column;
import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  void _showActionError(BuildContext context, String action) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not $action. Please try again.')),
    );
  }

  Future<void> _permanentlyDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.delete_forever_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
          size: 36,
        ),
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
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(databaseProvider).permanentlyDeleteNote(note.id);
    } catch (_) {
      if (!context.mounted) return;
      _showActionError(context, 'delete this note permanently');
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
                Text(
                  'Restore notes whenever you need them. Permanently deleted notes cannot be recovered.',
                ),
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
            return Center(
              child: NeoBrutalistPanel(
                padding: const EdgeInsets.all(18),
                child: Text('Could not load Trash: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: const [
                FeatureHero(
                  icon: Icons.delete_outline_rounded,
                  title: 'Trash is empty.',
                  subtitle:
                      'Notes you move here can be restored or deleted forever.',
                  compact: true,
                ),
                SizedBox(height: 24),
                NeoBrutalistPanel(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined,
                        size: 64,
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Nothing to clean up right now.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            itemCount: notes.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: FeatureHero(
                    icon: Icons.delete_outline_rounded,
                    title: 'Recently removed',
                    subtitle: 'Restore a note to your archive or remove it permanently.',
                    compact: true,
                  ),
                );
              }
              final note = notes[index - 1];
              return NeoBrutalistPanel(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.pink,
                    foregroundColor: AppTheme.ink,
                    child: Icon(Icons.delete_outline_rounded),
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
                        try {
                          await db.setDeleted(note.id, false);
                        } catch (_) {
                          if (!context.mounted) return;
                          _showActionError(context, 'restore this note');
                        }
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
              );
            },
          );
        },
      ),
    );
  }
}
