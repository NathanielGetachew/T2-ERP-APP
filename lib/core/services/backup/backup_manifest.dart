import 'dart:convert';

class BackupFileEntry {
  const BackupFileEntry({
    required this.relativePath,
    required this.size,
    required this.sha256,
  });

  final String relativePath;
  final int size;
  final String sha256;

  Map<String, Object> toJson() => {
    'relativePath': relativePath,
    'size': size,
    'sha256': sha256,
  };

  factory BackupFileEntry.fromJson(Map<String, dynamic> json) =>
      BackupFileEntry(
        relativePath: json['relativePath'] as String,
        size: json['size'] as int,
        sha256: json['sha256'] as String,
      );
}

class BackupCounts {
  const BackupCounts({
    required this.customers,
    required this.materials,
    required this.rentals,
    required this.returnEvents,
    required this.photos,
  });

  final int customers;
  final int materials;
  final int rentals;
  final int returnEvents;
  final int photos;

  Map<String, int> toJson() => {
    'customers': customers,
    'materials': materials,
    'rentals': rentals,
    'returnEvents': returnEvents,
    'photos': photos,
  };

  factory BackupCounts.fromJson(Map<String, dynamic> json) => BackupCounts(
    customers: json['customers'] as int,
    materials: json['materials'] as int,
    rentals: json['rentals'] as int,
    returnEvents: json['returnEvents'] as int,
    photos: json['photos'] as int,
  );
}

class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.dbSchemaVersion,
    required this.createdAtUtc,
    required this.counts,
    required this.files,
  });

  final int formatVersion;
  final String appVersion;
  final int dbSchemaVersion;
  final DateTime createdAtUtc;
  final BackupCounts counts;
  final List<BackupFileEntry> files;

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'appVersion': appVersion,
    'dbSchemaVersion': dbSchemaVersion,
    'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
    'counts': counts.toJson(),
    'files': files.map((file) => file.toJson()).toList(),
  };

  String encode() => jsonEncode(toJson());

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
    formatVersion: json['formatVersion'] as int,
    appVersion: json['appVersion'] as String,
    dbSchemaVersion: json['dbSchemaVersion'] as int,
    createdAtUtc: DateTime.parse(json['createdAtUtc'] as String).toUtc(),
    counts: BackupCounts.fromJson(json['counts'] as Map<String, dynamic>),
    files: (json['files'] as List<dynamic>)
        .map((item) => BackupFileEntry.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
