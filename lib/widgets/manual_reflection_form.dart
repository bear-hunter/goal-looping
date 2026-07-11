import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../models/reflection.dart';

/// Manual entry form for Kolb's reflection - Mobile-First Design
///
/// Architecture: 11 individual pages, one question each. Owns its own
/// [PageView]; the parent supplies the [PageController] and step callbacks.
/// Each page is a full-screen text input.
class ManualReflectionForm extends StatefulWidget {
  final String? targetFactorId;
  final String? previousExperimentId;
  final bool isFollowUp;
  final Reflection? initialReflection;
  final String initialExperimentText;
  final Function(Reflection) onSave;
  final PageController? pageController;
  final Function(int)? onPageChanged;
  final VoidCallback? onChanged;

  const ManualReflectionForm({
    super.key,
    this.targetFactorId,
    this.previousExperimentId,
    this.isFollowUp = false,
    this.initialReflection,
    this.initialExperimentText = '',
    required this.onSave,
    this.pageController,
    this.onPageChanged,
    this.onChanged,
  });

  /// Total number of pages in Manual Entry mode
  static const int totalPages = 11;

  /// Kolb phase label for a page index — pure, drives the step subtitle.
  static String getPhaseName(int index) {
    if (index <= 1) return 'Experience';
    if (index <= 7) return 'Reflection';
    if (index <= 9) return 'Abstraction';
    return 'Experiment';
  }

  @override
  State<ManualReflectionForm> createState() => ManualReflectionFormState();
}

class ManualReflectionFormState extends State<ManualReflectionForm> {
  // All text controllers
  final _experienceController = TextEditingController();
  final _marginalGainController = TextEditingController();
  final _eventSequenceController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _difficultiesController = TextEditingController();
  final _challengeResponseController = TextEditingController();
  final _triggersController = TextEditingController();
  final _whyBehaviorController = TextEditingController();
  final _abstractionController = TextEditingController();
  final _crossLifePatternsController = TextEditingController();
  final _experimentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final reflection = widget.initialReflection;
    if (reflection == null) return;

    _experienceController.text = reflection.experience;
    _marginalGainController.text = reflection.marginalGainDescription ?? '';
    _eventSequenceController.text = reflection.eventSequence ?? '';
    _feelingsController.text = reflection.feelings ?? '';
    _difficultiesController.text = reflection.difficulties ?? '';
    _challengeResponseController.text = reflection.challengeResponse ?? '';
    _triggersController.text = reflection.triggers ?? '';
    _whyBehaviorController.text = reflection.whyBehavior ?? '';
    _abstractionController.text = reflection.abstraction;
    _crossLifePatternsController.text = reflection.crossLifePatterns ?? '';
    _experimentsController.text = widget.initialExperimentText;
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _marginalGainController.dispose();
    _eventSequenceController.dispose();
    _feelingsController.dispose();
    _difficultiesController.dispose();
    _challengeResponseController.dispose();
    _triggersController.dispose();
    _whyBehaviorController.dispose();
    _abstractionController.dispose();
    _crossLifePatternsController.dispose();
    _experimentsController.dispose();
    super.dispose();
  }

  /// Builds page content for the given index (0-11).
  Widget _buildPage(int index, double keyboardHeight) {
    switch (index) {
      case 0:
        return _buildExperiencePage(keyboardHeight);
      case 1:
        return _buildMarginalGainPage(keyboardHeight);
      case 2:
        return _buildEventSequencePage(keyboardHeight);
      case 3:
        return _buildFeelingsPage(keyboardHeight);
      case 4:
        return _buildDifficultiesPage(keyboardHeight);
      case 5:
        return _buildChallengeResponsePage(keyboardHeight);
      case 6:
        return _buildTriggersPage(keyboardHeight);
      case 7:
        return _buildWhyBehaviorPage(keyboardHeight);
      case 8:
        return _buildAbstractionPage(keyboardHeight);
      case 9:
        return _buildCrossLifePage(keyboardHeight);
      case 10:
        return _buildExperimentsPage(keyboardHeight);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Save and return the reflection data
  void saveReflection() {
    final reflection = Reflection(
      id: '',
      experience: _experienceController.text,
      reflection:
          '''
Events: ${_eventSequenceController.text}
Feelings: ${_feelingsController.text}
Difficulties: ${_difficultiesController.text}
Response: ${_challengeResponseController.text}
Triggers: ${_triggersController.text}
Why: ${_whyBehaviorController.text}
'''
              .trim(),
      abstraction: _abstractionController.text,
      isFollowUp: widget.isFollowUp,
      previousExperimentId: widget.previousExperimentId,
      targetFactorId: widget.targetFactorId,
      linkedFactorIds: widget.targetFactorId != null
          ? [widget.targetFactorId!]
          : [],
      isManualEntry: true,
      marginalGainDescription: _marginalGainController.text,
      eventSequence: _eventSequenceController.text,
      feelings: _feelingsController.text,
      difficulties: _difficultiesController.text,
      challengeResponse: _challengeResponseController.text,
      triggers: _triggersController.text,
      whyBehavior: _whyBehaviorController.text,
      crossLifePatterns: _crossLifePatternsController.text,
      rawMarkdown: _experimentsController.text,
    );

    widget.onSave(reflection);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return PageView.builder(
      controller: widget.pageController,
      itemCount: ManualReflectionForm.totalPages,
      onPageChanged: widget.onPageChanged,
      itemBuilder: (context, index) => _buildPage(index, keyboardHeight),
    );
  }

  // ============================================
  // PAGE BUILDERS - One question per page
  // ============================================

  Widget _buildExperiencePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What experience do you want to reflect on?',
      subtitle: 'Describe the specific experience or event',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _experienceController,
        hint:
            'Describe your experience...\n\nBe specific about what happened, when, and where.',
      ),
    );
  }

  Widget _buildMarginalGainPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What would a marginal gain look like?',
      subtitle: 'What small improvement could you achieve?',
      helperText:
          'Remember that marginal gains look different at different levels of the conscious competence model.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _marginalGainController,
        hint:
            'e.g., Reducing decision fatigue by preparing the night before\n\nThink about small, achievable improvements.',
      ),
    );
  }

  Widget _buildEventSequencePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Sequence of events',
      subtitle:
          'List and describe the sequence of events in chronological order',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _eventSequenceController,
        hint:
            'What happened first, then next...\n\n1. First I...\n2. Then...\n3. After that...',
      ),
    );
  }

  Widget _buildFeelingsPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'How did you feel?',
      subtitle: 'How did you feel about the experience?',
      helperText:
          'Be specific and detailed about how you felt and when. Heightened emotions often indicate key parts of the process.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _feelingsController,
        hint:
            'Frustrated, anxious, calm, motivated...\n\nDescribe when you felt each emotion.',
      ),
    );
  }

  Widget _buildDifficultiesPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Difficulties and successes',
      subtitle: 'Which aspects felt especially difficult? Which went well?',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _difficultiesController,
        hint:
            'Difficult: ...\n\nWent well: ...\n\nBarriers, obstacles, or challenges faced.',
      ),
    );
  }

  Widget _buildChallengeResponsePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Response to challenges',
      subtitle: 'How did you respond to challenges and difficulties?',
      helperText:
          'This could include mental or physical activities you used to overcome the issue. Skip if no difficulties.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _challengeResponseController,
        hint:
            'Your actions, reactions, coping strategies...\n\nHow did you try to overcome obstacles?',
      ),
    );
  }

  Widget _buildTriggersPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What were the triggers?',
      subtitle: 'What triggered you to feel or act the way you did?',
      helperText:
          'Triggers are cues, signs, events, actions, or exposures that made you feel or act a certain way.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _triggersController,
        hint:
            'Time of day, emotion, environment, person...\n\nWhat specifically triggered your reactions?',
      ),
    );
  }

  Widget _buildWhyBehaviorPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Why did you act this way?',
      subtitle: 'Root cause analysis of your behavior',
      helperText:
          'This question challenges your metacognition (thinking about thinking). Reflect on "why", not just "what".',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _whyBehaviorController,
        hint:
            'I think I acted this way because...\n\nDig deep into the root causes.',
      ),
    );
  }

  Widget _buildAbstractionPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Habits, beliefs, and tendencies',
      subtitle: 'What patterns can you identify from your reflection?',
      helperText:
          'For example: whenever you feel overwhelmed, you tend to avoid challenges and revert to something easier.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _abstractionController,
        hint:
            'I notice that I tend to...\n\nIdentify patterns and tendencies in your behavior.',
      ),
      showGuidelines: true,
      guidelines: [
        'Your abstraction should be an analysis and evaluation of your reflection',
        'Examine your reflection for clues about root causes',
        'If you struggle to find patterns, your reflection may be too brief',
      ],
    );
  }

  Widget _buildCrossLifePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Cross-life patterns',
      subtitle: 'Do you act similarly in other parts of your life?',
      helperText:
          'This helps identify the holistic impact of your habits and tendencies.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _crossLifePatternsController,
        hint: 'Work: ...\nRelationships: ...\nHealth: ...\nHobbies: ...',
      ),
    );
  }

  Widget _buildExperimentsPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Experiments to try',
      subtitle: 'List potential solutions and actions to experiment on',
      helperText:
          'Enter one experiment per line (max 3). Keep them concise, specific, and actionable.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _experimentsController,
        hint: '- Experiment 1: ...\n- Experiment 2: ...\n- Experiment 3: ...',
      ),
      showGuidelines: true,
      guidelines: [
        'Keep experiments concise, specific, and actionable',
        'Avoid vague statements of intention',
        'Imagine waking up tomorrow and seeing this list',
        'Less than 3 experiments is ideal',
      ],
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================

  Widget _buildPageLayout({
    required String title,
    required String subtitle,
    required Widget child,
    required double keyboardHeight,
    String? helperText,
    bool showGuidelines = false,
    List<String>? guidelines,
  }) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: keyboardHeight + 120,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: colors.textMuted),
          ),

          // Helper text
          if (helperText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.info.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.info.withAlpha(50)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: colors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      helperText,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Guidelines
          if (showGuidelines && guidelines != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guidelines',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...guidelines.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: colors.textMuted)),
                          Expanded(
                            child: Text(
                              g,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Main input
          child,
        ],
      ),
    );
  }

  Widget _buildExpandedTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      maxLines: 10,
      onChanged: (_) => widget.onChanged?.call(),
      style: TextStyle(color: colors.textPrimary, fontSize: 16, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.textMuted.withAlpha(150),
          fontSize: 15,
        ),
        filled: true,
        fillColor: colors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}
