import 'dart:io';

import 'package:t2_rental/core/services/backup/backup_crypto.dart';
import 'package:t2_rental/core/services/backup/backup_manifest.dart';
import 'package:t2_rental/core/services/backup/backup_service.dart';

class FakeBackupService implements BackupService {
  File? createdBackupFile;
  BackupManifest? manifestToReturn;
  Object? createError;
  Object? inspectError;
  Object? restoreError;

  String? lastCreatePassword;
  String? lastInspectPassword;
  String? lastRestorePassword;
  File? lastRestoredFile;

  @override
  Future<File> createBackup(
    String password, {
    BackupProgress? onProgress,
  }) async {
    lastCreatePassword = password;
    if (createError != null) throw createError!;
    onProgress?.call(0.5, 'encrypt');
    onProgress?.call(1.0, 'complete');
    return createdBackupFile ??
        File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}fake.t2backup',
        );
  }

  @override
  Future<BackupManifest> inspectBackup(File file, String password) async {
    lastInspectPassword = password;
    if (inspectError != null) throw inspectError!;
    return manifestToReturn ??
        BackupManifest(
          formatVersion: backupFormatVersion,
          appVersion: '1.0.0+1',
          dbSchemaVersion: 4,
          createdAtUtc: DateTime.utc(2026, 11, 1),
          counts: const BackupCounts(
            customers: 5,
            materials: 3,
            rentals: 2,
            returnEvents: 1,
            photos: 4,
          ),
          files: const [],
        );
  }

  @override
  Future<void> restoreBackup(
    File file,
    String password, {
    BackupProgress? onProgress,
  }) async {
    lastRestoredFile = file;
    lastRestorePassword = password;
    if (restoreError != null) throw restoreError!;
    onProgress?.call(0.5, 'swap');
    onProgress?.call(1.0, 'complete');
  }
}
