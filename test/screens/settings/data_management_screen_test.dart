import 'dart:convert';

import 'package:centile/screens/settings/data_management_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('imports picker bytes when a Web file has no path', (
    tester,
  ) async {
    final bytes = Uint8List.fromList(utf8.encode('[]'));
    final picker = _FakeFilePicker(
      FilePickerResult([
        PlatformFile(name: 'backup.json', size: bytes.length, bytes: bytes),
      ]),
    );
    FilePicker.platform = picker;

    await tester.pumpWidget(
      MaterialApp(theme: ThemeData.dark(), home: const DataManagementScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import from File'));
    await tester.pumpAndSettle();

    expect(picker.requestedWithData, kIsWeb);
    expect(find.text('Invalid Backup File'), findsOneWidget);
  });
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.result);

  final FilePickerResult result;
  bool? requestedWithData;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    requestedWithData = withData;
    return result;
  }
}
