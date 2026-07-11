# BRIEF – Planned Changes

## 1. Activity type colors

Each activity type has a distinct color used in the type badge (description dialog + history):
- **Práce** — red
- **Volný čas** — green
- **Odpočinek** — blue
- **Spánek** — black or dark blue
- **Cvičení** — dark orange

Add "Cvičení" as a new activity type option.

## 2. Pre-fill description while timer is running

While the timer is running, provide a button (or similar UI element) that allows the user to write a description in advance.

Behavior:
- Tapping the button pauses the timer (but does NOT stop/finish it)
- Opens the description input dialog (with the activity type selector)
- The user fills in the description and type, then confirms
- The timer resumes counting from where it was paused
- When the timer eventually finishes (naturally or via flag/stop) and the description dialog appears, the previously entered description and activity type are pre-filled
- The pre-filled description applies only to the current session — once the entry is saved, it is cleared

## 3. Stop button should not auto-restart timer

After the user taps Stop, confirms the reset, and submits the description, the timer must NOT auto-restart. It should return to the idle state.

Auto-restart (starting a new session automatically) should only happen when the timer finishes via the flag (finish now) button or when it expires naturally.

## 4. Skip description option

The description dialog must have a "Skip" button that:
- Saves the time entry with the selected activity type but with an empty description
- Behaves the same as submit (auto-restart or idle depending on how the timer ended)

## 5. Skip ringing overlay when app is in foreground

When the timer expires while the app is already in the foreground, do not show the ringing overlay at all. Transition directly from running → logging (show the description dialog). The ringing overlay and alarm sound should only activate when the app is in the background or the user is not present.
