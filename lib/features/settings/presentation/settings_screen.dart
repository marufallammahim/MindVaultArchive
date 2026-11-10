import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _palette = <Color>[
    Color(0xFF7A1735),
    Color(0xFFB64D69),
    Color(0xFFE97855),
    Color(0xFFFFC94A),
    Color(0xFFA8D76D),
    Color(0xFF4D91F0),
    Color(0xFF9270D8),
    Color(0xFF24A89A),
    Color(0xFF64748B),
    Color(0xFF202124),
  ];

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider);
    final name = TextEditingController(text: profile.name);
    var avatar = profile.avatarBase64;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: const Text('Your profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: avatar == null
                    ? null
                    : MemoryImage(base64Decode(avatar!)),
                child: avatar == null
                    ? const Icon(Icons.person_outline, size: 38)
                    : null,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  final bytes = result?.files.single.bytes;
                  if (bytes == null) return;
                  if (bytes.length > 1500 * 1024) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Choose an image smaller than 1.5 MB.'),
                      ),
                    );
                    return;
                  }
                  refresh(() => avatar = base64Encode(bytes));
                },
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Choose photo'),
              ),
              if (avatar != null)
                TextButton(
                  onPressed: () => refresh(() => avatar = null),
                  child: const Text('Remove photo'),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: name,
                autofocus: true,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  hintText: 'Enter your name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save profile'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await ref.read(userProfileProvider.notifier).save(
            name: name.text,
            avatarBase64: avatar,
          );
    }
    name.dispose();
  }

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
    final amoledEnabled = ref.watch(amoledThemeProvider);
    final accent = ref.watch(accentColorProvider);
    final profile = ref.watch(userProfileProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          Text('PERSONAL SPACE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  )),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 26,
                backgroundImage: profile.avatar,
                child: profile.avatar == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              title: Text(profile.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Name and profile picture'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editProfile(context, ref),
            ),
          ),
          const SizedBox(height: 28),
          Text('APPEARANCE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  )),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Color mode',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
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
                    onSelectionChanged: (selection) => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(selection.first),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('AMOLED black'),
                    subtitle: const Text(
                      'Pure black canvas with high-contrast cards',
                    ),
                    value: amoledEnabled,
                    onChanged: (value) => ref
                        .read(amoledThemeProvider.notifier)
                        .setEnabled(value),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Primary color',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Choose an accent for buttons, highlights and controls.',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 13,
                    runSpacing: 13,
                    children: [
                      for (final color in _palette)
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => ref
                              .read(accentColorProvider.notifier)
                              .setColor(color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.toARGB32() == color.toARGB32()
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: accent.toARGB32() == color.toARGB32()
                                ? const Icon(Icons.check,
                                    size: 19, color: Colors.white)
                                : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDialog<Color>(
                        context: context,
                        builder: (dialogContext) => _CustomColorDialog(
                          initialColor: accent,
                        ),
                      );
                      if (picked != null) {
                        ref.read(accentColorProvider.notifier).setColor(picked);
                      }
                    },
                    icon: const Icon(Icons.color_lens_outlined),
                    label: const Text('Custom color (HEX)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('ARCHIVE TOOLS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  )),
          const SizedBox(height: 8),
          _settingLink(context, Icons.insights_outlined, 'Archive insights',
              'Archive health, duplicate titles and broken links', '/insights'),
          _settingLink(context, Icons.timeline_outlined, 'Memory timeline',
              'Browse note and task activity in date order', '/timeline'),
          _settingLink(context, Icons.code_outlined, 'Developer notebook',
              'Reusable code snippets and commands', '/developer-notebook'),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Categories'),
            subtitle: const Text('Create, rename and organize note categories'),
            trailing: IconButton(
              tooltip: 'Add category',
              icon: const Icon(Icons.add),
              onPressed: () => _editCategory(context, ref),
            ),
          ),
          StreamBuilder<List<Category>>(
            stream: (db.select(db.categories)
                  ..orderBy([(category) => OrderingTerm.asc(category.name)]))
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
          const SizedBox(height: 18),
          const Divider(),
          _settingLink(context, Icons.sell_outlined, 'Tags',
              'Create and manage reusable note tags', '/tags'),
          _settingLink(context, Icons.lock_outline, 'Protector',
              'Protect app access with your existing PIN gate', '/app-lock'),
          _settingLink(context, Icons.inventory_2_outlined, 'Archive transfer',
              'Export or import a portable JSON archive', '/archive-tools'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Storage'),
            subtitle: Text('Notes are stored locally on this device'),
            leading: Icon(Icons.storage_outlined),
          ),
        ],
      ),
    );
  }

  Widget _settingLink(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}

class _CustomColorDialog extends StatefulWidget {
  const _CustomColorDialog({required this.initialColor});
  final Color initialColor;

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: '#${widget.initialColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final raw = _controller.text.replaceAll('#', '');
    final parsed = int.tryParse(raw, radix: 16);
    final preview = parsed == null || raw.length != 6
        ? widget.initialColor
        : Color(0xFF000000 | parsed);
    return AlertDialog(
      title: const Text('Custom accent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: preview,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 7,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'HEX color',
              hintText: '#7A1735',
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: parsed == null || raw.length != 6
              ? null
              : () => Navigator.pop(context, Color(0xFF000000 | parsed)),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
