import 'package:centile/core/theme/theme.dart';
import 'package:centile/models/category_model.dart';
import 'package:centile/models/recurring_task.dart';
import 'package:centile/models/task.dart';
import 'package:centile/providers/app_state.dart';
import 'package:centile/screens/today/add_task_sheet.dart';
import 'package:centile/screens/today/recurring_task_wizard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('quick task creation commits a visible checklist draft', (
    tester,
  ) async {
    final state = _RecordingAppState();
    await _openAddTaskSheet(tester, state);

    await tester.enterText(find.widgetWithText(TextField, 'Task name'), 'Pack');
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump();

    final checklistField = find.widgetWithText(TextField, 'Add item...');
    await tester.enterText(checklistField, 'Passport');
    await tester.ensureVisible(find.text('Create Task'));
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    expect(state.addedTask?.checklistItems, ['Passport']);
  });

  testWidgets('blocked High priority creation shows validation', (
    tester,
  ) async {
    final state = _RecordingAppState(canAddHighPriority: false);
    await _openAddTaskSheet(tester, state);

    await tester.enterText(
      find.widgetWithText(TextField, 'Task name'),
      'Third',
    );
    await tester.ensureVisible(find.text('Default'));
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create Task'));
    await tester.tap(find.text('Create Task'));
    await tester.pump();

    expect(state.addedTask, isNull);
    expect(
      find.text(
        'You already have two active High-priority tasks. Complete or lower one first.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('recurring edit can open a past start date', (tester) async {
    final state = _RecordingAppState();
    final category = CategoryModel.create(
      id: 'general',
      name: 'General',
      icon: Icons.category,
      color: Colors.green,
    );
    state.categories.add(category);
    final task = RecurringTask(
      id: 'weekly-review',
      name: 'Weekly review',
      categoryId: category.id,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: RecurringTaskWizard(existingTask: task),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var page = 0; page < 3; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Start date'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recurring creation rejects an empty weekday schedule', (
    tester,
  ) async {
    final state = _RecordingAppState();
    state.categories.add(
      CategoryModel.create(
        id: 'general',
        name: 'General',
        icon: Icons.category,
        color: Colors.green,
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RecurringTaskWizard(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g., Weekly review, Water plants'),
      'Weekly review',
    );
    await tester.tap(find.text('General'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Specific days'));
    await tester.pump();
    final dayLabels = [
      find.text('M'),
      find.text('T').at(0),
      find.text('W'),
      find.text('T').at(1),
      find.text('F'),
      find.text('S').at(0),
      find.text('S').at(1),
    ];
    await tester.ensureVisible(dayLabels.first);
    await tester.pump();
    for (final label in dayLabels) {
      await tester.tap(label);
      await tester.pump();
    }

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Task'));
    await tester.pump();

    expect(state.addedRecurringTask, isNull);
    expect(find.text('Select at least one scheduled day.'), findsOneWidget);
  });
}

Future<void> _openAddTaskSheet(WidgetTester tester, AppState state) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AddTaskSheet.show(
                  context,
                  initialDate: DateTime(2026, 7, 11),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

class _RecordingAppState extends AppState {
  _RecordingAppState({this.canAddHighPriority = true});

  final bool canAddHighPriority;
  Task? addedTask;
  RecurringTask? addedRecurringTask;

  @override
  bool get canAddPriorityTask => canAddHighPriority;

  @override
  Future<void> addTask(Task task) async {
    addedTask = task;
  }

  @override
  Future<void> addRecurringTask(RecurringTask task) async {
    addedRecurringTask = task;
  }
}
