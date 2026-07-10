import 'package:drift/drift.dart';

@DataClassName('TimeEntry')
class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
