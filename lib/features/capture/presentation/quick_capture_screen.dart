import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _restoringDraft = true;
  static const _draftTitleKey = 'quick_capture_draft_title';
  static const _draftContentKey = 'quick_capture_draft_content';

  @override
  void initState() {
    super.initState();
    _title.addListener(_persistDraft);
    _content.addListener(_persistDraft);
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      _title.text = preferences.getString(_draftTitleKey) ?? '';
      _content.text = preferences.getString(_draftContentKey) ?? '';
    } catch (_) {
      // Keep capture available when preferences cannot be read.
    } finally {
      if (mounted) setState(() => _restoringDraft = false);
    }
  }

  Future<void> _persistDraft() async {
    if (_restoringDraft || !mounted) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_draftTitleKey, _title.text);
      await preferences.setString(_draftContentKey, _content.text);
    } catch (_) {
      // Explicit Save remains available if draft persistence fails.
    }
  }

  Future<void> _clearDraft() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_draftTitleKey);
      await preferences.remove(_draftContentKey);
    } catch (_) {
      // A stale draft can be safely overwritten on the next capture.
    }
  }

  @override
  void dispose() {
    _title.removeListener(_persistDraft);
    _content.removeListener(_persistDraft);
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
          content: Text('Write a title or capture an idea first.'),
        ),
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
      await _clearDraft();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Capture failed: $error')));
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
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Give this thought a title…',
              border: InputBorder.none,
            ),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.7),
          ),
          const Divider(),
          TextField(
            controller: _content,
            minLines: 10,
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
          if (_restoringDraft)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          const Text(
            'Unfinished text is saved as a local draft and restored when you return. Saved notes stay on this device.',
          ),
        ],
      ),
    );
  }
}
