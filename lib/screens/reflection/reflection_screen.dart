import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import 'reflection_detail_screen.dart';

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
                      Text('Reflection Forge', style: Theme.of(context).textTheme.displayMedium)
                          .animate().fadeIn(duration: 400.ms),
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
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
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

              // Pending Experiments
              if (state.pendingExperiments.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Icon(Icons.science_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(width: 12),
                        Text('Pending Experiments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.warning)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: Text('${state.pendingExperiments.length}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exp = state.pendingExperiments[index];
                      return GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exp.description, style: TextStyle(color: AppColors.textPrimary)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _ActionChip(
                                  label: 'Add to Top 2',
                                  color: AppColors.primary,
                                  enabled: state.canAddPriorityTask,
                                  onTap: () => state.promoteExperimentToTask(exp.id, toPriority: true),
                                ),
                                const SizedBox(width: 8),
                                _ActionChip(
                                  label: 'Add to Backlog',
                                  color: AppColors.textMuted,
                                  onTap: () => state.promoteExperimentToTask(exp.id, toPriority: false),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: state.pendingExperiments.length,
                  ),
                ),
              ],

              // Recent Reflections
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
                            Icon(Icons.psychology_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
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

  const _ReflectionCard({required this.reflection, this.onTap});

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

class _NewReflectionSheetState extends State<_NewReflectionSheet> {
  int _step = 0; // Start at Step 0: Factor selection
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

          // Progress (6 steps now: 0=Factor, 1=Experience, 2=Reflection, 3=Abstraction, 4=Experiments, 5=Markdown)
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(state),
            ),
          ),

          // Actions
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

  void _saveReflection() {
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
      state.addExperiment(exp);
      experimentIds.add(exp.id);
    }

    reflection.experimentIds.addAll(experimentIds);
    state.addReflection(reflection);

    Navigator.pop(context);
  }
}

