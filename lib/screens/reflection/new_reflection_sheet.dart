import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../models/reflection.dart';
import '../../models/experiment.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../../widgets/bottom_sheet_wrapper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/manual_reflection_form.dart';
import '../../widgets/reflection_step_scaffold.dart';

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
  final _markdownFocusNode = FocusNode();

  // Factor linkage
  String? _selectedFactorId;
  String? _previousExperimentId;
  bool _isCyclingFromExperiment = false;
  bool _isExpandedContext = false;

  // Flow state: the setup step gates the mode-specific pages.
  bool _inSetup = true;
  bool _modeLocked = false;

  /// Guided paste page: false shows the drop-zone hero, true the text editor.
  bool _pasteEditorActive = false;

  bool _isInit = false;
  bool _manualFormDirty = false;

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
    _markdownFocusNode.removeListener(_onMarkdownFocusChange);
    _markdownFocusNode.dispose();
    super.dispose();
  }

  void _initializeState() {
    _markdownFocusNode.addListener(_onMarkdownFocusChange);
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
        _experimentsController.text = experiments
            .map((e) => '- ${e.description}')
            .join('\n');
      }

      if (r.isManualEntry) {
        _entryMode = _EntryMode.manual;
      }
      _modeLocked = true;
    } else if (widget.previousReflection != null) {
      _selectedFactorId = widget.previousReflection!.targetFactorId;
      _isCyclingFromExperiment = true;
      _isExpandedContext = true;
    }
  }

  /// Mode-specific page count (excludes the shared setup step).
  int get _contentPageCount => _entryMode == _EntryMode.manual
      ? ManualReflectionForm.totalPages
      : _guidedPageCount;

  /// Guided flow content pages: paste, review, confirm.
  static const int _guidedPageCount = 3;

  /// Progress-bar steps: the setup step plus the content pages.
  int get _totalSteps => 1 + _contentPageCount;

  /// Content page index for the active mode.
  int get _currentContentPage =>
      _entryMode == _EntryMode.manual ? _currentManualPage : _currentGuidedPage;

  /// Global step: 0 is setup, 1.._contentPageCount are content pages.
  int get _globalStep => _inSetup ? 0 : 1 + _currentContentPage;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEditing = widget.reflectionToEdit != null;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isLastStep =
        !_inSetup && _currentContentPage == _contentPageCount - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: ReflectionStepScaffold(
        title: isEditing ? 'Edit Reflection' : 'New Kolb\'s Cycle',
        subtitle: _stepSubtitle(),
        currentStep: _globalStep,
        totalSteps: _totalSteps,
        onClose: _handleClose,
        onBack: _inSetup ? null : _goBack,
        onNext: isLastStep ? () => _handleSave(state) : _goNext,
        isLastStep: isLastStep,
        body: IndexedStack(
          sizing: StackFit.expand,
          index: _inSetup ? 0 : 1,
          children: [
            _buildSetupStep(state),
            _entryMode == _EntryMode.manual
                ? _buildManualPageView(state)
                : _buildGuidedPageView(keyboardHeight, state),
          ],
        ),
      ),
    );
  }

  /// AppBar subtitle: phase name (manual) + current step count.
  String _stepSubtitle() {
    if (_inSetup) return 'Setup · Step 1 of $_totalSteps';
    final stepCount = 'Step ${_globalStep + 1} of $_totalSteps';
    if (_entryMode == _EntryMode.manual) {
      final phase = ManualReflectionForm.getPhaseName(_currentManualPage);
      return '$phase · $stepCount';
    }
    return stepCount;
  }

  /// Shared setup step (step 0): mode picker, target factor, follow-up.
  Widget _buildSetupStep(AppState state) {
    final colors = context.colors;
    final isEditing = widget.reflectionToEdit != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up your reflection',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose how to capture this Kolb\'s cycle and what it connects to.',
            style: TextStyle(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (widget.previousReflection != null && !isEditing) ...[
            _buildPreviousContextCard(),
            const SizedBox(height: AppSpacing.lg),
          ],

          _buildSectionLabel('Entry method'),
          const SizedBox(height: AppSpacing.sm),
          _buildModeCard(
            mode: _EntryMode.guided,
            icon: Icons.auto_awesome_rounded,
            title: 'Guided / Paste',
            description:
                'Paste a full Kolb\'s cycle and review the parsed sections.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildModeCard(
            mode: _EntryMode.manual,
            icon: Icons.edit_note_rounded,
            title: 'Manual entry',
            description: 'Answer one guided prompt per step, at your own pace.',
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildSectionLabel('Target factor'),
          const SizedBox(height: AppSpacing.sm),
          _buildFactorSelector(state),
          const SizedBox(height: AppSpacing.lg),

          _buildSectionLabel('Follow-up'),
          const SizedBox(height: AppSpacing.sm),
          _buildFollowUpCard(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final colors = context.colors;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: colors.textMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildModeCard({
    required _EntryMode mode,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = context.colors;
    final selected = _entryMode == mode;
    return GlassCard(
      margin: EdgeInsets.zero,
      highlighted: selected,
      onTap: _modeLocked ? null : () => setState(() => _entryMode = mode),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? colors.primary : colors.textMuted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selected ? colors.primary : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: selected ? colors.primary : colors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    final colors = context.colors;
    return GlassCard(
      margin: EdgeInsets.zero,
      onTap: () =>
          setState(() => _isCyclingFromExperiment = !_isCyclingFromExperiment),
      child: Row(
        children: [
          Icon(Icons.replay_rounded, color: colors.primary, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Follow-up from a previous cycle',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isCyclingFromExperiment
                      ? 'Yes — continuing a prior experiment'
                      : 'No — this is a new reflection',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCyclingFromExperiment,
            onChanged: (v) => setState(() => _isCyclingFromExperiment = v),
            activeTrackColor: colors.primary.withAlpha(128),
            activeThumbColor: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildManualPageView(AppState state) {
    return ManualReflectionForm(
      key: _manualFormKey,
      targetFactorId: _selectedFactorId,
      previousExperimentId: _previousExperimentId,
      isFollowUp: _isCyclingFromExperiment,
      initialReflection: widget.reflectionToEdit,
      initialExperimentText: _experimentsController.text,
      pageController: _manualPageController,
      onPageChanged: (page) => setState(() => _currentManualPage = page),
      onSave: (reflection) => _saveManualReflection(state, reflection),
      onChanged: () => _manualFormDirty = true,
    );
  }

  Widget _buildGuidedPageView(double keyboardHeight, AppState state) {
    return PageView(
      controller: _guidedPageController,
      onPageChanged: (page) => setState(() => _currentGuidedPage = page),
      children: [
        _buildGuidedPage0(), // Paste
        _buildGuidedPage2(keyboardHeight), // Review
        _buildGuidedPage3(keyboardHeight, state), // Confirm
      ],
    );
  }

  PageController get _activePageController => _entryMode == _EntryMode.manual
      ? _manualPageController
      : _guidedPageController;

  void _goNext() {
    if (_inSetup) {
      FocusScope.of(context).unfocus();
      setState(() {
        _inSetup = false;
        _modeLocked = true;
      });
      return;
    }
    _activePageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentContentPage == 0) {
      FocusScope.of(context).unfocus();
      setState(() => _inSetup = true);
      return;
    }
    _activePageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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

  Widget _buildGuidedPage0() {
    final colors = context.colors;
    final hasContent = _markdownController.text.trim().isNotEmpty;
    final showHero = !hasContent && !_pasteEditorActive;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paste Gemini Output',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Drop in the full Kolb\'s cycle from Gemini below.',
            style: TextStyle(color: colors.textMuted),
          ),
          const SizedBox(height: 10),
          _buildFormatLink(),
          const SizedBox(height: 18),
          Expanded(child: showHero ? _buildPasteHero() : _buildPasteEditor()),
        ],
      ),
    );
  }

  /// Rebuilds on focus change; drops back to the hero when the editor is
  /// blurred while empty so the paste CTA returns.
  void _onMarkdownFocusChange() {
    if (!_markdownFocusNode.hasFocus &&
        _markdownController.text.trim().isEmpty) {
      _pasteEditorActive = false;
    }
    if (mounted) setState(() {});
  }

  /// Switches the paste page to the editable text area and focuses it.
  void _activatePasteEditor() {
    setState(() => _pasteEditorActive = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markdownFocusNode.requestFocus();
    });
  }

  /// Reads the system clipboard into the markdown field and parses it.
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Clipboard is empty — copy your Gemini output first.',
            ),
          ),
        );
      }
      return;
    }
    _markdownController.text = text;
    setState(() => _pasteEditorActive = true);
    _parseMarkdown(text);
  }

  /// Clears the pasted text and returns to the drop-zone hero.
  void _clearMarkdown() {
    _markdownFocusNode.unfocus();
    setState(() {
      _markdownController.clear();
      _pasteEditorActive = false;
    });
  }

  /// "View expected format" link under the page subtitle.
  Widget _buildFormatLink() {
    final colors = context.colors;
    return InkWell(
      onTap: _showFormatSheet,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              'View expected format',
              style: TextStyle(
                color: colors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: colors.primary.withAlpha(110),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state — dashed drop-zone with a clipboard CTA.
  Widget _buildPasteHero() {
    final colors = context.colors;
    return GestureDetector(
      onTap: _activatePasteEditor,
      child: _DashedBorderBox(
        radius: AppRadius.xl,
        color: colors.primary.withAlpha(90),
        fillColor: colors.primary.withAlpha(12),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: 46,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Paste your Gemini output',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'The Kolb sections are split out automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste_go_rounded, size: 18),
                  label: const Text('Paste from clipboard'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _activatePasteEditor,
                  child: Text(
                    'or type it manually',
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Filled state — editable text area with live parse feedback.
  Widget _buildPasteEditor() {
    final colors = context.colors;
    final hasContent = _markdownController.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TextField(
            controller: _markdownController,
            focusNode: _markdownFocusNode,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: 'Paste the complete Gemini Kolb\'s output here…',
              hintStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.surfaceLight,
              contentPadding: const EdgeInsets.all(14),
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
            ),
            onChanged: _parseMarkdown,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: hasContent
                  ? _buildParsedStatusIndicator()
                  : _buildEditorHint(),
            ),
            if (hasContent) ...[
              const SizedBox(width: 6),
              TextButton(onPressed: _clearMarkdown, child: const Text('Clear')),
            ],
          ],
        ),
      ],
    );
  }

  /// Subtle hint shown under an empty (but active) editor.
  Widget _buildEditorHint() {
    final colors = context.colors;
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 15, color: colors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Sections are detected automatically as you paste.',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Opens the bottom sheet documenting the expected paste format.
  void _showFormatSheet() {
    FocusScope.of(context).unfocus();
    BottomSheetWrapper.show(
      context: context,
      title: 'Expected format',
      child: _buildFormatSheetContent(),
    );
  }

  Widget _buildFormatSheetContent() {
    final colors = context.colors;
    const rows = [
      ['# Cycle Info', '- **Factor:** [Name]'],
      ['# Experience', '[text]'],
      ['# Reflection', '[text]'],
      ['# Abstraction', '[text]'],
      ['# Experiments', '- [item]'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paste output from Gemini that follows this structure. '
          'Headings are matched automatically.',
          style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                _buildFormatRow(
                  rows[i][0],
                  rows[i][1],
                  isLast: i == rows.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _copyTemplate,
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy empty template'),
        ),
      ],
    );
  }

  Widget _buildFormatRow(
    String heading,
    String placeholder, {
    required bool isLast,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.glassBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              heading,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              placeholder,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Copies an empty Kolb's-cycle skeleton to the clipboard.
  void _copyTemplate() {
    const template =
        '# Cycle Info\n'
        '- **Factor:** \n\n'
        '# Experience\n\n\n'
        '# Reflection\n\n\n'
        '# Abstraction\n\n\n'
        '# Experiments\n- ';
    Clipboard.setData(const ClipboardData(text: template));
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empty template copied to clipboard.')),
      );
    }
  }

  Widget _buildGuidedPage2(double keyboardHeight) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Edit',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Review the extracted fields below. Edit if needed.',
            style: TextStyle(color: colors.textMuted),
          ),
          const SizedBox(height: 20),

          _buildFieldWithLabel('Experience', _experienceController, 3),
          const SizedBox(height: 16),

          _buildFieldWithLabel('Reflection', _reflectionController, 4),
          const SizedBox(height: 16),

          _buildFieldWithLabel('Abstraction', _abstractionController, 4),
          const SizedBox(height: 16),

          _buildFieldWithLabel(
            'Experiments (one per line)',
            _experimentsController,
            4,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidedPage3(double keyboardHeight, AppState state) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 100),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm & Save',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Review the summary before saving.',
            style: TextStyle(color: colors.textMuted),
          ),
          const SizedBox(height: 20),

          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedFactorId != null) ...[
                  _buildSummaryRow(
                    'Factor',
                    state.factors
                        .firstWhere(
                          (f) => f.id == _selectedFactorId,
                          orElse: () => state.factors.first,
                        )
                        .name,
                  ),
                  const SizedBox(height: 8),
                ],

                if (_isCyclingFromExperiment)
                  _buildSummaryRow('Cycling', '♻️ Follow-up from previous'),

                const Divider(height: 24),

                _buildSummaryRow(
                  'Experience',
                  _experienceController.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),

                _buildSummaryRow(
                  'Reflection',
                  _reflectionController.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),

                _buildSummaryRow(
                  'Abstraction',
                  _abstractionController.text,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),

                _buildSummaryRow(
                  'Experiments',
                  '${_experimentsController.text.split('\n').where((l) => l.trim().isNotEmpty).length} experiment(s)',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ready to save! Tap Save below.',
                    style: TextStyle(
                      color: colors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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

  Widget _buildFieldWithLabel(
    String label,
    TextEditingController controller,
    int lines,
  ) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: lines,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousContextCard() {
    final colors = context.colors;
    final prev = widget.previousReflection!;
    return GestureDetector(
      onTap: () => setState(() => _isExpandedContext = !_isExpandedContext),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_edu_rounded,
                  size: 16,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cycling from previous...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.textMuted,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpandedContext ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
            if (_isExpandedContext) ...[
              const SizedBox(height: 8),
              Text(
                'Experience:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                prev.experience,
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFactorSelector(AppState state) {
    final colors = context.colors;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withAlpha(30)
                      : colors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  f.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (state.factors.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '⚠️ Add Factors in Strategy first',
              style: TextStyle(color: colors.warning),
            ),
          ),
      ],
    );
  }

  Widget _buildParsedStatusIndicator() {
    final colors = context.colors;
    final hasExperience = _experienceController.text.isNotEmpty;
    final hasReflection = _reflectionController.text.isNotEmpty;
    final hasAbstraction = _abstractionController.text.isNotEmpty;
    final hasExperiments = _experimentsController.text.isNotEmpty;
    final parsedCount = [
      hasExperience,
      hasReflection,
      hasAbstraction,
      hasExperiments,
    ].where((b) => b).length;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: parsedCount >= 3
            ? colors.success.withAlpha(20)
            : colors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            parsedCount >= 3 ? Icons.check_circle_rounded : Icons.info_rounded,
            color: parsedCount >= 3 ? colors.success : colors.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              parsedCount >= 3
                  ? '✓ Parsed $parsedCount/4 sections. Swipe to continue.'
                  : 'Parsed $parsedCount/4 sections. Check format.',
              style: TextStyle(
                color: parsedCount >= 3 ? colors.success : colors.warning,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {int maxLines = 1}) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '(empty)' : value,
            style: TextStyle(
              color: value.isEmpty ? colors.textMuted : colors.textPrimary,
              fontSize: 12,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    if (_manualFormDirty ||
        _experienceController.text.isNotEmpty ||
        _reflectionController.text.isNotEmpty) {
      return await showDialog(
            context: context,
            builder: (dialogContext) {
              final colors = dialogContext.colors;
              return AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text('You have unsaved changes. Discard them?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Keep Editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      'Discard',
                      style: TextStyle(color: colors.danger),
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;
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
        linkedFactorIds: _selectedFactorId == null
            ? const []
            : [_selectedFactorId!],
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
        final experimentIds = await _createExperimentsOnly(
          state,
          newReflection.id,
          reflection.rawMarkdown!,
        );
        newReflection.experimentIds.addAll(experimentIds);
      }

      await state.addLinkedReflection(
        newReflection,
        previousReflection: widget.previousReflection,
      );
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
        final experimentIds = await _createExperimentsOnly(
          state,
          newReflection.id,
          reflection.rawMarkdown!,
        );
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
        rawMarkdown: _markdownController.text.isNotEmpty
            ? _markdownController.text
            : null,
        targetFactorId: _selectedFactorId,
        linkedFactorIds: _selectedFactorId == null
            ? const []
            : [_selectedFactorId!],
      );
      await state.updateReflection(updated);
      await _syncExperiments(state, updated.id, _experimentsController.text);
    } else {
      final newReflection = _createReflectionObject(
        _experienceController.text,
        _reflectionController.text,
        _abstractionController.text,
        _markdownController.text.isNotEmpty ? _markdownController.text : null,
      );

      final experimentIds = await _createExperimentsOnly(
        state,
        newReflection.id,
        _experimentsController.text,
      );
      newReflection.experimentIds.addAll(experimentIds);

      if (widget.previousReflection != null) {
        await state.addLinkedReflection(
          newReflection,
          previousReflection: widget.previousReflection,
        );
      } else {
        await state.addReflection(newReflection);
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<List<String>> _createExperimentsOnly(
    AppState state,
    String reflectionId,
    String text,
  ) async {
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

  Future<void> _syncExperiments(
    AppState state,
    String reflectionId,
    String text,
  ) async {
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
    final factorMatch = RegExp(
      r'\*\*Factor:\*\*\s*(.+)',
      caseSensitive: false,
    ).firstMatch(markdown);
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

    final cycleIdMatch = RegExp(
      r'\*\*Previous Cycle ID:\*\*\s*(.+)',
      caseSensitive: false,
    ).firstMatch(markdown);
    if (cycleIdMatch != null) {
      final id = cycleIdMatch.group(1)?.trim() ?? '';
      if (id.isNotEmpty && id.toLowerCase() != 'none') {
        _previousExperimentId = id;
        _isCyclingFromExperiment = true;
      }
    }

    final expMatch = RegExp(
      r'#\s*Experience\s*\n(.*?)(?=#|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(markdown);
    if (expMatch != null) {
      _experienceController.text = expMatch.group(1)?.trim() ?? '';
    }

    final refMatch = RegExp(
      r'#\s*Reflection\s*\n(.*?)(?=#|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(markdown);
    if (refMatch != null) {
      _reflectionController.text = refMatch.group(1)?.trim() ?? '';
    }

    final absMatch = RegExp(
      r'#\s*Abstraction\s*\n(.*?)(?=#|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(markdown);
    if (absMatch != null) {
      _abstractionController.text = absMatch.group(1)?.trim() ?? '';
    }

    final expsMatch = RegExp(
      r'#\s*Experiments?\s*\n(.*?)(?=#|$)',
      dotAll: true,
      caseSensitive: false,
    ).firstMatch(markdown);
    if (expsMatch != null) {
      _experimentsController.text = expsMatch.group(1)?.trim() ?? '';
    }

    setState(() {});
  }
}

/// Rounded rectangle with a dashed stroke — the guided paste drop-zone.
class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color fillColor;
  final double radius;

  const _DashedBorderBox({
    required this.child,
    required this.color,
    required this.fillColor,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        fillColor: fillColor,
        radius: radius,
      ),
      child: SizedBox.expand(child: child),
    );
  }
}

/// Paints a rounded-rect fill plus a dashed stroke along its perimeter.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double radius;

  static const double _dashLength = 6;
  static const double _gapLength = 5;
  static const double _strokeWidth = 1.6;

  _DashedBorderPainter({
    required this.color,
    required this.fillColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    final stroke = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          stroke,
        );
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.radius != radius;
}
