import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/editor/providers/editor_provider.dart';
import 'package:mindvault_archive/features/editor/presentation/markdown_toolbar.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
  bool _previewMode = false;

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

  Future<void> _shareMarkdown() async {
    final saved =
        await ref.read(editorProvider(widget.noteId).notifier).forceSave();
    if (!mounted) {
      return;
    }
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the note before exporting it.')),
      );
      return;
    }
    final title = _titleController.text.trim();
    final safeName = (title.isEmpty ? 'mindvault-note' : title)
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
    final markdown =
        '# ${title.isEmpty ? 'Untitled' : title}\n\n${_contentController.text}';
    try {
      await Share.shareXFiles(
        [
          XFile.fromData(
            utf8.encode(markdown),
            mimeType: 'text/markdown',
            name: '$safeName.md',
          ),
        ],
        text: 'Exported from MindVault Archive',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export Markdown: $error')),
      );
    }
  }


  Future<void> _attachFile() async {
    final saved = await ref
        .read(editorProvider(widget.noteId).notifier)
        .forceSave();
    if (!mounted) {
      return;
    }
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the note before attaching a file.')),
      );
      return;
    }
    File? target;
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) {
        return;
      }
      final picked = selection.files.single;
      final bytes = picked.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('The selected file could not be read.');
      }
      if (bytes.length > 25 * 1024 * 1024) {
        throw StateError('Files larger than 25 MB are not supported yet.');
      }
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(
        p.join(documents.path, 'mindvault', 'attachments'),
      );
      await directory.create(recursive: true);
      final id = const Uuid().v4();
      final safeName = p
          .basename(picked.name)
          .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final filename = '${id}_${safeName.isEmpty ? 'attachment' : safeName}';
      target = File(p.join(directory.path, filename));
      await target.writeAsBytes(bytes, flush: true);
      final extension = p.extension(picked.name).toLowerCase();
      final type = {
        '.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'
      }.contains(extension)
          ? 'image'
          : {'.mp3', '.m4a', '.wav', '.ogg', '.aac'}.contains(extension)
              ? 'audio'
              : {'.mp4', '.mov', '.mkv', '.webm'}.contains(extension)
                  ? 'video'
                  : extension == '.pdf'
                      ? 'pdf'
                      : 'file';
      await ref.read(databaseProvider).into(
        ref.read(databaseProvider).attachments,
      ).insert(
        AttachmentsCompanion.insert(
          id: id,
          noteId: widget.noteId,
          type: type,
          localPath: target.path,
          filename: picked.name,
        ),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attached "${picked.name}" to this note.')),
      );
    } catch (error) {
      if (target != null && await target.exists()) {
        await target.delete();
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not attach file: $error')),
      );
    }
  }

  Future<void> _openAttachment(Attachment attachment) async {
    final file = File(attachment.localPath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This attachment file is missing.')),
        );
      }
      return;
    }
    if (attachment.type == 'image' || attachment.type == 'drawing') {
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          child: InteractiveViewer(
            child: Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Padding(
                padding: EdgeInsets.all(24),
                child: Text('This image could not be displayed.'),
              ),
            ),
          ),
        ),
      );
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile(file.path, mimeType: attachment.type == 'pdf' ? 'application/pdf' : null)],
        text: 'Open this MindVault Archive attachment with a compatible app.',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open attachment: $error')),
        );
      }
    }
  }

  Future<void> _removeAttachment(Attachment attachment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove attachment?'),
        content: Text('Remove "${attachment.filename}" from this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await (ref.read(databaseProvider).delete(
        ref.read(databaseProvider).attachments,
      )..where((item) => item.id.equals(attachment.id))).go();
      final file = File(attachment.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove attachment: $error')),
        );
      }
    }
  }

  IconData _attachmentIcon(Attachment item) {
    switch (item.type) {
      case 'image':
      case 'drawing':
        return Icons.image_outlined;
      case 'audio':
        return Icons.audio_file_outlined;
      case 'video':
        return Icons.video_file_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      default:
        return Icons.attach_file_outlined;
    }
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
            IconButton(
              tooltip: 'Attach file',
              icon: const Icon(Icons.attach_file),
              onPressed: _attachFile,
            ),
            IconButton(
              tooltip: 'Export or share Markdown',
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: _shareMarkdown,
            ),
            IconButton(
              tooltip: _previewMode ? 'Edit Markdown' : 'Preview Markdown',
              icon: Icon(
                _previewMode ? Icons.edit_outlined : Icons.visibility_outlined,
              ),
              onPressed: () => setState(() => _previewMode = !_previewMode),
            ),
            IconButton(
              tooltip: 'Tasks linked to this note',
              icon: const Icon(Icons.task_alt_outlined),
              onPressed: () => context.push('/tasks?noteId=${widget.noteId}'),
            ),
            IconButton(
              tooltip: 'Version history',
              icon: const Icon(Icons.history),
              onPressed: () async {
                final notifier = ref.read(
                  editorProvider(widget.noteId).notifier,
                );
                final saved = await notifier.forceSave();
                if (!context.mounted) return;
                if (!saved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Save the current note before restoring a revision.',
                      ),
                    ),
                  );
                  return;
                }

                final restored = await context.push<bool>(
                  '/history/${widget.noteId}',
                );
                if (restored != true || !mounted) return;
                await notifier.reloadFromDatabase();
                if (!mounted) return;
                final refreshed = ref.read(editorProvider(widget.noteId));
                _titleController.text = refreshed.title;
                _contentController.text = refreshed.content;
              },
            ),
            PopupMenuButton<int>(
              tooltip: 'Note color',
              icon: const Icon(Icons.palette_outlined),
              onSelected: (value) async {
                await db.setNoteColor(
                  widget.noteId,
                  value == -1 ? null : value,
                );
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
                    content: Text(
                      saved ? 'Note saved.' : 'Could not save note.',
                    ),
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
                      ..orderBy([
                        (category) => OrderingTerm.asc(category.name),
                      ]))
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
                        initialValue:
                            categories.any((item) => item.id == selectedId)
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
                                    widget.noteId,
                                    value,
                                  );
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Could not assign category: $error',
                                      ),
                                    ),
                                  );
                                }
                              },
                      );
                    },
                  );
                },
              ),
              StreamBuilder<List<Tag>>(
                stream: (db.select(
                  db.tags,
                )..orderBy([(tag) => OrderingTerm.asc(tag.name)]))
                    .watch(),
                builder: (context, tagsSnapshot) {
                  final tags = tagsSnapshot.data ?? [];
                  return StreamBuilder<List<NoteTag>>(
                    stream: (db.select(db.noteTags)
                          ..where(
                            (item) => item.noteId.equals(widget.noteId),
                          ))
                        .watch(),
                    builder: (context, selectedSnapshot) {
                      final selectedIds = (selectedSnapshot.data ?? [])
                          .map((item) => item.tagId)
                          .toSet();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: tags.isEmpty
                                  ? const Text('No tags yet')
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        for (final tag in tags)
                                          FilterChip(
                                            label: Text(tag.name),
                                            selected: selectedIds.contains(
                                              tag.id,
                                            ),
                                            onSelected: (selected) async {
                                              final next = {...selectedIds};
                                              if (selected) {
                                                next.add(tag.id);
                                              } else {
                                                next.remove(tag.id);
                                              }
                                              try {
                                                await db.setNoteTags(
                                                  widget.noteId,
                                                  next.toList(),
                                                );
                                              } catch (error) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Could not update tags: $error',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                      ],
                                    ),
                            ),
                            IconButton(
                              tooltip: 'Manage tags',
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () => context.push('/tags'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<List<VaultTask>>(
                stream: (db.select(db.tasks)
                      ..where((task) => task.noteId.equals(widget.noteId))
                      ..orderBy([
                        (task) => OrderingTerm.asc(task.dueAt),
                        (task) => OrderingTerm.desc(task.updatedAt),
                      ]))
                    .watch(),
                builder: (context, taskSnapshot) {
                  final tasks = taskSnapshot.data ?? [];
                  if (tasks.isEmpty) return const SizedBox.shrink();
                  return Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.task_alt_outlined),
                      title: Text('Linked tasks (${tasks.length})'),
                      children: [
                        for (final task in tasks)
                          ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) =>
                                  db.setTaskCompleted(task.id, value ?? false),
                            ),
                            title: Text(
                              task.title,
                              style: task.isCompleted
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : null,
                            ),
                            subtitle: task.dueAt == null
                                ? null
                                : Text(
                                    'Due ${MaterialLocalizations.of(context).formatShortDate(task.dueAt!)}',
                                  ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              StreamBuilder<List<Note>>(
                stream: db.select(db.notes).watch(),
                builder: (context, notesSnapshot) {
                  final allNotes = notesSnapshot.data ?? [];
                  final currentTitle = state.title.trim();
                  final matches = RegExp(r'\[\[([^\]]+)\]\]')
                      .allMatches(state.content)
                      .map((match) => match.group(1)!.trim())
                      .where((title) => title.isNotEmpty)
                      .toSet();
                  final linkedNotes = allNotes
                      .where(
                        (note) =>
                            note.id != widget.noteId &&
                            matches.any(
                              (title) =>
                                  note.title.trim().toLowerCase() ==
                                  title.toLowerCase(),
                            ),
                      )
                      .toList();
                  final backlinks = currentTitle.isEmpty
                      ? <Note>[]
                      : allNotes
                          .where(
                            (note) =>
                                note.id != widget.noteId &&
                                note.documentContent.toLowerCase().contains(
                                      '[[${currentTitle.toLowerCase()}]]',
                                    ),
                          )
                          .toList();
                  if (linkedNotes.isEmpty && backlinks.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.account_tree_outlined),
                      title: Text(
                        'Links and backlinks (${linkedNotes.length + backlinks.length})',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                        if (linkedNotes.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Linked notes'),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final note in linkedNotes)
                                ActionChip(
                                  avatar: const Icon(Icons.link, size: 16),
                                  label: Text(note.title),
                                  onPressed: () =>
                                      context.push('/editor/${note.id}'),
                                ),
                            ],
                          ),
                        ],
                        if (backlinks.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Backlinks to this note'),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final note in backlinks)
                                ActionChip(
                                  avatar: const Icon(Icons.reply, size: 16),
                                  label: Text(
                                    note.title.isEmpty
                                        ? 'Untitled'
                                        : note.title,
                                  ),
                                  onPressed: () =>
                                      context.push('/editor/${note.id}'),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: _previewMode
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
                        child: _contentController.text.trim().isEmpty
                            ? const Center(
                                child: Text('Nothing to preview yet.'),
                              )
                            : MarkdownBody(
                                data: _contentController.text,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet.fromTheme(
                                  Theme.of(context),
                                ),
                              ),
                      )
                    : Column(
                        children: [
                          MarkdownToolbar(
                            controller: _contentController,
                            onChanged: _onTextChanged,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              onChanged: (_) => _onTextChanged(),
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: const InputDecoration(
                                hintText: 'Write with Markdown…',
                              ),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ],
                      ),
              ),
              AnimatedBuilder(
                animation: _contentController,
                builder: (context, child) {
                  final text = _contentController.text;
                  final words = RegExp(r'\S+').allMatches(text).length;
                  final readingMinutes = (words / 200).ceil();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                    child: Row(
                      children: [
                        Text('$words words'),
                        const SizedBox(width: 12),
                        Text('${text.length} characters'),
                        const Spacer(),
                        Text(readingMinutes == 0
                            ? 'Less than 1 min'
                            : '$readingMinutes min read'),
                      ],
                    ),
                  );
                },
              ),
              StreamBuilder<List<Attachment>>(
                stream: attachmentQuery.watch(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text('Could not load attachments: ${snapshot.error}'),
                    );
                  }
                  final attachments = snapshot.data ?? [];
                  if (attachments.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: attachments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = attachments[index];
                        return SizedBox(
                          width: 240,
                          child: Card(
                            child: ListTile(
                              dense: true,
                              leading: Icon(_attachmentIcon(item)),
                              title: Text(item.filename,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(item.type.toUpperCase()),
                              onTap: () => _openAttachment(item),
                              trailing: IconButton(
                                tooltip: 'Remove attachment',
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _removeAttachment(item),
                              ),
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
