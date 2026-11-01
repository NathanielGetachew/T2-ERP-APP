import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart' hide Sha256;
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../database/database.dart';
import '../../utils/uuid.dart';
import 'backup_crypto.dart';
import 'backup_manifest.dart';

const privateBackupDirectories = <String>['customer_ids'];

typedef BackupProgress = void Function(double value, String stage);

abstract interface class BackupService {
  Future<File> createBackup(String password, {BackupProgress? onProgress});

  Future<BackupManifest> inspectBackup(File file, String password);

  Future<void> restoreBackup(
    File file,
    String password, {
    BackupProgress? onProgress,
  });
}

class BackupStorageException implements Exception {
  const BackupStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupMetadataStore {
  BackupMetadataStore({this.documentsDirectory});

  final Directory? documentsDirectory;

  Future<DateTime?> readLastBackupAt() async {
    final directory = await _directory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}last_backup_at.txt',
    );
    if (!await file.exists()) return null;
    final value = (await file.readAsString()).trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> writeLastBackupAt(DateTime value) async {
    final directory = await _directory();
    await File('${directory.path}${Platform.pathSeparator}last_backup_at.txt')
        .writeAsString(value.toUtc().toIso8601String());
  }

  Future<Directory> _directory() async =>
      documentsDirectory ?? await getApplicationDocumentsDirectory();
}

class DriftBackupService implements BackupService {
  DriftBackupService(
    this.database, {
    this.documentsDirectory,
    this.temporaryDirectory,
    this.closeDatabase,
    this.reopenDatabase,
    this.onBeforeSwap,
    this.onDuringSwap,
  });

  AppDatabase database;
  final Directory? documentsDirectory;
  final Directory? temporaryDirectory;
  final Future<void> Function()? closeDatabase;
  final Future<AppDatabase> Function()? reopenDatabase;
  final Future<void> Function()? onBeforeSwap;
  final Future<void> Function()? onDuringSwap;

  @override
  Future<File> createBackup(
    String password, {
    BackupProgress? onProgress,
  }) async {
    _validatePassword(password);
    final temp = await _tempDirectory();
    final work = await temp.createTemp('t2-backup-');
    try {
      onProgress?.call(0.05, 'snapshot');
      final zip = await _buildZip(work, onProgress: onProgress);
      final now = DateTime.now();
      final output = File(
        '${temp.path}${Platform.pathSeparator}${_backupFileName(now)}',
      );
      onProgress?.call(0.65, 'encrypt');
      await encryptBackupFile(input: zip, output: output, password: password);
      final manifest = await _readManifestFromZip(zip);
      await _writeBackupAudit(manifest, await output.length());
      onProgress?.call(1, 'complete');
      return output;
    } finally {
      if (await work.exists()) await work.delete(recursive: true);
    }
  }

  @override
  Future<BackupManifest> inspectBackup(File file, String password) async {
    _validatePassword(password);
    final temp = await _tempDirectory();
    final work = await temp.createTemp('t2-inspect-');
    try {
      final zip = File('${work.path}${Platform.pathSeparator}backup.zip');
      await decryptBackupFile(input: file, output: zip, password: password);
      final extracted = Directory('${work.path}${Platform.pathSeparator}zip');
      await _extractZip(zip, extracted);
      final manifest = await _readManifest(extracted);
      _validateManifestVersion(manifest);
      await _verifyManifestFiles(extracted, manifest);
      return manifest;
    } finally {
      if (await work.exists()) await work.delete(recursive: true);
    }
  }

  @override
  Future<void> restoreBackup(
    File file,
    String password, {
    BackupProgress? onProgress,
  }) async {
    _validatePassword(password);
    final manifest = await inspectBackup(file, password);
    final documents = await _documents();
    final temp = await _tempDirectory();
    final work = await temp.createTemp('t2-restore-');
    final staging = Directory(
      '${documents.path}${Platform.pathSeparator}backup_staging',
    );
    final oldDb = File(
      '${documents.path}${Platform.pathSeparator}t2_rental.sqlite.pre-restore',
    );
    final oldDirectories = <String, Directory>{};
    var swapped = false;
    try {
      onProgress?.call(0.15, 'stage');
      final zip = File('${work.path}${Platform.pathSeparator}backup.zip');
      await decryptBackupFile(input: file, output: zip, password: password);
      if (await staging.exists()) await staging.delete(recursive: true);
      await _extractZip(zip, staging);
      await _verifyManifestFiles(staging, manifest);

      onProgress?.call(0.35, 'safety');
      final safetyDirectory = Directory(
        '${documents.path}${Platform.pathSeparator}safety_backups',
      );
      await safetyDirectory.create(recursive: true);
      final safetyWork = await _buildZip(work, onProgress: null);
      final safetyFile = File(
        '${safetyDirectory.path}${Platform.pathSeparator}pre-restore-${_stamp(DateTime.now())}.t2backup',
      );
      await encryptBackupFile(
        input: safetyWork,
        output: safetyFile,
        password: password,
      );
      await _pruneSafetyBackups(safetyDirectory);

      onProgress?.call(0.55, 'swap');
      if (onBeforeSwap != null) await onBeforeSwap!();
      await (closeDatabase ?? database.close)();
      final currentDb = _databaseFile(documents);
      if (await currentDb.exists()) await currentDb.rename(oldDb.path);
      if (onDuringSwap != null) await onDuringSwap!();
      for (final directoryName in privateBackupDirectories) {
        final current = Directory(
          '${documents.path}${Platform.pathSeparator}$directoryName',
        );
        if (await current.exists()) {
          final old = Directory(
            '${documents.path}${Platform.pathSeparator}$directoryName.pre-restore',
          );
          if (await old.exists()) await old.delete(recursive: true);
          await current.rename(old.path);
          oldDirectories[directoryName] = old;
        }
      }
      final stagedDb = File(
        '${staging.path}${Platform.pathSeparator}db${Platform.pathSeparator}app.sqlite',
      );
      await stagedDb.copy(currentDb.path);
      for (final directoryName in privateBackupDirectories) {
        final staged = Directory(
          '${staging.path}${Platform.pathSeparator}files${Platform.pathSeparator}$directoryName',
        );
        if (await staged.exists()) {
          await staged.rename(
            '${documents.path}${Platform.pathSeparator}$directoryName',
          );
        }
      }
      await _deleteSidecars(documents);
      swapped = true;
      onProgress?.call(0.85, 'reopen');
      if (reopenDatabase != null) database = await reopenDatabase!();
      await _writeRestoreAudit(manifest, safetyFile.path);
      if (await oldDb.exists()) await oldDb.delete();
      for (final old in oldDirectories.values) {
        if (await old.exists()) await old.delete(recursive: true);
      }
      onProgress?.call(1, 'complete');
    } catch (error) {
      if (swapped) {
        throw BackupStorageException(
          'Restore swap failed after replacement; the safety copy is at ${oldDb.path}.',
        );
      }
      await _rollbackSwap(documents, oldDb, oldDirectories);
      rethrow;
    } finally {
      if (await work.exists()) await work.delete(recursive: true);
      if (await staging.exists()) await staging.delete(recursive: true);
    }
  }

  Future<File> _buildZip(Directory work, {BackupProgress? onProgress}) async {
    final documents = await _documents();
    final dbSnapshot = File('${work.path}${Platform.pathSeparator}app.sqlite');
    final escapedSnapshotPath = dbSnapshot.path.replaceAll("'", "''");
    await database.customStatement("VACUUM INTO '$escapedSnapshotPath'");
    final files = <BackupFileEntry>[await _entry(dbSnapshot, 'db/app.sqlite')];
    for (final directoryName in privateBackupDirectories) {
      final directory = Directory(
        '${documents.path}${Platform.pathSeparator}$directoryName',
      );
      if (!await directory.exists()) continue;
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final relative = _relativePath(documents, entity);
        files.add(await _entry(entity, 'files/$relative'));
      }
    }
    final counts = BackupCounts(
      customers: await database
          .select(database.customers)
          .get()
          .then((rows) => rows.length),
      materials: await database
          .select(database.materialTypes)
          .get()
          .then((rows) => rows.length),
      rentals: await database
          .select(database.rentals)
          .get()
          .then((rows) => rows.length),
      returnEvents: await database
          .select(database.returnEvents)
          .get()
          .then((rows) => rows.length),
      photos: files
          .where((file) => file.relativePath.startsWith('files/customer_ids/'))
          .length,
    );
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      appVersion: '1.0.0+1',
      dbSchemaVersion: database.schemaVersion,
      createdAtUtc: DateTime.now().toUtc(),
      counts: counts,
      files: files,
    );
    final manifestFile = File(
      '${work.path}${Platform.pathSeparator}manifest.json',
    );
    await manifestFile.writeAsString(manifest.encode());
    final zip = File('${work.path}${Platform.pathSeparator}backup.zip');
    final encoder = ZipFileEncoder();
    encoder.create(zip.path);
    await encoder.addFile(manifestFile, 'manifest.json');
    await encoder.addFile(dbSnapshot, 'db/app.sqlite');
    for (final file in files.where(
      (file) => file.relativePath != 'db/app.sqlite',
    )) {
      final docRelative = file.relativePath.startsWith('files/')
          ? file.relativePath.substring('files/'.length)
          : file.relativePath;
      await encoder.addFile(
        File(
          '${documents.path}${Platform.pathSeparator}${docRelative.replaceAll('/', Platform.pathSeparator)}',
        ),
        file.relativePath,
      );
    }
    encoder.close();
    onProgress?.call(0.5, 'package');
    return zip;
  }

  Future<BackupManifest> _readManifestFromZip(File zip) async {
    final temp = await _tempDirectory();
    final directory = await temp.createTemp('t2-manifest-');
    try {
      await _extractZip(zip, directory);
      return await _readManifest(directory);
    } finally {
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  }

  Future<BackupManifest> _readManifest(Directory directory) async {
    final file = File(
      '${directory.path}${Platform.pathSeparator}manifest.json',
    );
    return BackupManifest.fromJson(
      jsonDecode(await file.readAsString()) as Map<String, dynamic>,
    );
  }

  Future<void> _extractZip(File zip, Directory destination) async {
    await destination.create(recursive: true);
    final input = InputFileStream(zip.path);
    final archive = ZipDecoder().decodeStream(input);
    for (final entry in archive) {
      final name = entry.name.replaceAll('\\', '/');
      if (name.startsWith('/') || name.contains('../')) {
        throw const BackupFormatException(
          'Backup contains an unsafe file path.',
        );
      }
      final output = File(
        '${destination.path}${Platform.pathSeparator}${name.replaceAll('/', Platform.pathSeparator)}',
      );
      if (entry.isFile) {
        await output.parent.create(recursive: true);
        final stream = OutputFileStream(output.path);
        entry.writeContent(stream);
        stream.close();
      } else {
        await output.parent.create(recursive: true);
      }
    }
    input.close();
  }

  Future<void> _verifyManifestFiles(
    Directory extracted,
    BackupManifest manifest,
  ) async {
    for (final entry in manifest.files) {
      final file = File(
        '${extracted.path}${Platform.pathSeparator}${entry.relativePath.replaceAll('/', Platform.pathSeparator)}',
      );
      if (!await file.exists() || await file.length() != entry.size) {
        throw const BackupFormatException(
          'Backup file contents do not match the manifest.',
        );
      }
      final digestBytes = await _hashFile(file);
      if (_hex(digestBytes) != entry.sha256) {
        throw const BackupFormatException(
          'Backup checksum verification failed.',
        );
      }
    }
  }

  void _validateManifestVersion(BackupManifest manifest) {
    if (manifest.formatVersion > backupFormatVersion) {
      throw const UnsupportedBackupException(
        'This backup format requires a newer version of the app. Please update the app first.',
      );
    }
    if (manifest.dbSchemaVersion > appDatabaseSchemaVersion) {
      throw const UnsupportedBackupException(
        'This backup database schema requires a newer version of the app. Please update the app first.',
      );
    }
  }

  Future<BackupFileEntry> _entry(File file, String relativePath) async {
    final digestBytes = await _hashFile(file);
    return BackupFileEntry(
      relativePath: relativePath,
      size: await file.length(),
      sha256: _hex(digestBytes),
    );
  }

  Future<List<int>> _hashFile(File file) async {
    final sink = Sha256().newHashSink();
    await for (final chunk in file.openRead()) {
      sink.add(chunk);
    }
    sink.close();
    final hash = await sink.hash();
    return hash.bytes;
  }

  Future<void> _writeBackupAudit(BackupManifest manifest, int fileSize) async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            id: uuidV4(),
            createdAt: now,
            updatedAt: now,
            entityType: 'backup',
            entityId: uuidV4(),
            action: 'backupCreated',
            newValue: Value(
              jsonEncode({
                'counts': manifest.counts.toJson(),
                'fileSize': fileSize,
              }),
            ),
            at: now,
            by: 'local-user',
          ),
        );
  }

  Future<void> _writeRestoreAudit(
    BackupManifest manifest,
    String safetyPath,
  ) async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            id: uuidV4(),
            createdAt: now,
            updatedAt: now,
            entityType: 'backup',
            entityId: uuidV4(),
            action: 'backupRestored',
            newValue: Value(
              jsonEncode({
                'counts': manifest.counts.toJson(),
                'safetyCopy': safetyPath.split(Platform.pathSeparator).last,
              }),
            ),
            at: now,
            by: 'local-user',
          ),
        );
  }

  Future<void> _pruneSafetyBackups(Directory directory) async {
    final files =
        (await directory.list().where((entity) => entity is File).toList())
            .cast<File>()
          ..sort((a, b) => b.path.compareTo(a.path));
    for (final file in files.skip(3)) {
      await file.delete();
    }
  }

  Future<void> _rollbackSwap(
    Directory documents,
    File oldDb,
    Map<String, Directory> oldDirectories,
  ) async {
    final currentDb = _databaseFile(documents);
    if (await currentDb.exists() && await oldDb.exists()) {
      await currentDb.delete();
    }
    if (await oldDb.exists()) {
      await oldDb.rename(currentDb.path);
    }
    for (final entry in oldDirectories.entries) {
      final current = Directory(
        '${documents.path}${Platform.pathSeparator}${entry.key}',
      );
      if (await current.exists()) {
        await current.delete(recursive: true);
      }
      if (await entry.value.exists()) {
        await entry.value.rename(current.path);
      }
    }
  }

  Future<void> _deleteSidecars(Directory documents) async {
    for (final suffix in const ['-wal', '-shm']) {
      final file = File('${_databaseFile(documents).path}$suffix');
      if (await file.exists()) await file.delete();
    }
  }

  Future<Directory> _documents() async =>
      documentsDirectory ?? await getApplicationDocumentsDirectory();

  Future<Directory> _tempDirectory() async =>
      temporaryDirectory ?? await getTemporaryDirectory();

  File _databaseFile(Directory documents) =>
      File('${documents.path}${Platform.pathSeparator}t2_rental.sqlite');
}

void _validatePassword(String password) {
  if (password.length < 8) {
    throw const BackupStorageException(
      'Backup password must be at least 8 characters.',
    );
  }
}

String _relativePath(Directory root, File file) {
  final rootPath = root.path.endsWith(Platform.pathSeparator)
      ? root.path
      : '${root.path}${Platform.pathSeparator}';
  return file.path
      .substring(rootPath.length)
      .replaceAll(Platform.pathSeparator, '/');
}

String _backupFileName(DateTime value) =>
    'T2Rental-backup-${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}-${value.hour.toString().padLeft(2, '0')}${value.minute.toString().padLeft(2, '0')}.t2backup';

String _stamp(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}-${value.hour.toString().padLeft(2, '0')}${value.minute.toString().padLeft(2, '0')}${value.second.toString().padLeft(2, '0')}';

String _hex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
