import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../data/database.dart';
import 'database_provider.dart';

/// Returns the logical day for a given [dateTime].
/// If the time is before [dayStartHour], the logical day is the previous calendar day.
DateTime logicalDay(DateTime dateTime) {
  if (dateTime.hour < dayStartHour) {
    final prev = dateTime.subtract(const Duration(days: 1));
    return DateTime(prev.year, prev.month, prev.day);
  }
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

final selectedDayProvider = StateProvider<DateTime>((ref) {
  return logicalDay(DateTime.now());
});

final dayEntriesProvider = StreamProvider<List<TimeEntry>>((ref) {
  final day = ref.watch(selectedDayProvider);
  final dbServiceAsync = ref.watch(databaseServiceProvider);

  return dbServiceAsync.when(
    data: (service) => service.watchEntriesForDay(day),
    loading: () => const Stream.empty(),
    error: (_, _) => const Stream.empty(),
  );
});
