import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../providers/theme_provider.dart';
import 'category_management_screen.dart';
import 'data_management_screen.dart';

/// Settings screen with app configuration links
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categories Section
          _SectionHeader(title: 'Organization', textColor: colors.textSecondary),
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
          const SizedBox(height: 24),

          // Data Section
          _SectionHeader(title: 'Data', textColor: colors.textSecondary),
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
          _SectionHeader(title: 'Appearance', textColor: colors.textSecondary),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: themeProvider.themeModeIcon,
            title: 'Theme',
            subtitle: themeProvider.themeModeDisplayName,
            trailing: Switch(
              value: themeProvider.themeMode == AppThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeTrackColor: AppColors.primary.withAlpha(128),
              thumbColor: WidgetStatePropertyAll(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About', textColor: colors.textSecondary),
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
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
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
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
