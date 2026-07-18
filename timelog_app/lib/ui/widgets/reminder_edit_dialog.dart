import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/recurring_reminders_provider.dart';
import '../../services/active_days_utils.dart';
import 'day_selector.dart';
import 'reminder_form_data.dart';

/// Create/edit modal for a Recurring_Reminder (Requirement 2). Pass
/// [reminder] to pre-fill for editing; omit it to create a new reminder with
/// the spec's default values (08:00–00:00, 60 min, all days, active).
class ReminderEditDialog extends ConsumerStatefulWidget {
  final AppThemeData theme;
  final RecurringReminder? reminder;

  const ReminderEditDialog({
    super.key,
    required this.theme,
    this.reminder,
  });

  /// Shows the dialog. Tapping outside or pressing cancel while the form has
  /// unsaved changes prompts for confirmation before dismissing (Req 2.6).
  static Future<void> show(
    BuildContext context, {
    required AppThemeData theme,
    RecurringReminder? reminder,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Reminder edit dialog',
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ReminderEditDialog(theme: theme, reminder: reminder);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  ConsumerState<ReminderEditDialog> createState() => _ReminderEditDialogState();
}

class _ReminderEditDialogState extends ConsumerState<ReminderEditDialog> {
  static const _intervals = [30, 60, 120, 180, 240];

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _repeatInterval;
  late Set<int> _activeDays;
  late bool _isActive;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    if (reminder == null) {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 0, minute: 0);
      _repeatInterval = 60;
      _activeDays = {1, 2, 3, 4, 5, 6, 7};
      _isActive = true;
    } else {
      _nameController = TextEditingController(text: reminder.name);
      _descriptionController = TextEditingController(text: reminder.description ?? '');
      _startTime = _fromMinutes(reminder.startTime);
      _endTime = _fromMinutes(reminder.endTime);
      _repeatInterval = reminder.repeatInterval;
      _activeDays = decodeDays(reminder.activeDays);
      _isActive = reminder.isActive;
    }
  }

  static TimeOfDay _fromMinutes(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  ReminderFormData get _formData => ReminderFormData(
        name: _nameController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        repeatIntervalMinutes: _repeatInterval,
        activeDays: _activeDays,
        isActive: _isActive,
      );

  bool get _isOvernight =>
      _startTime.hour * 60 + _startTime.minute >= _endTime.hour * 60 + _endTime.minute;

  bool get _hasUnsavedChanges {
    final reminder = widget.reminder;
    if (reminder == null) {
      return _nameController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _startTime != const TimeOfDay(hour: 8, minute: 0) ||
          _endTime != const TimeOfDay(hour: 0, minute: 0) ||
          _repeatInterval != 60 ||
          !_setEquals(_activeDays, {1, 2, 3, 4, 5, 6, 7}) ||
          !_isActive;
    }
    return _nameController.text != reminder.name ||
        _descriptionController.text != (reminder.description ?? '') ||
        _startTime != _fromMinutes(reminder.startTime) ||
        _endTime != _fromMinutes(reminder.endTime) ||
        _repeatInterval != reminder.repeatInterval ||
        !_setEquals(_activeDays, decodeDays(reminder.activeDays)) ||
        _isActive != reminder.isActive;
  }

  static bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.every(b.contains);

  Future<void> _pickTime(bool isStart) async {
    final current = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _tryDismiss() async {
    if (_saving) return;
    if (!_hasUnsavedChanges) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Zahodit změny?',
          style: TextStyle(
            color: widget.theme.text,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Neuložené změny budou ztraceny.',
          style: TextStyle(color: widget.theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Zpět',
              style: TextStyle(color: widget.theme.dim, fontFamily: 'Sora'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Zahodit',
              style: TextStyle(color: Colors.red[400], fontFamily: 'Sora'),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    final data = _formData;
    if (!data.isValid || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final notifier = ref.read(recurringRemindersProvider.notifier);
      final reminder = widget.reminder;
      if (reminder == null) {
        await notifier.addReminder(data.toCompanion());
      } else {
        await notifier.updateReminder(reminder.id, data.toCompanion());
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
      }
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final data = _formData;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _tryDismiss();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _tryDismiss,
              child: Container(color: Colors.black54),
            ),
          ),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 380,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 48,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.border),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Upravit připomínku' : 'Nová připomínka',
                        style: TextStyle(
                          color: theme.text,
                          fontFamily: 'Sora',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldContainer(
                                theme: theme,
                                child: TextField(
                                  controller: _nameController,
                                  maxLength: 100,
                                  style: TextStyle(color: theme.text, fontFamily: 'Sora'),
                                  decoration: InputDecoration(
                                    hintText: 'Název',
                                    hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                                    border: InputBorder.none,
                                    counterStyle: TextStyle(color: theme.faint, fontSize: 11),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _FieldContainer(
                                theme: theme,
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLength: 300,
                                  maxLines: 3,
                                  style: TextStyle(color: theme.text, fontFamily: 'Sora'),
                                  decoration: InputDecoration(
                                    hintText: 'Popis (nepovinné)',
                                    hintStyle: TextStyle(color: theme.faint, fontFamily: 'Sora'),
                                    border: InputBorder.none,
                                    counterStyle: TextStyle(color: theme.faint, fontSize: 11),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _TimeField(
                                      theme: theme,
                                      label: 'Od',
                                      time: _formatTime(_startTime),
                                      onTap: () => _pickTime(true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _TimeField(
                                      theme: theme,
                                      label: 'Do',
                                      time: _formatTime(_endTime),
                                      onTap: () => _pickTime(false),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isOvernight) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Okno přesahuje přes půlnoc do dalšího dne.',
                                  style: TextStyle(
                                    color: theme.accent,
                                    fontFamily: 'Sora',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                'Interval opakování',
                                style: TextStyle(
                                  color: theme.dim,
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _intervals.map((minutes) {
                                  final isSelected = minutes == _repeatInterval;
                                  return GestureDetector(
                                    onTap: () => setState(() => _repeatInterval = minutes),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.accent.withValues(alpha: 0.2)
                                            : theme.panel,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? theme.accent : theme.border,
                                        ),
                                      ),
                                      child: Text(
                                        '$minutes min',
                                        style: TextStyle(
                                          color: isSelected ? theme.accent : theme.text,
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aktivní dny',
                                style: TextStyle(
                                  color: theme.dim,
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DaySelector(
                                activeDays: _activeDays,
                                theme: theme,
                                onChanged: (days) => setState(() => _activeDays = days),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Aktivní',
                                    style: TextStyle(
                                      color: theme.text,
                                      fontFamily: 'Sora',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch(
                                    value: _isActive,
                                    activeThumbColor: theme.accent,
                                    onChanged: (value) => setState(() => _isActive = value),
                                  ),
                                ],
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontFamily: 'Sora',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _saving ? null : _tryDismiss,
                            style: TextButton.styleFrom(foregroundColor: theme.dim),
                            child: Text(
                              'Zrušit',
                              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: data.isValid && !_saving ? _save : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accent,
                              foregroundColor: theme.ink,
                              disabledBackgroundColor: theme.accent.withValues(alpha: 0.3),
                              disabledForegroundColor: theme.ink.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _saving
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: theme.ink,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Uložit',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldContainer extends StatelessWidget {
  final AppThemeData theme;
  final Widget child;

  const _FieldContainer({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }
}

class _TimeField extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeField({
    required this.theme,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: theme.faint, fontFamily: 'Sora', fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'JetBrainsMono',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
