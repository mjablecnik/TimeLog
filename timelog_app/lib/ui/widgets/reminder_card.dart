import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/date_format_utils.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/recurring_reminders_provider.dart';
import '../../services/active_days_utils.dart';
import '../../services/recurring_reminder_service.dart' show isoDateString;

/// A single Recurring_Reminder entry: time window, interval, active days,
/// today's completion checkbox, active/inactive toggle, and edit/delete
/// actions (Requirements 1.2, 1.3, 1.4, 1.5, 3.1, 12.1).
class ReminderCard extends ConsumerStatefulWidget {
  final RecurringReminder reminder;
  final AppThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<ReminderCard> {
  bool _completedToday = false;
  bool _loadingCompletion = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompletion();
  }

  @override
  void didUpdateWidget(covariant ReminderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reminder.id != widget.reminder.id) {
      _loadCompletion();
    }
  }

  Future<void> _loadCompletion() async {
    final db = ref.read(appDatabaseProvider);
    final today = isoDateString(tz.TZDateTime.now(tz.local));
    final has = await db.hasCompletionForToday(widget.reminder.id, today);
    if (mounted) {
      setState(() {
        _completedToday = has;
        _loadingCompletion = false;
      });
    }
  }

  String _formatTime(int minutesFromMidnight) {
    final h = (minutesFromMidnight ~/ 60).toString().padLeft(2, '0');
    final m = (minutesFromMidnight % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatActiveDays(AppLocalizations l10n, int mask) {
    final labels = weekdayShortLabels(l10n);
    final days = decodeDays(mask);
    return List.generate(7, (i) => i + 1)
        .where(days.contains)
        .map((day) => labels[day - 1])
        .join(', ');
  }

  Future<void> _toggleCompletion(bool? checked) async {
    setState(() => _error = null);
    final notifier = ref.read(recurringRemindersProvider.notifier);
    try {
      if (checked == true) {
        await notifier.markDoneForToday(widget.reminder.id);
      } else {
        await notifier.undoCompletionForToday(widget.reminder.id);
      }
      await _loadCompletion();
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.reminderCompletionUpdateFailed);
      }
    }
  }

  Future<void> _toggleActive(bool _) async {
    setState(() => _error = null);
    try {
      await ref.read(recurringRemindersProvider.notifier).toggleActive(widget.reminder.id);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (e is InsufficientNotificationCapacityError) {
        setState(() => _error = l10n.reminderCapacityError(e.available, e.required));
      } else {
        setState(() => _error = l10n.reminderActiveToggleFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = widget.reminder;
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context)!;
    final isDone = _completedToday;
    final labelColor = reminder.isActive ? theme.text : theme.faint;
    final valueColor = reminder.isActive ? theme.accent : theme.faint;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: _loadingCompletion
                    ? null
                    : Checkbox(
                        value: isDone,
                        onChanged: _toggleCompletion,
                        activeColor: theme.accent,
                        checkColor: theme.ink,
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reminder.name,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: theme.dim,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                value: reminder.isActive,
                activeThumbColor: theme.accent,
                onChanged: _toggleActive,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${_formatTime(reminder.startTime)} – ${_formatTime(reminder.endTime)}',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.durationMinutesLabel(reminder.repeatInterval),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13,
                  color: theme.dim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatActiveDays(l10n, reminder.activeDays),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              color: theme.dim,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red[400],
                fontFamily: 'Sora',
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: widget.onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: theme.dim),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 18, color: theme.dim),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
