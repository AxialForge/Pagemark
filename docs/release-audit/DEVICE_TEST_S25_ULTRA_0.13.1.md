# Device test results - Pagemark 0.13.1 on a Samsung Galaxy S25 Ultra

Tested by the owner on 2026-10-14 with the printed plan "Pagemark 0.13.1 Galaxy S25 Ultra test plan" (Rev 1.2), handwritten results scanned to PDF. Transcribed and checked against the code on 2026-10-15.

## Summary

| | Count |
|---|---|
| Passed | 70 |
| Failed | 13 |
| Skipped | 10 (7.7, 7.8, 7.9, 9.5, 9.9 and all five TalkBack tests 10.1 to 10.5) |
| Crashes or freezes | none |

The 13 failures were: 2.8, 3.2, 3.9, 4.6, 5.4, 6.6, 6.8, 8.2, 8.3, 9.4, 9.6, 11.3 and 13.1. Of these, **7 are app problems, 3 are mistakes in my test plan, and 3 need more information from you** (see the tables).

All the 0.13.1 audit fixes that were on the plan **passed on the real phone**: tidy genres (2.2), stuck timer (3.5, 3.6), Stats calendar fits the screen (5.1), year card and PDF report without locked books (5.2, 5.3). Install over an older version, restore, folder backup, whole-app lock, recents blank, offline use, update check, widget and shortcuts, font and display size at largest, dark themes and split screen all passed.

## App problems (findings)

| ID | Sev | Test | What happened | Likely cause | Status |
|---|---|---|---|---|---|
| PGM-330 | MEDIUM | 9.6 | In landscape the Library cannot be scrolled past "Currently reading": the search box, filter chips and the reading strip use up the whole height. | `lib/ui/library.dart` puts the strip above the list in a fixed Column; a landscape phone has about 360 dp of height. | OPEN |
| PGM-331 | MEDIUM | 9.4 | The back gesture on Stats, Locked or Settings closes the app instead of going back to Library. | The Home shell has no back handling for the other tabs (only the Library's selection mode does). | OPEN |
| PGM-332 | HIGH (until explained) | 8.2, 5.4 | The daily reading reminder set for 2 minutes ahead never showed ("no notify"). The loan reminder could not be tested (see PGM-340). | Not diagnosed. Reminders use inexact alarms; Samsung battery rules may delay or drop them. Could also be a release-build problem. Nothing in the code or the APK shows a fault. | OPEN, NEEDS INFO |
| PGM-333 | LOW | 3.9 | Editing a book accepts 0 or 99999 pages. The 0.13.1 fix only covered lookup results. | `EditBook` saves any whole number for pages and year. | OPEN |
| PGM-334 | LOW | 4.6 | Adding selected books to a shelf has no Undo (moving to Trash, Finished and Locked do). | `_bulkShelf` in `lib/ui/library.dart` shows no undo bar. | OPEN |
| PGM-335 | LOW | 2.8 | "Choose another edition" did not appear in Refresh details. | The button only shows when the lookup returned an Open Library work id; some lookups (by ISBN or from Google) have none. | OPEN |
| PGM-336 | LOW | 2.4 and your note 1 | In Scan many books, a book that could not be found showed an internet problem note instead of "not found". | A busy or failed lookup is shown as "No internet" and the real reason is lost. | OPEN |
| PGM-337 | LOW | 11.2 | Offline, a book search says "Nothing found" as well as the connection message. | After a failed lookup the empty results list still shows the "Nothing found" card. | OPEN |

## Mistakes in the test plan (not app problems)

| Test | Plan said | Reality | Action |
|---|---|---|---|
| 3.2 | Move a progress slider | There is no slider; Update progress asks for the current page, and the percentage and days left update from that. | Fix the plan wording. Your note "no slider, just a Current page window" is exactly right. |
| 5.4 | Choose "remind tomorrow" | The choices are 2 weeks, 1 month, 2 months, none. A one-day reminder cannot be tested. | Add "Tomorrow" and "In a week" to Lend this book (PGM-340), and fix the plan. |
| 6.6 | Turn on fingerprint in Settings | Fingerprint is chosen when the lock is created and offered on the lock screen; Settings, Privacy and lock has no fingerprint switch. | Fix the plan. Whether Settings should offer it is a design choice (PGM-338). |

## Need more information from you

| Test | Your note | Question |
|---|---|---|
| 6.8 | Hide the Locked tab: "locked library does not show up" | After pressing and holding the word "Library" at the top, did the PIN screen not appear at all, or did the tab not disappear? |
| 8.3 | "no main" | I could not read this. Did the red "Turn on" box not appear on the Notifications page after switching notifications off? |
| 11.3 | Offline scan failed | What did you see? The plan expected "could not be looked up" and the barcode number kept in the search box. |
| 13.1 | "Nearby devices?" | Pagemark asks for no Bluetooth or Nearby permission (its manifest has none). Samsung and Android 16 list "Nearby devices" for apps that use the network. I believe it is the phone, but please tell me if it shows as Allowed. (INFO, PGM-339) |

## Your ideas (added to the roadmap as requests, not findings)

1. **Search results look cramped** and may need borders (2.1). Covers seem to load slowly (2.3, 13.4 "good but slow").
2. **Quick start guide** needed after install (1.2). The in-app guide exists but is not offered on first launch.
3. **Take a photo of the cover and crop it** when a book is added by hand (2.5).
4. **Library search should also search online** when nothing is found locally (2.9).
5. **Reading timer notification** so it shows on the lock screen while running (3.3).
6. **Reading timer on the book page without logging a read first** (3.5).
7. **Copy a book's title** by pressing and holding it.

## Not tested

TalkBack (10.1 to 10.5), fingerprint unlock cancel and wrong finger (6.6 by plan error), restore on a second phone (7.8), full storage (7.9), file import with Undo (7.7), scheduled backups over two days with Samsung's battery manager (9.5), reduce animations (9.9). These stay on the manual test plan.

## Audit evidence

Scanned results: `Documents\PageMark_.13.1_Galaxy_S25_Ultra_Test_Plan.pdf` (9 pages). A recovery code is written on page 4 of the scan; it belongs to the test phone's locked library and is not copied here.
