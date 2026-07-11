import 'package:drift/drift.dart';

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
    final start = _dayStart(day);
    final end = _dayEnd(day);
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
  }) async {
    await (_db.update(_db.timeEntries)..where((t) => t.id.equals(id))).write(
      TimeEntriesCompanion(
        description: Value(description),
        activityType: activityType == null
            ? const Value.absent()
            : Value(activityType),
        project: project,
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
      DateTime(day.year, day.month, day.day, 0, 0, 0);

  DateTime _dayEnd(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59, 999);
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
