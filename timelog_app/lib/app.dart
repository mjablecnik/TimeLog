import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  /// If the app was cold-launched by tapping a recurring reminder notification,
  /// this holds the reminder ID so we can show the action screen immediately.
  final int? coldLaunchReminderId;

  const TimeLogApp({super.key, this.coldLaunchReminderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'TimeLog',
      debugShowCheckedModeBanner: false,
      theme: theme.toMaterialTheme(),
      home: _MainShell(coldLaunchReminderId: coldLaunchReminderId),
    );
  }
}

class _MainShell extends ConsumerStatefulWidget {
  final int? coldLaunchReminderId;

  const _MainShell({this.coldLaunchReminderId});

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _selectedIndex = 0;
  bool _coldLaunchHandled = false;

  static const List<Widget> _screens = [
    TimerScreen(),
    HistoryScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.coldLaunchReminderId != null) {
      // Schedule the push for after this widget's first frame, at which point
      // the navigator (navigatorKey) is guaranteed to be mounted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _coldLaunchHandled) return;
        _coldLaunchHandled = true;
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReminderActionScreen(
              reminderId: widget.coldLaunchReminderId!,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
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
