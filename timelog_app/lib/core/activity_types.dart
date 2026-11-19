import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Kind of extra text field a main type shows in the entry sheets.
enum TypeExtra { none, project, customName }

/// A category of suggested names. Each scope has its own list of names.
enum SuggestionScope { workPaid, workUnpaid, housework, other }

/// A refinement of a main type, e.g. paid / unpaid work.
class ActivitySubtype {
  const ActivitySubtype({
    required this.key,
    required this.dark,
    required this.light,
  });

  /// Stable identifier persisted in `time_entries.subtype` — never translated.
  /// Unique within its main type.
  final String key;

  /// Colour on the dark themes (Ember, Midnight).
  final Color dark;

  /// Colour on the light theme (Paper).
  final Color light;
}

/// A top-level activity type.
class ActivityType {
  const ActivityType({
    required this.key,
    required this.dark,
    required this.light,
    this.subtypes = const [],
    this.extra = TypeExtra.none,
  });

  /// Stable identifier persisted in `time_entries.activity_type` — never
  /// translated. The Czech strings are identifiers, not display text.
  final String key;

  /// Main colour on the dark themes.
  final Color dark;

  /// Main colour on the light theme.
  final Color light;

  /// Ordered subtypes; empty when the type has none.
  final List<ActivitySubtype> subtypes;

  /// Extra field shown below the type chips.
  final TypeExtra extra;
}

/// The single source of truth for types, subtypes and colours. Every widget
/// that classifies or draws an entry reads this list.
const List<ActivityType> activityRegistry = [
  ActivityType(
    key: 'Práce',
    dark: Color(0xFFBC2D34),
    light: Color(0xFF8F1B21),
    extra: TypeExtra.project,
    subtypes: [
      ActivitySubtype(
        key: 'paid',
        dark: Color(0xFFBC2D34),
        light: Color(0xFF8F1B21),
      ),
      ActivitySubtype(
        key: 'unpaid',
        dark: Color(0xFFD9595E),
        light: Color(0xFFC23A40),
      ),
    ],
  ),
  ActivityType(
    key: 'Domácí práce',
    dark: Color(0xFFF2994A),
    light: Color(0xFFD66A0A),
    extra: TypeExtra.project,
  ),
  ActivityType(
    key: 'Meeting',
    dark: Color(0xFFB27CF0),
    light: Color(0xFFA766F1),
  ),
  ActivityType(
    key: 'Komunikace',
    dark: Color(0xFFF06BB0),
    light: Color(0xFFF0429C),
  ),
  ActivityType(
    key: 'Přesun',
    dark: Color(0xFF93A0B4),
    light: Color(0xFF7A8BA4),
  ),
  ActivityType(
    key: 'Zábava',
    dark: Color(0xFF2CC4B0),
    light: Color(0xFF137E70),
    subtypes: [
      ActivitySubtype(
        key: 'active',
        dark: Color(0xFF2CC4B0),
        light: Color(0xFF137E70),
      ),
      ActivitySubtype(
        key: 'passive',
        dark: Color(0xFF7FD9CC),
        light: Color(0xFF1F9989),
      ),
    ],
  ),
  ActivityType(
    key: 'Cvičení',
    dark: Color(0xFFE8D04A),
    light: Color(0xFF86730A),
    subtypes: [
      ActivitySubtype(
        key: 'walk',
        dark: Color(0xFFF3E58A),
        light: Color(0xFF9D8810),
      ),
      ActivitySubtype(
        key: 'running',
        dark: Color(0xFFE8D04A),
        light: Color(0xFF86730A),
      ),
      ActivitySubtype(
        key: 'gym',
        dark: Color(0xFFC9A92A),
        light: Color(0xFF6B5A06),
      ),
    ],
  ),
  ActivityType(
    key: 'Seberozvoj',
    dark: Color(0xFF86C95E),
    light: Color(0xFF3F8A1F),
    subtypes: [
      ActivitySubtype(
        key: 'books',
        dark: Color(0xFFB0E08E),
        light: Color(0xFF4F9A25),
      ),
      ActivitySubtype(
        key: 'study',
        dark: Color(0xFF86C95E),
        light: Color(0xFF3F8A1F),
      ),
      ActivitySubtype(
        key: 'ai',
        dark: Color(0xFF5FAE3C),
        light: Color(0xFF2A6E12),
      ),
    ],
  ),
  ActivityType(
    key: 'Odpočinek',
    dark: Color(0xFF4A78F0),
    light: Color(0xFF2F5BD8),
    subtypes: [
      ActivitySubtype(
        key: 'active',
        dark: Color(0xFF4A78F0),
        light: Color(0xFF2F5BD8),
      ),
      ActivitySubtype(
        key: 'passive',
        dark: Color(0xFF8AA8F6),
        light: Color(0xFF5A84F2),
      ),
    ],
  ),
  ActivityType(
    key: 'Hygiena',
    dark: Color(0xFF46C6EE),
    light: Color(0xFF0A7DA6),
    subtypes: [
      ActivitySubtype(
        key: 'general',
        dark: Color(0xFF46C6EE),
        light: Color(0xFF0A7DA6),
      ),
      ActivitySubtype(
        key: 'toilet',
        dark: Color(0xFF8ED9F6),
        light: Color(0xFF1796C8),
      ),
    ],
  ),
  ActivityType(
    key: 'Jídlo',
    dark: Color(0xFFA97C50),
    light: Color(0xFF8A5E32),
    subtypes: [
      ActivitySubtype(
        key: 'breakfast',
        dark: Color(0xFFC49A68),
        light: Color(0xFF9A6C3E),
      ),
      ActivitySubtype(
        key: 'lunch',
        dark: Color(0xFFA97C50),
        light: Color(0xFF8A5E32),
      ),
      ActivitySubtype(
        key: 'dinner',
        dark: Color(0xFF856036),
        light: Color(0xFF6E4A24),
      ),
      ActivitySubtype(
        key: 'snack',
        dark: Color(0xFFD9B88F),
        light: Color(0xFFA87846),
      ),
    ],
  ),
  ActivityType(
    key: 'Ostatní',
    dark: Color(0xFFC9C3B8),
    light: Color(0xFF7A746C),
    extra: TypeExtra.customName,
  ),
];

/// Neutral colour for a type key that the registry does not define.
const Color _unknownTypeColor = Color(0xFFBDBDBD);

/// Type keys of the registry, in display order.
List<String> get activityTypes => [
  for (final type in activityRegistry) type.key,
];

/// The type with [typeKey], or null when the registry does not define it.
ActivityType? activityTypeOf(String typeKey) {
  for (final type in activityRegistry) {
    if (type.key == typeKey) return type;
  }
  return null;
}

/// The subtype [subtypeKey] of [typeKey], or null when either is not defined
/// or [subtypeKey] is null.
ActivitySubtype? subtypeOf(String typeKey, String? subtypeKey) {
  if (subtypeKey == null) return null;
  final type = activityTypeOf(typeKey);
  if (type == null) return null;
  for (final subtype in type.subtypes) {
    if (subtype.key == subtypeKey) return subtype;
  }
  return null;
}

/// Main colour of [typeKey]; neutral grey for an unknown type.
Color activityMainColor(String typeKey, {required bool isDark}) {
  final type = activityTypeOf(typeKey);
  if (type == null) return _unknownTypeColor;
  return isDark ? type.dark : type.light;
}

/// Colour of an entry: the subtype colour when [subtypeKey] is valid for the
/// type, otherwise the main colour, otherwise neutral grey. Never throws.
Color activityEntryColor(
  String typeKey,
  String? subtypeKey, {
  required bool isDark,
}) {
  final subtype = subtypeOf(typeKey, subtypeKey);
  if (subtype != null) return isDark ? subtype.dark : subtype.light;
  return activityMainColor(typeKey, isDark: isDark);
}

/// The subtype to preselect for [typeKey]: [remembered] when it is valid for
/// the type, otherwise the first subtype, otherwise null (type has none).
String? defaultSubtypeKey(String typeKey, {String? remembered}) {
  final type = activityTypeOf(typeKey);
  if (type == null || type.subtypes.isEmpty) return null;
  if (remembered != null && subtypeOf(typeKey, remembered) != null) {
    return remembered;
  }
  return type.subtypes.first.key;
}

/// The suggestion scope of an entry, or null for types without suggestions.
SuggestionScope? suggestionScopeOf(String typeKey, String? subtypeKey) {
  switch (typeKey) {
    case 'Práce':
      if (subtypeKey == 'paid') return SuggestionScope.workPaid;
      if (subtypeKey == 'unpaid') return SuggestionScope.workUnpaid;
      return null;
    case 'Domácí práce':
      return SuggestionScope.housework;
    case 'Ostatní':
      return SuggestionScope.other;
    default:
      return null;
  }
}

/// The scope with [name] (as stored in `task_projects.scope`); an unknown or
/// missing value counts as unpaid work.
SuggestionScope suggestionScopeFromName(String? name) {
  for (final scope in SuggestionScope.values) {
    if (scope.name == name) return scope;
  }
  return SuggestionScope.workUnpaid;
}

/// Colour of a suggestion category (used for the dot on project chips).
Color suggestionScopeColor(SuggestionScope scope, {required bool isDark}) {
  switch (scope) {
    case SuggestionScope.workPaid:
      return activityEntryColor('Práce', 'paid', isDark: isDark);
    case SuggestionScope.workUnpaid:
      return activityEntryColor('Práce', 'unpaid', isDark: isDark);
    case SuggestionScope.housework:
      return activityMainColor('Domácí práce', isDark: isDark);
    case SuggestionScope.other:
      return activityMainColor('Ostatní', isDark: isDark);
  }
}

/// Localized category name of a suggestion scope.
String suggestionScopeLabel(AppLocalizations l10n, SuggestionScope scope) {
  switch (scope) {
    case SuggestionScope.workPaid:
      return l10n.scopeWorkPaid;
    case SuggestionScope.workUnpaid:
      return l10n.scopeWorkUnpaid;
    case SuggestionScope.housework:
      return l10n.scopeHousework;
    case SuggestionScope.other:
      return l10n.scopeOther;
  }
}

/// Whether [typeKey] shows the project text field.
bool hasProjectField(String typeKey) =>
    activityTypeOf(typeKey)?.extra == TypeExtra.project;

/// Whether [typeKey] shows the custom name text field.
bool hasCustomNameField(String typeKey) =>
    activityTypeOf(typeKey)?.extra == TypeExtra.customName;

/// Maps a type key (a stable identifier persisted in the database — never
/// translate the key itself) to its localized display label. An unknown key
/// is returned as is.
String activityTypeLabel(AppLocalizations l10n, String typeKey) {
  switch (typeKey) {
    case 'Práce':
      return l10n.activityWork;
    case 'Domácí práce':
      return l10n.activityHousework;
    case 'Meeting':
      return l10n.activityMeeting;
    case 'Komunikace':
      return l10n.activityCommunication;
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
    case 'Ostatní':
      return l10n.activityOther;
    default:
      return typeKey;
  }
}

/// Localized label of a subtype; the subtype key itself for an unknown one.
String subtypeLabel(AppLocalizations l10n, String typeKey, String subtypeKey) {
  switch ('$typeKey/$subtypeKey') {
    case 'Práce/paid':
      return l10n.subtypePaid;
    case 'Práce/unpaid':
      return l10n.subtypeUnpaid;
    case 'Zábava/active':
      return l10n.subtypeEntertainmentActive;
    case 'Zábava/passive':
      return l10n.subtypeEntertainmentPassive;
    case 'Cvičení/walk':
      return l10n.subtypeWalk;
    case 'Cvičení/running':
      return l10n.subtypeRunning;
    case 'Cvičení/gym':
      return l10n.subtypeGym;
    case 'Seberozvoj/books':
      return l10n.subtypeBooks;
    case 'Seberozvoj/study':
      return l10n.subtypeStudy;
    case 'Seberozvoj/ai':
      return l10n.subtypeAi;
    case 'Odpočinek/active':
      return l10n.subtypeRestActive;
    case 'Odpočinek/passive':
      return l10n.subtypeRestPassive;
    case 'Hygiena/general':
      return l10n.subtypeGeneral;
    case 'Hygiena/toilet':
      return l10n.subtypeToilet;
    case 'Jídlo/breakfast':
      return l10n.subtypeBreakfast;
    case 'Jídlo/lunch':
      return l10n.subtypeLunch;
    case 'Jídlo/dinner':
      return l10n.subtypeDinner;
    case 'Jídlo/snack':
      return l10n.subtypeSnack;
    default:
      return subtypeKey;
  }
}

/// The line shown below the description of a history card: text and the colour
/// of the dot before it (null for no dot). Null when there is nothing to show.
({String text, Color? dotColor})? entryMetaLine(
  AppLocalizations l10n, {
  required String typeKey,
  String? subtypeKey,
  String? project,
  String? customName,
  required bool isDark,
}) {
  final color = activityEntryColor(typeKey, subtypeKey, isDark: isDark);
  final hasSubtype = subtypeOf(typeKey, subtypeKey) != null;
  final projectText = (project ?? '').trim();
  final nameText = (customName ?? '').trim();

  if (hasCustomNameField(typeKey)) {
    if (nameText.isEmpty) return null;
    return (text: nameText, dotColor: color);
  }
  if (hasSubtype) {
    final label = subtypeLabel(l10n, typeKey, subtypeKey!);
    final text = projectText.isEmpty ? label : '$projectText · $label';
    return (text: text, dotColor: color);
  }
  if (projectText.isNotEmpty) return (text: projectText, dotColor: null);
  return null;
}
