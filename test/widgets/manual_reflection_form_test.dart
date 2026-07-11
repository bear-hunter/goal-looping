import 'package:centile/models/growth_area.dart';
import 'package:centile/models/reflection.dart';
import 'package:centile/providers/app_state.dart';
import 'package:centile/screens/reflection/new_reflection_sheet.dart';
import 'package:centile/widgets/manual_reflection_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('manual reflection edit preserves all saved fields', (
    tester,
  ) async {
    final formKey = GlobalKey<ManualReflectionFormState>();
    Reflection? saved;
    final existing = Reflection(
      id: 'reflection-1',
      experience: 'Existing experience',
      abstraction: 'Existing abstraction',
      targetFactorId: 'factor-1',
      previousExperimentId: 'experiment-0',
      isFollowUp: true,
      isManualEntry: true,
      marginalGainDescription: 'Small improvement',
      eventSequence: 'First this happened',
      feelings: 'Calm',
      difficulties: 'A hard part',
      challengeResponse: 'Tried a smaller step',
      triggers: 'A deadline',
      whyBehavior: 'Old habit',
      crossLifePatterns: 'The same pattern at work',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ManualReflectionForm(
            key: formKey,
            initialReflection: existing,
            initialExperimentText: '- Try one\n- Try two',
            targetFactorId: existing.targetFactorId,
            previousExperimentId: existing.previousExperimentId,
            isFollowUp: existing.isFollowUp,
            onSave: (reflection) => saved = reflection,
          ),
        ),
      ),
    );

    formKey.currentState!.saveReflection();

    expect(saved, isNotNull);
    expect(saved!.experience, 'Existing experience');
    expect(saved!.abstraction, 'Existing abstraction');
    expect(saved!.marginalGainDescription, 'Small improvement');
    expect(saved!.eventSequence, 'First this happened');
    expect(saved!.feelings, 'Calm');
    expect(saved!.difficulties, 'A hard part');
    expect(saved!.challengeResponse, 'Tried a smaller step');
    expect(saved!.triggers, 'A deadline');
    expect(saved!.whyBehavior, 'Old habit');
    expect(saved!.crossLifePatterns, 'The same pattern at work');
    expect(saved!.rawMarkdown, '- Try one\n- Try two');
    expect(saved!.targetFactorId, 'factor-1');
    expect(saved!.previousExperimentId, 'experiment-0');
    expect(saved!.isFollowUp, isTrue);
  });

  testWidgets('manual input requests confirmation before closing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: AppState(),
        child: const MaterialApp(home: NewReflectionSheet()),
      ),
    );

    await tester.tap(find.text('Manual entry'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Do not lose this');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(
      find.text('You have unsaved changes. Discard them?'),
      findsOneWidget,
    );
  });

  for (final isManual in [false, true]) {
    testWidgets(
      '${isManual ? 'manual' : 'guided'} edit keeps target and linked factors in sync',
      (tester) async {
        final state = _RecordingAppState();
        state.factors.addAll([
          GrowthArea(
            id: 'factor-a',
            name: 'Factor A',
            type: GrowthAreaType.skill,
            goalId: 'goal-1',
          ),
          GrowthArea(
            id: 'factor-b',
            name: 'Factor B',
            type: GrowthAreaType.skill,
            goalId: 'goal-1',
          ),
        ]);
        final existing = Reflection(
          id: 'reflection-1',
          experience: 'Experience',
          reflection: 'Reflection',
          abstraction: 'Abstraction',
          targetFactorId: 'factor-a',
          linkedFactorIds: ['factor-a'],
          isManualEntry: isManual,
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
              home: NewReflectionSheet(reflectionToEdit: existing),
            ),
          ),
        );

        await tester.tap(find.text('Factor B'));
        await tester.pump();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        final nextPageCount = isManual ? 10 : 2;
        for (var page = 0; page < nextPageCount; page++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(state.updatedReflection?.targetFactorId, 'factor-b');
        expect(state.updatedReflection?.linkedFactorIds, ['factor-b']);
      },
    );
  }
}

class _RecordingAppState extends AppState {
  Reflection? updatedReflection;

  @override
  Future<void> updateReflection(Reflection reflection) async {
    updatedReflection = reflection;
  }
}
