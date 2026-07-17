import 'package:drift/drift.dart';

@DataClassName('RecurringReminder')
class RecurringReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().withLength(min: 0, max: 300).nullable()();
  IntColumn get startTime => integer()(); // Minutes from midnight, 0-1439
  IntColumn get endTime => integer()(); // Minutes from midnight, 0-1439
  IntColumn get repeatInterval => integer()(); // Minutes: 30, 60, 120, 180, 240
  IntColumn get activeDays => integer()(); // 7-bit bitmask (bit 0 = Monday)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
