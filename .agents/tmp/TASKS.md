# Tasks

- [x] 1. [HIGH] Update Midnight theme colors in `lib/core/theme.dart` — change `background` to `0xFF0F1319`, `accent` to `0xFF78B4C4`, `text` to `0xFFE6EAF2`, `ink` to `0xFF08131A`, and update derived colors (`dim`, `faint`, `glow`, `glowSoft`) to use the new base values
- [x] 2. [HIGH] Update Paper theme colors in `lib/core/theme.dart` — change `background` to `0xFFF3EEE6`, `accent` to `0xFFC25E3C`, `text` to `0xFF2B2420`, `ink` to `0xFFFBF7F1`, and update derived colors (`dim`, `faint`, `glow`, `glowSoft`) to use the new base values
- [x] 3. [HIGH] Fix `finishNow()` in `lib/services/timer_service.dart` — capture `DateTime.now()` as the end timestamp and store it in the state (use the existing `endAt` field) instead of setting `endAt: null`
- [x] 4. [HIGH] Update `timer_screen.dart` to use `timerState.endAt` from the finish-now state transition instead of `_ringStartedAt` when passing the end time to `DescriptionSheet`
- [x] 5. [HIGH] Persist `_adjustedMinutes` to SharedPreferences in `timer_screen.dart` — write the value whenever it changes (in `_incrementDuration` and `_decrementDuration`)
- [x] 6. [HIGH] Restore `_adjustedMinutes` from SharedPreferences on `_TimerScreenState.initState()` — read the persisted value and fall back to deriving it from `timerState.totalSeconds / 60` if not set
- [x] 7. [MEDIUM] Extract duration adjuster into `lib/ui/widgets/duration_adjuster.dart` — move the `_StepButton` class and the adjuster Row into a new public `DurationAdjuster` widget accepting `minutes`, `onIncrement`, `onDecrement`, `min`, `max`, and `theme` parameters
- [x] 8. [MEDIUM] Update `timer_screen.dart` to import and use the extracted `DurationAdjuster` widget, removing the inlined `_StepButton` class and adjuster Row code
- [x] 9. [LOW] Run `dart run build_runner build` to regenerate `timer_service.freezed.dart` if any `TimerState` field changes were needed (verify the existing `endAt` field suffices)
- [x] 10. [LOW] Verify the app builds cleanly after all changes (`flutter build linux --release` or `flutter analyze`)
