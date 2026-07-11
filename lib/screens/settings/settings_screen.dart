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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categories Section
          _SectionHeader(
            title: 'Organization',
            textColor: colors.textSecondary,
          ),
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
          const SizedBox(height: 8),

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
              activeTrackColor: colors.primary.withAlpha(128),
              thumbColor: WidgetStatePropertyAll(colors.primary),
            ),
          ),
          const SizedBox(height: 8),

          // About Section
          _SectionHeader(title: 'About', textColor: colors.textSecondary),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About Goal Loop',
            subtitle: 'Version 2.0.5',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.glassBorder.withAlpha(40),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: colors.primary, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textSecondary,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}
