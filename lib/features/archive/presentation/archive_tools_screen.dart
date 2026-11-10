import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/features/archive/data/archive_transfer_service.dart';

class ArchiveToolsScreen extends ConsumerStatefulWidget {
  const ArchiveToolsScreen({super.key});

  @override
  ConsumerState<ArchiveToolsScreen> createState() => _ArchiveToolsScreenState();
}

class _ArchiveToolsScreenState extends ConsumerState<ArchiveToolsScreen> {
  final _importController = TextEditingController();
  String? _exportDocument;
  bool _busy = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  ArchiveTransferService get _service =>
      ArchiveTransferService(ref.read(databaseProvider));

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final document = await _service.exportJson();
      if (!mounted) return;
      setState(() => _exportDocument = document);
    } catch (error) {
      _showMessage('Export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyExport() async {
    final document = _exportDocument;
    if (document == null) return;
    await Clipboard.setData(ClipboardData(text: document));
    if (mounted) _showMessage('Archive JSON copied to clipboard.');
  }

  Future<void> _import() async {
    if (_importController.text.trim().isEmpty) {
      _showMessage('Paste an archive JSON document first.');
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await _service.importJson(_importController.text);
      if (!mounted) return;
      _importController.clear();
      _showMessage(
        'Imported ${result.imported} notes, ${result.importedTasks} tasks, ${result.importedTags} tags and ${result.importedRevisions} revisions; skipped ${result.skipped} notes, ${result.skippedTasks} tasks, ${result.skippedTags} tags and ${result.skippedRevisions} revisions.',
      );
    } on FormatException catch (error) {
      _showMessage('Archive not imported: ${error.message}');
    } catch (error) {
      _showMessage('Import failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive transfer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Portable archive',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Export notes, categories, tags, tasks and revision history as versioned '
            'JSON, or import a previous MindVault archive. Import validates '
            'the document before writing and protects existing records.',
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Generate archive JSON'),
          ),
          if (_exportDocument != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _copyExport,
              icon: const Icon(Icons.copy),
              label: const Text('Copy archive JSON'),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _exportDocument!,
              maxLines: 12,
            ),
          ],
          const SizedBox(height: 28),
          Text('Import archive', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Paste the complete JSON document. Existing notes and tasks are never '
            'overwritten. Categories and tags are matched by stable ID.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _importController,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Paste MindVault archive JSON here',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Validate and import'),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 20),
          const Text(
            'Format v4 includes notes, categories, tags, note-tag links, tasks and note '
            'revisions, plus timestamps and archive state. Attachment file bytes '
            'and other binary assets are not included yet. This is not a full '
            'device backup.',
          ),
        ],
      ),
    );
  }
}
