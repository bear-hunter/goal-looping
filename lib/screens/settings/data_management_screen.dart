import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import '../../services/backup_service.dart';
import '../../models/backup_models.dart';
import '../../widgets/glass_card.dart';

/// Screen for managing data backup, export, and import
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  DateTime? _lastExportTime;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Data Management',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner
            GlassCard(
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Backup all your app data to keep it safe or transfer to another device.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Export section
            _buildSection(
                  context,
                  title: 'Export Data',
                  icon: Icons.upload_file_rounded,
                  iconColor: colors.success,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create a backup file of all your data.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      if (_lastExportTime != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: colors.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Last export: ${DateFormat('MMM d, y HH:mm').format(_lastExportTime!)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: _isExporting ? null : _handleExport,
                        icon: _isExporting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.textPrimary,
                                ),
                              )
                            : const Icon(Icons.upload_file_rounded),
                        label: Text(
                          _isExporting ? 'Exporting...' : 'Export All Data',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0),

            const SizedBox(height: 16),

            // Import section
            _buildSection(
                  context,
                  title: 'Import Data',
                  icon: Icons.download_rounded,
                  iconColor: colors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Restore data from a backup file.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isImporting ? null : _handleImport,
                        icon: _isImporting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.textPrimary,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(
                          _isImporting ? 'Loading...' : 'Import from File',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0),

            const SizedBox(height: 24),

            // Warning section
            GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: colors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Important',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colors.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Backup files are prepared locally before sharing\n'
                        '• Use the share sheet to save backups to cloud storage\n'
                        '• Keep backups in a safe location\n'
                        '• Import will ask whether to merge or replace data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      late final String fileName;
      late final int sizeInBytes;
      late final Future<void> Function() shareBackup;

      if (kIsWeb) {
        final jsonString = await BackupService.generateBackupJson();
        final bytes = Uint8List.fromList(utf8.encode(jsonString));
        final backupFileName = BackupService.generateBackupFilename();
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'application/json',
          name: backupFileName,
        );

        fileName = backupFileName;
        sizeInBytes = bytes.length;
        shareBackup = () async {
          await Share.shareXFiles([xFile], fileNameOverrides: [backupFileName]);
        };
      } else {
        final file = await BackupService.exportAllData();

        fileName = file.uri.pathSegments.last;
        sizeInBytes = await file.length();
        shareBackup = () async {
          await Share.shareXFiles([XFile(file.path)]);
        };
      }

      setState(() {
        _lastExportTime = DateTime.now();
        _isExporting = false;
      });

      // Show success dialog with options
      if (mounted) {
        _showExportSuccessDialog(
          fileName: fileName,
          sizeInBytes: sizeInBytes,
          shareBackup: shareBackup,
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        _showErrorDialog('Export Failed', e.toString());
      }
    }
  }

  void _showExportSuccessDialog({
    required String fileName,
    required int sizeInBytes,
    required Future<void> Function() shareBackup,
  }) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.success),
            const SizedBox(width: 12),
            Text(
              'Export Successful',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your backup is ready to share or save:',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Size: ${(sizeInBytes / 1024).toStringAsFixed(1)} KB',
              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: colors.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await shareBackup();
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);

    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );

      if (result == null) {
        setState(() => _isImporting = false);
        return;
      }

      final pickedFile = result.files.single;
      late final String jsonString;
      if (kIsWeb) {
        final bytes = pickedFile.bytes;
        if (bytes == null) {
          throw const FormatException('The selected file could not be read.');
        }
        jsonString = utf8.decode(bytes);
      } else if (pickedFile.path != null) {
        jsonString = await File(pickedFile.path!).readAsString();
      } else if (pickedFile.bytes != null) {
        jsonString = utf8.decode(pickedFile.bytes!);
      } else {
        throw const FormatException('The selected file could not be read.');
      }

      // Preview backup
      final preview = await BackupService.previewBackup(jsonString);

      setState(() => _isImporting = false);

      if (!preview.isValid) {
        if (mounted) {
          _showErrorDialog(
            'Invalid Backup File',
            preview.validationErrors.join('\n'),
          );
        }
        return;
      }

      // Show preview dialog
      if (mounted) {
        _showImportPreviewDialog(jsonString, preview);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        _showErrorDialog('Import Failed', e.toString());
      }
    }
  }

  void _showImportPreviewDialog(String jsonString, BackupPreview preview) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Import Preview',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metadata
              _buildInfoRow(
                'Exported',
                DateFormat(
                  'MMM d, y HH:mm',
                ).format(preview.metadata.exportedAt),
              ),
              _buildInfoRow('App Version', preview.metadata.appVersion),
              const SizedBox(height: 16),

              // Data counts
              Text(
                'Data Summary:',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...preview.dataCounts.entries.map((entry) {
                if (entry.value == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDataTypeName(entry.key),
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (preview.hasConflicts) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Note:',
                            style: TextStyle(
                              color: colors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...preview.conflicts.map(
                        (conflict) => Text(
                          '• $conflict',
                          style: TextStyle(color: colors.warning, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showImportModeDialog(jsonString, ImportMode.merge);
            },
            child: Text('Merge', style: TextStyle(color: colors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showReplaceWarningDialog(jsonString);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colors.danger),
            child: const Text('Replace All'),
          ),
        ],
      ),
    );
  }

  void _showReplaceWarningDialog(String jsonString) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.danger),
            const SizedBox(width: 12),
            Text('Replace All Data?', style: TextStyle(color: colors.danger)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will DELETE all your current data and replace it with the backup.',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone unless you have another backup.',
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performImport(jsonString, ImportMode.replace);
            },
            child: Text(
              'Yes, Replace All',
              style: TextStyle(color: colors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportModeDialog(String jsonString, ImportMode mode) {
    _performImport(jsonString, mode);
  }

  Future<void> _performImport(String jsonString, ImportMode mode) async {
    final colors = context.colors;
    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: colors.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Importing data...',
                style: TextStyle(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await BackupService.importData(jsonString, mode);

      if (mounted) {
        if (result.success) {
          try {
            await appState.loadData();
          } catch (e) {
            if (mounted) {
              navigator.pop(); // Close loading dialog
              _showErrorDialog(
                'Import Completed',
                'Your data was imported, but the app could not refresh automatically. Restart the app if the latest data is not visible.\n\n$e',
              );
            }
            return;
          }
        }

        navigator.pop(); // Close loading dialog

        if (result.success) {
          _showImportSuccessDialog(result);
        } else {
          _showErrorDialog('Import Failed', result.errors.join('\n'));
        }
      }
    } catch (e) {
      if (mounted) {
        navigator.pop(); // Close loading dialog
        _showErrorDialog('Import Failed', e.toString());
      }
    }
  }

  void _showImportSuccessDialog(ImportResult result) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colors.success),
            const SizedBox(width: 12),
            Text(
              'Import Successful',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully imported ${result.totalImported} items.',
              style: TextStyle(color: colors.textSecondary),
            ),
            if (result.totalSkipped > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Skipped: ${result.totalSkipped} items',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
            if (result.totalFailed > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Failed: ${result.totalFailed} items',
                style: TextStyle(color: colors.warning, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate back to home or refresh
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textMuted)),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDataTypeName(String key) {
    final Map<String, String> names = {
      'goals': 'Goals',
      'growthAreas': 'Growth Areas',
      'sprintTargets': 'Sprint Targets',
      'tasks': 'Tasks',
      'subtasks': 'Subtasks',
      'habits': 'Habits',
      'reflections': 'Reflections',
      'reflectionGroups': 'Reflection Groups',
      'experiments': 'Experiments',
      'barriers': 'Barriers',
      'categories': 'Categories',
      'recurringTasks': 'Recurring Tasks',
      'spacedRepetitionSubjects': 'Review Subjects',
      'spacedRepetitionTopics': 'Review Topics',
      'achievements': 'Achievements',
      'focusLogs': 'Focus Logs',
      'userStats': 'User Stats',
      'settings': 'Settings',
    };
    return names[key] ?? key;
  }

  void _showErrorDialog(String title, String message) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.danger),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: colors.danger)),
          ],
        ),
        content: Text(message, style: TextStyle(color: colors.textSecondary)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
