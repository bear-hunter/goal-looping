import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../models/category_model.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';
import '../settings/category_wizard.dart';

/// Onboarding screen with introduction to the app's key features
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 5 informational pages + 1 interactive categories page.
  static const int _pageCount = 6;

  List<OnboardingPage> _buildPages(AppColorsTheme colors) => [
    OnboardingPage(
      icon: Icons.flag_rounded,
      iconColor: colors.warning,
      title: 'Set Your Direction',
      subtitle: 'Define your goal and break it down into actionable growth areas.',
      description: 'Start with a clear vision of where you want to go. Your goal becomes your anchor for everything else.',
    ),
    OnboardingPage(
      icon: Icons.task_alt_rounded,
      iconColor: colors.primary,
      title: 'Focus on What Matters',
      subtitle: 'Limit yourself to just 2 priority tasks at a time.',
      description: 'Avoid overwhelm by focusing on the most impactful tasks. Complete them before adding more.',
    ),
    OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      iconColor: colors.success,
      title: 'Build Better Habits',
      subtitle: 'Track behaviors that support or hinder your goals.',
      description: 'Build positive habits and identify limiting ones. Log daily with mood and barrier tracking.',
    ),
    OnboardingPage(
      icon: Icons.psychology_rounded,
      iconColor: colors.info,
      title: 'Reflect & Improve',
      subtitle: 'Use the Kolb learning cycle to grow continuously.',
      description: 'Experience → Reflect → Conceptualize → Experiment. Turn insights into actionable experiments.',
    ),
    OnboardingPage(
      icon: Icons.emoji_events_rounded,
      iconColor: colors.warning,
      title: 'Earn Rewards',
      subtitle: 'Gain XP for completing tasks and maintaining streaks.',
      description: 'Level up, unlock achievements, and spend coins in the shop. Make progress feel rewarding!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await StorageService.setOnboardingComplete(true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dataPages = _buildPages(colors);
    // The categories page is spliced in after "Build Better Habits".
    final pages = <Widget>[
      _buildPage(dataPages[0], 0, colors),
      _buildPage(dataPages[1], 1, colors),
      _buildPage(dataPages[2], 2, colors),
      _buildCategoryPage(colors),
      _buildPage(dataPages[3], 4, colors),
      _buildPage(dataPages[4], 5, colors),
    ];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _currentPage < pages.length - 1
                    ? TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return pages[index];
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? colors.primary
                          : colors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _currentPage < pages.length - 1 ? 'Continue' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index, AppColorsTheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.iconColor.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(
                color: page.iconColor.withAlpha(60),
                width: 3,
              ),
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.iconColor,
            ),
          ).animate(delay: 100.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: page.iconColor,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: colors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  /// Interactive onboarding page: previews the seeded default categories and
  /// lets the user add one immediately via [CategoryWizard].
  Widget _buildCategoryPage(AppColorsTheme colors) {
    final categories = context.watch<AppState>().categories;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withAlpha(60),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.category_rounded,
                size: 56,
                color: colors.primary,
              ),
            ).animate(delay: 100.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 40),
            Text(
              'Organize with Categories',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(
              begin: 0.2,
              end: 0,
            ),
            const SizedBox(height: 12),
            Text(
              'These are your starting categories — add or edit anytime in Settings.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(
              begin: 0.2,
              end: 0,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories)
                  _categoryChip(category, colors),
              ],
            ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => CategoryWizard.show(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add your own'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(CategoryModel category, AppColorsTheme colors) {
    final color = Color(category.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(fontSize: 13, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
