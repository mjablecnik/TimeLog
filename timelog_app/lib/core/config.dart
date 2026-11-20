/// The hour at which a "logical day" starts for statistics and history.
/// Entries between 00:00–02:59 are counted toward the previous day.
const int dayStartHour = 3;

/// Index of the Stats tab within `_MainShellState._screens` / `AppBottomNav`
/// (see `app.dart`). Tabs: Timer, History, Stats, Settings.
const statsTabIndex = 2;

class TimerConfig {
  static const int defaultDurationMinutes = 20;
  static const int minDurationMinutes = 1;
  static const int maxDurationMinutes = 1440;

  final int durationMinutes;

  factory TimerConfig({int? minutes}) {
    final m = minutes ?? defaultDurationMinutes;
    if (m < minDurationMinutes || m > maxDurationMinutes) {
      return const TimerConfig._(defaultDurationMinutes);
    }
    return TimerConfig._(m);
  }

  const TimerConfig._(this.durationMinutes);

  int get totalSeconds => durationMinutes * 60;
}
