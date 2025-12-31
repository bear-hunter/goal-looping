import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/app_state.dart';
import 'category_management_screen.dart';
import 'category_wizard.dart';
import 'data_management_screen.dart';

/// Settings screen with app configuration links
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.background : LightColors.background;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categories Section
          _SectionHeader(title: 'Organization', textColor: textSecondary),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.category_rounded,
            title: 'Categories',
            subtitle: 'Manage habit and task categories',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoryManagementScreen(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.add_circle_outline_rounded,
            title: 'New Category',
            subtitle: 'Create a custom category',
            onTap: () => CategoryWizard.show(context),
          ),
          const SizedBox(height: 24),

          // Data Section
          _SectionHeader(title: 'Data', textColor: textSecondary),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.storage_rounded,
            title: 'Data Management',
            subtitle: 'Export, backup, and restore',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DataManagementScreen()),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _SectionHeader(title: 'Appearance', textColor: textSecondary),
          const SizedBox(height: 8),
          Consumer<AppState>(
            builder: (context, state, _) => _SettingsTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'Theme',
              subtitle: isDark ? 'Dark mode' : 'Light mode',
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  // Toggle theme - this would need theme provider support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme toggle coming soon!')),
                  );
                },
                activeColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About', textColor: textSecondary),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About Goal Loop',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Goal Loop',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Goal Loop',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A productivity app combining habit tracking, task management, and goal setting.',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondary
        : LightColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: textSecondary),
          ],
        ),
      ),
    );
  }
}
