import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/manual_reflection_form.dart';
import 'reflection_detail_screen.dart';
import 'reflection_archive_screen.dart';
import '../experiment/experiment_screen.dart';

/// Module 5: Reflection Forge - Kolb's Cycles with Markdown parsing
class ReflectionScreen extends StatelessWidget {
  const ReflectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Reflection Forge', style: Theme.of(context).textTheme.displayMedium)
                                .animate().fadeIn(duration: 400.ms),
                          ),
                          // Experiments button
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExperimentScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.science_rounded, size: 20, color: AppColors.warning),
                                  if (state.pendingExperiments.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${state.pendingExperiments.length}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Archive button
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReflectionArchiveScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.textMuted.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.archive_outlined, size: 20, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Transform reflections into actions',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),

              // New Reflection Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => _showNewReflectionDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(76), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('New Kolb\'s Cycle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Active Cycle Chains (grouped reflections)
              if (state.activeReflectionGroups.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Icon(Icons.replay_circle_filled_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text('Active Cycle Chains', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.primary.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                          child: Text('${state.activeReflectionGroups.length}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = state.activeReflectionGroups[index];
                      return _CycleChainCard(
                        group: group,
                        reflections: group.reflectionIds
                            .map((id) => state.getReflectionById(id))
                            .where((r) => r != null)
                            .toList(),
                        onViewReflection: (reflectionId) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReflectionDetailScreen(reflectionId: reflectionId),
                          ),
                        ),
                      );
                    },
                    childCount: state.activeReflectionGroups.length,
                  ),
                ),
              ],

              // Recent Reflections (ungrouped)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Text('Recent Cycles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),

              if (state.reflections.isEmpty)
                SliverToBoxAdapter(
                  child: GlassCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.psychology_rounded, size: 48, color: AppColors.textMuted.withAlpha(127)),
                            const SizedBox(height: 12),
                            Text('Start your first reflection cycle', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reflection = state.reflections[index];
                      return _ReflectionCard(
                        reflection: reflection,
                        cycleNumber: reflection.groupId != null 
                            ? state.getReflectionGroup(reflection.groupId!)?.reflectionIds.indexOf(reflection.id) ?? 0 + 1
                            : null,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReflectionDetailScreen(reflectionId: reflection.id),
                          ),
                        ),
                      );
                    },
                    childCount: state.reflections.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  void _showNewReflectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _NewReflectionSheet(),
    );
  }
}

/// Cycle chain card showing timeline
class _CycleChainCard extends StatelessWidget {
  final dynamic group;
  final List<dynamic> reflections;
  final Function(String) onViewReflection;

  const _CycleChainCard({
    required this.group,
    required this.reflections,
    required this.onViewReflection,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Text('🔁', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title ?? 'Reflection Cycle',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${reflections.length} cycles',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reflections.length,
              itemBuilder: (ctx, i) {
                final r = reflections[i];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => onViewReflection(r.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: i == reflections.length - 1 
                              ? AppColors.primary.withAlpha(30) 
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: i == reflections.length - 1 
                                ? AppColors.primary 
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: i == reflections.length - 1 
                                    ? AppColors.primary 
                                    : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'cycle',
                              style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < reflections.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionChip({required this.label, required this.color, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? color.withOpacity(0.3) : AppColors.glassBorder),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: enabled ? color : AppColors.textMuted)),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final Reflection reflection;
  final VoidCallback? onTap;
  final int? cycleNumber;

  const _ReflectionCard({required this.reflection, this.onTap, this.cycleNumber});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reflection.experience.isNotEmpty ? reflection.experience : 'Untitled Reflection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cycleNumber != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🔁 $cycleNumber',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _formatDate(reflection.createdAt),
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: reflection.completionPercent,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(
            '${(reflection.completionPercent * 100).toInt()}% complete • ${reflection.experimentIds.length} experiments',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }
}

class _NewReflectionSheet extends StatefulWidget {
  const _NewReflectionSheet();

  @override
  State<_NewReflectionSheet> createState() => _NewReflectionSheetState();
}

enum _EntryMode { guided, manual }

class _NewReflectionSheetState extends State<_NewReflectionSheet> {
  int _step = 0; // Start at Step 0: Factor selection
  _EntryMode _entryMode = _EntryMode.guided;
  final _experienceController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _abstractionController = TextEditingController();
  final _experimentsController = TextEditingController();
  final _markdownController = TextEditingController();
  
  // Phase 4: Factor linkage and cycling
  String? _selectedFactorId;
  String? _previousExperimentId;
  bool _isCyclingFromExperiment = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('New Kolb\'s Cycle', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Entry Mode Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryMode = _EntryMode.guided),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _entryMode == _EntryMode.guided 
                            ? AppColors.primary.withAlpha(30) 
                            : AppColors.surfaceLight,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        border: Border.all(
                          color: _entryMode == _EntryMode.guided 
                              ? AppColors.primary 
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.paste_rounded, 
                            size: 18,
                            color: _entryMode == _EntryMode.guided ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Paste from Gemini',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _entryMode == _EntryMode.guided ? FontWeight.w600 : FontWeight.normal,
                              color: _entryMode == _EntryMode.guided ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryMode = _EntryMode.manual),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _entryMode == _EntryMode.manual 
                            ? AppColors.primary.withAlpha(30) 
                            : AppColors.surfaceLight,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        border: Border.all(
                          color: _entryMode == _EntryMode.manual 
                              ? AppColors.primary 
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded, 
                            size: 18,
                            color: _entryMode == _EntryMode.manual ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Manual Entry',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _entryMode == _EntryMode.manual ? FontWeight.w600 : FontWeight.normal,
                              color: _entryMode == _EntryMode.manual ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Progress (6 steps for guided mode)
          if (_entryMode == _EntryMode.guided)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(6, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

          // Content
          Expanded(
            child: _entryMode == _EntryMode.manual
                ? _ManualEntryContent(
                    targetFactorId: _selectedFactorId,
                    previousExperimentId: _previousExperimentId,
                    onSave: (reflection) {
                      _saveManualReflection(state, reflection);
                    },
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildStepContent(state),
                  ),
          ),

          // Actions (only for guided mode)
          if (_entryMode == _EntryMode.guided)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(onPressed: () => setState(() => _step--), child: const Text('Back')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _step < 5 ? () => setState(() => _step++) : _saveReflection,
                    child: Text(_step < 5 ? 'Next' : 'Save'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _saveManualReflection(AppState state, Reflection reflection) async {
    final reflectionId = StorageService.generateId();
    
    // Parse experiments from rawMarkdown (temporary storage)
    final experimentLines = (reflection.rawMarkdown ?? '')
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .take(3)
        .toList();

    final experimentIds = <String>[];
    for (final line in experimentLines) {
      final exp = Experiment(
        id: StorageService.generateId(),
        description: line,
        reflectionId: reflectionId,
      );
      await state.addExperiment(exp);
      experimentIds.add(exp.id);
    }
    
    // Copy reflection with generated ID and experiment IDs
    final savedReflection = Reflection(
      id: reflectionId,
      experience: reflection.experience,
      reflection: reflection.reflection,
      abstraction: reflection.abstraction,
      isFollowUp: reflection.isFollowUp,
      previousExperimentId: reflection.previousExperimentId,
      targetFactorId: reflection.targetFactorId,
      linkedFactorIds: reflection.linkedFactorIds,
      isManualEntry: true,
      marginalGainDescription: reflection.marginalGainDescription,
      eventSequence: reflection.eventSequence,
      feelings: reflection.feelings,
      difficulties: reflection.difficulties,
      challengeResponse: reflection.challengeResponse,
      triggers: reflection.triggers,
      whyBehavior: reflection.whyBehavior,
      crossLifePatterns: reflection.crossLifePatterns,
      experimentIds: experimentIds,
    );
    
    state.addReflection(savedReflection);
    Navigator.pop(context);
  }

  Widget _buildStepContent(AppState state) {
    switch (_step) {
      case 0: // NEW: Factor Selection + Cycling
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 0: Target Factor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Which Factor from your dissected tree are you improving?', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            
            // Factor selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.factors.map((f) {
                final isSelected = _selectedFactorId == f.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFactorId = f.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder, width: isSelected ? 2 : 1),
                    ),
                    child: Text(f.name, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    )),
                  ),
                );
              }).toList(),
            ),
            
            if (state.factors.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('⚠️ Add Factors in Strategy first', style: TextStyle(color: AppColors.warning)),
              ),
            
            const SizedBox(height: 24),
            
            // Cycling from previous experiment
            Text('Cycling from previous?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Always cycle experiments to ensure marginal gains compound', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            
            if (state.pendingExperiments.isNotEmpty)
              ...state.pendingExperiments.take(5).map((exp) {
                final isSelected = _previousExperimentId == exp.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _previousExperimentId = isSelected ? null : exp.id;
                    _isCyclingFromExperiment = !isSelected;
                    if (!isSelected) {
                      _experienceController.text = 'Experiment: ${exp.description}';
                    }
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.warning.withAlpha(30) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.warning : AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.science_rounded, color: isSelected ? AppColors.warning : AppColors.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(exp.description, style: TextStyle(color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                        if (isSelected) Icon(Icons.check_circle_rounded, color: AppColors.warning, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            
            if (state.pendingExperiments.isEmpty)
              Text('No pending experiments to cycle from', style: TextStyle(color: AppColors.textMuted)),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 1: Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('What experience do you want to reflect on?', style: TextStyle(color: AppColors.textMuted)),
            if (_isCyclingFromExperiment)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.warning.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Text('♻️ Cycling from previous experiment', style: TextStyle(color: AppColors.warning, fontSize: 12)),
                ),
              ),
            const SizedBox(height: 16),
            TextField(controller: _experienceController, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe the experience...')),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2: Reflection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('How did you feel? What went well/poorly?', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextField(controller: _reflectionController, maxLines: 6, decoration: const InputDecoration(hintText: 'Reflect on the experience...')),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 3: Abstraction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('What habits, beliefs, or tendencies explain your actions?', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextField(controller: _abstractionController, maxLines: 6, decoration: const InputDecoration(hintText: 'Identify patterns...')),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 4: Experiments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('List 1-3 experiments (one per line)', style: TextStyle(color: AppColors.textMuted)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.info.withAlpha(20), borderRadius: BorderRadius.circular(8)),
              child: Text('💡 Less than 3 experiments is ideal for focused progress', style: TextStyle(color: AppColors.info, fontSize: 12)),
            ),
            TextField(controller: _experimentsController, maxLines: 6, decoration: const InputDecoration(hintText: '- Experiment 1\n- Experiment 2\n- Experiment 3 (max)')),
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Or: Paste Markdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Paste Gemini Kolb\'s output to auto-parse', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextField(
              controller: _markdownController, 
              maxLines: 10, 
              decoration: const InputDecoration(hintText: 'Paste markdown here...'),
              onChanged: _parseMarkdown,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _parseMarkdown(String markdown) {
    final expMatch = RegExp(r'#\s*Experience\s*\n(.*?)(?=#|$)', dotAll: true).firstMatch(markdown);
    if (expMatch != null) _experienceController.text = expMatch.group(1)?.trim() ?? '';

    final expsMatch = RegExp(r'#\s*Experiments?\s*\n(.*?)(?=#|$)', dotAll: true).firstMatch(markdown);
    if (expsMatch != null) _experimentsController.text = expsMatch.group(1)?.trim() ?? '';
  }

  void _saveReflection() async {
    final state = context.read<AppState>();
    final reflectionId = StorageService.generateId();

    // Create reflection with Factor linkage
    final reflection = Reflection(
      id: reflectionId,
      experience: _experienceController.text,
      reflection: _reflectionController.text,
      abstraction: _abstractionController.text,
      rawMarkdown: _markdownController.text.isNotEmpty ? _markdownController.text : null,
      targetFactorId: _selectedFactorId,
      previousExperimentId: _previousExperimentId,
      isFollowUp: _isCyclingFromExperiment,
      linkedFactorIds: _selectedFactorId != null ? [_selectedFactorId!] : [],
    );

    // Parse experiments (limit to 3)
    final experimentLines = _experimentsController.text
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .take(3) // Max 3 experiments
        .toList();

    final experimentIds = <String>[];
    for (final line in experimentLines) {
      final exp = Experiment(
        id: StorageService.generateId(),
        description: line,
        reflectionId: reflectionId,
      );
      await state.addExperiment(exp);
      experimentIds.add(exp.id);
    }

    reflection.experimentIds.addAll(experimentIds);
    state.addReflection(reflection);

    Navigator.pop(context);
  }
}

/// Wrapper for manual entry content using the ManualReflectionForm
class _ManualEntryContent extends StatelessWidget {
  final String? targetFactorId;
  final String? previousExperimentId;
  final Function(Reflection) onSave;

  const _ManualEntryContent({
    this.targetFactorId,
    this.previousExperimentId,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ManualReflectionForm(
      targetFactorId: targetFactorId,
      previousExperimentId: previousExperimentId,
      onSave: onSave,
    );
  }
}

