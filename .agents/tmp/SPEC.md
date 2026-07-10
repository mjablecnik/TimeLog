# Timelog App — Bug Fix Specification

## Overview

This specification addresses 5 implementation issues found during code review of the `timelog_app` Flutter project. The app is a Pomodoro-style timer with theming, history tracking, and persistence. All issues are deviations from the design prototype and requirements.

## Technical Context

- **Framework:** Flutter with Riverpod (StateNotifier pattern)
- **State persistence:** SharedPreferences
- **Code generation:** Freezed for immutable state classes
- **Design reference:** `timelog_app/.design/Pomodoro.dc.html`

## Issues & Technical Approach

### Issue 1: Duration Adjuster Not Persisted

**Problem:** `_adjustedMinutes` in `_TimerScreenState` resets to 20 on every app launch. The timer service persists `totalSeconds` via SharedPreferences, but the UI ignores this.

**Approach:** On init, derive `_adjustedMinutes` from the persisted `totalSeconds` in the timer state. Additionally, persist `_adjustedMinutes` directly to SharedPreferences when it changes, so the idle-screen value survives restarts even when the timer hasn't been started.

**Files affected:**
- `lib/ui/screens/timer_screen.dart` — read persisted value on init, write on change

### Issue 2: Midnight Theme Colors Incorrect

**Problem:** Current implementation uses wrong hex values for the Midnight theme.

**Correct values from prototype:**
- `bg: #0F1319` (currently `#0D1117`)
- `accent: #78B4C4` (currently `#58A6FF`)
- `text: #E6EAF2` (currently `#E6EDF3`)

**Files affected:**
- `lib/core/theme.dart` — update `AppThemeData.midnight` static const

### Issue 3: Paper Theme Colors Incorrect

**Problem:** Current implementation uses wrong hex values for the Paper theme.

**Correct values from prototype:**
- `bg: #F3EEE6` (currently `#F5F0EB`)
- `accent: #C25E3C` (currently `#9B4523`)
- `text: #2B2420` (currently `#2C2420`)

**Files affected:**
- `lib/core/theme.dart` — update `AppThemeData.paper` static const

### Issue 4: finishNow() End Time Inaccuracy

**Problem:** When the user presses "Finish Now", the end timestamp is captured in the UI listener (`_ringStartedAt = DateTime.now()` on state transition to `ringing`), which fires one frame after `finishNow()` is called. This introduces a small delay.

**Approach:** Capture `DateTime.now()` inside `TimerNotifier.finishNow()` and store it in the `TimerState.endAt` field (or a new dedicated field). The UI then uses this precise timestamp instead of approximating it.

**Files affected:**
- `lib/services/timer_service.dart` — capture end time in `finishNow()` and expose via state
- `lib/ui/screens/timer_screen.dart` — use `timerState.endAt` (or equivalent) instead of `_ringStartedAt`

### Issue 5: Duration Adjuster Not Extracted to Separate Widget

**Problem:** The `_StepButton` class and duration adjuster UI is inlined in `timer_screen.dart`. The design spec requires a separate `lib/ui/widgets/duration_adjuster.dart`.

**Approach:** Extract the duration adjuster Row (with decrement button, label, increment button) and the `_StepButton` into `lib/ui/widgets/duration_adjuster.dart` as a public widget. The timer screen imports and uses this widget.

**Files affected:**
- `lib/ui/widgets/duration_adjuster.dart` — new file
- `lib/ui/screens/timer_screen.dart` — remove inlined code, import new widget

## File Structure (Changes Only)

```
lib/
├── ui/
│   ├── screens/
│   │   └── timer_screen.dart        # modified (issues 1, 4, 5)
│   └── widgets/
│       └── duration_adjuster.dart   # new (issue 5)
├── services/
│   └── timer_service.dart           # modified (issue 4)
└── core/
    └── theme.dart                   # modified (issues 2, 3)
```

## Constraints & Considerations

- **Freezed regeneration:** Changes to `TimerState` fields in `timer_service.dart` require running `dart run build_runner build` to regenerate `timer_service.freezed.dart`.
- **SharedPreferences key naming:** Use `timer_adjustedMinutes` as the persistence key for the duration adjuster, consistent with existing `timer_*` key convention.
- **Derived colors:** When updating `bg`, `text`, and `accent`, the derived colors (`ink`, `dim`, `faint`, `glow`, `glowSoft`) that depend on them should also be reviewed. The `ink` value for Midnight changes to `#08131a` and for Paper changes to `#FBF7F1` per the prototype.
- **No behavior change to `start()`:** The `setDuration()` call before `start()` already handles syncing `_adjustedMinutes` to `totalSeconds`. Persistence of `_adjustedMinutes` is purely for UI restoration.
- **The `endAt` field already exists in `TimerState`:** We can repurpose it in `finishNow()` to store the precise finish timestamp rather than adding a new field. After `finishNow()`, `endAt` is set to `null` — instead, set it to `DateTime.now()` at the moment of finish.
