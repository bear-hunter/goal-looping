import 'package:centile/models/backup_models.dart';
import 'package:centile/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupService import validation', () {
    test('invalid replace import fails before storage mutation', () async {
      final result = await BackupService.importData(
        '{"metadata":{},"data":{"tasks":"not-a-list"}}',
        ImportMode.replace,
      );

      expect(result.success, isFalse);
      expect(result.errors.single, contains('Import failed'));
    });

    test('preview reports invalid backup structure', () async {
      final preview = await BackupService.previewBackup('[]');

      expect(preview.isValid, isFalse);
      expect(preview.validationErrors, isNotEmpty);
    });
  });
}
