import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';

class DrawingScreen extends ConsumerStatefulWidget {
  final String noteId;
  const DrawingScreen({super.key, required this.noteId});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 3.2,
    penColor: AppTheme.ink,
    exportBackgroundColor: AppTheme.lightSurface,
  );
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveDrawing() async {
    if (_saving) return;
    setState(() => _saving = true);
    File? createdFile;
    try {
      final db = ref.read(databaseProvider);
      final note = await (db.select(
        db.notes,
      )..where((item) => item.id.equals(widget.noteId))).getSingleOrNull();
      if (note == null || note.isDeleted) {
        throw StateError('Open an active note before saving a drawing.');
      }

      final bytes = await _controller.toPngBytes();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Draw something before saving.');
      }

      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(
        p.join(documents.path, 'mindvault', 'drawings'),
      );
      await directory.create(recursive: true);

      final id = const Uuid().v4();
      final filename = 'drawing_$id.png';
      final file = File(p.join(directory.path, filename));
      createdFile = file;
      await file.writeAsBytes(bytes, flush: true);

      await db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: id,
              noteId: widget.noteId,
              type: 'drawing',
              localPath: file.path,
              filename: filename,
            ),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drawing saved to this note.')),
      );
      context.pop();
    } catch (error) {
      if (createdFile != null && await createdFile.exists()) {
        await createdFile.delete();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save drawing: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sketch pad'),
      actions: [
        IconButton(
          tooltip: 'Save drawing',
          icon: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          onPressed: _saving ? null : _saveDrawing,
        ),
      ],
    ),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FeatureHero(
            icon: Icons.gesture_rounded,
            title: 'Sketch an idea',
            subtitle: 'Draw freely. Your sketch is saved as an attachment to this note.',
            compact: true,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 20, 12),
            child: NeoBrutalistPanel(
              color: AppTheme.lightSurface,
              padding: EdgeInsets.zero,
              child: Signature(
                controller: _controller,
                backgroundColor: AppTheme.lightSurface,
              ),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: NeoBrutalistPanel(
          color: AppTheme.pink,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Undo',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.undo),
                onPressed: _controller.undo,
              ),
              IconButton(
                tooltip: 'Redo',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.redo),
                onPressed: _controller.redo,
              ),
              IconButton(
                tooltip: 'Clear',
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.ink,
                  side: const BorderSide(color: AppTheme.ink, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(Icons.clear),
                onPressed: _controller.clear,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
