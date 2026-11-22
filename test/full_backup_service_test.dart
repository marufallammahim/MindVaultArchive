import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault_archive/core/database/database.dart';
import 'package:mindvault_archive/features/archive/data/full_backup_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase sourceDatabase;
  late AppDatabase targetDatabase;
  late Directory sourceDirectory;
  late Directory restoreDirectory;

  setUp(() async {
    sourceDatabase = AppDatabase(NativeDatabase.memory());
    targetDatabase = AppDatabase(NativeDatabase.memory());
    sourceDirectory = await Directory.systemTemp.createTemp(
      'mindvault-source-',
    );
    restoreDirectory = await Directory.systemTemp.createTemp(
      'mindvault-restore-',
    );
  });

  tearDown(() async {
    await sourceDatabase.close();
    await targetDatabase.close();
    if (await sourceDirectory.exists()) {
      await sourceDirectory.delete(recursive: true);
    }
    if (await restoreDirectory.exists()) {
      await restoreDirectory.delete(recursive: true);
    }
  });

  test('full ZIP backup restores notes and attachment bytes', () async {
    await sourceDatabase.saveNoteContent(
      'backup-note',
      'Drawing note',
      'A note with a drawing attachment.',
    );
    final drawing = File(p.join(sourceDirectory.path, 'drawing.png'));
    final originalBytes = <int>[137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3];
    await drawing.writeAsBytes(originalBytes);
    await sourceDatabase
        .into(sourceDatabase.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'drawing-attachment',
            noteId: 'backup-note',
            type: 'drawing',
            localPath: drawing.path,
            filename: 'drawing.png',
            documentPosition: const Value(2),
          ),
        );

    final zip = await FullBackupService(sourceDatabase).exportZip();
    final result = await FullBackupService(
      targetDatabase,
      restoreDirectory: restoreDirectory,
    ).importZip(zip);

    expect(result.imported, 1);
    expect(result.importedAttachments, 1);
    final restoredNote = await (targetDatabase.select(
      targetDatabase.notes,
    )..where((note) => note.id.equals('backup-note'))).getSingle();
    expect(restoredNote.title, 'Drawing note');

    final restoredAttachment = await (targetDatabase.select(
      targetDatabase.attachments,
    )..where((item) => item.id.equals('drawing-attachment'))).getSingle();
    final restoredFile = File(restoredAttachment.localPath);
    expect(await restoredFile.exists(), isTrue);
    expect(await restoredFile.readAsBytes(), originalBytes);
  });

  test('rejects oversized ZIP output before decompression', () async {
    final archive = Archive()..addFile(ArchiveFile('large.bin', 1, [1]));
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive)!);
    final data = ByteData.sublistView(bytes);
    var centralDirectoryOffset = -1;
    for (var offset = 0; offset <= bytes.length - 46; offset++) {
      if (data.getUint32(offset, Endian.little) == 0x02014b50) {
        centralDirectoryOffset = offset;
        break;
      }
    }
    expect(centralDirectoryOffset, greaterThanOrEqualTo(0));
    data.setUint32(
      centralDirectoryOffset + 24,
      FullBackupService.maxBackupBytes + 1,
      Endian.little,
    );

    await expectLater(
      FullBackupService(
        targetDatabase,
        restoreDirectory: restoreDirectory,
      ).importZip(bytes),
      throwsA(isA<FormatException>()),
    );
    expect(await targetDatabase.select(targetDatabase.notes).get(), isEmpty);
  });

  test(
    'full backup refuses to silently omit missing attachment files',
    () async {
      await sourceDatabase.saveNoteContent(
        'missing-file-note',
        'Missing file',
        'This backup must fail.',
      );
      await sourceDatabase
          .into(sourceDatabase.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'missing-attachment',
              noteId: 'missing-file-note',
              type: 'audio',
              localPath: p.join(sourceDirectory.path, 'not-found.m4a'),
              filename: 'not-found.m4a',
            ),
          );

      await expectLater(
        FullBackupService(sourceDatabase).exportZip(),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'full backup skips colliding attachment IDs without overwriting',
    () async {
      await sourceDatabase.saveNoteContent(
        'collision-note',
        'Source note',
        'Backup body',
      );
      final sourceFile = File(p.join(sourceDirectory.path, 'source.bin'));
      await sourceFile.writeAsBytes([1, 2, 3, 4]);
      await sourceDatabase
          .into(sourceDatabase.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'same-attachment',
              noteId: 'collision-note',
              type: 'file',
              localPath: sourceFile.path,
              filename: 'source.bin',
            ),
          );

      await targetDatabase.saveNoteContent(
        'collision-note',
        'Local note',
        'Keep local content',
      );
      final localFile = File(p.join(restoreDirectory.path, 'local.bin'));
      await localFile.writeAsBytes([9, 9, 9]);
      await targetDatabase
          .into(targetDatabase.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'same-attachment',
              noteId: 'collision-note',
              type: 'file',
              localPath: localFile.path,
              filename: 'local.bin',
            ),
          );

      final zip = await FullBackupService(sourceDatabase).exportZip();
      final result = await FullBackupService(
        targetDatabase,
        restoreDirectory: restoreDirectory,
      ).importZip(zip);

      expect(result.skipped, 1);
      expect(result.skippedAttachments, 1);
      final note = await (targetDatabase.select(
        targetDatabase.notes,
      )..where((item) => item.id.equals('collision-note'))).getSingle();
      expect(note.title, 'Local note');
      expect(await localFile.readAsBytes(), [9, 9, 9]);
    },
  );
}
