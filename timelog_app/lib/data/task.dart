import 'package:drift/drift.dart';

import 'task_project.dart';

@DataClassName('TaskItem')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().withLength(min: 0, max: 1000).nullable()();
  TextColumn get deadline => text().nullable()(); // ISO 8601 date "YYYY-MM-DD"
  IntColumn get projectId =>
      integer().nullable().references(TaskProjects, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortPosition => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
