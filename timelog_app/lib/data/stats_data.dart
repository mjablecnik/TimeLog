import 'package:flutter/foundation.dart';

import 'database.dart';

/// Aggregation period for the statistics screen.
enum StatsPeriod { daily, weekly }

/// Aggregated time-tracking statistics for a given period.
@immutable
class StatsData {
  final Duration totalTracked;
  final Duration untrackedTime;
  final Map<String, Duration> byActivityType;

  /// Only includes entries whose activity type is a work type
  /// (`Práce` / `Volná práce`).
  final Map<String, Duration> byProject;

  /// Raw entries for the period, used by the timeline widget.
  final List<TimeEntry> entries;

  const StatsData({
    required this.totalTracked,
    required this.untrackedTime,
    required this.byActivityType,
    required this.byProject,
    required this.entries,
  });
}
