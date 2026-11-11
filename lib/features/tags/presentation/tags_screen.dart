import 'package:drift/drift.dart' show OrderingTerm;
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  Future<void> _addTag(BuildContext context, WidgetRef ref, {Tag? tag}) async {
    final controller = TextEditingController(text: tag?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tag == null ? 'New tag' : 'Rename tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            hintText: 'e.g. Research, Important, Idea',
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    try {
      await ref
          .read(databaseProvider)
          .saveTag(tag?.id ?? const Uuid().v4(), name, color: tag?.color);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save tag: $error')));
    }
  }

  Future<void> _deleteTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(
          'Remove the tag “${tag.name}” from all notes? The notes themselves will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(databaseProvider).deleteTag(tag.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.tags)
      ..orderBy([(tag) => OrderingTerm.asc(tag.name)]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            tooltip: 'Add tag',
            onPressed: () => _addTag(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Tag>>(
        stream: query.watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load tags: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tags = snapshot.data!;
          if (tags.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No tags yet. Create tags to add another layer of organization to your notes.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: tags.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: FeatureHero(
                    icon: Icons.sell_rounded,
                    title: 'Organize by tag',
                    subtitle:
                        'Create lightweight labels to connect related notes.',
                    compact: true,
                  ),
                );
              }
              final tag = tags[index - 1];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: Text(tag.name),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'rename') {
                        _addTag(context, ref, tag: tag);
                      } else if (action == 'delete') {
                        _deleteTag(context, ref, tag);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTag(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New tag'),
      ),
    );
  }
}
