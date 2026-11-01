import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart' hide Sha256;
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t2_rental/core/database/database.dart';
import 'package:t2_rental/core/services/backup/backup_crypto.dart';
import 'package:t2_rental/core/services/backup/backup_manifest.dart';
import 'package:t2_rental/core/services/backup/backup_service.dart';

void main() {
  late Directory tempDir;
  late Directory docsDir;
  late Directory workDir;
  late File dbFile;
  final openDbs = <AppDatabase>[];

  AppDatabase createDb(File file) {
    final d = AppDatabase(NativeDatabase(file));
    openDbs.add(d);
    return d;
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('t2-backup-service-test-');
    docsDir = Directory('${tempDir.path}${Platform.pathSeparator}docs');
    workDir = Directory('${tempDir.path}${Platform.pathSeparator}work');
    await docsDir.create(recursive: true);
    await workDir.create(recursive: true);
    dbFile = File('${docsDir.path}${Platform.pathSeparator}t2_rental.sqlite');
  });

  tearDown(() async {
    for (final d in openDbs) {
      try {
        await d.close();
      } catch (_) {}
    }
    openDbs.clear();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  Future<void> seedTestData(AppDatabase database, Directory documents) async {
    final now = DateTime.utc(2026, 11, 1, 10, 0);

    // 1. Customer
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'cust-1',
            fullName: 'Abebe Kebede',
            address: 'Bole, Addis Ababa',
            phone: '0911000000',
            idPhotoFront: 'customer_ids/cust_1_front.jpg',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Fake photo file
    final photoDir = Directory(
      '${documents.path}${Platform.pathSeparator}customer_ids',
    );
    await photoDir.create(recursive: true);
    final photoFile = File(
      '${photoDir.path}${Platform.pathSeparator}cust_1_front.jpg',
    );
    await photoFile.writeAsBytes(List<int>.generate(64, (i) => i * 3 % 256));

    // 2. Material
    await database
        .into(database.materialTypes)
        .insert(
          MaterialTypesCompanion.insert(
            id: 'mat-1',
            name: 'Panel 60x120',
            category: 'Panel',
            pricePerDay: 2500, // 25.00 ETB
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 3. Rental
    await database
        .into(database.rentals)
        .insert(
          RentalsCompanion.insert(
            id: 'rent-1',
            customerId: 'cust-1',
            rentedAt: now,
            status: 'partiallyReturned',
            rentalNumber: const Value(1),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 4. RentalItem
    await database
        .into(database.rentalItems)
        .insert(
          RentalItemsCompanion.insert(
            id: 'item-1',
            rentalId: 'rent-1',
            materialTypeId: 'mat-1',
            materialNameSnapshot: 'Panel 60x120',
            pricePerDaySnapshot: 2500,
            quantity: 10,
            quantityReturned: 4,
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 5. Active return event
    await database
        .into(database.returnEvents)
        .insert(
          ReturnEventsCompanion.insert(
            id: 'ret-1',
            rentalItemId: 'item-1',
            quantity: 4,
            returnedAt: now,
            billableDays: 2,
            amount: 20000,
            rentalId: const Value('rent-1'),
            pricePerDaySnapshot: const Value(2500),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 6. Voided return event
    await database
        .into(database.returnEvents)
        .insert(
          ReturnEventsCompanion.insert(
            id: 'ret-2',
            rentalItemId: 'item-1',
            quantity: 2,
            returnedAt: now,
            billableDays: 3,
            amount: 15000,
            rentalId: const Value('rent-1'),
            pricePerDaySnapshot: const Value(2500),
            voidedAt: Value(now),
            voidReason: const Value('Accidental return registered'),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('createBackup -> inspectBackup: counts, checksums, and tampered detection', () async {
    final db = createDb(dbFile);
    await seedTestData(db, docsDir);

    final service = DriftBackupService(
      db,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );

    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);
    expect(await backupFile.exists(), isTrue);

    // Inspect the backup
    final manifest = await service.inspectBackup(backupFile, password);
    expect(manifest.formatVersion, equals(backupFormatVersion));
    expect(manifest.dbSchemaVersion, equals(appDatabaseSchemaVersion));
    expect(manifest.counts.customers, equals(1));
    expect(manifest.counts.materials, equals(1));
    expect(manifest.counts.rentals, equals(1));
    expect(manifest.counts.returnEvents, equals(2));
    expect(manifest.counts.photos, equals(1));

    // Audit log should record 'backupCreated'
    final audits = await db.select(db.auditLogs).get();
    expect(audits.any((a) => a.action == 'backupCreated'), isTrue);

    // Tamper with an inner file inside the zip:
    // Extract, flip a byte in the photo file, re-zip, re-encrypt
    final tamperDir = await workDir.createTemp('tamper-');
    final zipFile = File(
      '${tamperDir.path}${Platform.pathSeparator}backup.zip',
    );
    await decryptBackupFile(
      input: backupFile,
      output: zipFile,
      password: password,
    );

    final extractedDir = Directory(
      '${tamperDir.path}${Platform.pathSeparator}extracted',
    );
    await extractedDir.create(recursive: true);
    final input = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeStream(input);
    for (final entry in archive) {
      final f = File(
        '${extractedDir.path}${Platform.pathSeparator}${entry.name}',
      );
      if (entry.isFile) {
        await f.parent.create(recursive: true);
        final out = OutputFileStream(f.path);
        entry.writeContent(out);
        out.close();
      }
    }
    input.close();

    // Modify the photo bytes
    final tamperedPhoto = File(
      '${extractedDir.path}${Platform.pathSeparator}files${Platform.pathSeparator}customer_ids${Platform.pathSeparator}cust_1_front.jpg',
    );
    final photoBytes = await tamperedPhoto.readAsBytes();
    photoBytes[0] ^= 0xFF;
    await tamperedPhoto.writeAsBytes(photoBytes);

    // Re-create the zip with the tampered photo (manifest is unchanged)
    final tamperedZip = File(
      '${tamperDir.path}${Platform.pathSeparator}tampered.zip',
    );
    final encoder = ZipFileEncoder();
    encoder.create(tamperedZip.path);
    for (final entity in extractedDir.listSync(recursive: true)) {
      if (entity is File) {
        final relative = entity.path
            .substring(extractedDir.path.length + 1)
            .replaceAll(Platform.pathSeparator, '/');
        await encoder.addFile(entity, relative);
      }
    }
    encoder.close();

    final tamperedBackup = File(
      '${tamperDir.path}${Platform.pathSeparator}tampered.t2backup',
    );
    await encryptBackupFile(
      input: tamperedZip,
      output: tamperedBackup,
      password: password,
    );

    // Inspecting tampered backup should fail checksum verification
    expect(
      service.inspectBackup(tamperedBackup, password),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('restore into a fresh app dir: row values and photo bytes identical', () async {
    final db = createDb(dbFile);
    await seedTestData(db, docsDir);

    final service = DriftBackupService(
      db,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );

    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    // Fresh target directory
    final freshDocs = Directory(
      '${tempDir.path}${Platform.pathSeparator}fresh_docs',
    );
    await freshDocs.create(recursive: true);
    final freshDbFile = File(
      '${freshDocs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    var freshDb = createDb(freshDbFile);

    final freshService = DriftBackupService(
      freshDb,
      documentsDirectory: freshDocs,
      temporaryDirectory: workDir,
      closeDatabase: () async => freshDb.close(),
      reopenDatabase: () async {
        freshDb = createDb(freshDbFile);
        return freshDb;
      },
    );

    await freshService.restoreBackup(backupFile, password);

    // Verify row values
    final customers = await freshDb.select(freshDb.customers).get();
    expect(customers.length, equals(1));
    expect(customers.first.fullName, equals('Abebe Kebede'));

    final rentals = await freshDb.select(freshDb.rentals).get();
    expect(rentals.length, equals(1));
    expect(rentals.first.status, equals('partiallyReturned'));

    final items = await freshDb.select(freshDb.rentalItems).get();
    expect(items.length, equals(1));
    expect(items.first.quantity, equals(10));
    expect(items.first.quantityReturned, equals(4));

    final returns = await freshDb.select(freshDb.returnEvents).get();
    expect(returns.length, equals(2));

    // Verify photo bytes
    final restoredPhoto = File(
      '${freshDocs.path}${Platform.pathSeparator}customer_ids${Platform.pathSeparator}cust_1_front.jpg',
    );
    expect(await restoredPhoto.exists(), isTrue);
    final expectedBytes = List<int>.generate(64, (i) => i * 3 % 256);
    expect(await restoredPhoto.readAsBytes(), equals(expectedBytes));

    // Audit log should record 'backupRestored'
    final audits = await freshDb.select(freshDb.auditLogs).get();
    expect(audits.any((a) => a.action == 'backupRestored'), isTrue);
  });

  test('restore over different data fully replaces it', () async {
    final db = createDb(dbFile);
    await seedTestData(db, docsDir);
    final service = DriftBackupService(
      db,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );
    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    // Target with DIFFERENT data
    final targetDocs = Directory(
      '${tempDir.path}${Platform.pathSeparator}target_docs',
    );
    await targetDocs.create(recursive: true);
    final targetDbFile = File(
      '${targetDocs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    var targetDb = createDb(targetDbFile);

    final now = DateTime.utc(2026, 11, 1);
    await targetDb
        .into(targetDb.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'cust-old',
            fullName: 'Old Customer Should Disappear',
            address: 'Old Address',
            phone: '0900000000',
            idPhotoFront: 'customer_ids/old.jpg',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final targetService = DriftBackupService(
      targetDb,
      documentsDirectory: targetDocs,
      temporaryDirectory: workDir,
      closeDatabase: () async => targetDb.close(),
      reopenDatabase: () async {
        targetDb = createDb(targetDbFile);
        return targetDb;
      },
    );

    await targetService.restoreBackup(backupFile, password);

    final customers = await targetDb.select(targetDb.customers).get();
    expect(customers.length, equals(1));
    expect(customers.first.fullName, equals('Abebe Kebede'));
    expect(customers.any((c) => c.fullName.contains('Disappear')), isFalse);
  });

  test('safety copies created and pruned to 3', () async {
    var testDb = createDb(dbFile);
    await seedTestData(testDb, docsDir);
    final service = DriftBackupService(
      testDb,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
      closeDatabase: () async => testDb.close(),
      reopenDatabase: () async {
        testDb = createDb(dbFile);
        return testDb;
      },
    );
    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    final safetyDir = Directory(
      '${docsDir.path}${Platform.pathSeparator}safety_backups',
    );
    await safetyDir.create(recursive: true);

    // Pre-create 4 dummy safety backup files
    for (var i = 1; i <= 4; i++) {
      final f = File(
        '${safetyDir.path}${Platform.pathSeparator}pre-restore-2026110$i-120000.t2backup',
      );
      await f.writeAsString('safety $i');
    }

    // Now restore, which builds a new safety copy and prunes to 3
    await service.restoreBackup(backupFile, password);

    final safetyFiles = safetyDir.listSync().whereType<File>().toList();
    expect(safetyFiles.length, equals(3));
  });

  test('failure injected BEFORE swap leaves current data untouched', () async {
    final seedDb = createDb(dbFile);
    await seedTestData(seedDb, docsDir);
    final service = DriftBackupService(
      seedDb,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );
    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    // Target with original data
    final targetDocs = Directory(
      '${tempDir.path}${Platform.pathSeparator}target_before_swap',
    );
    await targetDocs.create(recursive: true);
    final targetDbFile = File(
      '${targetDocs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    var targetDb = createDb(targetDbFile);

    final now = DateTime.utc(2026, 11, 1);
    await targetDb
        .into(targetDb.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'cust-keep',
            fullName: 'Keep This Data',
            address: 'Keep Address',
            phone: '0999999999',
            idPhotoFront: 'customer_ids/keep.jpg',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final failingService = DriftBackupService(
      targetDb,
      documentsDirectory: targetDocs,
      temporaryDirectory: workDir,
      closeDatabase: () async => targetDb.close(),
      reopenDatabase: () async {
        targetDb = createDb(targetDbFile);
        return targetDb;
      },
      onBeforeSwap: () async => throw Exception('Disk full before swap'),
    );

    await expectLater(
      failingService.restoreBackup(backupFile, password),
      throwsA(isA<Exception>()),
    );

    // Verify current data is untouched
    final customers = await targetDb.select(targetDb.customers).get();
    expect(customers.length, equals(1));
    expect(customers.first.fullName, equals('Keep This Data'));
  });

  test('failure injected DURING swap rolls back', () async {
    final seedDb = createDb(dbFile);
    await seedTestData(seedDb, docsDir);
    final service = DriftBackupService(
      seedDb,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );
    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    final targetDocs = Directory(
      '${tempDir.path}${Platform.pathSeparator}target_during_swap',
    );
    await targetDocs.create(recursive: true);
    final targetDbFile = File(
      '${targetDocs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    var targetDb = createDb(targetDbFile);

    final now = DateTime.utc(2026, 11, 1);
    await targetDb
        .into(targetDb.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'cust-keep2',
            fullName: 'Keep This Data 2',
            address: 'Keep Address 2',
            phone: '0999999999',
            idPhotoFront: 'customer_ids/keep2.jpg',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final failingService = DriftBackupService(
      targetDb,
      documentsDirectory: targetDocs,
      temporaryDirectory: workDir,
      closeDatabase: () async => targetDb.close(),
      reopenDatabase: () async {
        targetDb = createDb(targetDbFile);
        return targetDb;
      },
      onDuringSwap: () async => throw Exception('Crash during swap'),
    );

    await expectLater(
      failingService.restoreBackup(backupFile, password),
      throwsA(isA<Exception>()),
    );

    // Reopen targetDb to verify rollback restored original file
    targetDb = createDb(targetDbFile);
    final customers = await targetDb.select(targetDb.customers).get();
    expect(customers.length, equals(1));
    expect(customers.first.fullName, equals('Keep This Data 2'));
  });

  test('a backup from an older schema version migrates on restore', () async {
    // 1. Create a database at schema version 3
    final v3Docs = Directory('${tempDir.path}${Platform.pathSeparator}v3_docs');
    await v3Docs.create(recursive: true);
    final v3DbFile = File(
      '${v3Docs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    final v3Db = createDb(v3DbFile);

    // Seed v3 data
    await seedTestData(v3Db, v3Docs);

    // Rollback schema to version 3 by dropping v4 columns and setting PRAGMA user_version = 3
    await v3Db.customStatement(
      'ALTER TABLE return_events DROP COLUMN voided_at;',
    );
    await v3Db.customStatement(
      'ALTER TABLE return_events DROP COLUMN void_reason;',
    );
    await v3Db.customStatement('PRAGMA user_version = 3;');
    await v3Db.close();

    // Package this into a backup file with dbSchemaVersion = 3 in manifest
    final v3Zip = File('${workDir.path}${Platform.pathSeparator}v3_backup.zip');
    final manifest = BackupManifest(
      formatVersion: backupFormatVersion,
      appVersion: '1.0.0+1',
      dbSchemaVersion: 3,
      createdAtUtc: DateTime.utc(2026, 11, 1),
      counts: const BackupCounts(
        customers: 1,
        materials: 1,
        rentals: 1,
        returnEvents: 2,
        photos: 1,
      ),
      files: [
        BackupFileEntry(
          relativePath: 'db/app.sqlite',
          size: await v3DbFile.length(),
          sha256: _hex(
            (await Sha256().hash(await v3DbFile.readAsBytes())).bytes,
          ),
        ),
      ],
    );

    final manifestFile = File(
      '${workDir.path}${Platform.pathSeparator}v3_manifest.json',
    );
    await manifestFile.writeAsString(manifest.encode());
    final encoder = ZipFileEncoder();
    encoder.create(v3Zip.path);
    await encoder.addFile(manifestFile, 'manifest.json');
    await encoder.addFile(v3DbFile, 'db/app.sqlite');
    encoder.close();

    const password = 'test-secure-password';
    final v3BackupFile = File(
      '${workDir.path}${Platform.pathSeparator}v3.t2backup',
    );
    await encryptBackupFile(
      input: v3Zip,
      output: v3BackupFile,
      password: password,
    );

    // 2. Restore this v3 backup into a new app directory running schema version 4
    final targetDocs = Directory(
      '${tempDir.path}${Platform.pathSeparator}target_migrate',
    );
    await targetDocs.create(recursive: true);
    final targetDbFile = File(
      '${targetDocs.path}${Platform.pathSeparator}t2_rental.sqlite',
    );
    var targetDb = createDb(targetDbFile);

    final restoreService = DriftBackupService(
      targetDb,
      documentsDirectory: targetDocs,
      temporaryDirectory: workDir,
      closeDatabase: () async => targetDb.close(),
      reopenDatabase: () async {
        targetDb = createDb(targetDbFile);
        return targetDb;
      },
    );

    await restoreService.restoreBackup(v3BackupFile, password);

    // Check that user_version was migrated to 4
    final result = await targetDb
        .customSelect('PRAGMA user_version;')
        .getSingle();
    final migratedVersion = result.data['user_version'] as int;
    expect(migratedVersion, equals(4));

    // Data should still exist
    final customers = await targetDb.select(targetDb.customers).get();
    expect(customers.length, equals(1));
    expect(customers.first.fullName, equals('Abebe Kebede'));
  });

  test('a newer-version backup is refused', () async {
    final db = createDb(dbFile);
    await seedTestData(db, docsDir);
    final service = DriftBackupService(
      db,
      documentsDirectory: docsDir,
      temporaryDirectory: workDir,
    );
    const password = 'test-secure-password';
    final backupFile = await service.createBackup(password);

    // Modify manifest to have formatVersion = 999
    final tamperDir = await workDir.createTemp('newer-');
    final zipFile = File(
      '${tamperDir.path}${Platform.pathSeparator}backup.zip',
    );
    await decryptBackupFile(
      input: backupFile,
      output: zipFile,
      password: password,
    );

    final extractedDir = Directory(
      '${tamperDir.path}${Platform.pathSeparator}extracted',
    );
    await extractedDir.create(recursive: true);
    final input = InputFileStream(zipFile.path);
    final archive = ZipDecoder().decodeStream(input);
    for (final entry in archive) {
      final f = File(
        '${extractedDir.path}${Platform.pathSeparator}${entry.name}',
      );
      if (entry.isFile) {
        await f.parent.create(recursive: true);
        final out = OutputFileStream(f.path);
        entry.writeContent(out);
        out.close();
      }
    }
    input.close();

    final manifestFile = File(
      '${extractedDir.path}${Platform.pathSeparator}manifest.json',
    );
    final manifestMap =
        jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    manifestMap['formatVersion'] = 999;
    await manifestFile.writeAsString(jsonEncode(manifestMap));

    final newerZip = File(
      '${tamperDir.path}${Platform.pathSeparator}newer.zip',
    );
    final encoder = ZipFileEncoder();
    encoder.create(newerZip.path);
    for (final entity in extractedDir.listSync(recursive: true)) {
      if (entity is File) {
        final relative = entity.path
            .substring(extractedDir.path.length + 1)
            .replaceAll(Platform.pathSeparator, '/');
        await encoder.addFile(entity, relative);
      }
    }
    encoder.close();

    final newerBackup = File(
      '${tamperDir.path}${Platform.pathSeparator}newer.t2backup',
    );
    await encryptBackupFile(
      input: newerZip,
      output: newerBackup,
      password: password,
    );

    expect(
      service.inspectBackup(newerBackup, password),
      throwsA(isA<UnsupportedBackupException>()),
    );
  });
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
