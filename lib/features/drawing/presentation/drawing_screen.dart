import 'dart:io';

import 'package:mindvault_archive/core/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

import 'package:mindvault_archive/app/providers.dart';

class DrawingScreen extends ConsumerStatefulWidget {
  final String noteId;
  const DrawingScreen({super.key, required this.noteId});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
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
    try {
      final bytes = await _controller.toPngBytes();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Draw something before saving.');
      }

      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(p.join(documents.path, 'mindvault', 'drawings'));
      await directory.create(recursive: true);

      final id = const Uuid().v4();
      final filename = 'drawing_$id.png';
      final file = File(p.join(directory.path, filename));
      await file.writeAsBytes(bytes, flush: true);

      final db = ref.read(databaseProvider);
      final existing = await (db.select(db.notes)
            ..where((note) => note.id.equals(widget.noteId)))
          .getSingleOrNull();
      if (existing == null) {
        await db.into(db.notes).insert(
              NotesCompanion.insert(id: widget.noteId),
            );
      }

      await db.into(db.attachments).insert(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save drawing: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Drawing Canvas'),
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
        body: Signature(
          controller: _controller,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Undo',
                icon: const Icon(Icons.undo),
                onPressed: _controller.undo,
              ),
              IconButton(
                tooltip: 'Redo',
                icon: const Icon(Icons.redo),
                onPressed: _controller.redo,
              ),
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear),
                onPressed: _controller.clear,
              ),
            ],
          ),
        ),
      );
}
