import 'dart:convert';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/app/providers.dart';
import 'package:mindvault_archive/features/archive/data/archive_transfer_service.dart';
import 'package:mindvault_archive/features/archive/data/full_backup_service.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _shareExport() async {
    final document = _exportDocument;
    if (document == null) return;
    try {
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(document),
          mimeType: 'application/json',
          name: 'mindvault-archive.json',
        ),
      ], text: 'MindVault Archive JSON export');
    } catch (error) {
      if (mounted) _showMessage('Could not share archive: $error');
    }
  }

  Future<void> _pickImportFile() async {
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null) {
        _showMessage('Could not read the selected JSON file.');
        return;
      }
      _importController.text = utf8.decode(bytes);
      if (mounted) {
        _showMessage('JSON file loaded. Review it, then validate and import.');
      }
    } catch (error) {
      if (mounted) _showMessage('Could not open JSON file: $error');
    }
  }

  Future<void> _exportFullBackup() async {
    setState(() => _busy = true);
    try {
      final bytes =
          await FullBackupService(ref.read(databaseProvider)).exportZip();
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          mimeType: 'application/zip',
          name: 'mindvault-full-backup.zip',
        ),
      ], text: 'MindVault Archive full backup');
    } catch (error) {
      if (mounted) _showMessage('Full backup failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFullBackup() async {
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null) {
        _showMessage('Could not read the selected ZIP file.');
        return;
      }
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Restore full backup?'),
          content: const Text(
            'The backup will be validated and its attachment checksums verified. '
            'Existing notes, tasks and attachments with matching IDs will not '
            'be overwritten. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Validate and restore'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _busy = true);
      final result =
          await FullBackupService(ref.read(databaseProvider)).importZip(bytes);
      if (!mounted) return;
      _showMessage(
        'Restored ${result.imported} notes, ${result.importedTasks} tasks and '
        '${result.importedAttachments} attachments. Skipped '
        '${result.skipped} notes, ${result.skippedTasks} tasks and '
        '${result.skippedAttachments} attachments.',
      );
    } on FormatException catch (error) {
      if (mounted) _showMessage('Backup rejected: ${error.message}');
    } catch (error) {
      if (mounted) _showMessage('Restore failed: $error');
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archive transfer')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          const FeatureHero(
            icon: Icons.inventory_2_rounded,
            title: 'Your archive, protected',
            subtitle: 'Export, restore and move your local knowledge safely.',
          ),
          const SizedBox(height: 22),
          Text(
            'Full device backup',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create or restore a ZIP backup containing your archive data and '
            'attachment files. Each attachment is checked with SHA-256 before '
            'restore. Missing source files stop backup creation rather than '
            'silently producing an incomplete archive.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _exportFullBackup,
            icon: const Icon(Icons.backup_outlined),
            label: const Text('Create full ZIP backup'),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _importFullBackup,
            icon: const Icon(Icons.settings_backup_restore_outlined),
            label: const Text('Restore full ZIP backup'),
          ),
          const Divider(height: 28),
          Text(
            'Portable JSON transfer',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Export note, category, tag, task and revision data as versioned '
            'JSON, or import a previous MindVault JSON archive. Import validates '
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _copyExport,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy JSON'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _shareExport,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share / Save JSON'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(_exportDocument!, maxLines: 12),
          ],
          const SizedBox(height: 28),
          Text('Import archive', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Paste the complete JSON document. Existing notes and tasks are never '
            'overwritten. Categories and tags are matched by stable ID.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickImportFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Choose JSON file'),
          ),
          const SizedBox(height: 8),
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
            'Format v5 includes notes, categories, tags, note-tag links, linked tasks and '
            'note revisions. JSON-only transfer does not contain attachment '
            'bytes; use the full ZIP backup above when you need media files.',
          ),
        ],
      ),
    );
  }
}
