import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/editor/providers/editor_provider.dart';
import 'package:mindvault_archive/features/editor/presentation/markdown_toolbar.dart';
import 'package:mindvault_archive/features/editor/presentation/markdown_preview_editing_controller.dart';
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
  late final MarkdownPreviewEditingController _contentController;
  bool _initialized = false;
  bool _previewMode = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = MarkdownPreviewEditingController();
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
    final saved = await ref
        .read(editorProvider(widget.noteId).notifier)
        .forceSave();
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
    final safeName = (title.isEmpty ? 'mindvault-note' : title).replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '-',
    );
    final markdown =
        '# ${title.isEmpty ? 'Untitled' : title}\n\n${_contentController.text}';
    try {
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(markdown),
          mimeType: 'text/markdown',
          name: '$safeName.md',
        ),
      ], text: 'Exported from MindVault Archive');
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
      final type =
          {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'}.contains(extension)
          ? 'image'
          : {'.mp3', '.m4a', '.wav', '.ogg', '.aac'}.contains(extension)
          ? 'audio'
          : {'.mp4', '.mov', '.mkv', '.webm'}.contains(extension)
          ? 'video'
          : extension == '.pdf'
          ? 'pdf'
          : 'file';
      await ref
          .read(databaseProvider)
          .into(ref.read(databaseProvider).attachments)
          .insert(
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not attach file: $error')));
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
              errorBuilder: (context, error, stackTrace) => const Padding(
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
      await Share.shareXFiles([
        XFile(
          file.path,
          mimeType: attachment.type == 'pdf' ? 'application/pdf' : null,
        ),
      ], text: 'Open this MindVault Archive attachment with a compatible app.');
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
      await (ref
              .read(databaseProvider)
              .delete(ref.read(databaseProvider).attachments)
            ..where((item) => item.id.equals(attachment.id)))
          .go();
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
        if (didPop || _leaving) return;
        _leaving = true;
        final router = GoRouter.of(context);
        var saved = false;
        try {
          saved = await ref
              .read(editorProvider(widget.noteId).notifier)
              .forceSave();
        } catch (error, stack) {
          debugPrint('Editor exit save failed: $error');
          debugPrintStack(stackTrace: stack);
        }
        if (!context.mounted) return;
        if (saved) {
          router.pop();
        } else {
          _leaving = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your note could not be saved. Please try again.'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Create a Note',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.transparent),
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
            IconButton(
              tooltip: 'Move note to Trash',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final saved = await ref
                    .read(editorProvider(widget.noteId).notifier)
                    .forceSave();
                if (!context.mounted || !saved) return;
                final confirmed = await context.push<bool>(
                  '/delete/${widget.noteId}',
                );
                if (confirmed == true && context.mounted) {
                  await db.setDeleted(widget.noteId, true);
                  if (context.mounted) context.pop();
                }
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
                PopupMenuItem(
                  value: 0xFFF7CB46,
                  child: Text('Sunflower yellow'),
                ),
                PopupMenuItem(value: 0xFFC0F7FE, child: Text('Sky cyan')),
                PopupMenuItem(value: 0xFF99E885, child: Text('Pixel green')),
                PopupMenuItem(value: 0xFFFE90E8, child: Text('Bubblegum pink')),
                PopupMenuItem(value: 0xFFFFDC8B, child: Text('Warm cream')),
              ],
            ),
            IconButton(
              tooltip: 'Draw',
              icon: const Icon(Icons.brush),
              onPressed: () => context.push('/drawing/${widget.noteId}'),
            ),
          ],
        ),
        body: CustomPaint(
          painter: _PixelDotPainter(
            dotColor: Theme.of(context).colorScheme.outlineVariant
                .withValues(alpha: 0.28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1.12,
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: 'Give this note a title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                ),
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    final text = _contentController.text;
                    final words = RegExp(r'\S+').allMatches(text).length;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$words words  •  ${text.length} characters',
                        ),
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
                                  styleSheet: MarkdownStyleSheet(),
                                ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _contentController,
                                onChanged: (_) => _onTextChanged(),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      height: 1.65,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                cursorColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                decoration: InputDecoration(
                                  hintText: 'Start writing your note…',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  filled: false,
                                  contentPadding: EdgeInsets.fromLTRB(
                                    16,
                                    18,
                                    16,
                                    18,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
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
                StreamBuilder<List<Attachment>>(
                  stream: attachmentQuery.watch(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Could not load attachments: ${snapshot.error}',
                        ),
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
                                title: Text(
                                  item.filename,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                MarkdownToolbar(
                  controller: _contentController,
                  onChanged: _onTextChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PixelDotPainter extends CustomPainter {
  const _PixelDotPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const step = 16.0;
    for (double y = 8; y < size.height; y += step) {
      for (double x = 8; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelDotPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}
