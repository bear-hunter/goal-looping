import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/manual_reflection_form.dart';

/// New Kolb's Cycle - Mobile-First Design
/// 
/// Architecture: One question per page with PageView navigation
/// - Manual Entry: 12 pages (one question each)
/// - Guided/Paste: 4 pages
/// - Horizontal swipe between pages
/// - Full-screen text inputs
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
  _EntryMode _entryMode = _EntryMode.guided;
  
  // Page controllers
  final _guidedPageController = PageController();
  final _manualPageController = PageController();
  int _currentGuidedPage = 0;
  int _currentManualPage = 0;
  
  // Manual form state key
  final _manualFormKey = GlobalKey<ManualReflectionFormState>();
  
  // Guided mode controllers
  final _experienceController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _abstractionController = TextEditingController();
  final _experimentsController = TextEditingController();
  final _markdownController = TextEditingController();
  
  // Factor linkage
  String? _selectedFactorId;
  String? _previousExperimentId;
  bool _isCyclingFromExperiment = false;
  bool _isExpandedContext = false;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _guidedPageController.addListener(_onGuidedPageChanged);
    _manualPageController.addListener(_onManualPageChanged);
  }

  void _onGuidedPageChanged() {
    final page = _guidedPageController.page?.round() ?? 0;
    if (page != _currentGuidedPage) {
      setState(() => _currentGuidedPage = page);
    }
  }

  void _onManualPageChanged() {
    final page = _manualPageController.page?.round() ?? 0;
    if (page != _currentManualPage) {
      setState(() => _currentManualPage = page);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _initializeState();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _guidedPageController.dispose();
    _manualPageController.dispose();
    _experienceController.dispose();
    _reflectionController.dispose();
    _abstractionController.dispose();
    _experimentsController.dispose();
    _markdownController.dispose();
    super.dispose();
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
      
      final state = Provider.of<AppState>(context, listen: false);
      final experiments = state.getExperimentsForReflection(r.id);
      if (experiments.isNotEmpty) {
        _experimentsController.text = experiments.map((e) => '- ${e.description}').join('\n');
      }

      if (r.isManualEntry) {
        _entryMode = _EntryMode.manual;
      }
    } else if (widget.previousReflection != null) {
      _selectedFactorId = widget.previousReflection!.targetFactorId;
      _isCyclingFromExperiment = true;
      _isExpandedContext = true;
    }
  }

  int get _totalPages => _entryMode == _EntryMode.manual 
      ? ManualReflectionForm.totalPages 
      : 4; // Guided has 4 pages

  int get _currentPage => _entryMode == _EntryMode.manual 
      ? _currentManualPage 
      : _currentGuidedPage;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEditing = widget.reflectionToEdit != null;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              // App Bar
              SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => _handleClose(),
                      ),
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Reflection' : 'New Kolb\'s Cycle',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Entry Mode Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEntryModeToggle(),
              ),
              
              const SizedBox(height: 12),
              
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProgressIndicator(),
              ),
              
              const SizedBox(height: 8),
              
              // Phase indicator for manual mode
              if (_entryMode == _EntryMode.manual)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        _manualFormKey.currentState?.getPhaseEmoji(_currentManualPage) ?? '📝',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _manualFormKey.currentState?.getPhaseName(_currentManualPage) ?? 'Experience',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentManualPage + 1} of $_totalPages',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Previous Context Card (if cycling)
              if (widget.previousReflection != null && !isEditing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildPreviousContextCard(),
                ),
              
              // Main Content - PageView
              Expanded(
                child: _entryMode == _EntryMode.manual
                    ? _buildManualPageView(keyboardHeight, state)
                    : _buildGuidedPageView(keyboardHeight, state),
              ),
              
              // Bottom Navigation
              _buildBottomNavigation(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryModeToggle() {
    return Row(
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
    );
  }

  Widget _buildProgressIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final progress = (_currentPage + 1) / _totalPages;
        
        return Stack(
          children: [
            // Background
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: totalWidth * progress,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildManualPageView(double keyboardHeight, AppState state) {
    return Column(
      children: [
        // Hidden form to hold state
        ManualReflectionForm(
          key: _manualFormKey,
          targetFactorId: _selectedFactorId,
          previousExperimentId: _previousExperimentId,
          onSave: (reflection) => _saveManualReflection(state, reflection),
          onChanged: () => setState(() {}),
        ),
        
        // PageView
        Expanded(
          child: PageView.builder(
            controller: _manualPageController,
            itemCount: ManualReflectionForm.totalPages,
            onPageChanged: (page) => setState(() => _currentManualPage = page),
            itemBuilder: (context, index) {
              return _manualFormKey.currentState?.getPage(index, keyboardHeight) 
                  ?? const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuidedPageView(double keyboardHeight, AppState state) {
    return PageView(
      controller: _guidedPageController,
      onPageChanged: (page) => setState(() => _currentGuidedPage = page),
      children: [
        _buildGuidedPage0(keyboardHeight), // Paste
        _buildGuidedPage1(keyboardHeight, state), // Factor
        _buildGuidedPage2(keyboardHeight), // Review
        _buildGuidedPage3(keyboardHeight, state), // Confirm
      ],
    );
  }

  Widget _buildBottomNavigation(AppState state) {
    final isLastPage = _currentPage == _totalPages - 1;
    final isFirstPage = _currentPage == 0;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 
        12, 
        16, 
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstPage)
            TextButton.icon(
              onPressed: _goToPreviousPage,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          
          const Spacer(),
          
          // Page indicator
          Text(
            '${_currentPage + 1} / $_totalPages',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          
          const Spacer(),
          
          // Next/Save button
          ElevatedButton.icon(
            onPressed: isLastPage ? () => _handleSave(state) : _goToNextPage,
            icon: Icon(isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 18),
            label: Text(isLastPage ? 'Save' : 'Next'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextPage() {
    if (_entryMode == _EntryMode.manual) {
      _manualPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _guidedPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_entryMode == _EntryMode.manual) {
      _manualPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _guidedPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSave(AppState state) {
    if (_entryMode == _EntryMode.manual) {
      _manualFormKey.currentState?.saveReflection();
    } else {
      _saveReflection();
    }
  }

  // ============================================
  // GUIDED MODE PAGES
  // ============================================

  Widget _buildGuidedPage0(double keyboardHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Paste Full Gemini Output',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste the entire Kolb\'s cycle output from Gemini below.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          
          // Format hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected format:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '# Cycle Info\n- **Factor:** [Name]\n\n# Experience\n[text]\n\n# Reflection\n[text]\n\n# Abstraction\n[text]\n\n# Experiments\n- [item]',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          TextField(
            controller: _markdownController,
            maxLines: 12,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Paste the complete Gemini Kolb\'s output here...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: _parseMarkdown,
          ),
          
          if (_markdownController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildParsedStatusIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidedPage1(double keyboardHeight, AppState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Select Target Factor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Which factor does this reflection relate to?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          
          _buildFactorSelector(state),
        ],
      ),
    );
  }

  Widget _buildGuidedPage2(double keyboardHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✏️ Review & Edit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review the extracted fields below. Edit if needed.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          
          _buildFieldWithLabel('Experience', _experienceController, 3),
          const SizedBox(height: 16),
          
          _buildFieldWithLabel('Reflection', _reflectionController, 4),
          const SizedBox(height: 16),
          
          _buildFieldWithLabel('Abstraction', _abstractionController, 4),
          const SizedBox(height: 16),
          
          _buildFieldWithLabel('Experiments (one per line)', _experimentsController, 4),
        ],
      ),
    );
  }

  Widget _buildGuidedPage3(double keyboardHeight, AppState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Confirm & Save',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review the summary before saving.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedFactorId != null) ...[
                  _buildSummaryRow('Factor', state.factors.firstWhere(
                    (f) => f.id == _selectedFactorId, 
                    orElse: () => state.factors.first,
                  ).name),
                  const SizedBox(height: 8),
                ],
                
                if (_isCyclingFromExperiment)
                  _buildSummaryRow('Cycling', '♻️ Follow-up from previous'),
                
                const Divider(height: 24),
                
                _buildSummaryRow('Experience', _experienceController.text, maxLines: 2),
                const SizedBox(height: 8),
                
                _buildSummaryRow('Reflection', _reflectionController.text, maxLines: 2),
                const SizedBox(height: 8),
                
                _buildSummaryRow('Abstraction', _abstractionController.text, maxLines: 2),
                const SizedBox(height: 8),
                
                _buildSummaryRow('Experiments', '${_experimentsController.text.split('\n').where((l) => l.trim().isNotEmpty).length} experiment(s)'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Ready to save! Tap Save below.', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================

  Widget _buildFieldWithLabel(String label, TextEditingController controller, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: lines,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousContextCard() {
    final prev = widget.previousReflection!;
    return GestureDetector(
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
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFactorSelector(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: state.factors.map((f) {
            final isSelected = _selectedFactorId == f.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedFactorId = f.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.glassBorder, 
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(f.name, style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                )),
              ),
            );
          }).toList(),
        ),
        if (state.factors.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('⚠️ Add Factors in Strategy first', style: TextStyle(color: AppColors.warning)),
          ),
      ],
    );
  }

  Widget _buildParsedStatusIndicator() {
    final hasExperience = _experienceController.text.isNotEmpty;
    final hasReflection = _reflectionController.text.isNotEmpty;
    final hasAbstraction = _abstractionController.text.isNotEmpty;
    final hasExperiments = _experimentsController.text.isNotEmpty;
    final parsedCount = [hasExperience, hasReflection, hasAbstraction, hasExperiments].where((b) => b).length;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: parsedCount >= 3 ? AppColors.success.withAlpha(20) : AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            parsedCount >= 3 ? Icons.check_circle_rounded : Icons.info_rounded, 
            color: parsedCount >= 3 ? AppColors.success : AppColors.warning, 
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parsedCount >= 3 
                  ? '✓ Parsed $parsedCount/4 sections. Swipe to continue.' 
                  : 'Parsed $parsedCount/4 sections. Check format.',
              style: TextStyle(
                color: parsedCount >= 3 ? AppColors.success : AppColors.warning, 
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '(empty)' : value,
            style: TextStyle(color: value.isEmpty ? AppColors.textMuted : AppColors.textPrimary, fontSize: 12),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    if (_experienceController.text.isNotEmpty || _reflectionController.text.isNotEmpty) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Discard them?'),
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
      final updated = widget.reflectionToEdit!.copyWith(
        experience: reflection.experience,
        reflection: reflection.reflection,
        abstraction: reflection.abstraction,
        targetFactorId: _selectedFactorId,
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
        rawMarkdown: reflection.rawMarkdown,
      );
      await state.updateReflection(updated);
      
      if (reflection.rawMarkdown != null) {
        await _syncExperiments(state, updated.id, reflection.rawMarkdown!);
      }
    } else if (widget.previousReflection != null) {
      final newReflection = _createReflectionObject(
        reflection.experience, 
        reflection.reflection, 
        reflection.abstraction, 
        null,
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
      );
      
      if (reflection.rawMarkdown != null) {
         final experimentIds = await _createExperimentsOnly(state, newReflection.id, reflection.rawMarkdown!);
         newReflection.experimentIds.addAll(experimentIds);
      }
      
      await state.addLinkedReflection(newReflection, previousReflection: widget.previousReflection);
    } else {
      final newReflection = _createReflectionObject(
        reflection.experience, 
        reflection.reflection, 
        reflection.abstraction, 
        null,
        marginalGainDescription: reflection.marginalGainDescription,
        eventSequence: reflection.eventSequence,
        feelings: reflection.feelings,
        difficulties: reflection.difficulties,
        challengeResponse: reflection.challengeResponse,
        triggers: reflection.triggers,
        whyBehavior: reflection.whyBehavior,
        crossLifePatterns: reflection.crossLifePatterns,
      );
      
      if (reflection.rawMarkdown != null) {
         final experimentIds = await _createExperimentsOnly(state, newReflection.id, reflection.rawMarkdown!);
         newReflection.experimentIds.addAll(experimentIds);
      }
      
      await state.addReflection(newReflection);
    }
    
    if (mounted) Navigator.pop(context);
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
       final newReflection = _createReflectionObject(
          _experienceController.text, 
          _reflectionController.text, 
          _abstractionController.text, 
          _markdownController.text.isNotEmpty ? _markdownController.text : null
       );
       
       final experimentIds = await _createExperimentsOnly(state, newReflection.id, _experimentsController.text);
       newReflection.experimentIds.addAll(experimentIds);

       if (widget.previousReflection != null) {
          await state.addLinkedReflection(newReflection, previousReflection: widget.previousReflection);
       } else {
          await state.addReflection(newReflection);
       }
    }

    if (mounted) {
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

  void _parseMarkdown(String markdown) {
    final factorMatch = RegExp(r'\*\*Factor:\*\*\s*(.+)', caseSensitive: false).firstMatch(markdown);
    if (factorMatch != null) {
      final factorName = factorMatch.group(1)?.trim() ?? '';
      final state = context.read<AppState>();
      for (final factor in state.factors) {
        if (factor.name.toLowerCase() == factorName.toLowerCase()) {
          setState(() => _selectedFactorId = factor.id);
          break;
        }
      }
    }

    final cycleIdMatch = RegExp(r'\*\*Previous Cycle ID:\*\*\s*(.+)', caseSensitive: false).firstMatch(markdown);
    if (cycleIdMatch != null) {
      final id = cycleIdMatch.group(1)?.trim() ?? '';
      if (id.isNotEmpty && id.toLowerCase() != 'none') {
        _previousExperimentId = id;
        _isCyclingFromExperiment = true;
      }
    }

    final expMatch = RegExp(r'#\s*Experience\s*\n(.*?)(?=#|$)', dotAll: true, caseSensitive: false).firstMatch(markdown);
    if (expMatch != null) {
      _experienceController.text = expMatch.group(1)?.trim() ?? '';
    }

    final refMatch = RegExp(r'#\s*Reflection\s*\n(.*?)(?=#|$)', dotAll: true, caseSensitive: false).firstMatch(markdown);
    if (refMatch != null) {
      _reflectionController.text = refMatch.group(1)?.trim() ?? '';
    }

    final absMatch = RegExp(r'#\s*Abstraction\s*\n(.*?)(?=#|$)', dotAll: true, caseSensitive: false).firstMatch(markdown);
    if (absMatch != null) {
      _abstractionController.text = absMatch.group(1)?.trim() ?? '';
    }

    final expsMatch = RegExp(r'#\s*Experiments?\s*\n(.*?)(?=#|$)', dotAll: true, caseSensitive: false).firstMatch(markdown);
    if (expsMatch != null) {
      _experimentsController.text = expsMatch.group(1)?.trim() ?? '';
    }
    
    setState(() {});
  }
}
