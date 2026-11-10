import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/features/editor/providers/editor_provider.dart';
import 'package:mindvault_archive/main.dart';

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
    ref.read(editorProvider(widget.noteId).notifier)
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_initialized) {
      _titleController.text = state.title;
      _contentController.text = state.content;
      _initialized = true;
    }

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          await ref.read(editorProvider(widget.noteId).notifier).forceSave();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.isSaving ? 'Saving…' : 'Saved',
              style: Theme.of(context).textTheme.labelLarge),
          actions: [
            IconButton(
              tooltip: 'Draw',
              icon: const Icon(Icons.brush),
              onPressed: () => context.push('/drawing/${widget.noteId}'),
            ),
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: () async {
                await ref.read(editorProvider(widget.noteId).notifier).forceSave();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved.')),
                  );
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                onChanged: (_) => _onTextChanged(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: 'Note Title'),
                maxLines: null,
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
              StreamBuilder(
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
