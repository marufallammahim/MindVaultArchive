import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class NoteTemplate {
  const NoteTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String content;
  final bool isCustom;
}

const noteTemplates = <NoteTemplate>[
  NoteTemplate(
    id: 'daily-journal',
    title: 'Daily journal',
    description: 'Reflect, notice patterns, and plan tomorrow.',
    icon: Icons.auto_stories_rounded,
    content: '## Today\n\nDate: \n\n### Highlights\n- \n\n### What I learned\n- \n\n### Challenges\n- \n\n### Tomorrow\n- ',
  ),
  NoteTemplate(
    id: 'meeting',
    title: 'Meeting notes',
    description: 'Agenda, decisions, and action items.',
    icon: Icons.groups_2_rounded,
    content: '## Meeting\n\nDate: \nAttendees: \n\n### Agenda\n- \n\n### Discussion\n\n### Decisions\n- \n\n### Action items\n- [ ] ',
  ),
  NoteTemplate(
    id: 'project-plan',
    title: 'Project plan',
    description: 'Goals, milestones, risks, and next steps.',
    icon: Icons.rocket_launch_rounded,
    content: '## Project overview\n\nGoal: \n\n### Scope\n- \n\n### Milestones\n1. \n2. \n\n### Risks\n- \n\n### Next actions\n- [ ] ',
  ),
  NoteTemplate(
    id: 'study',
    title: 'Study notes',
    description: 'Capture concepts, examples, and questions.',
    icon: Icons.school_rounded,
    content: '## Topic\n\nSubject: \nSource: \n\n### Key concepts\n- \n\n### Explanation\n\n### Examples\n- \n\n### Questions to revisit\n- ',
  ),
  NoteTemplate(
    id: 'developer',
    title: 'Developer log',
    description: 'Track code ideas, commands, and debugging.',
    icon: Icons.terminal_rounded,
    content: '## Technical note\n\nProject: \nLanguage / tool: \n\n### Problem or idea\n\n### Approach\n\n### Commands / snippets\n\n### Result\n\n### Follow-up\n- [ ] ',
  ),
];

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  static const _storageKey = 'mindvault_custom_templates_v1';
  final _search = TextEditingController();
  List<NoteTemplate> _custom = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = <NoteTemplate>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final value = Map<String, dynamic>.from(item);
        if (value['id'] is! String ||
            value['title'] is! String ||
            value['content'] is! String) {
          continue;
        }
        loaded.add(
          NoteTemplate(
            id: value['id'] as String,
            title: value['title'] as String,
            description: value['description'] as String? ?? 'Personal template',
            icon: Icons.bookmark_rounded,
            content: value['content'] as String,
            isCustom: true,
          ),
        );
      }
      if (mounted) setState(() => _custom = loaded);
    } catch (_) {
      if (mounted) _message('Could not load saved templates.');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(
          _custom
              .map(
                (item) => {
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'content': item.content,
                },
              )
              .toList(),
        ),
      );
    } catch (_) {
      _message('Template could not be saved. Check device storage.');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _createCustomTemplate() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final content = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New template',
                style: Theme.of(sheetContext).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: title,
                autofocus: true,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Template name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: description,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Short description',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: content,
                minLines: 6,
                maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Markdown starter content',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (title.text.trim().isEmpty ||
                        content.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(sheetContext, true);
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save template'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final cleanTitle = title.text.trim();
    final cleanDescription = description.text.trim();
    final cleanContent = content.text;
    title.dispose();
    description.dispose();
    content.dispose();
    if (saved != true || cleanTitle.isEmpty || cleanContent.trim().isEmpty) {
      return;
    }
    setState(
      () => _custom = [
        ..._custom,
        NoteTemplate(
          id: const Uuid().v4(),
          title: cleanTitle,
          description: cleanDescription.isEmpty
              ? 'Personal template'
              : cleanDescription,
          icon: Icons.bookmark_rounded,
          content: cleanContent,
          isCustom: true,
        ),
      ],
    );
    await _persist();
  }

  Future<void> _createFromTemplate(NoteTemplate template) async {
    final id = const Uuid().v4();
    try {
      await ref
          .read(databaseProvider)
          .saveNoteContent(id, template.title, template.content);
      if (!mounted) return;
      context.push('/editor/$id');
    } catch (error) {
      _message('Could not create note: $error');
    }
  }

  Future<void> _deleteCustom(NoteTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this template?'),
        content: Text(
          '“${template.title}” will be removed from your template library. Existing notes will stay unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _custom.removeWhere((item) => item.id == template.id));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final all = [...noteTemplates, ..._custom];
    final filtered = all
        .where(
          (item) => ('${item.title} ${item.description}')
              .toLowerCase()
              .contains(_query),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
          IconButton(
            tooltip: 'Create template',
            onPressed: _createCustomTemplate,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FeatureHero(
                    icon: Icons.auto_awesome_rounded,
                    title: 'A good start, every time.',
                    subtitle:
                        'Choose a structure and turn it into an editable note.',
                    compact: true,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _search,
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Find a template',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _search.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'TEMPLATE LIBRARY',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${filtered.length} available',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No templates match your search.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 112),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent > 650 ? 3 : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.94,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = filtered[index];
                      const colors = [
                        AppTheme.primary,
                        AppTheme.pink,
                        AppTheme.secondary,
                        AppTheme.tertiary,
                        AppTheme.warmYellow,
                      ];
                      final color = colors[index % colors.length];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.ink,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: Material(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _createFromTemplate(item),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondary,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.ink,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: AppTheme.ink,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (item.isCustom)
                                        PopupMenuButton<String>(
                                          tooltip: 'Template actions',
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              _deleteCustom(item);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppTheme.ink,
                                          fontWeight: FontWeight.w900,
                                          height: 1.1,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.ink.withValues(
                                            alpha: 0.72,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Row(
                                    children: [
                                      Text(
                                        'Use template',
                                        style: TextStyle(
                                          color: AppTheme.ink,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 17,
                                        color: AppTheme.ink,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: filtered.length),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomTemplate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New template'),
      ),
    );
  }
}
