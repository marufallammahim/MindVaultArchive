import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/archive/data/archive_transfer_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Full ZIP backup containing the versioned JSON archive and attachment bytes.
///
/// Local absolute paths are never exported. Each attachment is restored to a
/// new app-private path and its SHA-256 checksum is verified before import.
class FullBackupService {
  FullBackupService(this._database, {Directory? restoreDirectory})
      : _restoreDirectory = restoreDirectory;

  static const backupFormat = 'mindvault-full-backup';
  static const backupVersion = 1;
  static const maxBackupBytes = 250 * 1024 * 1024;
  static const maxAttachments = 1000;

  final AppDatabase _database;
  final Directory? _restoreDirectory;

  Future<Uint8List> exportZip() async {
    final zip = Archive();
    final archiveJson = await ArchiveTransferService(_database).exportJson();
    final jsonBytes = utf8.encode(archiveJson);
    zip.addFile(
      ArchiveFile('mindvault-archive.json', jsonBytes.length, jsonBytes),
    );

    final attachments = await _database.select(_database.attachments).get();
    if (attachments.length > maxAttachments) {
      throw StateError('Backup contains too many attachments.');
    }

    var totalBytes = jsonBytes.length;
    final manifestAttachments = <Map<String, Object?>>[];

    for (final attachment in attachments) {
      if (!_validId(attachment.id)) {
        throw StateError('Attachment ID is not safe for portable backup.');
      }
      final source = File(attachment.localPath);
      if (!await source.exists()) {
        throw StateError(
          'Attachment "' +
              attachment.filename +
              '" is missing. Backup stopped '
                  'to avoid creating an incomplete archive.',
        );
      }

      final bytes = await source.readAsBytes();
      totalBytes += bytes.length;
      if (totalBytes > maxBackupBytes) {
        throw StateError('Backup exceeds the 250 MB safety limit.');
      }

      final safeName = _safeFilename(attachment.filename);
      final archivePath = 'attachments/' + attachment.id + '/' + safeName;
      zip.addFile(ArchiveFile(archivePath, bytes.length, bytes));

      manifestAttachments.add({
        'id': attachment.id,
        'noteId': attachment.noteId,
        'type': attachment.type,
        'filename': p.basename(attachment.filename),
        'duration': attachment.duration,
        'documentPosition': attachment.documentPosition,
        'createdAt': attachment.createdAt.toUtc().toIso8601String(),
        'metadata': attachment.metadata,
        'archivePath': archivePath,
        'sha256': sha256.convert(bytes).toString(),
      });
    }

    final manifest = <String, Object?>{
      'format': backupFormat,
      'version': backupVersion,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'attachments': manifestAttachments,
    };
    final manifestBytes = utf8.encode(jsonEncode(manifest));
    zip.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    final encoded = ZipEncoder().encode(zip);
    if (encoded == null) {
      throw StateError('Could not encode the full backup ZIP.');
    }
    if (encoded.length > maxBackupBytes) {
      throw StateError('Compressed backup exceeds the 250 MB safety limit.');
    }
    return Uint8List.fromList(encoded);
  }

  Future<ArchiveImportResult> importZip(Uint8List zipBytes) async {
    if (zipBytes.length > maxBackupBytes) {
      throw const FormatException('Backup exceeds the 250 MB safety limit.');
    }

    final decoded = ZipDecoder().decodeBytes(zipBytes);
    final files = <String, ArchiveFile>{};
    var uncompressedBytes = 0;
    for (final file in decoded.files) {
      if (!file.isFile) continue;
      if (_unsafeArchivePath(file.name)) {
        throw const FormatException('Backup contains an unsafe file path.');
      }
      if (files.containsKey(file.name)) {
        throw const FormatException('Backup contains duplicate file paths.');
      }
      final bytes = _fileBytes(file);
      uncompressedBytes += bytes.length;
      if (uncompressedBytes > maxBackupBytes) {
        throw const FormatException(
          'Uncompressed backup exceeds the 250 MB safety limit.',
        );
      }
      files[file.name] = file;
    }

    final jsonFile = files['mindvault-archive.json'];
    final manifestFile = files['manifest.json'];
    if (jsonFile == null || manifestFile == null) {
      throw const FormatException('Backup is missing required archive files.');
    }

    final archiveJson = utf8.decode(_fileBytes(jsonFile));
    final manifestValue = jsonDecode(utf8.decode(_fileBytes(manifestFile)));
    if (manifestValue is! Map<String, dynamic> ||
        manifestValue['format'] != backupFormat ||
        manifestValue['version'] != backupVersion) {
      throw const FormatException('Unsupported full backup format.');
    }

    final rawAttachments = manifestValue['attachments'];
    if (rawAttachments is! List || rawAttachments.length > maxAttachments) {
      throw const FormatException('Backup attachment manifest is invalid.');
    }

    final archiveValue = jsonDecode(archiveJson);
    if (archiveValue is! Map<String, dynamic> ||
        archiveValue['contents'] is! Map<String, dynamic> ||
        (archiveValue['contents'] as Map<String, dynamic>)['notes'] is! List) {
      throw const FormatException('Backup note archive is invalid.');
    }
    final rawNotes =
        (archiveValue['contents'] as Map<String, dynamic>)['notes'] as List;
    final archivedNoteIds = rawNotes
        .whereType<Map<String, dynamic>>()
        .map((note) => note['id'])
        .whereType<String>()
        .toSet();

    final prepared = <_PreparedAttachment>[];
    final attachmentIds = <String>{};
    for (final raw in rawAttachments) {
      if (raw is! Map<String, dynamic>) {
        throw const FormatException('Backup contains an invalid attachment.');
      }
      final id = raw['id'];
      final noteId = raw['noteId'];
      final type = raw['type'];
      final filename = raw['filename'];
      final duration = raw['duration'];
      final position = raw['documentPosition'];
      final createdAt = raw['createdAt'];
      final metadata = raw['metadata'];
      final archivePath = raw['archivePath'];
      final checksum = raw['sha256'];

      if (id is! String ||
          !_validId(id) ||
          !attachmentIds.add(id) ||
          noteId is! String ||
          !archivedNoteIds.contains(noteId) ||
          type is! String ||
          type.trim().isEmpty ||
          filename is! String ||
          filename.trim().isEmpty ||
          (duration != null && duration is! int) ||
          position is! int ||
          createdAt is! String ||
          (metadata != null && metadata is! String) ||
          archivePath is! String ||
          checksum is! String) {
        throw const FormatException('Backup attachment fields are invalid.');
      }

      final expectedPath = 'attachments/' + id + '/' + _safeFilename(filename);
      if (archivePath != expectedPath) {
        throw const FormatException(
          'Backup attachment path does not match its ID.',
        );
      }
      final entry = files[archivePath];
      if (entry == null) {
        throw const FormatException('Backup attachment file is missing.');
      }
      final bytes = _fileBytes(entry);
      if (sha256.convert(bytes).toString() != checksum) {
        throw const FormatException('Backup attachment checksum failed.');
      }
      prepared.add(
        _PreparedAttachment(
          id: id,
          noteId: noteId,
          type: type,
          filename: filename,
          duration: duration as int?,
          documentPosition: position,
          createdAt: _parseDate(createdAt),
          metadata: metadata as String?,
          bytes: bytes,
        ),
      );
    }

    final attachmentDirectory = await _attachmentsDirectory();
    final createdFiles = <String, File>{};
    final records = <AttachmentImportRecord>[];

    try {
      for (final item in prepared) {
        final uniqueName = item.id +
            '_' +
            const Uuid().v4() +
            '_' +
            _safeFilename(item.filename);
        final target = File(p.join(attachmentDirectory.path, uniqueName));
        await target.writeAsBytes(item.bytes, flush: true);
        createdFiles[item.id] = target;
        records.add(
          AttachmentImportRecord(
            id: item.id,
            noteId: item.noteId,
            type: item.type,
            localPath: target.path,
            filename: item.filename,
            duration: item.duration,
            documentPosition: item.documentPosition,
            createdAt: item.createdAt,
            metadata: item.metadata,
          ),
        );
      }

      final result = await ArchiveTransferService(_database)
          .importJson(archiveJson, attachments: records);
      final importedIds = result.importedAttachmentIds.toSet();
      for (final entry in createdFiles.entries) {
        if (!importedIds.contains(entry.key)) {
          await entry.value.delete();
        }
      }
      return result;
    } catch (_) {
      for (final file in createdFiles.values) {
        if (await file.exists()) await file.delete();
      }
      rethrow;
    }
  }

  Future<Directory> _attachmentsDirectory() async {
    final root = _restoreDirectory ??
        Directory(
          p.join(
            (await getApplicationDocumentsDirectory()).path,
            'mindvault_archive',
            'attachments',
          ),
        );
    await root.create(recursive: true);
    return root;
  }

  Uint8List _fileBytes(ArchiveFile file) {
    final content = file.content;
    if (content is List<int>) return Uint8List.fromList(content);
    throw const FormatException('Backup contains an unreadable file entry.');
  }

  bool _validId(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(value);

  bool _unsafeArchivePath(String value) {
    if (value.startsWith('/') || value.contains(String.fromCharCode(92))) {
      return true;
    }
    final segments = value.split('/');
    return segments.any((segment) => segment == '..' || segment == '.');
  }

  String _safeFilename(String value) {
    final base = p.basename(value.trim());
    final safe = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return safe.isEmpty || safe == '.' || safe == '..'
        ? 'attachment.bin'
        : safe;
  }

  DateTime _parseDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException('Backup contains an invalid timestamp.');
    }
    return parsed.toUtc();
  }
}

class _PreparedAttachment {
  const _PreparedAttachment({
    required this.id,
    required this.noteId,
    required this.type,
    required this.filename,
    required this.duration,
    required this.documentPosition,
    required this.createdAt,
    required this.metadata,
    required this.bytes,
  });

  final String id;
  final String noteId;
  final String type;
  final String filename;
  final int? duration;
  final int documentPosition;
  final DateTime createdAt;
  final String? metadata;
  final Uint8List bytes;
}
