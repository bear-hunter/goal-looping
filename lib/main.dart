import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme.dart';
import 'providers/app_state.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/today/today_screen.dart';
import 'screens/strategy/strategy_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/habits/habits_list_screen.dart';
import 'screens/reflection/reflection_screen.dart';
import 'screens/spaced_repetition/spaced_repetition_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/achievement_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StorageService.initialize();
  } catch (e) {
    // Log the error but don't clear data - this preserves user data
    debugPrint('Hive init failed: $e');
    // Try to reinitialize without clearing data
    try {
      await StorageService.reopenBoxes();
    } catch (e2) {
      debugPrint('Hive reopen also failed: $e2');
      // Continue anyway - app may work with limited persistence
    }
  }

  // Ensure boxes are open (handles hot restart scenarios)
  if (!StorageService.isInitialized) {
    try {
      await StorageService.reopenBoxes();
    } catch (e) {
      debugPrint('Failed to reopen boxes: $e');
    }
  }

  // Initialize notifications
  try {
    await NotificationService.initialize();
    await NotificationService.requestPermission();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  runApp(const MarginalGainsApp());
}

class MarginalGainsApp extends StatelessWidget {
  const MarginalGainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..loadData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Centile',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.systemThemeMode,
            home: const AppRoot(),
          );
        },
      ),
    );
  }
}

/// Root widget that checks onboarding status
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showOnboarding = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer precaching until after first frame to improve Time to Interactive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheTreeAssets();
    });
  }

  /// Precache all tree assets to avoid loading delays
  /// This runs after the first frame to not block initial render
  void _precacheTreeAssets() {
    final treeTypes = ['oak', 'cherry', 'maple', 'pine', 'willow', 'baobab'];
    final stages = ['sprout', 'sapling', 'mature'];

    for (final tree in treeTypes) {
      for (final stage in stages) {
        precacheImage(
          AssetImage('assets/images/trees/${tree}_$stage.png'),
          context,
        );
      }
    }
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final hasCompleted = StorageService.hasCompletedOnboarding;
      setState(() {
        _showOnboarding = !hasCompleted;
        _isInitialized = true;
      });
    } catch (e) {
      // If error checking, skip onboarding
      setState(() {
        _showOnboarding = false;
        _isInitialized = true;
      });
    }
  }

  void _completeOnboarding() {
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading while checking onboarding status
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const MainNavigationShell();
  }
}

/// Main navigation shell with bottom navigation bar
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    StrategyScreen(),
    TasksScreen(),
    HabitsListScreen(),
    SpacedRepetitionScreen(),
    ReflectionScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.today_outlined),
      selectedIcon: Icon(Icons.today_rounded),
      label: 'Today',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag_rounded),
      label: 'Strategy',
    ),
    NavigationDestination(
      icon: Icon(Icons.checklist_outlined),
      selectedIcon: Icon(Icons.checklist_rounded),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield_rounded),
      label: 'Habits',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school_rounded),
      label: 'Review',
    ),
    NavigationDestination(
      icon: Icon(Icons.psychology_outlined),
      selectedIcon: Icon(Icons.psychology_rounded),
      label: 'Reflect',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Schedule initial achievement check after first frame
    // Using debounced check to prevent blocking UI during rapid state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      // Use debounced version to prevent O(N) checks on every notification
      state.addListener(() => state.scheduleAchievementCheck());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.glassBorder
        : LightColors.glassBorder;
    final navBarBgColor = isDark ? AppColors.surface : LightColors.surface;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Stack(
          children: [
            Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _screens[_currentIndex],
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor, width: 1)),
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  backgroundColor: navBarBgColor,
                  indicatorColor: AppColors.primary.withAlpha(50),
                  destinations: _destinations,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            ),
            // Achievement notification overlay
            if (state.pendingAchievementNotifications.isNotEmpty)
              Container(
                color: Colors.black.withAlpha(180),
                child: AchievementNotification(
                  achievementId: state.pendingAchievementNotifications.first,
                  onDismiss: () => state.clearAchievementNotification(
                    state.pendingAchievementNotifications.first,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
