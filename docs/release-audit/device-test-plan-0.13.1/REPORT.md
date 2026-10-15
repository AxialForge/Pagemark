# Pagemark 0.13.1 - Step-by-step test plan for the Samsung Galaxy S25 Ultra

How to use this document: work top to bottom. Each test has numbered steps, the result you should see, and boxes to tick. Write anything odd in the Notes column, or take a screenshot (Power + Volume Down). Plan on 2 to 3 hours in total; the notification and background checks need waiting time, so start those first (Part 1).

Tick **P** for pass, **F** for fail, **S** for skipped. If a test fails, do not stop: note it and keep going. At the end, fill in the Summary (Part 14) and send it back.

## Part 0 - Before you start

**What you need**
- The Galaxy S25 Ultra with a screen lock and a fingerprint already set up in Samsung's Settings.
- The file `Pagemark-0.13.1-arm64.apk` (from `C:\Project Folder\Pagemark\build\release-0.13.1`). Copy it to the phone (USB cable, Nearby Share, or Google Drive).
- Wi-Fi, and later a way to switch on airplane mode.
- Three or four real books with barcodes on the back, one of them a book you own twice or already added.
- A free Google Drive or OneDrive app on the phone (for the cloud-folder backup test), and optionally a second phone for the restore test.
- Optional for test 12.4: the free app PCAPdroid from Google Play (no root needed) to see where the barcode scanner sends data.

**Important:** if Pagemark is already on the phone with books you care about, do test 1.1 first (save a backup), or do all testing on a clean phone profile. The tests below add, delete and restore books.

**Samsung One UI notes**
- Settings paths: Settings > Apps > Pagemark. Battery: Settings > Apps > Pagemark > Battery. Notifications: Settings > Apps > Pagemark > Notifications.
- Samsung's "Sleeping apps" and "Adaptive battery" can stop scheduled backups. Test 9.5 checks this.
- Pagemark's own pages are called: **Library**, **Locked**, **Stats**, **Settings**.

---

## Part 1 - Install, first start and upgrade

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 1.1 | If an older Pagemark is installed: open it, Settings > Backup and restore > **Save a copy as a file**, choose a password, save to Drive. | A backup file is saved; the page shows "last saved" with today's time. | ☐P ☐F ☐S | |
| 1.2 | Open the APK from My Files. If Samsung asks, allow **Install unknown apps** for My Files, then tap **Install**. | Installs over the old version without asking to uninstall. Your books are still there (upgrade test). | ☐P ☐F | |
| 1.3 | Settings > Apps > Pagemark. Look at the version. | Version 0.13.1. | ☐P ☐F | |
| 1.4 | (Clean phone only) Uninstall Pagemark, then install again. Open it. | Three short welcome screens appear. **Skip** works at any time. | ☐P ☐F ☐S | |
| 1.5 | On the last welcome screen choose **Try it with 5 sample books**. | Five classics appear in the Library with a note that they are samples. | ☐P ☐F ☐S | |
| 1.6 | Tap **Remove** on the sample card. | The samples go; any book you added yourself stays. | ☐P ☐F ☐S | |
| 1.7 | Settings > Our promise to you. Read the list of internet uses. | Lists book search, update check and the barcode reader. Matches what you expect. | ☐P ☐F | |

## Part 2 - Adding books

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 2.1 | Library > **Add book**. Type a title (for example "Dune Frank Herbert") and tap the magnifier. | Results with covers appear within a few seconds. | ☐P ☐F | |
| 2.2 | Tap the best match. | The book is added and its page opens. Genres read cleanly: about three, no duplicates, no "(imaginary place)" entries. (Checks PGM-302.) | ☐P ☐F | |
| 2.3 | Add > tap the barcode icon. When Android asks, allow the **Camera**. Scan the back of a real book. | Camera opens, scans, adds the book. The camera permission is asked only now, not at install. | ☐P ☐F | |
| 2.4 | Add > the tick icon (**Scan many books**). Scan 4 books one after another, including one you already have and one barcode that is not in the database (or scan a non-book barcode). | One click per book, duplicates skipped, not-found items listed at the end. | ☐P ☐F | |
| 2.5 | Add > **Add by hand**. Type a title and author only. Save. | The book is added with no cover and no crash. | ☐P ☐F | |
| 2.6 | Open Chrome, find a book page, Share > **Pagemark**. | Pagemark opens with the search already filled in, nothing saved yet. | ☐P ☐F | |
| 2.7 | On a book you edited by hand: three dots > **Refresh details from the internet**. | Your typed details are not ticked; only missing ones are. Applying changes nothing you did not tick. | ☐P ☐F | |
| 2.8 | On a book: **Choose another edition**, pick one. | Only cover, publisher, year, pages and ISBN change. | ☐P ☐F | |
| 2.9 | Settings > Your library: turn **Also search Google Books** off, search a book, then turn it on and search again. | Both work; results may differ in how many are found. Nothing breaks. | ☐P ☐F | |

## Part 3 - Reading log, timer and progress

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 3.1 | Open a book > **Log a read**. Choose **Print**, status **Reading**, a start date today, 4.5 stars, a note. **Save**. | Saved. Half stars work. | ☐P ☐F | |
| 3.2 | On that book tap **Update progress** and move the slider. | Percentage and "days left" update. (If no bar shows, set page count with the pencil.) | ☐P ☐F | |
| 3.3 | Tap **Start** under the progress card. Lock the phone and leave it for 2 minutes. Unlock. | The timer is still running with about 2 minutes counted. | ☐P ☐F | |
| 3.4 | Tap **Stop**, enter a page number. | Minutes and page are saved; the day is marked in the Stats calendar. | ☐P ☐F | |
| 3.5 | Start a timer on book A. Open book B. | Book B shows a way to stop or discard the other timer. You are never stuck with a timer you cannot stop. (Checks PGM-320.) | ☐P ☐F | |
| 3.6 | With the timer on book A running, mark book A **Finished**. | The timer stops or is cleared; no stuck timer is shown anywhere. (Checks PGM-320.) | ☐P ☐F | |
| 3.7 | Add the same book as **Audiobook** in a second read. | Two reads on one book, each with its own format. | ☐P ☐F | |
| 3.8 | **Add quote** on a book. Save. Search for a word from the quote in the Library search box. | The quote shows on the book page and the search finds the book. | ☐P ☐F | |
| 3.9 | Open a book and enter 0 or a huge page count (for example 99999) in the edit page. | Rejected or sensible message; no crash. (Checks PGM-303.) | ☐P ☐F | |

## Part 4 - Library, search, shelves, selection

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 4.1 | Type in the search box (title, then an author, then a note word). | Results narrow as you type. | ☐P ☐F | |
| 4.2 | Tap each chip: **Want to read**, **Reading**, **Finished**. Slide the chips sideways. | Each filters correctly; sideways slide shows formats and shelves. | ☐P ☐F | |
| 4.3 | Tap the sort icon and try each sort. | Order changes each time. | ☐P ☐F | |
| 4.4 | Tap the list icon and try all five looks: Classic, Cover wall, Bookshelf, Spines, Compact. | All render without cut-off text. | ☐P ☐F | |
| 4.5 | Open a book > **+ Shelf** > **New shelf** "Test shelf". Then three dots in Library > **Manage shelves**. | Shelf exists; deleting it later does not delete books. | ☐P ☐F | |
| 4.6 | Press and hold a book, tap two more. Tap the bookmark icon (**Add to shelf**) in the top bar and pick the shelf. Then select the books again, tap the delete icon and tap **Undo** in the black bar at the bottom within 8 seconds. | Multi-select works. Adding to a shelf shows "Added 3 to the shelf" (no Undo for shelves). After delete, **Undo** brings the books back. | ☐P ☐F | |
| 4.7 | Three dots > **Series**. Give a book **Series** and **Number in series** with the pencil first. | Series page lists it with the next book. | ☐P ☐F | |
| 4.8 | Three dots > **Read next order**. Drag a book to the top. | Order sticks after leaving and returning. | ☐P ☐F | |
| 4.9 | Delete a book. Then Settings > Your library > **Deleted books** and restore it. | It returns with its reads. | ☐P ☐F | |

## Part 5 - Stats, goal, sharing

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 5.1 | Open the **Stats** tab. Tap **Set goal** and choose 12. | Charts, ring and calendar show; the month calendar fits on screen. (Checks PGM-300.) | ☐P ☐F | |
| 5.2 | Stats > **Year in books** > **Share picture**. Send it to Drive or Messages. | Picture opens and shows no locked book. | ☐P ☐F | |
| 5.3 | Stats > **Report (PDF)**. Open the result. | PDF opens with your books and no locked ones. | ☐P ☐F | |
| 5.4 | Open a book > **Lend this book**, name a person, remind tomorrow. Then move the phone clock forward one day (Settings > General management > Date and time, switch off automatic) and wait for 10:00 (or set the clock to 09:59). Set automatic time back on afterwards. | A notification at 10:00 that names neither book nor person. **Got it back** cancels the reminder. | ☐P ☐F ☐S | |

## Part 6 - Locked library and privacy

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 6.1 | Tap **Locked** > **Set a PIN** (4 to 12 numbers), twice. Write down the **recovery code**. | PIN set. Recovery code shown once. | ☐P ☐F | |
| 6.2 | Open a book > three dots > **Move to locked library**. | Book disappears from Library, Stats and search, and is in Locked. | ☐P ☐F | |
| 6.3 | Enter the wrong PIN 5 or more times. | You are slowed down and then locked out for a time; a clear message shows. | ☐P ☐F | |
| 6.4 | Unlock with the right PIN. Press **Home** and open the **Recents** screen (swipe up and hold). | The Pagemark thumbnail is **blank** (protected). Opening the app again asks for the PIN. | ☐P ☐F | |
| 6.5 | Try a screenshot (Power + Volume Down) on the Locked screen. | Blocked or black image. | ☐P ☐F | |
| 6.6 | Settings > Privacy and lock: turn on fingerprint unlock. Lock, then unlock with your fingerprint. Also try cancelling and a wrong finger. | Fingerprint unlocks; cancel returns to PIN; wrong finger does not unlock. | ☐P ☐F | |
| 6.7 | On the lock screen tap **Forgot PIN?** and use the recovery code. | PIN reset once and a new recovery code is shown. | ☐P ☐F | |
| 6.8 | Settings > Privacy and lock: **Hide the Locked tab**. Press and hold the word "Library" at the top. | Tab is gone; the long press opens the vault (with PIN). Turn the setting off again after. | ☐P ☐F | |
| 6.9 | In the locked library, scan or search for a book. | A warning says search text goes to the internet; shown once. | ☐P ☐F | |
| 6.10 | Copy some text from a locked book's note, switch to another app, paste. | Note what you see in Notes. (This is an open check from the audit; any result is useful.) | ☐P ☐F | |
| 6.11 | Settings > Privacy and lock: turn on the whole-app lock, set the delay to 0. Press Home and return. | The lock covers the whole app, including any open book. | ☐P ☐F ☐S | |

## Part 7 - Backups, exports, restore

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 7.1 | Settings > Backup and restore > **Save a copy as a file**. Set a password. Save it to Google Drive. | File appears in Drive; size is larger than a few KB. | ☐P ☐F | |
| 7.2 | **Save my list as a spreadsheet**. Open it in Sheets or Excel. | Your books are listed; locked books are not. | ☐P ☐F | |
| 7.3 | **Save backups to a folder automatically** > **Choose a folder**. Pick a folder inside Google Drive or OneDrive. Answer the password question. Tap **Back up now**. | A file named `Pagemark-backup-...` appears in that folder, and the cloud app uploads it. | ☐P ☐F | |
| 7.4 | Add one more book, then **Restore from a file**. Choose the file from 7.1, enter the password. | Pagemark closes. Open it again: the library matches the backup (the extra book is gone). | ☐P ☐F | |
| 7.5 | Immediately restore a **second** file within a minute (or the same one again). | A way back exists: Settings > **Go back to an earlier copy** lists the copies made before each restore. Choose one; the earlier state returns. | ☐P ☐F | |
| 7.6 | Try restoring with a **wrong password**. | Clear error; your library is unchanged. | ☐P ☐F | |
| 7.7 | Settings > Import and export > **Bring in books from another app**, pick a Goodreads or StoryGraph file (or a Pagemark list). | Preview first; import works; **Undo** removes the import. | ☐P ☐F ☐S | |
| 7.8 | (Second phone, optional) Install Pagemark there, restore the file from 7.1. | Library appears, covers included. | ☐P ☐F ☐S | |
| 7.9 | Make storage nearly full (copy large files), then try an export. Free the space afterwards. | A clear error message; the library is untouched. | ☐P ☐F ☐S | |

## Part 8 - Notifications and widget

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 8.1 | Settings > Notifications. Allow when Android asks. | Page shows notifications are on. | ☐P ☐F | |
| 8.2 | Turn on **Daily reading reminder** for 2 minutes from now. | A notification appears at that time and does not name a book. | ☐P ☐F | |
| 8.3 | Settings > Apps > Pagemark > Notifications: switch notifications **off**. Return to Pagemark's Notifications page. | A red box with **Turn on** appears. Tap it and re-allow. | ☐P ☐F | |
| 8.4 | Turn on **Remind me to back up** (every week). | The page shows it is set; no crash. | ☐P ☐F | |
| 8.5 | Long-press an empty home screen > Widgets > Pagemark > Add. | The widget shows books you are reading and your goal. No locked books. | ☐P ☐F | |
| 8.6 | Settings > Widget and shortcuts: switch off showing titles. | Widget shows counts only. | ☐P ☐F | |
| 8.7 | Long-press the Pagemark icon. | Shortcuts **Add book** and **Reading now** work. | ☐P ☐F | |
| 8.8 | Restart the phone. After it boots, wait 2 minutes. | Reminders still scheduled; widget still shows. | ☐P ☐F | |

## Part 9 - Samsung-specific: display, back gesture, battery

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 9.1 | Settings > Display > **Font size and style**: drag to the largest, plus **Bold font**. Open Library, a book, Stats, Settings. | Nothing is cut off or overlapping; buttons still tappable. Set it back after. | ☐P ☐F | |
| 9.2 | Settings > Display > **Screen zoom**: largest. Repeat 9.1 screens. | Same result. Set it back after. | ☐P ☐F | |
| 9.3 | Turn on **Dark mode** (Settings > Display). In Pagemark, try a light and a dark theme (Settings > Appearance). | Text readable in all six themes. | ☐P ☐F | |
| 9.4 | Use the back gesture (swipe from the edge, and slowly to see the preview) from a book page and from Settings. | Goes back one step; never exits unexpectedly. From Library, back leaves the app. | ☐P ☐F | |
| 9.5 | Settings > Apps > Pagemark > Battery: note the setting. Turn on automatic folder backup with the shortest interval and leave the phone idle for two days (do this one over a weekend). | A new backup file appears in the folder on schedule, even with Samsung's battery optimization on. Record which battery mode you used. | ☐P ☐F ☐S | |
| 9.6 | Rotate the phone to landscape on Library, a book, Stats. With a book open, rotate. | Layout adapts; a large-screen two-pane view may appear; no crash or lost scroll. | ☐P ☐F | |
| 9.7 | Open Pagemark in split-screen (Recents > app icon > Open in split screen view) next to Chrome. Drag the divider. | Usable at every size. | ☐P ☐F | |
| 9.8 | Open the book page, press Home, open another heavy app for 5 minutes, return. | Pagemark returns to where you were or to the Library; no data lost. | ☐P ☐F | |
| 9.9 | Turn on **Reduce animations** (Settings > Accessibility > Visibility enhancements). Move through screens. | No problems. Turn off afterwards. | ☐P ☐F ☐S | |

## Part 10 - Accessibility (TalkBack)

Turn TalkBack on: Settings > Accessibility > **TalkBack**. Swipe right to move, double-tap to activate. Turn it off after.

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 10.1 | Walk the Library: search box, chips, a book, Add book, the bottom tabs. | Every item is spoken with a meaningful name. Icon buttons have names, not "button". | ☐P ☐F | |
| 10.2 | Add a book by hand and give it a rating with swipe. | You can set the rating without seeing the screen. | ☐P ☐F | |
| 10.3 | Open Stats and move over calendar days. | Days are announced with a date and whether you read. | ☐P ☐F | |
| 10.4 | In Read next order, reorder one book. | There is a way to move it without dragging (for example move up or down actions). | ☐P ☐F | |
| 10.5 | Lend a book while TalkBack is on. | Form fields are labelled. | ☐P ☐F | |

## Part 11 - Offline and errors

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 11.1 | Turn on airplane mode. Open Pagemark. | Opens normally; library readable. | ☐P ☐F | |
| 11.2 | Offline: add a book by hand, open covers, try a book search. | By-hand works; search shows a clear message; no crash. | ☐P ☐F | |
| 11.3 | Offline: scan a barcode. | A message says the book could not be looked up; the barcode is kept for adding by hand. | ☐P ☐F | |
| 11.4 | Turn airplane mode off. Search again. | Works again without restarting. | ☐P ☐F | |
| 11.5 | Change the time zone (Settings > General management > Date and time > Time zone), finish a book, change the zone again. | The finished date stays on the day you finished. Turn automatic time zone back on after. | ☐P ☐F ☐S | |

## Part 12 - Updates and the barcode scanner's data (store form checks)

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 12.1 | Settings > Updates > check for updates. | A clear result ("up to date" or a newer version). | ☐P ☐F | |
| 12.2 | If a newer version is offered, tap Download and install. Allow Install unknown apps for Pagemark when asked. | Downloads, verifies, installs over the top, data intact, no "App not installed" error. | ☐P ☐F ☐S | |
| 12.3 | Settings > Updates: turn off **Check automatically**. | The setting stays off after restarting the app. | ☐P ☐F | |
| 12.4 | Install **PCAPdroid** (free). Start a capture for Pagemark only. In Pagemark, open the barcode scanner and scan two books, then stop the capture. Look at the connections list. | Record every host Pagemark or Google Play services contacts during the scan. Expected: only Open Library and Google Books after a scan. Anything else (for example a Google diagnostics address) must be written in Notes. This answers the Google Play Data safety question (MOB-PRV-0002). | ☐P ☐F ☐S | |
| 12.5 | Settings > Help and about > **What's new** and **Problem report** > **Copy**. Paste it into a note. | Opens; the report has error lines but no book titles. | ☐P ☐F | |

## Part 13 - Final checks

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 13.1 | Settings > Apps > Pagemark > **Permissions**. | Only Camera and Notifications are listed (and Nearby/other items only if you used them). No Location, Contacts, Microphone, Storage. | ☐P ☐F | |
| 13.2 | Settings > Apps > Pagemark > **Mobile data**. Look at the data used during the day. | A small number of megabytes at most. | ☐P ☐F | |
| 13.3 | Use the app normally for 10 minutes, scrolling a library of 20 or more books. | Smooth scrolling, no stutter, no heat. | ☐P ☐F | |
| 13.4 | Settings > Apps > Pagemark > **Storage**: **Clear cache**. Reopen. | Library intact, covers reload. | ☐P ☐F | |
| 13.5 | Uninstall Pagemark, then reinstall and restore your backup. | Data returns from the backup; nothing hidden is left behind that you did not expect. | ☐P ☐F ☐S | |

## Part 14 - Summary to send back

Phone: Samsung Galaxy S25 Ultra. One UI version: ______  Android version: ______  Pagemark version: ______  Date tested: ______

| Item | Count |
|---|---|
| Tests passed | |
| Tests failed (list numbers) | |
| Skipped (list numbers) | |
| Anything that crashed or froze | |
| Hosts seen in test 12.4 | |
| Battery mode used in 9.5 | |

For each failed test: the test number, what you did, what you saw, and a screenshot or screen recording (swipe down twice > **Screen recorder**). Send the summary and files back to Claude to turn into findings.

## Appendix - Where each test comes from

| Tests | Source |
|---|---|
| 2.2, 3.5, 3.6, 3.9, 5.1 | Fixes marked ready for verification in the 1.0.0 gate audit (PGM-302, PGM-320, PGM-303, PGM-300) |
| 6.4, 6.5, 6.10 | Mobile audit: recents thumbnail and clipboard not yet tested (MOB-SEC area) |
| 12.4 | Mobile audit finding MOB-PRV-0002 (Google Play Data safety form) |
| 9.5 | Samsung battery manager risk from the repository audit (scheduled backups) |
| Parts 7, 8, 10 and the rest | docs/release-audit/MANUAL_TEST_PLAN.md and the in-app guide |
