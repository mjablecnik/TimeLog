import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
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
