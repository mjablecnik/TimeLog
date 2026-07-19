import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' show kPendingReminderIdKey;
import 'providers/reminder_action_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/timer_screen.dart';
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TimeLog',
      debugShowCheckedModeBanner: false,
      theme: theme.toMaterialTheme(),
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

  static const List<Widget> _screens = [
    TimerScreen(),
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
    }
  }

  Future<void> _checkPersistedPendingReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final reminderId = prefs.getInt(kPendingReminderIdKey);
    if (reminderId != null) {
      await prefs.remove(kPendingReminderIdKey);
      if (mounted) _openReminderAction(reminderId);
    }
  }

  void _consumePendingReminder() {
    final pendingId = ref.read(pendingReminderActionProvider);
    if (pendingId != null) {
      ref.read(pendingReminderActionProvider.notifier).state = null;
      _openReminderAction(pendingId);
    }
  }

  void _openReminderAction(int reminderId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ReminderActionScreen(reminderId: reminderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    ref.listen<int?>(pendingReminderActionProvider, (prev, next) {
      if (next != null) {
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
          if (index == 2) {
            ref.invalidate(statisticsProvider);
          }
          setState(() => _selectedIndex = index);
        },
        theme: theme,
      ),
    );
  }
}
