import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/database_provider.dart';
import 'backup_service.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final database = ref.watch(databaseProvider);
  return DriftBackupService(
    database,
    closeDatabase: database.close,
    reopenDatabase: () async {
      ref.invalidate(databaseProvider);
      return ref.read(databaseProvider);
    },
  );
});

final backupMetadataStoreProvider = Provider<BackupMetadataStore>((ref) {
  return BackupMetadataStore();
});

typedef BackupShareFn = Future<void> Function(List<String> paths);

final backupShareProvider = Provider<BackupShareFn>((ref) {
  return (paths) async {
    await SharePlus.instance.share(
      ShareParams(files: paths.map((p) => XFile(p)).toList()),
    );
  };
});

final lastBackupAtProvider = FutureProvider.autoDispose<DateTime?>(
  (ref) => ref.watch(backupMetadataStoreProvider).readLastBackupAt(),
);
