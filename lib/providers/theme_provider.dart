import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme mode options for the app
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _settingsBox = 'settings';
  
  AppThemeMode _themeMode = AppThemeMode.dark; // Default to dark
  
  AppThemeMode get themeMode => _themeMode;
  
  ThemeMode get systemThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
  
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  /// Initialize theme from saved preferences
  Future<void> initialize() async {
    try {
      if (Hive.isBoxOpen(_settingsBox)) {
        final box = Hive.box(_settingsBox);
        final savedMode = box.get(_themeKey) as String?;
        if (savedMode != null) {
          _themeMode = AppThemeMode.values.firstWhere(
            (e) => e.name == savedMode,
            orElse: () => AppThemeMode.dark,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Use default theme if loading fails
      debugPrint('Failed to load theme preference: $e');
    }
  }
  
  /// Set theme mode and persist
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      if (Hive.isBoxOpen(_settingsBox)) {
        final box = Hive.box(_settingsBox);
        await box.put(_themeKey, mode.name);
      }
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }
  
  /// Toggle between light and dark (skipping system for simplicity)
  Future<void> toggleTheme() async {
    await setThemeMode(_themeMode == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark);
  }
  
  /// Cycle through all theme modes
  Future<void> cycleThemeMode() async {
    final modes = AppThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }
  
  /// Get display name for current theme mode
  String get themeModeDisplayName {
    switch (_themeMode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
  
  /// Get icon for current theme mode
  IconData get themeModeIcon {
    switch (_themeMode) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }
}
