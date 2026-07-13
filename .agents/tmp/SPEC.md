# Specification: Activity Type Changes + Entertainment Sub-type

## Overview

Three changes to the TimeLog app's activity type system:

1. **Add entertainment sub-type selector to "Zábava"** — when "Zábava" is selected, show a mandatory single-choice selector with two options: "Aktivní zábava" and "Pasivní zábava". This is analogous to how work activities show a project name field, but instead of free-text it's a fixed two-option picker.
2. **Rename "Volný čas" → "Seberozvoj"** across the entire codebase.
3. **Rename "Volná práce" → "Domácí práce"** across the entire codebase, including updating `workActivityTypes` (since "Domácí práce" is housework, not work — it should likely be removed from `workActivityTypes` and no longer show the project field).

## Technical Approach

### 1. Rename Activity Types (Pure String Replacement)

**"Volný čas" → "Seberozvoj":**
- `lib/core/activity_types.dart`: update `activityTypes` list and `activityTypeColor()` switch case
- No database migration needed — existing entries keep the old string unless migrated

**"Volná práce" → "Domácí práce":**
- `lib/core/activity_types.dart`: update `activityTypes` list, `workActivityTypes` list, and `activityTypeColor()` switch case
- Decision: "Domácí práce" (housework) is NOT work — remove it from `workActivityTypes`. It should no longer show the project field.
- Update `stats_data.dart` doc comment referencing "Volná práce"

**Database migration:** Add a schema version 5 migration that updates existing `TimeEntries` rows:
- `UPDATE time_entries SET activity_type = 'Seberozvoj' WHERE activity_type = 'Volný čas'`
- `UPDATE time_entries SET activity_type = 'Domácí práce' WHERE activity_type = 'Volná práce'`

### 2. Entertainment Sub-type ("Zábava")

**Database:** Add a nullable `entertainment_type` column to `TimeEntries` table (schema version 5, same migration). Values: `'Aktivní zábava'` or `'Pasivní zábava'` or `null` (for non-entertainment entries).

**Core logic:**
- Add `entertainmentTypes` constant list: `['Aktivní zábava', 'Pasivní zábava']`
- Add `isEntertainmentActivityType(String type)` helper (checks `type == 'Zábava'`)

**UI — Description sheet, Edit sheet, Manual entry sheet:**
- When "Zábava" is selected, show a two-option toggle/chip selector (similar style to the activity type chips but smaller/inline) for choosing "Aktivní zábava" or "Pasivní zábava"
- The selection is mandatory before submission when "Zábava" is selected
- Persist the choice in the `entertainment_type` column

**UI — History entry card:**
- Display the entertainment type below the activity type badge (similar to how project is shown for work entries)

**Statistics:**
- Optionally break down "Zábava" time by entertainment type (analogous to byProject for work) — this is a nice-to-have enhancement

**SharedPreferences:**
- Persist last-selected entertainment type (similar to `_lastActivityTypeKey` pattern)

### 3. File Structure

No new files needed. Changes are in existing files:

```
lib/core/activity_types.dart          — add entertainmentTypes, isEntertainmentActivityType(), rename entries
lib/data/time_entry.dart              — add entertainment_type column
lib/data/database.dart                — bump schemaVersion to 5, add migration
lib/data/database.g.dart              — regenerate
lib/data/stats_data.dart              — update doc comment, optionally add byEntertainmentType
lib/ui/widgets/description_sheet.dart — add entertainment type selector when Zábava selected
lib/ui/widgets/edit_sheet.dart        — add entertainment type selector when Zábava selected
lib/ui/widgets/manual_entry_sheet.dart— add entertainment type selector when Zábava selected
lib/ui/widgets/history_entry_card.dart— display entertainment type
lib/providers/statistics_provider.dart— update doc references
lib/services/timer_service.dart       — ensure prefill supports entertainment_type
lib/services/timer_service.freezed.dart — regenerate
```

### 4. Constraints and Edge Cases

- Existing "Zábava" entries in DB will have `entertainment_type = null` — the UI should handle this gracefully (display without sub-type)
- The entertainment type selector must be **mandatory** for new entries when "Zábava" is selected (cannot submit without choosing one)
- Switching away from "Zábava" to another activity type clears the entertainment type selection
- The prefill (draft) flow must also persist the entertainment type choice
- `workActivityTypes` after rename: only `['Práce']` (single item) since "Domácí práce" is not work
- All renames must be reflected in the database migration so historical data stays consistent
