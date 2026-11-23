import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _palette = <Color>[
    Color(0xFFF7CB46),
    Color(0xFFC0F7FE),
    Color(0xFF99E885),
    Color(0xFFE9E0E8),
    Color(0xFFFFDC8B),
    Color(0xFF000000),
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
      await ref
          .read(userProfileProvider.notifier)
          .save(name: name.text, avatarBase64: avatar);
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
    final preset = ref.watch(themePresetProvider);
    final accent = ref.watch(accentColorProvider);
    final profile = ref.watch(userProfileProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: [
          const FeatureHero(
            icon: Icons.tune_rounded,
            title: 'Your archive, your way',
            subtitle: 'Personalize your space, appearance and organization.',
          ),
          const SizedBox(height: 26),
          Text(
            'PERSONAL SPACE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          NeoBrutalistPanel(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 26,
                backgroundImage: profile.avatar,
                child: profile.avatar == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              title: Text(
                profile.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Name and profile picture'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editProfile(context, ref),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'APPEARANCE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          NeoBrutalistPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<AppThemePreset>(
                  value: preset,
                  decoration: const InputDecoration(labelText: 'Theme preset'),
                  items: [
                    for (final option in AppThemePreset.values)
                      DropdownMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            Icon(
                              switch (option) {
                                AppThemePreset.light => Icons.light_mode_outlined,
                                AppThemePreset.dark => Icons.dark_mode_outlined,
                                AppThemePreset.amoled => Icons.brightness_3_outlined,
                                AppThemePreset.monochromeOled =>
                                  Icons.filter_b_and_w_outlined,
                              },
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(option.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themePresetProvider.notifier).setPreset(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(preset.description, style: Theme.of(context).textTheme.bodySmall),
                if (preset.isMonochrome) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Accent colors are ignored in this preset. Your saved accent is kept for the other themes.',
                  ),
                ] else ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Primary color',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
                  Text(
                    'Choose an accent for buttons, highlights and controls.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 13,
                    runSpacing: 13,
                    children: [
                      for (final color in _palette)
                        Tooltip(
                          message:
                              'Use accent color #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                          child: Semantics(
                            button: true,
                            selected: accent.toARGB32() == color.toARGB32(),
                            label:
                                'Accent color #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => ref
                                  .read(accentColorProvider.notifier)
                                  .setColor(color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 42,
                                height: 42,
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
                                    ? Icon(
                                        Icons.check,
                                        size: 19,
                                        color: color.computeLuminance() > 0.45
                                            ? AppTheme.ink
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDialog<Color>(
                        context: context,
                        builder: (dialogContext) =>
                            _CustomColorDialog(initialColor: accent),
                      );
                      if (picked != null) {
                        ref.read(accentColorProvider.notifier).setColor(picked);
                      }
                    },
                    icon: const Icon(Icons.color_lens_outlined),
                    label: const Text('Custom color (HEX)'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'ARCHIVE TOOLS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _settingLink(
            context,
            Icons.insights_outlined,
            'Archive insights',
            'Archive health, duplicate titles and broken links',
            '/insights',
          ),
          _settingLink(
            context,
            Icons.timeline_outlined,
            'Memory timeline',
            'Browse note and task activity in date order',
            '/timeline',
          ),
          _settingLink(
            context,
            Icons.code_outlined,
            'Developer notebook',
            'Reusable code snippets and commands',
            '/developer-notebook',
          ),
          const SizedBox(height: 24),
          const Divider(),
          NeoBrutalistPanel(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Create, rename and organize note categories',
                  ),
                  trailing: IconButton(
                    tooltip: 'Add category',
                    icon: const Icon(Icons.add),
                    onPressed: () => _editCategory(context, ref),
                  ),
                ),
                StreamBuilder<List<Category>>(
                  stream:
                      (db.select(db.categories)..orderBy([
                            (category) => OrderingTerm.asc(category.name),
                          ]))
                          .watch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Could not load categories: ${snapshot.error}',
                        ),
                      );
                    }
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.inbox_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No categories yet. Add one to organize notes.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final category in categories)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.secondary,
                                border: Border.all(
                                  color: AppTheme.ink,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.label_outline,
                                color: AppTheme.ink,
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Manage ${category.name}',
                              onSelected: (action) {
                                if (action == 'rename') {
                                  _editCategory(
                                    context,
                                    ref,
                                    category: category,
                                  );
                                } else if (action == 'delete') {
                                  _deleteCategory(context, ref, category);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(),
          _settingLink(
            context,
            Icons.sell_outlined,
            'Tags',
            'Create and manage reusable note tags',
            '/tags',
          ),
          _settingLink(
            context,
            Icons.lock_outline,
            'Protector',
            'Protect app access with your existing PIN gate',
            '/app-lock',
          ),
          _settingLink(
            context,
            Icons.inventory_2_outlined,
            'Archive transfer',
            'Export or import a portable JSON archive',
            '/archive-tools',
          ),
          const NeoBrutalistPanel(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                'Storage',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('Notes are stored locally on this device'),
              leading: Icon(Icons.storage_outlined),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalistPanel(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              border: Border.all(color: AppTheme.ink, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: AppTheme.ink, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(route),
        ),
      ),
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
      text:
          '#${widget.initialColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
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
            decoration: BoxDecoration(color: preview, shape: BoxShape.circle),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 7,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'HEX color',
              hintText: '#5A0719',
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
