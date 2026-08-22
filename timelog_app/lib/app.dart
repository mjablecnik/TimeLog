import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';
import 'main.dart' show kPendingReminderIdKey;
import 'providers/locale_provider.dart';
import 'providers/recurring_reminders_provider.dart';
import 'providers/reminder_action_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/timer_screen.dart';
import 'ui/screens/tasks_screen.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/statistics_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/reminder_action_screen.dart';
import 'ui/widgets/bottom_nav.dart';

/// App-wide navigator key so notification-tap handlers (which run outside
/// the widget tree, e.g. from `main()`) can push routes such as
/// Reminder_Action_Screen without needing a `BuildContext`.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TimeLogApp extends ConsumerWidget {
  const TimeLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TimeLog',
      debugShowCheckedModeBanner: false,
      theme: theme.toMaterialTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },
      home: const _MainShell(),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _reminderActionOpen = false;

  static const List<Widget> _screens = [
    TimerScreen(),
    TasksScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check on first frame in case provider was set before widget mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _consumePendingReminder();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPersistedPendingReminder();
      // Reschedule recurring reminder notifications on resume so that
      // slots beyond the original 6-hour lookahead window get scheduled.
      ref.read(recurringReminderServiceProvider).rescheduleAll();
    }
  }

  Future<void> _checkPersistedPendingReminder() async {
    if (_reminderActionOpen) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final reminderId = prefs.getInt(kPendingReminderIdKey);
    if (reminderId != null) {
      await prefs.remove(kPendingReminderIdKey);
      if (mounted) _openReminderAction(reminderId);
    }
  }

  void _consumePendingReminder() {
    if (_reminderActionOpen) return;
    final pendingId = ref.read(pendingReminderActionProvider);
    if (pendingId != null) {
      ref.read(pendingReminderActionProvider.notifier).state = null;
      _openReminderAction(pendingId);
    }
  }

  void _openReminderAction(int reminderId) {
    if (_reminderActionOpen) return;
    _reminderActionOpen = true;
    // Also clear prefs and provider to prevent duplicate triggers.
    ref.read(pendingReminderActionProvider.notifier).state = null;
    SharedPreferences.getInstance().then((prefs) => prefs.remove(kPendingReminderIdKey));

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ReminderActionScreen(reminderId: reminderId),
      ),
    ).then((_) {
      _reminderActionOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    ref.listen<int?>(pendingReminderActionProvider, (prev, next) {
      if (next != null && !_reminderActionOpen) {
        ref.read(pendingReminderActionProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openReminderAction(next);
        });
      }
    });

    return Scaffold(
      backgroundColor: theme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            ref.invalidate(statisticsProvider);
          }
          setState(() => _selectedIndex = index);
        },
        theme: theme,
      ),
    );
  }
}
