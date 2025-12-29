/// Mode for importing data
enum ImportMode {
  merge,  // Keep existing data, add new items or update matching IDs
  replace // Clear all data and import fresh
}

/// Metadata for backup files
class BackupMetadata {
  final String version;
  final DateTime exportedAt;
  final String appVersion;
  final Map<String, int> dataCounts;

  BackupMetadata({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.dataCounts,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'appVersion': appVersion,
    'dataCounts': dataCounts,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      version: json['version'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String,
      dataCounts: Map<String, int>.from(json['dataCounts'] as Map),
    );
  }
}

/// Preview of data to be imported
class BackupPreview {
  final BackupMetadata metadata;
  final Map<String, int> dataCounts;
  final List<String> conflicts;
  final List<String> validationErrors;

  BackupPreview({
    required this.metadata,
    required this.dataCounts,
    required this.conflicts,
    required this.validationErrors,
  });

  bool get isValid => validationErrors.isEmpty;

  bool get hasConflicts => conflicts.isNotEmpty;
}

/// Result of import operation
class ImportResult {
  final bool success;
  final Map<String, int> imported;
  final Map<String, int> skipped;
  final Map<String, int> failed;
  final List<String> errors;

  ImportResult({
    required this.success,
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });

  int get totalImported => imported.values.fold(0, (sum, count) => sum + count);
  int get totalSkipped => skipped.values.fold(0, (sum, count) => sum + count);
  int get totalFailed => failed.values.fold(0, (sum, count) => sum + count);
}

/// Exception thrown during backup/import operations
class BackupException implements Exception {
  final String message;
  final dynamic originalError;

  BackupException(this.message, [this.originalError]);

  @override
  String toString() => 'BackupException: $message${originalError != null ? '\nCaused by: $originalError' : ''}';
}
