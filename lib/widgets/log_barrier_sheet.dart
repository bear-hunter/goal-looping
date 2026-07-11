import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/theme/theme.dart';
import '../models/barrier_tag.dart';
import '../models/habit.dart';
import '../providers/app_state.dart';

/// Shared bottom sheet to create or edit a [BarrierEntry].
///
/// Used by the Barriers screen and the habit Defense tab. Captures a required
/// tag, an optional free-text note (kept separate from the tag), optional
/// habit/task links, an editable (back-datable) date, an optional response,
/// and an explicit handled toggle that is decoupled from the response.
class LogBarrierSheet extends StatefulWidget {
  final BarrierEntry? existing;
  final String? presetHabitId;
  final String? presetTaskId;

  const LogBarrierSheet({
    super.key,
    this.existing,
    this.presetHabitId,
    this.presetTaskId,
  });

  static Future<void> show(
    BuildContext context, {
    BarrierEntry? existing,
    String? presetHabitId,
    String? presetTaskId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LogBarrierSheet(
        existing: existing,
        presetHabitId: presetHabitId,
        presetTaskId: presetTaskId,
      ),
    );
  }

  @override
  State<LogBarrierSheet> createState() => _LogBarrierSheetState();
}

class _LogBarrierSheetState extends State<LogBarrierSheet> {
  String? _tagKey;
  late final TextEditingController _noteController;
  late final TextEditingController _responseController;
  late DateTime _date;
  String? _linkedHabitId;
  String? _linkedTaskId;
  bool _wasHandled = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tagKey = e?.tag;
    _noteController = TextEditingController(text: e?.note ?? '');
    _responseController = TextEditingController(text: e?.response ?? '');
    _date = e?.occurredAt ?? DateTime.now();
    _linkedHabitId = e?.linkedHabitId ?? widget.presetHabitId;
    _linkedTaskId = e?.linkedTaskId ?? widget.presetTaskId;
    _wasHandled = e?.wasHandled ?? false;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(
        () => _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  void _save() {
    final tag = _tagKey;
    if (tag == null) return;
    final state = context.read<AppState>();
    final note = _noteController.text.trim();
    final response = _responseController.text.trim();
    final existing = widget.existing;
    if (existing != null) {
      existing.tag = tag;
      existing.note = note.isEmpty ? null : note;
      existing.occurredAt = _date;
      existing.linkedHabitId = _linkedHabitId;
      existing.linkedTaskId = _linkedTaskId;
      existing.response = response.isEmpty ? null : response;
      existing.wasHandled = _wasHandled;
      state.updateBarrier(existing);
    } else {
      state.addBarrier(
        BarrierEntry(
          id: const Uuid().v4(),
          occurredAt: _date,
          tag: tag,
          note: note.isEmpty ? null : note,
          linkedHabitId: _linkedHabitId,
          linkedTaskId: _linkedTaskId,
          response: response.isEmpty ? null : response,
          wasHandled: _wasHandled,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = context.watch<AppState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? 'Edit Barrier' : 'Log a Barrier',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Tag (required)
            _label('What got in the way?', colors, required: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final info in BarrierTags.all)
                  _TagChip(
                    info: info,
                    isSelected: _tagKey == info.key,
                    onTap: () => setState(() => _tagKey = info.key),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Note (optional)
            _label('Note (optional)', colors),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: _fieldDecoration(
                colors,
                'Add any extra detail...',
              ),
            ),
            const SizedBox(height: 20),

            // Date
            _label('When', colors),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEE, MMM d, y').format(_date),
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Habit link (optional)
            _label('Link to habit (optional)', colors),
            const SizedBox(height: 8),
            _LinkDropdown(
              value: _linkedHabitId,
              hint: 'No habit',
              items: [
                for (final h in state.habits) (h.id, h.name),
              ],
              onChanged: (v) => setState(() => _linkedHabitId = v),
            ),
            const SizedBox(height: 16),

            // Task link (optional)
            _label('Link to task (optional)', colors),
            const SizedBox(height: 8),
            _LinkDropdown(
              value: _linkedTaskId,
              hint: 'No task',
              items: [
                for (final t in state.tasks) (t.id, t.title),
              ],
              onChanged: (v) => setState(() => _linkedTaskId = v),
            ),
            const SizedBox(height: 20),

            // Response (optional)
            _label('How did you handle it? (optional)', colors),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              maxLines: 2,
              decoration: _fieldDecoration(
                colors,
                'What did you do to overcome it?',
              ),
            ),
            const SizedBox(height: 12),

            // Handled toggle (independent of the response text)
            SwitchListTile(
              value: _wasHandled,
              onChanged: (v) => setState(() => _wasHandled = v),
              title: Text(
                'Mark as handled',
                style: TextStyle(color: colors.textPrimary),
              ),
              activeThumbColor: colors.success,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _tagKey == null ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  disabledBackgroundColor: colors.surfaceLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_isEditing ? 'Save Changes' : 'Log Barrier'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, AppColorsTheme colors, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colors.danger),
            ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(AppColorsTheme colors, String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: colors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.glassBorder),
      ),
    );
  }
}

/// A selectable barrier tag chip (icon + label).
class _TagChip extends StatelessWidget {
  final BarrierTagInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = BarrierTags.resolveColor(context, info.key);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(38) : colors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? color : colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              info.icon,
              size: 15,
              color: isSelected ? color : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              info.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A styled dropdown for an optional habit/task link. [items] are (id, label)
/// pairs; a null selection means "not linked".
class _LinkDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;

  const _LinkDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Guard against a stale value that no longer matches any item.
    final safeValue = items.any((e) => e.$1 == value) ? value : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.glassBorder),
      ),
      child: DropdownButton<String?>(
        value: safeValue,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: Text(hint, style: TextStyle(color: colors.textMuted)),
        dropdownColor: colors.surface,
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(hint, style: TextStyle(color: colors.textMuted)),
          ),
          for (final (id, label) in items)
            DropdownMenuItem<String?>(
              value: id,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
