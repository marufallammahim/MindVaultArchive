import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:uuid/uuid.dart';

class QuickCaptureScreen extends ConsumerStatefulWidget {
  const QuickCaptureScreen({super.key});

  @override
  ConsumerState<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends ConsumerState<QuickCaptureScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _capture({bool openEditor = false}) async {
    if (_saving) return;
    final title = _title.text.trim();
    final content = _content.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Write a title or capture an idea first.')),
      );
      return;
    }
    setState(() => _saving = true);
    final id = const Uuid().v4();
    try {
      await ref.read(databaseProvider).saveNoteContent(
            id,
            title.isEmpty ? 'Quick capture' : title,
            content,
          );
      if (!mounted) return;
      if (openEditor) {
        context.go('/editor/$id');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved locally to your archive.')),
        );
        _title.clear();
        _content.clear();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: ' + error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick capture'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _capture(),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Give this thought a title…',
              border: InputBorder.none,
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          TextField(
            controller: _content,
            minLines: 8,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Capture an idea before it disappears…',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : () => _capture(openEditor: true),
            icon: const Icon(Icons.edit_note),
            label: const Text('Save and continue editing'),
          ),
          if (_saving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 8),
          const Text(
            'Quick captures are saved on this device. No account or internet connection is required.',
          ),
        ],
      ),
    );
  }
}
