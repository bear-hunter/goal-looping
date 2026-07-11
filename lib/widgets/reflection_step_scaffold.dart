import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// Shared chrome for the reflection composer flow (guided + manual modes).
///
/// Owns the themed [AppBar], a single top progress bar, and the bottom
/// Back / Next-Save bar. Page content is supplied via [body]. This is the one
/// navigation model both entry modes route through, so they stay consistent.
class ReflectionStepScaffold extends StatelessWidget {
  /// AppBar title.
  final String title;

  /// Optional second line under the title (phase name + step count).
  final String? subtitle;

  /// Current step, 0-based — drives the progress bar fill.
  final int currentStep;

  /// Total steps in the active flow.
  final int totalSteps;

  /// Close (X) handler.
  final VoidCallback onClose;

  /// Back handler. When null the Back button is hidden (first step).
  final VoidCallback? onBack;

  /// Next/Save handler. When null the primary button is disabled (gating).
  final VoidCallback? onNext;

  /// When true the primary button reads "Save" instead of "Next".
  final bool isLastStep;

  /// When true the primary button shows a spinner and is non-interactive.
  final bool isSaving;

  /// Page content (toggle, context card, PageView, ...).
  final Widget body;

  const ReflectionStepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    required this.onClose,
    this.onBack,
    this.onNext,
    required this.isLastStep,
    this.isSaving = false,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (subtitle != null && subtitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textMuted,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _ProgressBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
            ),
            Expanded(child: body),
            _BottomNav(
              onBack: onBack,
              onNext: onNext,
              isLastStep: isLastStep,
              isSaving: isSaving,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single top progress bar — pill track with an animated fill.
class _ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = totalSteps == 0
        ? 0.0
        : ((currentStep + 1) / totalSteps).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              height: 4,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Bottom navigation bar — Back (hidden on first step) + Next/Save.
class _BottomNav extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isLastStep;
  final bool isSaving;

  const _BottomNav({
    required this.onBack,
    required this.onNext,
    required this.isLastStep,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.glassBorder)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: isSaving ? null : onNext,
            icon: isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : Icon(
                    isLastStep
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
            label: Text(isLastStep ? 'Save' : 'Next'),
          ),
        ],
      ),
    );
  }
}
