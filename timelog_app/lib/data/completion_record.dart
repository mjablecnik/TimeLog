import 'package:drift/drift.dart';

import 'recurring_reminder.dart';

@DataClassName('CompletionRecord')
class CompletionRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId =>
      integer().references(RecurringReminders, #id, onDelete: KeyAction.cascade)();
  TextColumn get completionDate => text()(); // ISO 8601 date "YYYY-MM-DD"
  TextColumn get completionTimestamp => text()(); // ISO 8601 "YYYY-MM-DDTHH:mm:ss"

  @override
  List<Set<Column>> get uniqueKeys => [
        {reminderId, completionDate},
      ];
}
