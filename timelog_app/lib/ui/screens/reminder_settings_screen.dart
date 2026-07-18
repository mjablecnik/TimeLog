import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/database.dart';
import '../../providers/recurring_reminders_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_edit_dialog.dart';

/// Reminder list sub-screen within Settings: create, edit, delete, and
/// toggle Recurring_Reminders (Requirement 1).
class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  void _addReminder(BuildContext context, AppThemeData theme) {
    ReminderEditDialog.show(context, theme: theme);
  }

  void _editReminder(BuildContext context, AppThemeData theme, RecurringReminder reminder) {
    ReminderEditDialog.show(context, theme: theme, reminder: reminder);
  }

  Future<void> _deleteReminder(
    BuildContext context,
    WidgetRef ref,
    AppThemeData theme,
    RecurringReminder reminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Smazat připomínku?',
          style: TextStyle(color: theme.text, fontFamily: 'Sora', fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Připomínka „${reminder.name}“ bude trvale smazána.',
          style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Zpět', style: TextStyle(color: theme.dim, fontFamily: 'Sora')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Smazat',
              style: TextStyle(color: Colors.red[400], fontFamily: 'Sora'),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(recurringRemindersProvider.notifier).deleteReminder(reminder.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Smazání připomínky se nezdařilo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final remindersAsync = ref.watch(recurringRemindersProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Opakované připomínky',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.text,
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Positioned(
                  left: 4,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.text),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Positioned(
                  right: 4,
                  child: IconButton(
                    icon: Icon(Icons.add, color: theme.text),
                    onPressed: () => _addReminder(context, theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: remindersAsync.when(
                data: (reminders) {
                  if (reminders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 52, color: theme.faint),
                            const SizedBox(height: 16),
                            Text(
                              'Zatím nemáte žádné připomínky',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.dim, fontFamily: 'Sora', fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Klepnutím na + vytvořte první připomínku',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.faint, fontFamily: 'Sora', fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return ReminderCard(
                        key: ValueKey(reminder.id),
                        reminder: reminder,
                        theme: theme,
                        onEdit: () => _editReminder(context, theme, reminder),
                        onDelete: () => _deleteReminder(context, ref, theme, reminder),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: theme.accent),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Nepodařilo se načíst připomínky.',
                    style: TextStyle(color: theme.dim, fontFamily: 'Sora'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
