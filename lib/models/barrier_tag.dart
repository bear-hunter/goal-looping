import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

/// Metadata for a single barrier tag: a stable storage [key], a human-readable
/// [label], and an [icon]. Only the [key] is persisted (on `BarrierEntry.tag`);
/// labels and icons are presentation and may evolve freely.
class BarrierTagInfo {
  final String key;
  final String label;
  final IconData icon;

  const BarrierTagInfo({
    required this.key,
    required this.label,
    required this.icon,
  });
}

/// Canonical set of barrier tags plus lookup, color and migration helpers.
///
/// This is the single source of truth for barrier tags — it replaces the old
/// free-text `common` string list and the three divergent `_getBarrierColor`
/// switches that used to live in the barrier screens.
class BarrierTags {
  /// The nine canonical tags. `other` is always last (the fallback).
  static const List<BarrierTagInfo> all = [
    BarrierTagInfo(key: 'tired', label: 'Tired', icon: Icons.bedtime_rounded),
    BarrierTagInfo(
      key: 'no_time',
      label: 'No Time',
      icon: Icons.timer_off_rounded,
    ),
    BarrierTagInfo(
      key: 'stressed',
      label: 'Stressed',
      icon: Icons.bolt_rounded,
    ),
    BarrierTagInfo(
      key: 'distracted',
      label: 'Distracted',
      icon: Icons.blur_on_rounded,
    ),
    BarrierTagInfo(
      key: 'unmotivated',
      label: 'Unmotivated',
      icon: Icons.battery_1_bar_rounded,
    ),
    BarrierTagInfo(key: 'sick', label: 'Sick', icon: Icons.sick_rounded),
    BarrierTagInfo(
      key: 'social_pressure',
      label: 'Social Pressure',
      icon: Icons.groups_rounded,
    ),
    BarrierTagInfo(
      key: 'forgot',
      label: 'Forgot',
      icon: Icons.psychology_alt_rounded,
    ),
    BarrierTagInfo(
      key: 'other',
      label: 'Other',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  /// The fallback tag (`other`).
  static BarrierTagInfo get other => all.last;

  /// Look up tag info by [key], falling back to the `other` tag for an
  /// unknown or null key.
  static BarrierTagInfo byKeyOrOther(String? key) =>
      all.firstWhere((t) => t.key == key, orElse: () => other);

  /// Map a legacy free-text label (an old free-text barrier string or a
  /// `HabitLog.barrierTag`) to a canonical tag key. Returns null when no tag
  /// matches, so callers can decide whether to fall back to `other`.
  static String? keyForLegacyLabel(String? label) {
    if (label == null) return null;
    final normalized = label.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final t in all) {
      if (t.key == normalized || t.label.toLowerCase() == normalized) {
        return t.key;
      }
    }
    return null;
  }

  /// Single source of truth for barrier tag colors.
  static Color resolveColor(BuildContext context, String? key) {
    final swatches = CategoryPalette.of(context);
    switch (key) {
      case 'tired':
        return swatches[2]; // wisteria
      case 'no_time':
        return swatches[3]; // sky
      case 'stressed':
        return swatches[4]; // wine
      case 'distracted':
        return swatches[1]; // amber bark
      case 'unmotivated':
        return swatches[0]; // moss
      case 'sick':
        return swatches[6]; // sage
      case 'social_pressure':
        return swatches[5]; // gold
      case 'forgot':
        return context.colors.info;
      default:
        return context.colors.textMuted; // 'other' + unknown keys
    }
  }
}
