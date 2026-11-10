import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:uuid/uuid.dart';

class DeveloperNotebookScreen extends ConsumerWidget {
  const DeveloperNotebookScreen({super.key});

  Future<void> _createSnippet(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final language = TextEditingController(text: 'text');
    final code = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New code snippet'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: title,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Snippet title')),
              TextField(
                  controller: language,
                  decoration: const InputDecoration(
                      labelText: 'Language (dart, python, bash…)')),
              TextField(
                  controller: code,
                  minLines: 6,
                  maxLines: 12,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration:
                      const InputDecoration(labelText: 'Code or command')),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save snippet')),
        ],
      ),
    );
    final cleanTitle = title.text.trim();
    final cleanLanguage =
        language.text.trim().isEmpty ? 'text' : language.text.trim();
    final cleanCode = code.text;
    title.dispose();
    language.dispose();
    code.dispose();
    if (saved != true ||
        cleanTitle.isEmpty ||
        cleanCode.trim().isEmpty ||
        !context.mounted) {
      return;
    }
    final id = const Uuid().v4();
    try {
      await ref.read(databaseProvider).saveNoteContent(id, '[Code] $cleanTitle',
          'Language: $cleanLanguage\n\n\u0060\u0060\u0060$cleanLanguage\n$cleanCode\n\u0060\u0060\u0060');
      if (context.mounted) {
        context.push('/editor/$id');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save snippet: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Developer notebook')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createSnippet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New snippet'),
      ),
      body: StreamBuilder<List<Note>>(
        stream: (db.select(db.notes)..where((n) => n.isDeleted.equals(false)))
            .watch(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load snippets: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final snippets = snapshot.data!
              .where((n) => n.title.startsWith('[Code] '))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          if (snippets.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.code_rounded, size: 56),
                SizedBox(height: 12),
                Text('Your technical notebook is empty.'),
                SizedBox(height: 6),
                Text('Save commands, code samples and debugging notes here.',
                    textAlign: TextAlign.center),
              ]),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            itemCount: snippets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final note = snippets[index];
              final language = RegExp(r'^Language: (.+)$', multiLine: true)
                      .firstMatch(note.documentContent)
                      ?.group(1) ??
                  'text';
              return Card(
                  child: ListTile(
                leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Icon(Icons.code)),
                title: Text(note.title.substring(7),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/editor/${note.id}'),
              ));
            },
          );
        },
      ),
    );
  }
}
