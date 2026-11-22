import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/app/theme.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
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
  bool _draftRestored = false;
  bool _suppressDraftPersistence = false;
  int _draftWriteGeneration = 0;
  Future<void> _draftWriteQueue = Future<void>.value();
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
      final title = preferences.getString(_draftTitleKey) ?? '';
      final content = preferences.getString(_draftContentKey) ?? '';
      _title.text = title;
      _content.text = content;
      _draftRestored = title.isNotEmpty || content.isNotEmpty;
    } catch (_) {
      // Keep capture available when preferences cannot be read.
    } finally {
      if (mounted) setState(() => _restoringDraft = false);
    }
  }

  Future<void> _persistDraft() {
    if (_restoringDraft || _suppressDraftPersistence || !mounted) {
      return Future<void>.value();
    }
    final generation = ++_draftWriteGeneration;
    final title = _title.text;
    final content = _content.text;
    _draftWriteQueue = _draftWriteQueue.then((_) async {
      if (!mounted ||
          _restoringDraft ||
          _suppressDraftPersistence ||
          generation != _draftWriteGeneration) {
        return;
      }
      try {
        final preferences = await SharedPreferences.getInstance();
        if (!mounted ||
            _suppressDraftPersistence ||
            generation != _draftWriteGeneration) {
          return;
        }
        await preferences.setString(_draftTitleKey, title);
        await preferences.setString(_draftContentKey, content);
      } catch (_) {
        // Explicit Save remains available if draft persistence fails.
      }
    });
    return _draftWriteQueue;
  }

  Future<void> _clearDraft() async {
    // Invalidate queued writes before removing the keys so a slower keystroke
    // write cannot recreate the draft after a successful capture.
    _draftWriteGeneration++;
    await _draftWriteQueue;
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
    if (_saving || _restoringDraft) return;
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
      await ref
          .read(databaseProvider)
          .saveNoteContent(
            id,
            title.isEmpty ? 'Quick capture' : title,
            content,
          );
      _suppressDraftPersistence = true;
      try {
        await _clearDraft();
        _draftRestored = false;
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
      } finally {
        _suppressDraftPersistence = false;
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Capture failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _captureDecoration({
    required String label,
    required String hint,
  }) {
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppTheme.ink, width: 2),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppTheme.lightSurface,
      labelStyle: const TextStyle(color: AppTheme.ink),
      hintStyle: TextStyle(color: AppTheme.ink.withValues(alpha: 0.6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: outline,
      enabledBorder: outline,
      disabledBorder: outline,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppTheme.ink, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCapture = !_saving && !_restoringDraft;
    final statusText = _restoringDraft
        ? 'Restoring your saved draft…'
        : _draftRestored
        ? 'A previous draft was restored. Changes stay on this device.'
        : 'Your unfinished text saves as a local draft while you write.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick capture'),
        actions: [
          TextButton(
            key: const ValueKey('quick-capture-save'),
            onPressed: canCapture ? () => _capture() : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const FeatureHero(
            icon: Icons.bolt_rounded,
            title: 'Catch the thought',
            subtitle: 'A quick local capture. Keep moving, organize it later.',
            compact: true,
          ),
          const SizedBox(height: 18),
          NeoBrutalistPanel(
            color: AppTheme.lightBackground,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('quick-capture-title'),
                  controller: _title,
                  enabled: canCapture,
                  autofocus: canCapture,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _captureDecoration(
                    label: 'Thought title',
                    hint: 'Give this thought a title…',
                  ),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('quick-capture-content'),
                  controller: _content,
                  enabled: canCapture,
                  minLines: 8,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _captureDecoration(
                    label: 'Your idea',
                    hint: 'Capture an idea before it disappears…',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppTheme.ink, height: 1.45),
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          NeoBrutalistPanel(
            color: AppTheme.tertiary,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _restoringDraft ? Icons.sync_rounded : Icons.save_outlined,
                  color: AppTheme.ink,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_restoringDraft) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const ValueKey('quick-capture-save-local'),
            onPressed: canCapture ? () => _capture() : null,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save locally'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey('quick-capture-save-edit'),
            onPressed: canCapture ? () => _capture(openEditor: true) : null,
            icon: const Icon(Icons.edit_note),
            label: const Text('Save and continue editing'),
          ),
          if (_saving) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 8),
          const Text(
            'Quick capture stays offline. Saved notes are stored in your local archive.',
          ),
        ],
      ),
    );
  }
}
