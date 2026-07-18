import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../providers/reminder_action_provider.dart';
import '../../providers/theme_provider.dart';
import 'reminder_settings_screen.dart';

/// Done/Snooze screen shown when the user taps a Recurring_Reminder
/// notification (Requirements 5.2, 5.3, 5.4, 5.5, 5.6, 6, 7, 12.3).
class ReminderActionScreen extends ConsumerStatefulWidget {
  final int reminderId;

  const ReminderActionScreen({super.key, required this.reminderId});

  @override
  ConsumerState<ReminderActionScreen> createState() => _ReminderActionScreenState();
}

class _ReminderActionScreenState extends ConsumerState<ReminderActionScreen> {
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

  /// Returns to the previous screen, or Timer_Screen (home) if this screen
  /// has no navigation history (e.g. it was the cold-launch entry point).
  void _dismiss() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => const TimeLogApp()));
    }
  }

  Future<void> _handleDone() async {
    await ref.read(reminderActionProvider.notifier).markDone(widget.reminderId);
    if (!mounted) return;
    if (ref.read(reminderActionProvider).error == null) {
      _dismiss();
    }
  }

  Future<void> _handleSnooze() async {
    await ref.read(reminderActionProvider.notifier).snooze(widget.reminderId);
    if (mounted) _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final state = ref.watch(reminderActionProvider);

    if (!_loaded) {
      return Scaffold(
        backgroundColor: theme.background,
        body: Center(child: CircularProgressIndicator(color: theme.accent)),
      );
    }

    if (state.reminder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()),
        );
      });
      return Scaffold(backgroundColor: theme.background, body: const SizedBox.shrink());
    }

    final reminder = state.reminder!;
    final description = reminder.description?.trim();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.panel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: theme.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                            'Odložit',
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
                                  'Hotovo',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
