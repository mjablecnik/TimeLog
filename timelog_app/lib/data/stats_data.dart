import 'package:flutter/foundation.dart';

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

  const StatsData({
    required this.totalTracked,
    required this.untrackedTime,
    required this.byActivityType,
    required this.byProject,
  });
}
