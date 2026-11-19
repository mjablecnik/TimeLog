import 'package:drift/drift.dart';

@DataClassName('TaskProject')
class TaskProjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  // Name of the SuggestionScope (category) of the project, e.g. 'workUnpaid'.
  TextColumn get scope => text().withDefault(const Constant('workUnpaid'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
