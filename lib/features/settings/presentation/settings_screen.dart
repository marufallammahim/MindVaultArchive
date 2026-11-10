import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'New category' : 'Rename category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Category name',
            hintText: 'e.g. Work, Ideas, Personal',
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
          .saveCategory(category?.id ?? const Uuid().v4(), name);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save category: $error')),
      );
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          'Notes in “${category.name}” will remain in your archive without a category.',
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
    try {
      await ref.read(databaseProvider).deleteCategory(category.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete category: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Appearance'),
            subtitle: Text('Choose how MindVault Archive looks'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_suggest_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Categories'),
            subtitle: const Text(
              'Create, rename, and organize note categories',
            ),
            trailing: IconButton(
              tooltip: 'Add category',
              icon: const Icon(Icons.add),
              onPressed: () => _editCategory(context, ref),
            ),
          ),
          StreamBuilder<List<Category>>(
            stream:
                (db.select(
                      db.categories,
                    )..orderBy([(category) => OrderingTerm.asc(category.name)]))
                    .watch(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Could not load categories: ${snapshot.error}');
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No categories yet. Add one to organize notes.'),
                );
              }
              return Column(
                children: [
                  for (final category in categories)
                    ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(category.name),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'rename') {
                            _editCategory(context, ref, category: category);
                          } else if (action == 'delete') {
                            _deleteCategory(context, ref, category);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'rename', child: Text('Rename')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: const Text('Tags'),
            subtitle: const Text('Create and manage reusable note tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tags'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('App lock'),
            subtitle: const Text('Protect app access with a six-digit PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/app-lock'),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Archive transfer'),
            subtitle: const Text('Export or import a portable JSON archive'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/archive-tools'),
          ),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Storage'),
            subtitle: Text('Notes are stored locally on this device'),
            leading: Icon(Icons.storage_outlined),
          ),
        ],
      ),
    );
  }
}
