# TimeLog — Features

The full list of what the app does. For a short overview see [README.md](README.md); for
internals see [timelog_app/DOCS.md](timelog_app/DOCS.md).

The bottom navigation has four tabs: Timer, History, Statistics and Settings.

## Timer

- Countdown timer with adjustable duration (5–60 minutes, 5-minute steps)
- Alarm sound and a native notification when the timer finishes, even while backgrounded
- iOS Live Activity / Dynamic Island support with pause/resume/stop actions from the lock screen
- A running or paused timer is restored after the app is restarted

## Logging

- Automatic time-entry logging on timer completion or manual stop; the entry is tagged with a
  description and an activity type
- Twelve built-in activity types — Work, Housework, Meeting, Communication, Travel,
  Entertainment, Exercise, Self-development, Rest, Hygiene, Meal and Other — each with its own
  colour. Most have subtypes (for example paid / unpaid work, walk / running / gym, breakfast /
  lunch / dinner / snack / shopping) shown as shades of the type's colour
- Optional project name for Work and Housework, and a free-text name for Other, with
  autocomplete suggestions that are kept separate for paid work, unpaid work, housework and
  other activities

## History

- Day navigation, a daily summary, per-entry edit and delete
- Manually adding a past entry

## Statistics

- Daily/weekly toggle and a visual timeline of the day's or week's entries
- Time breakdown by activity type (with subtypes), by project and by name for Other entries
- An untracked-time summary

## Reminders

- A daily reminder notification (toggle + time picker) that nudges you to start a timer, and
  can auto-start one when tapped
- Recurring reminders for habits: each has a time window, a repeat interval and active days,
  repeats until you mark it done, and can be snoozed

## Look and language

- Three colour themes (Ember, Midnight, Paper); Midnight is the default
- Czech and English

## Platforms and storage

- **Data export**: Settings → Data → Export data saves every table and the stored settings into one JSON file and opens the share sheet (see DOCS.md)
- Fully offline — entries are persisted locally in SQLite (no server, no account)
- Cross-platform Flutter app: Android, iOS, Linux, macOS, Windows, Web

## Not reachable at the moment

The Tasks screen (a to-do list with projects) is still in the code, but it was removed from the
bottom navigation when History became its own tab.
