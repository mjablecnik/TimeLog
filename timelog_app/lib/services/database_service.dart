import 'package:drift/drift.dart';

import '../core/config.dart';
import '../data/database.dart';

class DatabaseService {
  final AppDatabase _db;

  DatabaseService(this._db);

  Future<void> initialize() async {
    await _db.customSelect('SELECT 1').get().timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Database initialization timed out'),
        );
  }

  Future<int> insertTimeEntry(TimeEntriesCompanion entry) async {
    return await _db.into(_db.timeEntries).insert(entry);
  }

  Future<List<TimeEntry>> getEntriesForDay(DateTime day) async {
    return await getEntriesForRange(_dayStart(day), _dayEnd(day));
  }

  Future<List<TimeEntry>> getEntriesForRange(DateTime start, DateTime end) async {
    return await (_db.select(_db.timeEntries)
          ..where((t) => t.startTime.isBetweenValues(start.toIso8601String(), end.toIso8601String()))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> updateDescription(
    int id,
    String description, {
    String? activityType,
    Value<String?> project = const Value.absent(),
    Value<String?> subtype = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await (_db.update(_db.timeEntries)..where((t) => t.id.equals(id))).write(
      TimeEntriesCompanion(
        description: Value(description),
        activityType: activityType == null
            ? const Value.absent()
            : Value(activityType),
        project: project,
        subtype: subtype,
        customName: customName,
        startTime: startTime == null
            ? const Value.absent()
            : Value(startTime.toIso8601String()),
        endTime: endTime == null
            ? const Value.absent()
            : Value(endTime.toIso8601String()),
      ),
    );
  }

  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.timeEntries)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TimeEntry>> watchEntriesForDay(DateTime day) {
    final start = _dayStart(day);
    final end = _dayEnd(day);
    return (_db.select(_db.timeEntries)
          ..where((t) => t.startTime.isBetweenValues(start.toIso8601String(), end.toIso8601String()))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .watch();
  }

  DateTime _dayStart(DateTime day) =>
      DateTime(day.year, day.month, day.day, dayStartHour);

  DateTime _dayEnd(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1, dayStartHour)
          .subtract(const Duration(milliseconds: 1));
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
