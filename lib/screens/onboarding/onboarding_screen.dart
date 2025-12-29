import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/theme.dart';
import '../../services/storage_service.dart';

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

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.flag_rounded,
      iconColor: AppColors.warning,
      title: 'Set Your Direction',
      subtitle: 'Define your goal and break it down into actionable growth areas.',
      description: 'Start with a clear vision of where you want to go. Your goal becomes your anchor for everything else.',
    ),
    OnboardingPage(
      icon: Icons.task_alt_rounded,
      iconColor: AppColors.primary,
      title: 'Focus on What Matters',
      subtitle: 'Limit yourself to just 2 priority tasks at a time.',
      description: 'Avoid overwhelm by focusing on the most impactful tasks. Complete them before adding more.',
    ),
    OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.success,
      title: 'Build Better Habits',
      subtitle: 'Track behaviors that support or hinder your goals.',
      description: 'Build positive habits and identify limiting ones. Log daily with mood and barrier tracking.',
    ),
    OnboardingPage(
      icon: Icons.psychology_rounded,
      iconColor: AppColors.info,
      title: 'Reflect & Improve',
      subtitle: 'Use the Kolb learning cycle to grow continuously.',
      description: 'Experience → Reflect → Conceptualize → Experiment. Turn insights into actionable experiments.',
    ),
    OnboardingPage(
      icon: Icons.emoji_events_rounded,
      iconColor: AppColors.warning,
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
    if (_currentPage < _pages.length - 1) {
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
      _pages.length - 1,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _currentPage < _pages.length - 1
                    ? TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textMuted,
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
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.surfaceLight,
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
                    _currentPage < _pages.length - 1 ? 'Continue' : 'Get Started',
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

  Widget _buildPage(OnboardingPage page, int index) {
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
              color: AppColors.textPrimary,
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
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
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
