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
import 'screens/statistics/statistics_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/category_management_screen.dart';
import 'screens/settings/data_management_screen.dart';
import 'screens/profile/badge_gallery_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/archive/archived_items_screen.dart';
import 'screens/audit/audit_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/achievement_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await StorageService.initialize();
  } catch (e) {
    debugPrint('Hive init failed: $e');
    try {
      await StorageService.reopenBoxes();
    } catch (e2) {
      debugPrint('Hive reopen also failed: $e2');
    }
  }

  if (!StorageService.isInitialized) {
    try {
      await StorageService.reopenBoxes();
    } catch (e) {
      debugPrint('Failed to reopen boxes: $e');
    }
  }

  try {
    await NotificationService.initialize();
    await NotificationService.requestPermission();
    await NotificationService.requestExactAlarmPermissionIfNeeded();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _precacheTreeAssets();
    });
  }

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const MainNavigationShell();
  }
}

/// Main navigation shell — 5 persistent tabs (Today / Plan / Habits / Grow / You).
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  AppState? _listenedAppState;
  late final VoidCallback _achievementListener;

  static const List<Widget> _tabs = [
    TodayScreen(),
    _PlanShell(),
    HabitsListScreen(),
    _GrowShell(),
    _YouShell(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.today_outlined),
      selectedIcon: Icon(Icons.today_rounded),
      label: 'Today',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag_rounded),
      label: 'Plan',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield_rounded),
      label: 'Habits',
    ),
    NavigationDestination(
      icon: Icon(Icons.eco_outlined),
      selectedIcon: Icon(Icons.eco_rounded),
      label: 'Grow',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'You',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _achievementListener = () => _listenedAppState?.scheduleAchievementCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_listenedAppState == state) return;
    _listenedAppState?.removeListener(_achievementListener);
    _listenedAppState = state;
    _listenedAppState?.addListener(_achievementListener);
  }

  @override
  void dispose() {
    _listenedAppState?.removeListener(_achievementListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<AppState>(
      builder: (context, state, _) {
        return Stack(
          children: [
            Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: List.generate(
                  _tabs.length,
                  (index) => TickerMode(
                    enabled: index == _currentIndex,
                    child: _tabs[index],
                  ),
                ),
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                backgroundColor: colors.surface,
                indicatorColor: colors.primary.withAlpha(
                  context.isDarkMode ? 71 : 51,
                ),
                destinations: _destinations,
                labelBehavior:
                    MediaQuery.sizeOf(context).width < 390
                    ? NavigationDestinationLabelBehavior.onlyShowSelected
                    : NavigationDestinationLabelBehavior.alwaysShow,
              ).animate().fadeIn(duration: AppMotion.expressive),
            ),
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

/// Plan tab — Strategy + Tasks under a segmented control.
class _PlanShell extends StatefulWidget {
  const _PlanShell();

  @override
  State<_PlanShell> createState() => _PlanShellState();
}

class _PlanShellState extends State<_PlanShell> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    return _SegmentedShell(
      labels: const ['Strategy', 'Tasks'],
      index: _section,
      onChanged: (i) => setState(() => _section = i),
      children: const [StrategyScreen(), TasksScreen()],
    );
  }
}

/// Grow tab — Reflect / Review / Insights under a segmented control.
class _GrowShell extends StatefulWidget {
  const _GrowShell();

  @override
  State<_GrowShell> createState() => _GrowShellState();
}

class _GrowShellState extends State<_GrowShell> {
  int _section = 0;

  @override
  Widget build(BuildContext context) {
    return _SegmentedShell(
      labels: const ['Reflect', 'Review', 'Insights'],
      index: _section,
      onChanged: (i) => setState(() => _section = i),
      children: const [
        ReflectionScreen(),
        SpacedRepetitionScreen(),
        StatisticsScreen(),
      ],
    );
  }
}

/// You tab — list-based root for settings, profile, shop, etc.
class _YouShell extends StatelessWidget {
  const _YouShell();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('You'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _YouTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            page: const SettingsScreen(),
          ),
          _YouTile(
            icon: Icons.label_outline_rounded,
            label: 'Categories',
            page: const CategoryManagementScreen(),
          ),
          _YouTile(
            icon: Icons.emoji_events_outlined,
            label: 'Badges',
            page: const BadgeGalleryScreen(),
          ),
          _YouTile(
            icon: Icons.storefront_outlined,
            label: 'Shop',
            page: const ShopScreen(),
          ),
          _YouTile(
            icon: Icons.archive_outlined,
            label: 'Archive',
            page: const ArchivedItemsScreen(),
          ),
          _YouTile(
            icon: Icons.fact_check_outlined,
            label: 'Audit',
            page: const AuditScreen(),
          ),
          _YouTile(
            icon: Icons.storage_outlined,
            label: 'Data Management',
            page: const DataManagementScreen(),
          ),
        ],
      ),
    );
  }
}

class _YouTile extends StatelessWidget {
  const _YouTile({
    required this.icon,
    required this.label,
    required this.page,
  });

  final IconData icon;
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      leading: Icon(icon, color: colors.textSecondary),
      title: Text(label, style: TextStyle(color: colors.textPrimary)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.textMuted,
      ),
      onTap: () => Navigator.of(context).push(
        _sharedAxisRoute(page),
      ),
    );
  }
}

/// Segmented control above a cross-faded child stack. Used by Plan + Grow shells.
class _SegmentedShell extends StatelessWidget {
  const _SegmentedShell({
    required this.labels,
    required this.index,
    required this.onChanged,
    required this.children,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _SegmentedBar(
                labels: labels,
                index: index,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.standard,
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(index),
                  child: children[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  const _SegmentedBar({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: AppMotion.micro,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? colors.onPrimary : colors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Hand-rolled shared-axis (X) push route for within-tab navigation.
PageRouteBuilder<T> _sharedAxisRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: AppMotion.expressive,
    reverseTransitionDuration: AppMotion.standard,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slideIn = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(fadeIn);
      return FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(position: slideIn, child: child),
      );
    },
  );
}
