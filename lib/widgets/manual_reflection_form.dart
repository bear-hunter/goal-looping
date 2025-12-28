import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/theme.dart';
import '../models/reflection.dart';
import 'glass_card.dart';

/// Manual entry form for full Kolb's reflection template based on guidedkolbs.md
class ManualReflectionForm extends StatefulWidget {
  final String? targetFactorId;
  final String? previousExperimentId;
  final Function(Reflection) onSave;

  const ManualReflectionForm({
    super.key,
    this.targetFactorId,
    this.previousExperimentId,
    required this.onSave,
  });

  @override
  State<ManualReflectionForm> createState() => _ManualReflectionFormState();
}

class _ManualReflectionFormState extends State<ManualReflectionForm> {
  int _currentStep = 0;
  
  // Step 1: Experience
  final _experienceController = TextEditingController();
  final _marginalGainController = TextEditingController();
  bool _isFollowUp = false;
  
  // Step 2: Reflection
  final _eventSequenceController = TextEditingController();
  final _feelingsController = TextEditingController();
  final _difficultiesController = TextEditingController();
  final _challengeResponseController = TextEditingController();
  final _triggersController = TextEditingController();
  final _whyBehaviorController = TextEditingController();
  
  // Step 3: Abstraction
  final _abstractionController = TextEditingController();
  final _crossLifePatternsController = TextEditingController();
  
  // Step 4: Experiments
  final _experimentsController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guided Kolb\'s Reflection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'This technique is taught in the early lessons of Briefing.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),

        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: i <= _currentStep ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
        ),

        const SizedBox(height: 8),

        // Step title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(_stepEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                _stepTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate(key: ValueKey(_currentStep)).fadeIn(duration: 200.ms),
        ),

        const SizedBox(height: 8),

        // Step content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStepContent(),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _currentStep < 3 
                    ? () => setState(() => _currentStep++)
                    : _saveReflection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(_currentStep < 3 ? 'Next' : 'Save Reflection'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _stepEmoji {
    switch (_currentStep) {
      case 0: return '📝';
      case 1: return '🔍';
      case 2: return '💡';
      case 3: return '🧪';
      default: return '✨';
    }
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0: return 'Step 1: Experience';
      case 1: return 'Step 2: Reflection';
      case 2: return 'Step 3: Abstraction';
      case 3: return 'Step 4: Experiment';
      default: return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildExperienceStep();
      case 1:
        return _buildReflectionStep();
      case 2:
        return _buildAbstractionStep();
      case 3:
        return _buildExperimentsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildExperienceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Follow-up question
        _buildQuestionLabel('Is this Kolb\'s cycle reflecting on an experiment from a previous Kolb\'s?*'),
        _buildHelperText('Always cycle experiments from the previous Kolb\'s into your next one to ensure your marginal gains are compounding.'),
        GlassCard(
          child: Row(
            children: [
              Icon(Icons.replay_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Follow-up from previous cycle', style: TextStyle(color: AppColors.textPrimary)),
              ),
              Switch(
                value: _isFollowUp,
                onChanged: (v) => setState(() => _isFollowUp = v),
                activeTrackColor: AppColors.primary.withAlpha(128),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Guidelines
        _buildGuidelinesCard(
          'Guidelines for experience',
          [
            '**Process-focused** - avoid reflecting on outcomes (e.g. test results) as this is not a process.',
            '**Specific** - avoid reflecting on many events and activities as this will make it difficult to produce a targeted and focused reflection.',
            '**Recent** - reflecting on experience that happened too long ago makes it easier to forget important parts.',
            '**Concise** - the experience is usually only one sentence as we will elaborate on it in the next steps.',
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('What experience do you want to reflect on?*'),
        _buildMultilineField(_experienceController, 'Describe your experience...', 3),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('What would a marginal gain look like?'),
        _buildHelperText('Remember that marginal gains look different at different levels of the conscious competence model.'),
        _buildMultilineField(_marginalGainController, 'e.g., Reducing decision fatigue by preparing the night before', 2),
      ],
    );
  }

  Widget _buildReflectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionLabel('List and describe the sequence of events, in chronological order*'),
        _buildMultilineField(_eventSequenceController, 'What happened first, then...', 3),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('How did you feel about the experience?*'),
        _buildHelperText('Be specific and detailed about how you felt and when you felt this way. Heightened emotions often indicate key parts of the process that contributed to success or failure.'),
        _buildMultilineField(_feelingsController, 'Frustrated, anxious, calm, motivated...', 2),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('Which aspects (if any) of the process felt especially difficult? Which aspects felt like they went well?*'),
        _buildMultilineField(_difficultiesController, 'Barriers, obstacles, challenges faced', 2),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('How did you respond to challenges and difficulties during this process?'),
        _buildHelperText('This could include mental or physical activities you used to try and overcome the issue. Be specific and detailed. Skip this question if there were no difficulties.'),
        _buildMultilineField(_challengeResponseController, 'Your actions, reactions, coping strategies', 2),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('What were the triggers to you feeling the way you did?'),
        _buildHelperText('Triggers are cues, signs, events, actions, or exposures that made you feel or act a certain way.'),
        _buildMultilineField(_triggersController, 'Time of day, emotion, environment, person...', 2),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('Why do you think you acted the way you did during this experience?*'),
        _buildHelperText('This question challenges your metacognition (thinking about thinking). Rather than reflecting on "what", we should reflect on "why".'),
        _buildMultilineField(_whyBehaviorController, 'Root cause analysis...', 3),
        
        const SizedBox(height: 16),
        
        // Difficulties info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.info.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Difficulties with reflection', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info)),
              const SizedBox(height: 8),
              Text(
                'If you struggle with reflecting deeply, it may indicate either a lack of practice or a lack of self-awareness during the experience itself. Focus on completing as much as you can within 30 minutes.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAbstractionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guidelines
        _buildGuidelinesCard(
          'Guidelines for abstraction',
          [
            'Your abstraction should be an analysis and evaluation of your reflection.',
            'You are examining your reflection for clues that help you understand the root causes for your actions and processes.',
            'If you struggle to find trends and patterns, your reflection may be too brief or superficial.',
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('What habits, beliefs, and tendencies can you identify from your reflection that explains why you acted the way you did?*'),
        _buildHelperText('For example: you may identify that whenever you feel overwhelmed, you tend to try and avoid challenges and revert to something easier and more comfortable.'),
        _buildMultilineField(_abstractionController, 'Identify patterns and tendencies...', 4),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('Do you act or respond in similar ways in other parts of your life?'),
        _buildHelperText('This can help you to identify the holistic impact of the habits and tendencies you found above.'),
        _buildMultilineField(_crossLifePatternsController, 'Work, relationships, health, hobbies...', 3),
      ],
    );
  }

  Widget _buildExperimentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Guidelines
        _buildGuidelinesCard(
          'Guidelines for experiment',
          [
            'Keep your experiments concise, specific, and actionable.',
            'Avoid vague statements of intention.',
            'Imagine waking up tomorrow and seeing this list - you want to have a clear idea of exactly what you need to do.',
            'Less than 3 experiments is ideal. More than 4 experiments is highly unadvised.',
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildQuestionLabel('List some potential solutions and actions to experiment on.*'),
        _buildHelperText('Enter one experiment per line (max 3)'),
        _buildMultilineField(_experimentsController, '- Experiment 1\n- Experiment 2\n- Experiment 3', 5),
      ],
    );
  }

  Widget _buildGuidelinesCard(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: AppColors.textMuted)),
                Expanded(child: Text(p, style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuestionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHelperText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildMultilineField(TextEditingController controller, String hint, int lines) {
    return TextField(
      controller: controller,
      maxLines: lines,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted.withAlpha(150)),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _saveReflection() {
    // Create reflection with all manual entry fields
    final reflection = Reflection(
      id: '', // Will be set by caller
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
      rawMarkdown: _experimentsController.text, // Store experiments temporarily
    );

    widget.onSave(reflection);
  }
}
