import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/reminder_action_provider.dart';

/// Modal bottom sheet shown when the user taps a Recurring_Reminder
/// notification. Same UX pattern as the description sheet after timer
/// completion — works reliably on iOS even when coming from background.
class ReminderActionSheet extends ConsumerStatefulWidget {
  final int reminderId;
  final AppThemeData theme;

  const ReminderActionSheet({
    super.key,
    required this.reminderId,
    required this.theme,
  });

  @override
  ConsumerState<ReminderActionSheet> createState() => _ReminderActionSheetState();
}

class _ReminderActionSheetState extends ConsumerState<ReminderActionSheet> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ref.read(reminderActionProvider.notifier).load(widget.reminderId);
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _handleDone() async {
    await ref.read(reminderActionProvider.notifier).markDone(widget.reminderId);
    if (!mounted) return;
    if (ref.read(reminderActionProvider).error == null) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSnooze() async {
    await ref.read(reminderActionProvider.notifier).snooze(widget.reminderId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final state = ref.watch(reminderActionProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(theme, AppLocalizations.of(context)!, state),
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeData theme, AppLocalizations l10n, ReminderActionState state) {
    if (!_loaded) {
      return SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: theme.accent)),
      );
    }

    if (state.reminder == null) {
      // Reminder was deleted — just close the sheet.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox(height: 80);
    }

    final reminder = state.reminder!;
    final description = reminder.description?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dim.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          reminder.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.text,
            fontFamily: 'Sora',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
          ),
        ],
        if (state.error != null) ...[
          const SizedBox(height: 16),
          Text(
            state.error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[400],
              fontFamily: 'Sora',
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.isLoading ? null : _handleSnooze,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.dim,
                  side: BorderSide(color: theme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  l10n.reminderSnooze,
                  style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _handleDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accent,
                  foregroundColor: theme.ink,
                  disabledBackgroundColor: theme.accent.withValues(alpha: 0.3),
                  disabledForegroundColor: theme.ink.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: theme.ink,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l10n.reminderDone,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
