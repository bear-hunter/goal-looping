import 'package:centile/models/growth_area.dart';
import 'package:centile/models/reflection.dart';
import 'package:centile/models/reflection_group.dart';
import 'package:centile/providers/app_state.dart';
import 'package:centile/services/pdf_export_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const printingChannel = MethodChannel('net.nfet.printing');
  MethodCall? shareCall;

  setUp(() {
    shareCall = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, (call) async {
          if (call.method == 'sharePdf') {
            shareCall = call;
            return 1;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, null);
  });

  test('exports linked factor names directly from PDF bytes', () async {
    final state = AppState();
    state.factors.add(
      GrowthArea(
        id: 'factor-1',
        name: 'Time Management',
        type: GrowthAreaType.skill,
        goalId: 'goal-1',
      ),
    );
    final reflection = Reflection(
      id: 'reflection-1',
      experience: 'A focused work session.',
      reflection: 'The plan worked well.',
      abstraction: 'Timeboxing reduces distractions.',
      linkedFactorIds: ['factor-1'],
    );

    await PdfExportService.exportGroup(
      ReflectionGroup(id: 'group-1', title: 'Weekly Review'),
      [reflection],
      state,
    );

    expect(shareCall?.method, 'sharePdf');
    final arguments = Map<String, dynamic>.from(shareCall!.arguments as Map);
    final bytes = arguments['doc'] as Uint8List;
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(arguments['name'], startsWith('reflection_Weekly_Review_'));
  });
}
