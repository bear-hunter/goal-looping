import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme.dart';
import 'providers/app_state.dart';
import 'services/storage_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/strategy/strategy_screen.dart';
import 'screens/habits/habits_screen.dart';
import 'screens/audit/audit_screen.dart';
import 'screens/reflection/reflection_screen.dart';
import 'models/achievement.dart';
import 'widgets/achievement_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  runApp(const MarginalGainsApp());
}

class MarginalGainsApp extends StatelessWidget {
  const MarginalGainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..loadData(),
      child: MaterialApp(
        title: 'Marginal Gains',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationShell(),
      ),
    );
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
    HomeScreen(),
    StrategyScreen(),
    HabitsScreen(),
    AuditScreen(),
    ReflectionScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag_rounded),
      label: 'Strategy',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield_rounded),
      label: 'Habits',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics_rounded),
      label: 'Audit',
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
    // Check achievements when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.addListener(() => state.checkAchievements());
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  border: Border(
                    top: BorderSide(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  backgroundColor: AppColors.surface,
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
