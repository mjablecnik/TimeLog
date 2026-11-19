import 'package:drift/drift.dart';

@DataClassName('TimeEntry')
class TimeEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get description => text().withLength(min: 0, max: 500)();
  TextColumn get activityType => text().withDefault(const Constant('Práce'))();
  TextColumn get project => text().withLength(min: 0, max: 200).nullable()();
  // Legacy column of schema version 5-7 (active / passive entertainment). It is
  // read only by the version 8 migration and never written any more.
  TextColumn get entertainmentType => text().nullable()();
  // Key of the subtype of the activity type (e.g. 'paid', 'walk'); null when
  // the type has none. See lib/core/activity_types.dart.
  TextColumn get subtype => text().nullable()();
  // Free-text name of an 'Ostatní' entry.
  TextColumn get customName => text().withLength(min: 0, max: 200).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
