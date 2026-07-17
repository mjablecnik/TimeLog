import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'completion_record.dart';
import 'recurring_reminder.dart';
import 'time_entry.dart';

part 'database.g.dart';

@DriftDatabase(tables: [TimeEntries, RecurringReminders, CompletionRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(timeEntries, timeEntries.activityType);
          }
          if (from < 3) {
            // No SQL change needed: the description min-length constraint
            // is enforced by drift at the Dart layer, not a SQL CHECK.
          }
          if (from < 4) {
            await m.addColumn(timeEntries, timeEntries.project);
          }
          if (from < 5) {
            await m.addColumn(timeEntries, timeEntries.entertainmentType);
            await customStatement(
              "UPDATE time_entries SET activity_type = 'Seberozvoj' WHERE activity_type = 'Volný čas'",
            );
            await customStatement(
              "UPDATE time_entries SET activity_type = 'Domácí práce' WHERE activity_type = 'Volná práce'",
            );
          }
          if (from < 6) {
            await m.createTable(recurringReminders);
            await m.createTable(completionRecords);
          }
        },
      );

  // --- RecurringReminders CRUD ---

  Future<List<RecurringReminder>> getAllReminders() {
    return (select(recurringReminders)
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  Stream<List<RecurringReminder>> watchAllReminders() {
    return (select(recurringReminders)
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  Future<int> insertReminder(RecurringRemindersCompanion entry) {
    return into(recurringReminders).insert(entry);
  }

  Future<bool> updateReminder(RecurringRemindersCompanion entry) {
    return update(recurringReminders).replace(entry);
  }

  Future<int> deleteReminder(int id) {
    return (delete(recurringReminders)..where((t) => t.id.equals(id))).go();
  }

  Future<RecurringReminder?> getReminderById(int id) {
    return (select(recurringReminders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // --- CompletionRecords ---

  Future<int> insertCompletionRecord(CompletionRecordsCompanion entry) {
    return into(completionRecords).insert(entry);
  }

  Future<bool> hasCompletionForToday(int reminderId, String todayDate) async {
    final record = await (select(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.equals(todayDate)))
        .getSingleOrNull();
    return record != null;
  }

  Future<int> deleteCompletionForToday(int reminderId, String todayDate) {
    return (delete(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.equals(todayDate)))
        .go();
  }

  Future<List<CompletionRecord>> getCompletionsByReminder(int reminderId) {
    return (select(completionRecords)
          ..where((t) => t.reminderId.equals(reminderId))
          ..orderBy([(t) => OrderingTerm.asc(t.completionDate)]))
        .get();
  }

  Future<List<CompletionRecord>> getCompletionsByDateRange(
    int reminderId,
    String startDate,
    String endDate,
  ) {
    return (select(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.isBiggerOrEqualValue(startDate) &
              t.completionDate.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.completionDate)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'timelog.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => db.execute('PRAGMA foreign_keys = ON;'),
    );
  });
}
