import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/editor/providers/editor_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String noteId;
  const EditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    ref
        .read(editorProvider(widget.noteId).notifier)
        .updateContent(_titleController.text, _contentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider(widget.noteId));
    final db = ref.watch(databaseProvider);
    final attachmentQuery = db.select(db.attachments)
      ..where((attachment) => attachment.noteId.equals(widget.noteId))
      ..orderBy([(attachment) => OrderingTerm.desc(attachment.createdAt)]);

    if (!state.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_initialized) {
      _titleController.text = state.title;
      _contentController.text = state.content;
      _initialized = true;
    }

    return PopScope(
      canPop: !state.isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final saved =
            await ref.read(editorProvider(widget.noteId).notifier).forceSave();
        if (!mounted) return;
        if (saved) router.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            state.saveError != null
                ? 'Save failed'
                : state.isSaving
                    ? 'Saving…'
                    : 'Saved',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: state.saveError != null
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
          ),
          actions: [
            PopupMenuButton<int>(
              tooltip: 'Note color',
              icon: const Icon(Icons.palette_outlined),
              onSelected: (value) async {
                await db.setNoteColor(
                    widget.noteId, value == -1 ? null : value);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: -1, child: Text('Default color')),
                PopupMenuItem(value: 0xFFFFF0D8, child: Text('Warm cream')),
                PopupMenuItem(value: 0xFFE1F2E5, child: Text('Soft green')),
                PopupMenuItem(value: 0xFFE2ECFF, child: Text('Soft blue')),
                PopupMenuItem(value: 0xFFF4E4F4, child: Text('Soft lavender')),
                PopupMenuItem(value: 0xFFFFE5E5, child: Text('Soft rose')),
              ],
            ),
            IconButton(
              tooltip: 'Draw',
              icon: const Icon(Icons.brush),
              onPressed: () => context.push('/drawing/${widget.noteId}'),
            ),
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: () async {
                final saved = await ref
                    .read(editorProvider(widget.noteId).notifier)
                    .forceSave();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(saved ? 'Note saved.' : 'Could not save note.'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              if (state.saveError != null)
                MaterialBanner(
                  content: Text(state.saveError!),
                  leading: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final saved = await ref
                            .read(editorProvider(widget.noteId).notifier)
                            .forceSave();
                        if (!context.mounted) return;
                        if (saved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note saved.')),
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              TextField(
                controller: _titleController,
                onChanged: (_) => _onTextChanged(),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Note Title'),
                maxLines: null,
              ),
              StreamBuilder<List<Category>>(
                stream: (db.select(db.categories)
                      ..orderBy(
                          [(category) => OrderingTerm.asc(category.name)]))
                    .watch(),
                builder: (context, categoriesSnapshot) {
                  final categories = categoriesSnapshot.data ?? [];
                  return StreamBuilder<Note?>(
                    stream: (db.select(db.notes)
                          ..where((note) => note.id.equals(widget.noteId)))
                        .watchSingleOrNull(),
                    builder: (context, noteSnapshot) {
                      final selectedId = noteSnapshot.data?.categoryId;
                      return DropdownButtonFormField<String?>(
                        value: categories.any((item) => item.id == selectedId)
                            ? selectedId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.folder_outlined),
                          hintText: 'No category',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Uncategorized'),
                          ),
                          for (final category in categories)
                            DropdownMenuItem<String?>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: categoriesSnapshot.hasError
                            ? null
                            : (value) async {
                                try {
                                  await db.setNoteCategory(
                                      widget.noteId, value);
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Could not assign category: $error')),
                                  );
                                }
                              },
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  onChanged: (_) => _onTextChanged(),
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(hintText: 'Start writing…'),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              StreamBuilder<List<Attachment>>(
                stream: attachmentQuery.watch(),
                builder: (context, snapshot) {
                  final drawings = (snapshot.data ?? [])
                      .where((item) => item.type == 'drawing')
                      .toList();
                  if (drawings.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: drawings.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = drawings[index];
                        final file = File(item.localPath);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  width: 112,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(
                                  width: 112,
                                  child: Center(
                                    child: Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
