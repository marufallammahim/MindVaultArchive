import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:uuid/uuid.dart';

class NoteTemplate {
  const NoteTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String content;
}

const noteTemplates = <NoteTemplate>[
  NoteTemplate(
    id: 'daily-journal',
    title: 'Daily journal',
    description: 'Reflect on the day and capture what matters.',
    icon: Icons.book_outlined,
    content:
        '## Today\n\nDate: \n\n### Highlights\n- \n\n### What I learned\n- \n\n### Challenges\n- \n\n### Tomorrow\n- ',
  ),
  NoteTemplate(
    id: 'meeting',
    title: 'Meeting notes',
    description: 'Agenda, decisions, and action items.',
    icon: Icons.groups_outlined,
    content:
        '## Meeting\n\nDate: \nAttendees: \n\n### Agenda\n- \n\n### Discussion\n\n\n### Decisions\n- \n\n### Action items\n- [ ] ',
  ),
  NoteTemplate(
    id: 'project-plan',
    title: 'Project plan',
    description: 'Define goals, milestones, risks, and next steps.',
    icon: Icons.rocket_launch_outlined,
    content:
        '## Project overview\n\nGoal: \n\n### Scope\n- \n\n### Milestones\n1. \n2. \n\n### Risks\n- \n\n### Next actions\n- [ ] ',
  ),
  NoteTemplate(
    id: 'study',
    title: 'Study notes',
    description: 'Organize concepts, examples, and questions.',
    icon: Icons.school_outlined,
    content:
        '## Topic\n\nSubject: \nSource: \n\n### Key concepts\n- \n\n### Explanation\n\n\n### Examples\n- \n\n### Questions to revisit\n- ',
  ),
  NoteTemplate(
    id: 'developer',
    title: 'Developer notebook',
    description: 'Record code ideas, commands, and debugging notes.',
    icon: Icons.terminal_outlined,
    content:
        '## Technical note\n\nProject: \nLanguage / tool: \n\n### Problem or idea\n\n\n### Approach\n\n\n### Commands / snippets\n\n\n### Result\n\n\n### Follow-up\n- [ ] ',
  ),
];

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  Future<void> _createFromTemplate(
    BuildContext context,
    WidgetRef ref,
    NoteTemplate template,
  ) async {
    final id = const Uuid().v4();
    try {
      await ref.read(databaseProvider).saveNoteContent(
            id,
            template.title,
            template.content,
          );
      if (!context.mounted) return;
      context.push('/editor/$id');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create note: ' + error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note templates')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Start with a useful structure',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
              'Choose a template. You can edit every part after it opens.'),
          const SizedBox(height: 16),
          for (final template in noteTemplates)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  child: Icon(template.icon),
                ),
                title: Text(template.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(template.description),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _createFromTemplate(context, ref, template),
              ),
            ),
        ],
      ),
    );
  }
}
