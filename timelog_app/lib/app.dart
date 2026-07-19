import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _MainShellState extends ConsumerState<_MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    TimerScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    // React to notification taps via the same provider-listen pattern that
    // the timer uses for showing the description sheet. When the pending ID
    // changes from null to a value, push the ReminderActionScreen.
    ref.listen<int?>(pendingReminderActionProvider, (prev, next) {
      if (next != null) {
        // Reset immediately so the same tap isn't processed twice.
        ref.read(pendingReminderActionProvider.notifier).state = null;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReminderActionScreen(reminderId: next),
          ),
        );
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
