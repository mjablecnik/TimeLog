import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/database_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/reminder_action_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(
            content: Text(l10n.settingsNotificationsDisabled),
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
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final reminders = await db.getAllReminders();

    if (reminders.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsNoRemindersYet),
          ),
        );
      }
      return;
    }

    final reminder = reminders.first;
    final plugin = ref.read(reminderServiceProvider).plugin;
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await plugin.zonedSchedule(
      id: 9999,
      scheduledDate: scheduledTime,
      title: l10n.settingsTestNotificationTitle(reminder.name),
      body: RecurringReminderService.buildNotificationBody(reminder.description, l10n),
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
        SnackBar(
          content: Text(l10n.settingsTestNotificationScheduled),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(reminderProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              l10n.settingsTitle,
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
                l10n.settingsDailyReminderSection,
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
                          l10n.settingsReminderToggleLabel,
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
                            l10n.settingsReminderTimeLabel,
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
                        l10n.settingsRecurringRemindersLabel,
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
                l10n.settingsLanguageSection,
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
                  _LanguageOption(
                    theme: theme,
                    label: 'Čeština',
                    isSelected: currentLocale?.languageCode == 'cs',
                    onTap: () => ref.read(localeProvider.notifier).select(const Locale('cs')),
                  ),
                  Divider(height: 1, color: theme.border),
                  _LanguageOption(
                    theme: theme,
                    label: 'English',
                    isSelected: currentLocale?.languageCode == 'en',
                    onTap: () => ref.read(localeProvider.notifier).select(const Locale('en')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.settingsTestingSection,
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
                          l10n.settingsTestNotificationButton,
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
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final db = ref.read(appDatabaseProvider);
                  final reminders = await db.getAllReminders();
                  if (reminders.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.settingsNoReminder)),
                      );
                    }
                    return;
                  }
                  ref.read(pendingReminderActionProvider.notifier).state =
                      reminders.first.id;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, color: theme.dim, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.settingsShowModalDebugButton,
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

class _LanguageOption extends StatelessWidget {
  final AppThemeData theme;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.theme,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.text,
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: theme.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
