import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../providers/database_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/recurring_reminder_service.dart';
import 'reminder_settings_screen.dart';

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _onToggle(BuildContext context, WidgetRef ref, bool value) async {
    final notifier = ref.read(reminderProvider.notifier);
    if (!value) {
      await notifier.toggleEnabled();
      return;
    }
    final service = ref.read(reminderServiceProvider);
    final granted = await service.requestPermission();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Oznámení jsou zakázána. Povolte je v nastavení telefonu.',
            ),
          ),
        );
      }
      return;
    }
    await notifier.toggleEnabled();
  }

  Future<void> _onPickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(reminderProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.timeOfDay,
    );
    if (picked != null) {
      await ref.read(reminderProvider.notifier).setTime(picked);
    }
  }

  Future<void> _scheduleTestNotification(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final reminders = await db.getAllReminders();

    if (reminders.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nejdříve vytvořte alespoň jednu opakovanou připomínku.'),
          ),
        );
      }
      return;
    }

    final reminder = reminders.first;
    final plugin = ref.read(reminderServiceProvider).plugin;
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 2));

    await plugin.zonedSchedule(
      id: 9999,
      scheduledDate: scheduledTime,
      title: '🧪 Test: ${reminder.name}',
      body: RecurringReminderService.buildNotificationBody(reminder.description),
      payload: '$recurringReminderPayloadPrefix${reminder.id}',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          RecurringReminderService.channelId,
          RecurringReminderService.channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testovací notifikace přijde za 2 minuty.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              'Nastavení',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Denní připomínka',
                style: TextStyle(
                  color: theme.dim,
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Připomínat spuštění časovače',
                          style: TextStyle(
                            color: theme.text,
                            fontFamily: 'Sora',
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: settings.enabled,
                          activeThumbColor: theme.accent,
                          onChanged: (value) => _onToggle(context, ref, value),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.border),
                  InkWell(
                    onTap: () => _onPickTime(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Čas připomínky',
                            style: TextStyle(
                              color: theme.text,
                              fontFamily: 'Sora',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatTime(settings.timeOfDay),
                            style: TextStyle(
                              color: theme.dim,
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReminderSettingsScreen(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Opakované připomínky',
                        style: TextStyle(
                          color: theme.text,
                          fontFamily: 'Sora',
                          fontSize: 14,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: theme.dim),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Testování',
                style: TextStyle(
                  color: theme.dim,
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _scheduleTestNotification(context, ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bug_report, color: theme.dim, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Testovací notifikace (za 2 min)',
                          style: TextStyle(
                            color: theme.text,
                            fontFamily: 'Sora',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
