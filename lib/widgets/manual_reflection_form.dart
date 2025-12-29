import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../models/reflection.dart';
import 'glass_card.dart';

/// Manual entry form for Kolb's reflection - Mobile-First Design
/// 
/// Architecture: 12 individual pages, one question each
/// - Page controller managed by parent (NewReflectionSheet)
/// - Each page has full-screen text input
/// - Returns current page widget via getPage(index)
class ManualReflectionForm extends StatefulWidget {
  final String? targetFactorId;
  final String? previousExperimentId;
  final Function(Reflection) onSave;
  final PageController? pageController;
  final Function(int)? onPageChanged;
  final VoidCallback? onChanged;

  const ManualReflectionForm({
    super.key,
    this.targetFactorId,
    this.previousExperimentId,
    required this.onSave,
    this.pageController,
    this.onPageChanged,
    this.onChanged,
  });

  /// Total number of pages in Manual Entry mode
  static const int totalPages = 12;

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
  
  bool _isFollowUp = false;

  @override
  void initState() {
    super.initState();
    _isFollowUp = widget.previousExperimentId != null;
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

  /// Get page content for given index (0-11)
  Widget getPage(int index, double keyboardHeight) {
    switch (index) {
      case 0:
        return _buildFollowUpPage(keyboardHeight);
      case 1:
        return _buildExperiencePage(keyboardHeight);
      case 2:
        return _buildMarginalGainPage(keyboardHeight);
      case 3:
        return _buildEventSequencePage(keyboardHeight);
      case 4:
        return _buildFeelingsPage(keyboardHeight);
      case 5:
        return _buildDifficultiesPage(keyboardHeight);
      case 6:
        return _buildChallengeResponsePage(keyboardHeight);
      case 7:
        return _buildTriggersPage(keyboardHeight);
      case 8:
        return _buildWhyBehaviorPage(keyboardHeight);
      case 9:
        return _buildAbstractionPage(keyboardHeight);
      case 10:
        return _buildCrossLifePage(keyboardHeight);
      case 11:
        return _buildExperimentsPage(keyboardHeight);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Get phase name for page index
  String getPhaseName(int index) {
    if (index <= 2) return 'Experience';
    if (index <= 8) return 'Reflection';
    if (index <= 10) return 'Abstraction';
    return 'Experiment';
  }

  /// Get phase emoji for page index
  String getPhaseEmoji(int index) {
    if (index <= 2) return '📝';
    if (index <= 8) return '🔍';
    if (index <= 10) return '💡';
    return '🧪';
  }

  /// Save and return the reflection data
  void saveReflection() {
    final reflection = Reflection(
      id: '',
      experience: _experienceController.text,
      reflection: '''
Events: ${_eventSequenceController.text}
Feelings: ${_feelingsController.text}
Difficulties: ${_difficultiesController.text}
Response: ${_challengeResponseController.text}
Triggers: ${_triggersController.text}
Why: ${_whyBehaviorController.text}
'''.trim(),
      abstraction: _abstractionController.text,
      isFollowUp: _isFollowUp,
      previousExperimentId: widget.previousExperimentId,
      targetFactorId: widget.targetFactorId,
      linkedFactorIds: widget.targetFactorId != null ? [widget.targetFactorId!] : [],
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
    // This widget is now just a state holder
    // Pages are rendered by parent via getPage()
    return const SizedBox.shrink();
  }

  // ============================================
  // PAGE BUILDERS - One question per page
  // ============================================

  Widget _buildFollowUpPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Is this a follow-up?',
      subtitle: 'Are you reflecting on an experiment from a previous Kolb\'s cycle?',
      helperText: 'Always cycle experiments from the previous Kolb\'s into your next one to ensure your marginal gains are compounding.',
      keyboardHeight: keyboardHeight,
      child: GlassCard(
        onTap: () {
          setState(() => _isFollowUp = !_isFollowUp);
          if (widget.onChanged != null) widget.onChanged!();
        },
        child: Row(
          children: [
            Icon(Icons.replay_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow-up from previous cycle',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isFollowUp ? 'Yes, this is a follow-up' : 'No, this is a new reflection',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isFollowUp,
              onChanged: (v) {
                setState(() => _isFollowUp = v);
                if (widget.onChanged != null) widget.onChanged!();
              },
              activeTrackColor: AppColors.primary.withAlpha(128),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
      showGuidelines: true,
      guidelines: [
        'Process-focused - avoid reflecting on outcomes (e.g. test results)',
        'Specific - avoid reflecting on many events at once',
        'Recent - don\'t reflect on experiences too long ago',
        'Concise - experience is usually one sentence',
      ],
    );
  }

  Widget _buildExperiencePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What experience do you want to reflect on?',
      subtitle: 'Describe the specific experience or event',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _experienceController,
        hint: 'Describe your experience...\n\nBe specific about what happened, when, and where.',
      ),
    );
  }

  Widget _buildMarginalGainPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What would a marginal gain look like?',
      subtitle: 'What small improvement could you achieve?',
      helperText: 'Remember that marginal gains look different at different levels of the conscious competence model.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _marginalGainController,
        hint: 'e.g., Reducing decision fatigue by preparing the night before\n\nThink about small, achievable improvements.',
      ),
    );
  }

  Widget _buildEventSequencePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Sequence of events',
      subtitle: 'List and describe the sequence of events in chronological order',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _eventSequenceController,
        hint: 'What happened first, then next...\n\n1. First I...\n2. Then...\n3. After that...',
      ),
    );
  }

  Widget _buildFeelingsPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'How did you feel?',
      subtitle: 'How did you feel about the experience?',
      helperText: 'Be specific and detailed about how you felt and when. Heightened emotions often indicate key parts of the process.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _feelingsController,
        hint: 'Frustrated, anxious, calm, motivated...\n\nDescribe when you felt each emotion.',
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
        hint: 'Difficult: ...\n\nWent well: ...\n\nBarriers, obstacles, or challenges faced.',
      ),
    );
  }

  Widget _buildChallengeResponsePage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Response to challenges',
      subtitle: 'How did you respond to challenges and difficulties?',
      helperText: 'This could include mental or physical activities you used to overcome the issue. Skip if no difficulties.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _challengeResponseController,
        hint: 'Your actions, reactions, coping strategies...\n\nHow did you try to overcome obstacles?',
      ),
    );
  }

  Widget _buildTriggersPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'What were the triggers?',
      subtitle: 'What triggered you to feel or act the way you did?',
      helperText: 'Triggers are cues, signs, events, actions, or exposures that made you feel or act a certain way.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _triggersController,
        hint: 'Time of day, emotion, environment, person...\n\nWhat specifically triggered your reactions?',
      ),
    );
  }

  Widget _buildWhyBehaviorPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Why did you act this way?',
      subtitle: 'Root cause analysis of your behavior',
      helperText: 'This question challenges your metacognition (thinking about thinking). Reflect on "why", not just "what".',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _whyBehaviorController,
        hint: 'I think I acted this way because...\n\nDig deep into the root causes.',
      ),
    );
  }

  Widget _buildAbstractionPage(double keyboardHeight) {
    return _buildPageLayout(
      title: 'Habits, beliefs, and tendencies',
      subtitle: 'What patterns can you identify from your reflection?',
      helperText: 'For example: whenever you feel overwhelmed, you tend to avoid challenges and revert to something easier.',
      keyboardHeight: keyboardHeight,
      child: _buildExpandedTextField(
        controller: _abstractionController,
        hint: 'I notice that I tend to...\n\nIdentify patterns and tendencies in your behavior.',
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
      helperText: 'This helps identify the holistic impact of your habits and tendencies.',
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
      helperText: 'Enter one experiment per line (max 3). Keep them concise, specific, and actionable.',
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          
          // Helper text
          if (helperText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.info.withAlpha(50)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      helperText,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guidelines',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...guidelines.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: AppColors.textMuted)),
                        Expanded(
                          child: Text(
                            g,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  )),
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
    return TextField(
      controller: controller,
      maxLines: 10,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textMuted.withAlpha(150),
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),
    );
  }
}
