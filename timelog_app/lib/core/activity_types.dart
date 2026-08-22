import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

const List<String> activityTypes = [
  'Práce',
  'Domácí práce',
  'Přesun',
  'Zábava',
  'Cvičení',
  'Seberozvoj',
  'Odpočinek',
  'Hygiena',
  'Jídlo',
];

/// Activity types that represent work and should show a project field.
const List<String> workActivityTypes = ['Práce'];

bool isWorkActivityType(String type) => workActivityTypes.contains(type);

/// Activity types that represent housework and can optionally have a project.
bool isHouseworkActivityType(String type) => type == 'Domácí práce';

/// Whether this activity type supports a project field.
bool hasProjectField(String type) =>
    isWorkActivityType(type) || isHouseworkActivityType(type);

/// Sub-type choices shown when the "Zábava" activity type is selected.
const List<String> entertainmentTypes = ['Aktivní zábava', 'Pasivní zábava'];

bool isEntertainmentActivityType(String type) => type == 'Zábava';

/// Maps an internal [type] key (a stable identifier persisted in the
/// database — never translate the key itself) to its localized display
/// label. Used everywhere a `type` from [activityTypes] is rendered as
/// text; the underlying key is still used for `onTap`, color lookup,
/// selection comparison, and DB writes.
String activityTypeLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'Práce':
      return l10n.activityWork;
    case 'Domácí práce':
      return l10n.activityHousework;
    case 'Přesun':
      return l10n.activityCommute;
    case 'Zábava':
      return l10n.activityEntertainment;
    case 'Cvičení':
      return l10n.activityExercise;
    case 'Seberozvoj':
      return l10n.activitySelfDevelopment;
    case 'Odpočinek':
      return l10n.activityRest;
    case 'Hygiena':
      return l10n.activityHygiene;
    case 'Jídlo':
      return l10n.activityMeal;
    default:
      return type;
  }
}

/// Maps an internal entertainment sub-type key (from [entertainmentTypes])
/// to its localized display label. See [activityTypeLabel].
String entertainmentTypeLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'Aktivní zábava':
      return l10n.entertainmentActive;
    case 'Pasivní zábava':
      return l10n.entertainmentPassive;
    default:
      return type;
  }
}

/// Returns the distinct badge color for [type]. [isDark] selects the
/// variant for the "Zábava" and "Přesun" types, which need a different
/// shade on light themes to stay legible.
Color activityTypeColor(String type, {bool isDark = true}) {
  switch (type) {
    case 'Práce':
      return Colors.red[400]!;
    case 'Seberozvoj':
      return Colors.green[400]!;
    case 'Odpočinek':
      return Colors.blue[400]!;
    case 'Zábava':
      return isDark ? Colors.teal[300]! : Colors.teal[400]!;
    case 'Cvičení':
      return Colors.amber[600]!;
    case 'Domácí práce':
      return isDark ? Colors.orange[300]! : Colors.orange[700]!;
    case 'Přesun':
      return isDark ? Colors.indigo[300]! : Colors.indigo[400]!;
    case 'Jídlo':
      return isDark ? Colors.purple[200]! : Colors.purple[900]!;
    case 'Hygiena':
      return isDark ? Colors.blue[300]! : Colors.blue[900]!;
    default:
      return Colors.grey[400]!;
  }
}
