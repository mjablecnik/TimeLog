# BRIEF – Planned Changes

## 1. Confirmation dialog on Stop/Reset

When the user taps the Stop or Reset button, show a confirmation dialog asking "Do you really want to reset the timer?" The user must confirm before the timer is actually reset.

## 2. Ringing behavior when app is opened

When the timer finishes and the app starts beeping, opening the app should:
- Immediately stop the beeping
- Skip the dismiss dialog entirely
- Show the description input dialog right away

## 3. Activity type on description input

Add a type selector to the description dialog with these options:
- Práce
- Volný čas
- Odpočinek
- Spánek

The selected type must be:
- Visible in the history list next to each entry's description
- Persisted so the last chosen type is pre-selected as the default next time

## 4. Date format in history

When scrolling further into history, display dates in the format: `9. 7. 2026` (day. month. year with spaces after dots).

## 5. Flag button behavior change

When the user taps the flag (finish now) button:
- Do NOT start beeping
- Instead, immediately show the description input dialog (same as point 2)
- Beeping should only happen when the timer expires naturally and the user is not present / the app is in background

## 6. Theme switcher location

Remove the theme switcher from the history page. It should only exist on the timer page.
