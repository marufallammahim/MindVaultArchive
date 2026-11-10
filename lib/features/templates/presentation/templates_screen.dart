import 'dart:convert';

import 'package:flutter/material.dart';
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
      description: 'Reflect on the day and capture what matters.',
      icon: Icons.book_outlined,
      content:
          '## Today\n\nDate: \n\n### Highlights\n- \n\n### What I learned\n- \n\n### Challenges\n- \n\n### Tomorrow\n- '),
  NoteTemplate(
      id: 'meeting',
      title: 'Meeting notes',
      description: 'Agenda, decisions, and action items.',
      icon: Icons.groups_outlined,
      content:
          '## Meeting\n\nDate: \nAttendees: \n\n### Agenda\n- \n\n### Discussion\n\n\n### Decisions\n- \n\n### Action items\n- [ ] '),
  NoteTemplate(
      id: 'project-plan',
      title: 'Project plan',
      description: 'Define goals, milestones, risks, and next steps.',
      icon: Icons.rocket_launch_outlined,
      content:
          '## Project overview\n\nGoal: \n\n### Scope\n- \n\n### Milestones\n1. \n2. \n\n### Risks\n- \n\n### Next actions\n- [ ] '),
  NoteTemplate(
      id: 'study',
      title: 'Study notes',
      description: 'Organize concepts, examples, and questions.',
      icon: Icons.school_outlined,
      content:
          '## Topic\n\nSubject: \nSource: \n\n### Key concepts\n- \n\n### Explanation\n\n\n### Examples\n- \n\n### Questions to revisit\n- '),
  NoteTemplate(
      id: 'developer',
      title: 'Developer notebook',
      description: 'Record code ideas, commands, and debugging notes.',
      icon: Icons.terminal_outlined,
      content:
          '## Technical note\n\nProject: \nLanguage / tool: \n\n### Problem or idea\n\n\n### Approach\n\n\n### Commands / snippets\n\n\n### Result\n\n\n### Follow-up\n- [ ] '),
];

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  static const _storageKey = 'mindvault_custom_templates_v1';
  List<NoteTemplate> _customTemplates = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
  }

  Future<void> _loadCustomTemplates() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_storageKey);
      if (raw == null) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }
      final templates = <NoteTemplate>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final value = Map<String, dynamic>.from(item);
        if (value['id'] is! String ||
            value['title'] is! String ||
            value['content'] is! String) {
          continue;
        }
        templates.add(NoteTemplate(
          id: value['id'] as String,
          title: value['title'] as String,
          description: value['description'] as String? ?? 'Custom template',
          icon: Icons.bookmark_outline,
          content: value['content'] as String,
          isCustom: true,
        ));
      }
      if (mounted) {
        setState(() => _customTemplates = templates);
      }
    } catch (_) {
      // Invalid or unavailable preferences do not affect built-in templates.
    }
  }

  Future<void> _persistCustomTemplates() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _storageKey,
        jsonEncode(_customTemplates
            .map((template) => {
                  'id': template.id,
                  'title': template.title,
                  'description': template.description,
                  'content': template.content,
                })
            .toList()),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save custom templates: $error')),
        );
      }
    }
  }

  Future<void> _createCustomTemplate() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final content = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create a template'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: title,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Template name')),
              TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                  controller: content,
                  minLines: 6,
                  maxLines: 12,
                  decoration:
                      const InputDecoration(labelText: 'Markdown content')),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save template')),
        ],
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
    setState(() {
      _customTemplates = [
        ..._customTemplates,
        NoteTemplate(
          id: const Uuid().v4(),
          title: cleanTitle,
          description:
              cleanDescription.isEmpty ? 'Custom template' : cleanDescription,
          icon: Icons.bookmark_outline,
          content: cleanContent,
          isCustom: true,
        ),
      ];
    });
    await _persistCustomTemplates();
  }

  Future<void> _deleteCustomTemplate(NoteTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text(
            'Remove "${template.title}" from your custom library? Existing notes will not be affected.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    setState(
        () => _customTemplates.removeWhere((item) => item.id == template.id));
    await _persistCustomTemplates();
  }

  Future<void> _createFromTemplate(NoteTemplate template) async {
    final id = const Uuid().v4();
    try {
      await ref
          .read(databaseProvider)
          .saveNoteContent(id, template.title, template.content);
      if (!mounted) {
        return;
      }
      context.push('/editor/$id');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create note: $error')),
      );
    }
  }

  Widget _templateTile(NoteTemplate template) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(child: Icon(template.icon)),
          title: Text(template.title),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(template.description),
          ),
          trailing: template.isCustom
              ? IconButton(
                  tooltip: 'Delete custom template',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteCustomTemplate(template),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _createFromTemplate(template),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note templates'),
        actions: [
          IconButton(
            tooltip: 'Create custom template',
            onPressed: _createCustomTemplate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Start with a useful structure',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Choose a template or build your own reusable structure.'),
          const SizedBox(height: 18),
          Text('Built-in templates',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final template in noteTemplates) _templateTile(template),
          if (_customTemplates.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Your templates',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final template in _customTemplates) _templateTile(template),
          ],
          const SizedBox(height: 72),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomTemplate,
        icon: const Icon(Icons.add),
        label: const Text('Custom template'),
      ),
    );
  }
}
