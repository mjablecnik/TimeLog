import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/activity_types.dart';
import '../core/config.dart';
import '../data/database.dart';
import '../data/stats_data.dart';
import 'database_provider.dart';

final statisticsPeriodProvider = StateProvider<StatsPeriod>((ref) {
  return StatsPeriod.daily;
});

final statisticsDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // If before dayStartHour, consider it still the previous day
  if (now.hour < dayStartHour) {
    final prev = now.subtract(const Duration(days: 1));
    return DateTime(prev.year, prev.month, prev.day);
  }
  return DateTime(now.year, now.month, now.day);
});

final statisticsProvider = FutureProvider<StatsData>((ref) async {
  final period = ref.watch(statisticsPeriodProvider);
  final date = ref.watch(statisticsDateProvider);
  final dbService = await ref.watch(databaseServiceProvider.future);

  final start = _rangeStart(period, date);
  final end = _rangeEnd(period, start);
  final entries = await dbService.getEntriesForRange(start, end);

  return _computeStats(entries, period);
});

DateTime _rangeStart(StatsPeriod period, DateTime date) {
  if (period == StatsPeriod.daily) {
    return DateTime(date.year, date.month, date.day, dayStartHour);
  }
  final weekStart = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(weekStart.year, weekStart.month, weekStart.day, dayStartHour);
}

DateTime _rangeEnd(StatsPeriod period, DateTime start) {
  final days = period == StatsPeriod.daily ? 1 : 7;
  return start.add(Duration(days: days)).subtract(const Duration(milliseconds: 1));
}

StatsData _computeStats(List<TimeEntry> entries, StatsPeriod period) {
  final byActivityType = <String, Duration>{};
  // Key: "activityType\x00projectName" to keep entries unique per type
  final projectMap = <String, Duration>{};
  final projectTypes = <String, String>{};
  final byEntertainmentType = <String, Duration>{};
  var totalTracked = Duration.zero;

  for (final entry in entries) {
    final start = DateTime.parse(entry.startTime);
    final end = DateTime.parse(entry.endTime);
    final duration = end.difference(start);
    totalTracked += duration;

    byActivityType.update(
      entry.activityType,
      (value) => value + duration,
      ifAbsent: () => duration,
    );

    final project = entry.project;
    if (hasProjectField(entry.activityType) && project != null && project.isNotEmpty) {
      final key = '${entry.activityType}\x00$project';
      projectMap.update(key, (value) => value + duration, ifAbsent: () => duration);
      projectTypes[key] = entry.activityType;
    }

    final entertainmentType = entry.entertainmentType;
    if (isEntertainmentActivityType(entry.activityType) &&
        entertainmentType != null &&
        entertainmentType.isNotEmpty) {
      byEntertainmentType.update(
        entertainmentType,
        (value) => value + duration,
        ifAbsent: () => duration,
      );
    }
  }

  final projectStats = projectMap.entries.map((e) {
    final name = e.key.split('\x00')[1];
    return ProjectStat(
      name: name,
      activityType: projectTypes[e.key]!,
      duration: e.value,
    );
  }).toList()
    ..sort((a, b) => b.duration.compareTo(a.duration));

  final wakingHours = period == StatsPeriod.daily ? 16 : 16 * 7;
  final untracked = Duration(hours: wakingHours) - totalTracked;

  return StatsData(
    totalTracked: totalTracked,
    untrackedTime: untracked.isNegative ? Duration.zero : untracked,
    byActivityType: byActivityType,
    byProject: projectStats,
    byEntertainmentType: byEntertainmentType,
    entries: entries,
  );
}
