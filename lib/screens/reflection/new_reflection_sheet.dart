import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/manual_reflection_form.dart';

class NewReflectionSheet extends StatefulWidget {
  final Reflection? previousReflection;
  final String? groupId;
  final Reflection? reflectionToEdit;

  const NewReflectionSheet({
    super.key,
    this.previousReflection,
    this.groupId,
    this.reflectionToEdit,
  });

  @override
  State<NewReflectionSheet> createState() => _NewReflectionSheetState();
}

enum _EntryMode { guided, manual }

class _NewReflectionSheetState extends State<NewReflectionSheet> {
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
  bool _isExpandedContext = false;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _initializeState();
      _isInit = true;
    }
  }

  void _initializeState() {
    if (widget.reflectionToEdit != null) {
      final r = widget.reflectionToEdit!;
      _experienceController.text = r.experience;
      _reflectionController.text = r.reflection;
      _abstractionController.text = r.abstraction;
      _markdownController.text = r.rawMarkdown ?? '';
      _selectedFactorId = r.targetFactorId;
      _previousExperimentId = r.previousExperimentId;
      _isCyclingFromExperiment = r.isFollowUp;
      
      // Load experiments text
      final state = Provider.of<AppState>(context, listen: false);
      final experiments = state.getExperimentsForReflection(r.id);
      if (experiments.isNotEmpty) {
        _experimentsController.text = experiments.map((e) => '- ${e.description}').join('\n');
      }

      // Check if it was manual entry
      if (r.isManualEntry) {
        _entryMode = _EntryMode.manual;
      }
    } else if (widget.previousReflection != null) {
      // Pre-set context for cycling
      _selectedFactorId = widget.previousReflection!.targetFactorId;
      _isCyclingFromExperiment = true; // Cycling implies follow-up
      _isExpandedContext = true; // Auto-expand context
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEditing = widget.reflectionToEdit != null;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                  Text(isEditing ? 'Edit Reflection' : 'New Kolb\'s Cycle', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => _handleClose()),
                ],
              ),
            ),

            // Previous Context (if cycling and not editing)
            if (widget.previousReflection != null && !isEditing)
              _buildPreviousContextCard(),

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
                              'Guided / Paste',
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
                  ? Column(
                      children: [
                        if (_step == 0) // Show factor selector in manual mode too
                           Padding(
                             padding: const EdgeInsets.all(20),
                             child: _buildFactorSelector(state),
                           ),
                        Expanded(
                          child: ManualEntryContent(
                            targetFactorId: _selectedFactorId,
                            previousExperimentId: _previousExperimentId,
                            onSave: (reflection) {
                              _saveManualReflection(state, reflection);
                            },
                          ),
                        ),
                      ],
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
      ),
    );
  }

  Widget _buildPreviousContextCard() {
    final prev = widget.previousReflection!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _isExpandedContext = !_isExpandedContext),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_edu_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text('Cycling from previous...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const Spacer(),
                  Icon(_isExpandedContext ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.textMuted),
                ],
              ),
              if (_isExpandedContext) ...[
                const SizedBox(height: 8),
                Text('Experience:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                Text(prev.experience, style: TextStyle(fontSize: 12, color: AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
                if (prev.experimentIds.isNotEmpty) ...[
                   const SizedBox(height: 8),
                   Text('Experiments:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                   Text('${prev.experimentIds.length} experiments defined', style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_experienceController.text.isNotEmpty || _reflectionController.text.isNotEmpty) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep Editing')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Discard', style: TextStyle(color: AppColors.danger))),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  void _handleClose() async {
    final shouldPop = await _onWillPop();
    if (shouldPop && mounted) Navigator.pop(context);
  }

  void _saveManualReflection(AppState state, Reflection reflection) async {
    if (widget.reflectionToEdit != null) {
      // Update existing
      final updated = widget.reflectionToEdit!.copyWith(
        experience: reflection.experience,
        reflection: reflection.reflection,
        abstraction: reflection.abstraction,
        targetFactorId: _selectedFactorId,
        // Manual fields
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
        rawMarkdown: reflection.rawMarkdown, // Carries temp experiments
      );
      await state.updateReflection(updated);
      
      // Sync experiments from the temp rawMarkdown field where we stored them
      if (reflection.rawMarkdown != null) {
        await _syncExperiments(state, updated.id, reflection.rawMarkdown!);
      }
    } else if (widget.previousReflection != null) {
      // Link to previous
      final newReflection = _createReflectionObject(
        reflection.experience, 
        reflection.reflection, 
        reflection.abstraction, 
        null,
        // Pass manual fields
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
      );
      
      // Create experiments
      if (reflection.rawMarkdown != null) {
         final experimentIds = await _createExperimentsOnly(state, newReflection.id, reflection.rawMarkdown!);
         newReflection.experimentIds.addAll(experimentIds);
      }
      
      await state.addLinkedReflection(newReflection, previousReflection: widget.previousReflection);
    } else {
      // New standalone
      final newReflection = _createReflectionObject(
        reflection.experience, 
        reflection.reflection, 
        reflection.abstraction, 
        null,
        // Pass manual fields
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
      );
      
      // Create experiments
      if (reflection.rawMarkdown != null) {
         final experimentIds = await _createExperimentsOnly(state, newReflection.id, reflection.rawMarkdown!);
         newReflection.experimentIds.addAll(experimentIds);
      }
      
      await state.addReflection(newReflection);
    }
    
    if (context.mounted) Navigator.pop(context);
  }

  // Not used for manual mode anymore as we handle experiments differently there (in _saveManualReflection)
  Future<void> _saveExperiments(AppState state, String reflectionId, String? rawMarkdown) async {
    // Deprecated for manual flow, kept for compatibility if needed
  }

  Reflection _createReflectionObject(
    String exp, 
    String ref, 
    String abs, 
    String? rawMd, {
    String? marginalGainDescription,
    String? eventSequence,
    String? feelings,
    String? difficulties,
    String? challengeResponse,
    String? triggers,
    String? whyBehavior,
    String? crossLifePatterns,
  }) {
    return Reflection(
      id: widget.reflectionToEdit?.id ?? StorageService.generateId(),
      experience: exp,
      reflection: ref,
      abstraction: abs,
      rawMarkdown: rawMd,
      targetFactorId: _selectedFactorId,
      previousExperimentId: _previousExperimentId,
      isFollowUp: _isCyclingFromExperiment,
      linkedFactorIds: _selectedFactorId != null ? [_selectedFactorId!] : [],
      isManualEntry: _entryMode == _EntryMode.manual,
      groupId: widget.groupId,
      // Manual fields
      marginalGainDescription: marginalGainDescription,
      eventSequence: eventSequence,
      feelings: feelings,
      difficulties: difficulties,
      challengeResponse: challengeResponse,
      triggers: triggers,
      whyBehavior: whyBehavior,
      crossLifePatterns: crossLifePatterns,
    );
  }

  void _saveReflection() async {
    final state = context.read<AppState>();
    
    if (widget.reflectionToEdit != null) {
       // Update logic
       final updated = widget.reflectionToEdit!.copyWith(
          experience: _experienceController.text,
          reflection: _reflectionController.text,
          abstraction: _abstractionController.text,
          rawMarkdown: _markdownController.text.isNotEmpty ? _markdownController.text : null,
          targetFactorId: _selectedFactorId,
       );
       await state.updateReflection(updated);
       await _syncExperiments(state, updated.id, _experimentsController.text);
    } else {
       // Create new
       final newReflection = _createReflectionObject(
          _experienceController.text, 
          _reflectionController.text, 
          _abstractionController.text, 
          _markdownController.text.isNotEmpty ? _markdownController.text : null
       );
       
       // Create experiments first
       final experimentIds = await _createExperimentsOnly(state, newReflection.id, _experimentsController.text);
       newReflection.experimentIds.addAll(experimentIds);

       if (widget.previousReflection != null) {
          await state.addLinkedReflection(newReflection, previousReflection: widget.previousReflection);
       } else {
          await state.addReflection(newReflection);
       }
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<List<String>> _createExperimentsOnly(AppState state, String reflectionId, String text) async {
       final experimentLines = text
          .split('\n')
          .map((l) => l.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
          .where((l) => l.isNotEmpty)
          .take(3)
          .toList();

       final ids = <String>[];
       for (final line in experimentLines) {
          final exp = Experiment(
            id: StorageService.generateId(),
            description: line,
            reflectionId: reflectionId,
          );
          await state.addExperiment(exp);
          ids.add(exp.id);
       }
       return ids;
  }

  Future<void> _syncExperiments(AppState state, String reflectionId, String text) async {
      final existing = state.getExperimentsForReflection(reflectionId);
      final newLines = text
          .split('\n')
          .map((l) => l.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim())
          .where((l) => l.isNotEmpty)
          .take(3)
          .toList();
      
      final toKeep = <String>[];
      
      for (final line in newLines) {
         final match = existing
             .where((e) => e.description == line && !toKeep.contains(e.id))
             .firstOrNull;
         
         if (match != null) {
            toKeep.add(match.id);
         } else {
            // Create new
            final exp = Experiment(
               id: StorageService.generateId(),
               description: line,
               reflectionId: reflectionId,
            );
            await state.addExperiment(exp);
            
            final r = state.getReflectionById(reflectionId);
            if (r != null && !r.experimentIds.contains(exp.id)) {
               r.experimentIds.add(exp.id);
               await state.updateReflection(r);
            }
         }
      }
      
      // Delete missing pending experiments
      for (final old in existing) {
         if (!toKeep.contains(old.id)) {
            if (old.status == ExperimentStatus.pending) {
               await state.deleteExperiment(old.id);
               
               final r = state.getReflectionById(reflectionId);
               if (r != null) {
                  r.experimentIds.remove(old.id);
                  await state.updateReflection(r);
               }
            }
         }
      }
  }

  Widget _buildFactorSelector(AppState state) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Target Factor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
           const SizedBox(height: 8),
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
        ],
     );
  }

  Widget _buildStepContent(AppState state) {
    switch (_step) {
      case 0: // NEW: Factor Selection + Cycling
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFactorSelector(state),
            const SizedBox(height: 24),
            
            // Cycling from previous experiment (Only show if NOT editing or if referencing prev exp)
            if (widget.reflectionToEdit == null || _previousExperimentId != null) ...[
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
              ]
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
}

/// Wrapper for manual entry content using the ManualReflectionForm
class ManualEntryContent extends StatelessWidget {
  final String? targetFactorId;
  final String? previousExperimentId;
  final Function(Reflection) onSave;

  const ManualEntryContent({
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
