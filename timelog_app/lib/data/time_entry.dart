import 'package:drift/drift.dart';

@DataClassName('TimeEntry')
class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get description => text().withLength(min: 0, max: 500)();
  TextColumn get activityType => text().withDefault(const Constant('Práce'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
