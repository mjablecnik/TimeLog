# TimeLog Roadmap

Planned changes to how an entry is typed, kept in one place so they can be reviewed
together before anything is built. Everything under "Already in the app" is taken from the
code (`timelog_app/lib/core/activity_types.dart`), not from the README. Status as of
2026-11-19: everything in "Proposed structure and colours" is implemented in version 1.1.0
(spec `001-activity-subtypes`).

The goal is a type structure that is simple but functional: few main types, a small number
of subgroups where they really help, and colours in the statistics that stay tellable apart.

## Before 1.1.0

Nine flat main types, one colour each. Only Entertainment has subtypes (active / passive),
stored with the entry but **not** reflected in any colour: statistics colour by main type only.

| Type | Subtypes | Project field | Dark theme | Light theme |
|---|---|---|---|---|
| Work (`Práce`) | – | yes | red 400 `#EF5350` | same |
| Housework (`Domácí práce`) | – | yes | orange 300 `#FFB74D` | orange 700 `#F57C00` |
| Commute (`Přesun`) | – | no | indigo 300 `#7986CB` | indigo 400 `#5C6BC0` |
| Entertainment (`Zábava`) | active, passive | no | teal 300 `#4DB6AC` | teal 400 `#26A69A` |
| Exercise (`Cvičení`) | – | no | amber 600 `#FFB300` | same |
| Self-development (`Seberozvoj`) | – | no | green 400 `#66BB6A` | same |
| Rest (`Odpočinek`) | – | no | blue 400 `#42A5F5` | same |
| Hygiene (`Hygiena`) | – | no | blue 300 `#64B5F6` | blue 900 `#0D47A1` |
| Meal (`Jídlo`) | – | no | purple 200 `#CE93D8` | purple 900 `#4A148C` |

Unknown types fall back to grey 400 `#BDBDBD`. Colours are used by the day timeline, the
statistics breakdown by type and the history badges.

Things worth a look when reviewing the palette:

- **Rest and Hygiene are nearly the same blue** in the dark theme (blue 400 vs blue 300),
  so they are hard to tell apart in the timeline and the statistics.
- Entertainment (teal) and Self-development (green) are also close neighbours.
- In the light theme Hygiene and Meal switch to very dark shades (blue 900, purple 900),
  much heavier than every other type.

## Decisions so far

- **Paid / unpaid work is a flag on Work, not a separate type.** Same type, two shades of
  the same colour: paid is the darker one, unpaid slightly lighter.
- **Toilet goes under Hygiene** as a subgroup, with a slightly different shade of the
  Hygiene colour.
- **Self-development gets subgroups**, for example reading books, study, consulting an AI.
- **Meeting and Communication are their own main types.**
- **Meal gets subgroups** (breakfast, lunch, dinner, snack) as four shades of brown.
- **In the entry sheet the subgroup row sits in its own framed block** with a heading ("Upřesni: <type>") and extra space above it, so it is not overlooked.
- **A catch-all `Ostatní` type is added** with a free-text name instead of a project, for anything that fits no type. Names that recur are candidates for a real type or subgroup.
- **Exercise gets subgroups** (walk, running, gym) and **Rest gets active / passive**, each as shades of one hue.
- **Commute is renamed Travel**, and Entertainment's active / passive subtypes get separate colours.
- **Rest and Hygiene get clearly different colours**, and Entertainment and Self-development
  are pulled further apart too.
- Subgroups share the hue of their main type and differ only in shade, so the statistics
  stay readable at the main-type level and the subgroup is still recognisable.

## Structure and colours (implemented in 1.1.0)

Main type, its subgroups and the colour each would show in the statistics. Meeting and
Communication are their own main types. A subgroup keeps the hue of its main type and only
changes the shade. Hex values are the dark themes (Midnight, Ember); the light theme (Paper)
uses darker equivalents of the same hues, listed on the preview page. Everything here is a
proposal to be judged on screen.

| Main type | Subgroup | Colour | Change from today |
|---|---|---|---|
| Work | paid | `#BC2D34` | darker red |
| Work | unpaid | `#D9595E` | lighter red |
| Housework | – | `#F2994A` | slightly shifted orange |
| Meeting | – | `#B27CF0` | new, violet |
| Communication | – | `#F06BB0` | new, pink (Messenger, phone) |
| Travel (renamed from Commute) | – | `#93A0B4` | indigo to neutral slate; the stored key `Přesun` stays, only the label changes |
| Entertainment | active | `#2CC4B0` | teal, deeper shade |
| Entertainment | passive | `#7FD9CC` | teal, lighter shade; today both share one colour |
| Exercise | walk | `#F3E58A` | new subgroup, lightest |
| Exercise | running | `#E8D04A` | new subgroup; the main colour, amber to a clearer yellow |
| Exercise | gym | `#C9A92A` | new subgroup, deepest |
| Self-development | reading books | `#B0E08E` | |
| Self-development | study | `#86C95E` | |
| Self-development | AI consultation | `#5FAE3C` | |
| Rest | active | `#4A78F0` | new subgroup, deeper blue |
| Rest | passive | `#8AA8F6` | new subgroup, lighter blue |
| Hygiene | general | `#46C6EE` | blue to cyan |
| Hygiene | toilet | `#8ED9F6` | lighter cyan |
| Meal | breakfast | `#C49A68` | purple to brown; new subgroup |
| Meal | lunch | `#A97C50` | new subgroup, the main colour |
| Meal | dinner | `#856036` | new subgroup, darkest |
| Meal | snack | `#D9B88F` | new subgroup, lightest |
| Other (`Ostatní`) | – | `#C9C3B8` | new; the entry carries a free-text name (like the project for Work), shown in the statistics by name; dashed chip in the picker |

What this fixes, measured as perceptual colour distance (CIELAB ΔE, higher is easier to tell
apart): Rest and Hygiene go from 10.7 to about 36 apart, Housework and Exercise from 19 to
37. The closest pairs left are Rest and Meeting (26) and Hygiene and Travel (30). Eleven
main colours is close to the limit of what can be told apart at a glance, so names and
labels in the statistics still matter. The three Self-development greens are only 12 to 18
apart, so reading books, study and AI consultation are best told apart by label.

Rendered previews on the app's three backgrounds (Midnight, Ember, Paper) are kept in
`timelog_app/.design/`: `activity-palette.html` (types, subtypes and colours) and
`activity-types-ux.html` (entry sheet, history, statistics and the Tasks tab).

## Still undecided

- Sleep, family / friends and errands have no type; they are left to Other until the data shows they recur.
- Subgroup preselection: the last used one, else the first, so submitting is never blocked. Statistics show subgroups either always or on tap; see the UX preview page.
- **Analysis / comparing new things** has no home yet: its own main type, or a subgroup of
  Self-development? It has no colour until then.
- What happens to entries already saved: old Work entries have no paid/unpaid flag, and old
  Self-development entries have no subgroup.
- Should the statistics show subgroups as separate rows, or only inside a type's detail?
- Is a subgroup picker shown only after choosing the main type, as for Entertainment today?
- The light-theme shades of the three Self-development subgroups are close and need a look
  on the real screen.

## Future refactoring

- `timelog_app/lib/ui/widgets/` holds 20 source files, over the 15-file ceiling in the project structure standard. Spec `001-activity-subtypes` puts its new widgets into a subdirectory (`activity_picker/`) and does not move the existing ones. Reorganise the directory into subdirectories by responsibility (for example sheets, cards, tasks, reminders) in a later change, and add `scripts/check-structure.sh` so the limit is enforced.
- `timelog_app/test/` holds 26 files in one flat directory. Split it into subdirectories that mirror `lib/` at the same time.
