import 'package:centile/models/focus_log.dart';
import 'package:centile/models/subtask.dart';
import 'package:centile/models/task.dart';
import 'package:centile/providers/app_state.dart';
import 'package:centile/screens/home/focus_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('finishing a break does not save another focus session', (
    tester,
  ) async {
    final state = _RecordingAppState();
    final task = Task(id: 'task-1', title: 'Write report');

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(home: FocusModeScreen(task: task)),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(minutes: 25));

    expect(state.savedLogs, hasLength(1));
    expect(find.text('Focus Session Complete!'), findsOneWidget);

    await tester.tap(find.text('Start Break'));
    await tester.pump();
    expect(find.text('05:00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(minutes: 5));

    expect(state.savedLogs, hasLength(1));
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Focus Mode'), findsOneWidget);
    expect(find.text('Break complete — ready to focus again.'), findsOneWidget);
  });
}

class _RecordingAppState extends AppState {
  final List<FocusLog> savedLogs = [];

  @override
  List<Subtask> getSubtasksForTask(String taskId) => const [];

  @override
  Future<void> saveFocusSession(FocusLog log) async {
    savedLogs.add(log);
  }
}
