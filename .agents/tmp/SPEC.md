# Spec: TimeLog App Improvements (Batch 2)

## Overview

Four improvements to the TimeLog Flutter app:
1. Replace "Spánek" (Sleep) activity type with "Zábava" (Entertainment)
2. Fix statistics screen not refreshing when navigating to it
3. Smart start time default in manual entry: use end time of the last entry on the selected day
4. Add swipe gesture navigation in statistics screen (left/right to change day/week)

---

## 1. Replace "Spánek" with "Zábava"

**File:** `lib/core/activity_types.dart`

Replace the `'Spánek'` entry in the `activityTypes` list with `'Zábava'`. Update the `activityTypeColor` function to map `'Zábava'` to the color previously assigned to `'Spánek'` (purple shade). Remove the old `'Spánek'` case.

**Impact:** Existing database entries with `activityType = 'Spánek'` will no longer match a known type and will render with the default grey color. This is acceptable — no migration needed, they'll still display with their stored label.

---

## 2. Fix Statistics Screen Refresh

**Problem:** When navigating to the statistics tab, the displayed data is stale. The user must manually change the day or toggle period to force a refresh.

**Root cause:** `statisticsProvider` is a `FutureProvider` that watches `statisticsPeriodProvider` and `statisticsDateProvider`. When neither changes (user just switches tabs), the provider's cached value is shown without re-fetching from the database.

**Solution:** Invalidate `statisticsProvider` when the statistics screen becomes visible. Add an `invalidate(statisticsProvider)` call when `StatisticsScreen` builds (or use a lifecycle hook). The simplest approach is to convert `StatisticsScreen` to a `ConsumerStatefulWidget` and call `ref.invalidate(statisticsProvider)` in `didChangeDependencies` or use a `VisibilityDetector`-style approach. However, the cleanest approach given the bottom-nav architecture: invalidate the provider whenever the statistics tab is selected, or use `ref.invalidate` directly in the `StatisticsScreen` build method on first build.

**Chosen approach:** Make `StatisticsScreen` a `ConsumerStatefulWidget`, override `initState` to invalidate `statisticsProvider` so it re-fetches fresh data every time the screen widget is (re)created. Since the bottom nav likely keeps the screen alive, an alternative is to use `AutomaticKeepAlive` pattern or, better, invalidate in the `_DateNav` build. The most robust fix: the `StatisticsScreen` should invalidate `statisticsProvider` each time it appears. Since it's a `ConsumerWidget` that stays alive in the nav, we need to trigger invalidation when the tab is selected. We'll hook into the bottom navigation's tab change to invalidate.

**Final approach:** Add `ref.invalidate(statisticsProvider)` triggered from the bottom nav's `onTabChanged` callback (in `app.dart` or wherever the nav index lives), specifically when switching to the statistics tab index.

---

## 3. Smart Start Time for Manual Entry

**Problem:** When adding a new manual entry from scratch, start time should equal the end time of the last entry on the selected day.

**File:** `lib/ui/widgets/manual_entry_sheet.dart` — `_initDefaultTimes()`

**Current behavior:** Defaults to `now - 30min` (today) or `12:00` (past day).

**New behavior:**
1. Query the database for entries on `widget.selectedDay`, sorted by end time descending.
2. If entries exist, set `_startTime` = end time of the most recent entry (the one with the latest `endTime`).
3. If the selected day is today, set `_endTime` = now (clamped to day boundary).
4. If past day, set `_endTime` = `_startTime + 30 minutes` (clamped to 23:59 of that day).
5. If no entries exist, fall back to current behavior.

Since this requires an async DB query, `_initDefaultTimes` must become async and be called from `initState` with a `.then()` pattern or use a loading state.

---

## 4. Swipe Navigation in Statistics Screen

**Problem:** User wants to swipe left/right in the statistics screen to navigate between days (daily mode) or weeks (weekly mode).

**Solution:** Wrap the statistics content (below the period toggle) in a `GestureDetector` that detects horizontal swipes, or use a `PageView`-style approach. The simplest and most natural solution: wrap the main content area in a `GestureDetector` with `onHorizontalDragEnd` that:
- Swipe left (positive velocity) → go to next day/week (unless already at current)
- Swipe right (negative velocity) → go to previous day/week

This mirrors the existing chevron button behavior but triggered by swipe. The threshold should be reasonable (e.g., velocity > 300 or drag distance > 50px).

**File:** `lib/ui/screens/statistics_screen.dart`

---

## File Changes Summary

| File | Change |
|------|--------|
| `lib/core/activity_types.dart` | Replace `'Spánek'` with `'Zábava'` in list and color map |
| `lib/ui/screens/statistics_screen.dart` | Add swipe gesture + fix refresh on tab switch |
| `lib/ui/widgets/manual_entry_sheet.dart` | Async load last entry's end time as default start |
| `lib/app.dart` | Invalidate `statisticsProvider` on tab switch to statistics |

---

## Constraints

- No new packages needed — `GestureDetector` is built into Flutter.
- The statistics refresh fix must not cause infinite rebuilds (invalidate once per tab switch, not on every build).
- Swipe should not conflict with horizontal scrolling if any exists in the stats body (currently only vertical ListView, so no conflict).
- The `_initDefaultTimes` async pattern must handle the case where the widget is disposed before the query completes.
