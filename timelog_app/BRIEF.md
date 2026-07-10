# Implementation Issues

Issues found during code review against the specification at `.kiro/specs/timelog-timer/requirements.md`.

## 1. Duration adjuster not persisted across app launches

**Spec reference:** Requirement 15, Acceptance Criterion 8

> THE App SHALL persist the adjusted duration value across app launches so that the previously adjusted value is restored on the next app start

**Problem:** `_adjustedMinutes` is local state in `_TimerScreenState`. When the app restarts, it resets to 20 minutes instead of restoring the last user-adjusted value. The timer service restores `totalSeconds` via SharedPreferences, but the UI stepper ignores this and always shows 20.

**Fix:** Read/write `_adjustedMinutes` from SharedPreferences (or derive it from the persisted `totalSeconds` on init).

---

## 2. Midnight theme colors do not match prototype

**Spec reference:** Requirement 11, Acceptance Criterion 1

> THE App SHALL replicate the visual design defined in the HTML/JS prototype located at `timelog_app/.design/Pomodoro.dc.html`

**Problem:** The prototype defines Midnight as:
- `bg: #0F1319`
- `accent: #78B4C4`
- `text: #E6EAF2`

Current implementation uses:
- `background: 0xFF0D1117`
- `accent: 0xFF58A6FF`
- `text: 0xFFE6EDF3`

**Fix:** Update `AppThemeData.midnight` in `lib/core/theme.dart` to use the exact hex values from the prototype.

---

## 3. Paper theme colors do not match prototype

**Spec reference:** Requirement 11, Acceptance Criterion 1

> THE App SHALL replicate the visual design defined in the HTML/JS prototype located at `timelog_app/.design/Pomodoro.dc.html`

**Problem:** The prototype defines Paper as:
- `bg: #F3EEE6`
- `accent: #C25E3C`
- `text: #2B2420`

Current implementation uses:
- `background: 0xFFF5F0EB`
- `accent: 0xFF9B4523`
- `text: 0xFF2C2420`

**Fix:** Update `AppThemeData.paper` in `lib/core/theme.dart` to use the exact hex values from the prototype.

---

## 4. finishNow() end time may have frame-delay inaccuracy

**Spec reference:** Requirement 14, Acceptance Criterion 4

> THE App SHALL save the Time_Entry to the Local_Database with the timer's original start time as the start time and the moment the user pressed the finish-now button as the end time

**Problem:** In `timer_screen.dart`, `_ringStartedAt` is set in the `ref.listen` callback when the state transitions to `ringing`. For `finishNow()`, this timestamp is captured slightly after the user pressed the button (one frame later due to `ref.listen` async timing). The actual moment the user pressed the button is when `finishNow()` is called in `timer_service.dart`.

**Fix:** Capture the finish timestamp directly in `TimerNotifier.finishNow()` and expose it via state (e.g., store it as `endAt` or a dedicated field) instead of relying on the UI listener to approximate the time.

---

## 5. Inlined duration adjuster widget vs design file structure

**Spec reference:** Requirement 11, Acceptance Criterion 1 (visual design compliance); Design document file structure

**Problem:** The design document specifies a separate `lib/ui/widgets/duration_adjuster.dart` widget. The current implementation inlines this as a private `_StepButton` class inside `timer_screen.dart`.

**Fix:** Extract the duration adjuster into its own `lib/ui/widgets/duration_adjuster.dart` file to match the specified file structure.
