# BRIEF — TimeLog App: Round 3

## Overview

Three enhancements to the existing Flutter time-tracking app:
1. New activity types (Volná práce, Přesun, Jídlo)
2. Project field for work-related activity types with autocomplete
3. Statistics screen (third page) with daily/weekly breakdowns

---

## 1. New Activity Types

### Goal
Add three new activity types to the existing set:
- **Volná práce** — non-primary work (freelance, side projects, learning)
- **Přesun** — commuting/travel time
- **Jídlo** — eating or food preparation

### Color Requirements
Colors must be distinct from existing types and work well on both light/dark themes.

**Existing types and colors (for reference):**
| Type | Color |
|------|-------|
| Práce | Red (`Colors.red[400]`) |
| Volný čas | Green (`Colors.green[400]`) |
| Odpočinek | Blue (`Colors.blue[400]`) |
| Spánek | Purple (`Colors.purple[300/700]`) |
| Cvičení | Amber (`Colors.amber[600]`) |

**New types and proposed colors:**
| Type | Color | Rationale |
|------|-------|-----------|
| Volná práce | Teal (`Colors.teal[400]`) | Work-related but clearly distinct from the red of Práce |
| Přesun | Indigo (`Colors.indigo[300/400]`) | Neutral, travel-associated, distinct from blue (Odpočinek) |
| Jídlo | Orange (`Colors.orange[400]`) | Warm, food-associated, distinct from amber (Cvičení) |

### Affected Files
- `lib/core/activity_types.dart` — add new types + colors to the map

---

## 2. Project Field for Work Types

### Goal
When the user selects **Práce** or **Volná práce** as the activity type, an additional "Project" text field appears. The user can type a project name, and the app remembers previously used project names for autocomplete suggestions.

### Behavior
1. The project field is **only visible** when the selected type is "Práce" or "Volná práce".
2. The field uses autocomplete — previously entered project names are suggested as the user types.
3. Project names are persisted locally (SharedPreferences or a simple DB table) so they survive app restart.
4. The autocomplete list is case-insensitive for matching but preserves the original casing of saved entries.
5. The project name is saved alongside the time entry in the database.

### Data Changes
- Add a `project` column (nullable String) to the `time_entries` table.
- Store known project names in SharedPreferences (simple `List<String>`) or a dedicated DB table.
- Schema migration to add the column.

### UI Changes
- `description_sheet.dart` — show a project `Autocomplete<String>` field when type is Práce/Volná práce.
- `edit_sheet.dart` — same project field with autocomplete when editing an entry.
- `history_entry_card.dart` — display the project name if present (e.g., small subtitle below the description).

---

## 3. Statistics Screen (Third Page)

### Goal
A new third page/tab in the app showing time usage statistics derived from locally stored data.

### Navigation
- Add a third tab/page to the app's navigation (Timer, History, **Statistics**).

### Statistics Content

#### Time Period Filters
- **Daily** view — stats for today (and optionally select a specific date)
- **Weekly** view — stats for the current week (Mon–Sun)

#### Breakdown by Activity Type
- How much time was spent on each activity type (in the selected period).
- Displayed as a list or simple bar/pie chart with the type colors.
- Show both absolute time (e.g., "2h 30m") and percentage of total tracked time.

#### Breakdown by Project
- How much time was spent on each project (only for Práce + Volná práce entries).
- List of projects with their total time in the selected period.

#### Idle/Untracked Time
- Calculate how much time in the day/week was NOT tracked (i.e., gaps between entries, assuming a ~16h waking day or simply total_period_hours - tracked_hours).
- Show this as "Nesledovaný čas" (untracked time) so the user sees how much time they "wasted" or didn't log.

### Design
- Simple, clean UI consistent with the rest of the app.
- Use the activity type colors for visual distinction.
- No external charting library required — simple horizontal bars or a basic donut/pie built with CustomPainter is sufficient.
- Skeleton loading states while data is being queried.

### Affected Files
- `lib/ui/screens/statistics_screen.dart` — NEW
- `lib/app.dart` — add third tab/page for navigation
- `lib/providers/` — possibly a new provider for statistics data queries
- `lib/data/database_service.dart` or `database.dart` — add query methods for aggregated stats

---

## Constraints
- All new UI text must be localized (Czech primary, English secondary) per existing i18n approach.
- New colors must be visually distinct from all existing type colors on both light and dark themes.
- The project autocomplete must feel fast — no noticeable delay when typing.
- Statistics queries should be efficient (indexed where needed).
- No external charting libraries — keep it lightweight with Flutter's built-in painting.
