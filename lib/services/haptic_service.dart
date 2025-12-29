import 'package:flutter/services.dart';

/// Utility class for providing haptic feedback throughout the app.
/// Uses platform haptics for a native feel.
class HapticService {
  /// Light haptic for small interactions like taps, toggles
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic for confirmations, selections
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic for important actions like deletions, completions
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic for UI element selections (tabs, chips)
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Success feedback - for completed tasks, achievements
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error/warning feedback
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Vibration pattern for achievements/celebrations
  static void celebrate() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }
}
