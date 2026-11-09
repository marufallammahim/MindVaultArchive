import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:go_router/go_router.dart';

class DrawingScreen extends StatefulWidget {
  final String noteId;
  const DrawingScreen({super.key, required this.noteId});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Drawing Canvas'),
          actions: [
            IconButton(
              tooltip: 'Finish drawing',
              icon: const Icon(Icons.check),
              onPressed: () => context.pop(),
            ),
          ],
        ),
        body: Signature(
          controller: _controller,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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