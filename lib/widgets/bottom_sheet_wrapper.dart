import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// A reusable wrapper for bottom sheets with consistent styling.
/// 
/// Provides:
/// - Theme-aware background color
/// - Standard top border radius
/// - Keyboard-aware padding
/// - Optional drag handle indicator
/// - Consistent padding and structure
/// 
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (ctx) => BottomSheetWrapper(
///     title: 'Add Task',
///     child: YourContent(),
///   ),
/// );
/// ```
class BottomSheetWrapper extends StatelessWidget {
  /// The main content of the bottom sheet
  final Widget child;
  
  /// Optional title displayed at the top
  final String? title;
  
  /// Whether to show the drag handle indicator
  final bool showHandle;
  
  /// Custom padding for the content area
  final EdgeInsetsGeometry? padding;
  
  /// Whether to add padding for keyboard
  final bool avoidKeyboard;
  
  /// Optional trailing widget in the header (e.g., close button)
  final Widget? trailing;
  
  /// Maximum height as fraction of screen (0.0 - 1.0)
  final double? maxHeightFraction;

  const BottomSheetWrapper({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
    this.avoidKeyboard = true,
    this.trailing,
    this.maxHeightFraction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = avoidKeyboard 
        ? MediaQuery.of(context).viewInsets.bottom 
        : 0.0;
    
    Widget content = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          if (showHandle)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          
          // Title row (if provided)
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          
          // Main content
          Flexible(
            child: Padding(
              padding: padding ?? EdgeInsets.fromLTRB(20, title != null ? 0 : 8, 20, 20 + bottomPadding),
              child: child,
            ),
          ),
        ],
      ),
    );
    
    // Apply max height constraint if specified
    if (maxHeightFraction != null) {
      final maxHeight = MediaQuery.of(context).size.height * maxHeightFraction!;
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: content,
      );
    }
    
    return content;
  }
  
  /// Shows this bottom sheet with standard configuration
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool avoidKeyboard = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeightFraction,
    Widget? trailing,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BottomSheetWrapper(
        title: title,
        showHandle: showHandle,
        avoidKeyboard: avoidKeyboard,
        maxHeightFraction: maxHeightFraction,
        trailing: trailing,
        child: child,
      ),
    );
  }
}

/// A simple handle bar widget for bottom sheets
/// 
/// Can be used standalone when you need more control over the sheet layout
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.textSecondary.withAlpha(100),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
