import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'completion_record.dart';
import 'recurring_reminder.dart';
import 'task.dart';
import 'task_project.dart';
import 'time_entry.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  TimeEntries,
  RecurringReminders,
  CompletionRecords,
  TaskProjects,
  Tasks,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 7;

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
          if (from < 7) {
            await m.createTable(taskProjects);
            await m.createTable(tasks);
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

  // --- TaskProjects CRUD ---

  Future<List<TaskProject>> getAllTaskProjects() {
    return (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .get();
  }

  Stream<List<TaskProject>> watchAllTaskProjects() {
    return (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<int> insertTaskProject(TaskProjectsCompanion entry) {
    return into(taskProjects).insert(entry);
  }

  Future<int> deleteTaskProject(int id) {
    return (delete(taskProjects)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> getTaskProjectNames() async {
    final rows = await (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .get();
    return rows.map((r) => r.name).toList();
  }

  // --- Tasks CRUD ---

  Future<List<TaskItem>> getTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    final query = select(tasks)
      ..where((t) => projectId == null
          ? t.projectId.isNull()
          : t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortPosition)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.get();
  }

  Stream<List<TaskItem>> watchTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    final query = select(tasks)
      ..where((t) => projectId == null
          ? t.projectId.isNull()
          : t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortPosition)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.watch();
  }

  Future<int> insertTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }

  Future<bool> updateTaskFields(int id, TasksCompanion entry) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id)))
        .write(entry);
    return rows > 0;
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateTaskSortPositions(List<TaskItem> orderedTasks) async {
    await batch((b) {
      for (var i = 0; i < orderedTasks.length; i++) {
        b.update(
          tasks,
          TasksCompanion(sortPosition: Value(i)),
          where: (t) => t.id.equals(orderedTasks[i].id),
        );
      }
    });
  }

  Future<bool> markTaskCompleted(int id, DateTime completedAt) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: const Value(true),
        completedAt: Value(completedAt),
      ),
    );
    return rows > 0;
  }

  Future<bool> unmarkTaskCompleted(int id) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(
        isCompleted: Value(false),
        completedAt: Value(null),
      ),
    );
    return rows > 0;
  }

  Future<bool> archiveTask(int id) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(isArchived: Value(true)),
    );
    return rows > 0;
  }

  Future<bool> unarchiveTask(int id, int newSortPosition) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: const Value(false),
        completedAt: const Value(null),
        isArchived: const Value(false),
        sortPosition: Value(newSortPosition),
      ),
    );
    return rows > 0;
  }

  Future<List<TaskItem>> getExpiredCompletedTasks() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 12));
    return (select(tasks)
          ..where((t) =>
              t.isCompleted.equals(true) &
              t.isArchived.equals(false) &
              t.completedAt.isSmallerOrEqualValue(cutoff)))
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
