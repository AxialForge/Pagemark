# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-10-18

### Added
- **Series and volumes** for manga, comics and light novels. Open a series (Library ⋮ menu → Series, then tap it) to see one square for every volume: read (filled), owned (outlined), wanted (dashed) or missing (grey). Tap a square to open it, or tap a grey one to add it as owned or wanted. **Add volume** adds the next volume with the series, author and kind filled in, and **Share missing list** shares a note like "Berserk: missing 3-5, 7".
- Say whether a series is **Ongoing** or **Complete**, how many volumes it has, and whether it is **Manga**, **Comic** or **Light novel**. Pagemark never guesses these, and there is no new internet source.
- **Group volumes by series** in the Library (style button): one row per series with a small stack of covers. It turns on by itself when a series has three or more volumes, and searching still shows every volume. The grouped Library is a list in every style.
- On a book's page: "Series: Berserk, volume 4 of 12" that opens the series, **Previous volume** and **Next volume**, and in Edit **Kind** and **I own this** (a book you do not own stays on your list as wanted).
- When you add a book whose title ends in a volume number ("One Piece, Vol. 12"), Pagemark asks whether it is volume 12 of One Piece. In Scan many books a button beside each book offers the same. Nothing changes unless you tap it.
- Stats: a **Series and volumes** card (volumes read, series completed, finished books by kind).
- Export and import carry `kind`, `owned` and `series_status`; older files without them import as before.
- Database schema 7 (`kind`, `owned`, a series table). Every earlier schema upgrades and keeps its rows; each series' total from older versions is carried over.

### Changed
- The Series screen is now a list of series that open a page of their own. The number of volumes is kept once per series (in the Series page) instead of on every book; the old per-book "Books in the series" still works as a fallback.

## [1.0.0] - 2026-10-16

First stable release. No new features: this is the 0.13.4 app, audited, device-tested on a Galaxy S25 Ultra, and documented.

### Added
- Google Play listing assets (icon, feature graphic, phone screenshots) under `docs/play/`, built by `docs/_tools/build_play_assets.py`.
- Complete documentation set: User Manual, Install Manual, Release Notes, Package Overview (simple, medium, advanced) and a 1.0.0 readiness report.

### Changed
- Version 1.0.0 (build 26).

## [0.13.4] - 2026-10-16

### Added
- **How you unlock** (Settings → Privacy and lock): switch between a PIN and the fingerprint or device lock only after the lock is set up, instead of only when it is first created. You confirm it is you first.
- **Tidy genres** (Settings → Your library): shows which books have repeated or catalogue-label genres from older lookups, such as "Science fiction, Science-fiction, General", and tidies them on a tap, with Undo. Your own wording and capitals are kept, and locked books are never listed.

### Changed
- On the Library screen the "press and hold Library" entrance to a hidden Locked tab has a wider target than the word itself.

### Fixed
- Restoring from the oldest of the three kept restore points failed after the library had been closed: making the new restore point pruned the very file being restored. The incoming library is now copied aside first, and two restore points made in the same second no longer overwrite each other. Your live data was never lost, but the restore did not complete. (PGM-100, PGM-105)
- Undo after "Mark finished" no longer deletes a read you have since edited (minutes, narrator, page, format or dates), only an untouched one. (PGM-127)
- Files left in the phone's cache by the share sheet and file picker (which can hold exports that include locked books) are now really deleted when the locked library closes. The clean-up looked for the folders by a name that could never match. (PGM-203)
- Importing a date that does not exist ("02/29/2023", "2023/02/30") is refused instead of rolling into the next month, and a timestamp with a time zone keeps the day written in it. (PGM-113)
- Landscape: on a short screen the search box, filter chips and banners now slide away while you scroll down the Library and come back when you scroll up or reach the top, so the list has the room. (0.13.2 had only removed the Currently reading strip, which still left the list cramped.)

## [0.13.3] - 2026-10-15

### Fixed
- Genres that differ only by a hyphen ("Science fiction" and "Science-fiction") are treated as one.

### Documentation
- User Manual, Install Manual, Release Notes, Package Overview and README rewritten for the current app, with new screenshots (calendar, year card, lending, Read next, refresh details, tablet layout, notifications, promise) and a Quick start. PDF and Word versions are delivered to `Documentation/` as revisions.

## [0.13.2] - 2026-10-15

Fixes from the Galaxy S25 Ultra device test of 0.13.1 (PGM-330 to PGM-340).

### Fixed
- **Reminders now arrive.** The daily reading reminder, the backup reminder and the lent-book reminder never appeared on a real phone: the app's manifest was missing the two receivers the notification plugin needs to show a scheduled notification, so the alarm fired and nothing answered. They are declared now, and a test guards them. Reminders set before this update start working after you open Pagemark once.
- In landscape the Library can scroll again: on a short screen the "Currently reading" strip is left out so the list has room.
- The back gesture on Stats, Locked or Settings now returns to the Library first; Back on the Library leaves the app.
- Edit book no longer accepts 0 or 99999 pages, or a year outside 1000 to 2100.
- Adding books to a shelf has an Undo, like the other bulk actions, and takes off only the books it added.
- Refresh details finds the book's edition list more often, so "Choose another edition" shows up.
- A scanned book that fails to look up now says why (busy, no internet), not always "No internet".
- A search that could not reach the internet no longer also says "Nothing found".

### Added
- Lend this book offers Tomorrow and In a week as reminder times, as well as 2 weeks, 1 month and 2 months.

## [0.13.1] - 2026-10-14

Fixes from the 1.0.0 gate audit (PGM-300 to PGM-322).

### Fixed
- A reading timer left running for a book you had finished or deleted blocked the timer on every other book. Those books now show "Stop it", which saves the time to that book or throws it away.
- Stats no longer stretches on tablets and wide screens: the page keeps a reading width and the calendar's days are a fixed height, so a month fits on one screen.
- Genres from a lookup are cleaned: split on commas, repeats and labels such as "General" dropped, places and characters (for example "Dune (Imaginary place)") dropped, so Stats, the year card and suggestions show real genres. Use Refresh details on a book you already added to tidy it.
- A page count that is negative or absurd (or a year outside 1000 to 2100) from a lookup is no longer saved.
- The guide and Add a book keep a reading width on tablets.
- Moving the open book to the locked library on a tablet now closes it in the side pane, so it does not stay on show beside the main list.
- The empty library's "See how Pagemark works" button shows a help icon instead of a plus.

## [0.13.0] - 2026-10-14

### Added
- Google Books as a second source, merged with Open Library: more books found, and missing covers, pages, publishers and descriptions filled in. One source being down is fine. Turn it off in Settings, Your library, Also search Google Books.
- Refresh details from the internet (book menu): see what a lookup found and tick what to take. Details you typed yourself are only changed if you tick them; an ISBN you have and a cover you saved on the phone are never replaced.
- Choose another edition: pick the cover, publisher, year, pages and ISBN of a different printing (Open Library editions).
- Scan many books: keep the camera open and scan a whole shelf. One click per book, each added on its own; duplicates are skipped and books not found are listed.
- What next? In Read next order, a few suggestions from your own want-to-read list: next in a series you started, more from an author you rated 4 or more, a genre you rate highly. Worked out on the phone; the locked library is never used.

### Changed
- The Our promise page, About and the privacy notes now name Google Books as a place a search goes (unless turned off).

## [0.12.0] - 2026-10-14

### Added
- Reading timer on a book you are reading: Start, Stop, then say which page you are on. Time goes into the read and onto the calendar.
- "Days you read" calendar in Stats, month by month, with a gentle streak line (shown from two days in a row, never a guilt message).
- "Year in books" card in Stats (books, pages, hours, favourite genre, most-read author, average rating, top rated) to share as a picture, and a printable PDF report of the year's finished books.
- Read next order: drag the books you want to read into the order you will read them (Library menu).
- Lending: note who has a book, with an optional reminder to ask for it back. The notification names neither book nor person.

### Notes
- New database tables (schema 6). Older saved copies still restore. The spreadsheet export does not include sessions or loans; the full saved copy does.
- The PDF report uses the built-in fonts, so letters outside Western European ones print as ?.
- Locked books are never counted in the card, calendar or report.

## [0.11.0] - 2026-10-14

### Added
- Tablet and landscape layouts: from 600 dp wide the bottom bar becomes a side bar; from 840 dp the Library and the open book sit side by side. Settings pages stay a comfortable reading width.
- Screen-reader and touch-target fixes: star ratings read "3 of 5 stars" and can be swiped in half-star steps, covers and icon buttons have spoken names, welcome screens scroll at large text sizes.

### Changed
- `lib/ui.dart` split into part files under `lib/ui/`.


## [0.10.1] - 2026-10-14

### Added
- **Our promise to you** (Settings, and on the welcome screens): a plain-words page saying Pagemark never collects your data, has no ads, accounts or AI, and keeps your books on your phone. It lists the only places the app uses the internet and explains the barcode reader. A test now fails if a tracking, advertising or AI package is added, or if the app starts contacting a new internet address. The details (where the app uses the internet, and a note about Google's on-device barcode reader) are under "The small print".

## [0.10.0] - 2026-10-14

First start, safer backups, fewer dead ends.

### Added
- **Welcome screens** on the very first start (three swipes, **Skip** any time), ending with a choice: add your first book, try it with **5 sample books**, restore a saved library, or just look around. Anyone who already has books never sees them.
- **Sample books** (five public-domain classics with a mix of finished, reading, want and did-not-finish) with a card on the Library and a **Remove** button; they can also be removed from Settings > Your library. They never count towards the backup card.
- **"Protect your books" card** on the Library for anyone with 5 or more books and no recent backup: **Set up** opens the backup page, **Not now** hides it for a month.
- **When a book search finds nothing**, Pagemark now explains and suggests shorter searches (without a subtitle, brackets, punctuation or a leading "The", or just the first words). A barcode number you typed is kept when you add the book by hand.
- **How dates look** and **New reads start as** (Settings > Your library).

## [0.9.1] - 2026-10-14

### Added
- **Automatic backups to a folder you choose** (Settings > Backup and restore): pick a folder once with Android's own file picker, and Pagemark saves a fresh backup there by itself (every day, week, 2 weeks or month), keeping the newest 5. Choose a folder in Google Drive, OneDrive or Dropbox and Android copies it to the cloud for you, with no sign-in inside Pagemark. Optional password protection; **Back up now** and **Turn off** are on the same page.
- The widget picker now shows a real preview of the widget.

### Fixed
- The Backup page's "last backup" card updates the moment a backup is saved.
- A test now guards every source file against a byte-order mark or garbled dashes, and it already found and removed a leftover mark in one test file.

## [0.9.0] - 2026-10-13

Rate in more detail, simpler backups, a Notifications page.

### Added
- **Rate books in more detail** (Settings > Your library): optional stars for Story, Characters, Writing, Pace and How it made me feel, plus Narrator on audiobook reads. They show on the book page and in your saved lists, and Stats shows your average for each.
- **Star ratings on quotes** ("How much you love it") and an **average rating on the Series page** (counting the books you rated).
- **Notifications page** in Settings: all reminders in one place (daily reading reminder, backup reminder), with a clear warning and a **Turn on** button when Android has notifications switched off for Pagemark. The widget and icon shortcuts now have their own page, **Widget and shortcuts**.
- **Backup reminder** (Settings > Backup and restore > Remind me to back up): a notification every week, two weeks or month, counted from the last time you saved a copy. The Backup page now shows when you last saved a copy, in plain words, with a warning if it is overdue.

### Removed
- **Google Drive backup.** It needed a Google Cloud project and a "client ID", which was too hard for most people. Saving a password-protected copy as a file (and a spreadsheet) stays, and you can keep that file anywhere, including your own Google Drive. If you had Drive backup turned on, its old files stay in your Drive; Pagemark just stops using them.
- The background-work, Google sign-in and Drive libraries are gone from the app, so it is smaller and asks for fewer permissions.

### Changed
- The library file format moves to schema 5 (new columns for the detailed ratings and quote stars). Restores of older backups still work; a backup made by 0.9.0 cannot be restored by an older Pagemark.

## [0.8.1] - 2026-10-13

Plain words, simpler Settings.

### Added
- **How to use Pagemark**: a built-in guide with short, plain steps for everything the app does, and a search box. Open it from Settings, from the three-dot menu on the Library, or from the empty Library screen. It works without internet.

### Changed
- **Settings is now a short list of seven plain-language pages** (Appearance, Reminders and widget, Privacy and lock, Backup and restore, Import and export, Your library, Help and about) instead of one long scroll. Wording is simpler throughout: "Save a copy as a file" with a password, "Go back to an earlier copy", "Deleted books", "Problem report", "Turn off the lock".

### Fixed
- Plainer words everywhere: "password" instead of "passphrase", friendlier error messages for backups, the book search and updates, "Add by hand", "What's new", "Deleted books" and "Problem report".
- The dashes in the PIN screens ("4–12 digits") showed as garbled characters in 0.7.1 to 0.8.0.
- Version history now shows bold text and code properly instead of asterisks and backticks.

## [0.8.0] - 2026-10-13

Always at hand.

### Added
- **Reading reminder** (Settings > Reminders and widget): an optional daily notification at the time you pick. Off by default, never names a book, scheduled on the phone only. Android may deliver it a few minutes late.
- **Home-screen widget**: shows what you are reading (up to three titles) and your yearly goal. It reads only the main library, so locked books never appear. A switch hides the titles; with the whole-app lock on, the widget shows counts only.
- **Share to Pagemark**: share an ISBN, a title, or a Goodreads or Open Library link from any app and Pagemark opens Add book with the search filled in and run. Nothing is saved until you pick a result.
- **Launcher shortcuts** (long-press the app icon): "Add book" and "Reading now" (the Library with only the books you are reading).

### Changed
- Pagemark now includes the `home_widget` and `timezone` libraries. No new permissions.

## [0.7.2] - 2026-10-12

The rest of the audit fixes.

### Fixed
- **Undo import** now takes back everything the import added: reads and quotes added to books you already had, and shelves it created (new books still go to Trash).
- A shelf that only holds locked books no longer shows its name in the main library (and the other way round). Covers of locked books are no longer counted or saved by the main Covers page.
- Selecting tens of thousands of books at once no longer fails; undoing "mark finished" keeps a read you edited afterwards.
- A cover saved a moment ago can no longer be removed by the clean-up before it is attached to its book; cover file names that are just dots are refused.
- "At this pace" on Stats is correct around daylight-saving changes and in leap years; series numbers like NaN or 1e20 are refused.
- Open Library answers that are not valid JSON show a normal message instead of a generic error; a lockout can never last longer than an hour even if the phone clock was moved.
- CSV cells that begin with a tab or carriage return survive an export/import round trip.

### Changed
- The NAS backup script reads its folder from the `PAGEMARK_NAS` environment variable, so the address is no longer in the public repository.
- Documentation (CLAUDE.md, manuals) brought in line with the two build flavors and the new restore points.

## [0.7.1] - 2026-10-12

Audit fixes and a Google Play build.

### Security
- A lost lock no longer opens the library. If Android clears Pagemark's saved PIN, the locked library and the whole-app lock stay closed until the phone's own screen lock confirms you, then you set a new PIN (previously the screen offered "Set a PIN" and opened).
- PIN lockout can no longer overflow: after hundreds of wrong tries it stays at 1 hour instead of switching off.
- Wrong PINs tapped quickly are all counted.
- If the backup passphrase goes missing from the phone, scheduled backups stop and tell you instead of uploading an unencrypted copy. Changing the passphrase now triggers a new upload.
- Remove lock also turns off the whole-app lock. The recovery code is cleared from the clipboard after a minute.
- Screen capture protection stays on while the locked library closes in the background.
- The diagnostics log drops database details (they could contain titles); the share-sheet and file-picker caches are wiped; failed backups clean up their temporary copy.
- The updater only downloads from GitHub over https and refuses a download it cannot check.

### Added
- **Restore points** (Settings): go back to the copy Pagemark kept before any restore or import.
- A `play` build flavor for Google Play, without the permission to install updates. `tool/build.ps1` builds the GitHub APKs and the Play bundle.

### Fixed
- Two restores in the same minute no longer overwrite each other's restore point; a restore no longer reports failure after the library was already replaced; stricter checks reject database files that only look like Pagemark ones; oversized backup files are refused.
- Imports: impossible dates (Feb 30) are rejected, NaN/Infinity cells and unusual JSON shapes no longer crash, series numbers and descriptions survive an export/import round trip.
- Version comparison handles very large parts and release candidates.
- The Covers page no longer counts or saves covers of locked books.
- Removed an unused library; documentation brought in line with the app.

### Added

### Changed

### Fixed

## [0.7.0] - 2026-10-12

Lock options.

### Added

- Lock the whole app (Settings > Privacy): Pagemark asks for your PIN or fingerprint every time it opens and when you come back after
  the delay. The lock covers every screen (nothing can be opened over it), keeps your place underneath, blocks screenshots and the
  recents thumbnail while it shows, and Back leaves the app instead of the lock. Turning it on walks you through setting a PIN first.
- "Lock after leaving the app": Immediately (the default, as before), 1, 5 or 15 minutes. It applies to the locked library and to the
  whole-app lock. A short trip to another app no longer forces you to unlock again if you choose a delay.
- Documentation builds can switch off screen-capture blocking with `--dart-define=PAGEMARK_SCREENSHOTS=true` (never used for releases).

### Decided

- No encrypted database. Android already isolates and encrypts app storage, a key kept on the same phone adds little, and converting your
  library carries real risk of data loss. Exports and Drive backups can still be passphrase-encrypted.

## [0.6.0] - 2026-10-12

Keep more of what you read.

### Added

- Quotes: save passages from a book with the page and a note about why they stuck. Edit, copy, share (as "quote - author, title, p. N"),
  delete with Undo. The Library search finds a book by a line from it. Quotes travel in JSON exports and imports.
- Covers on your phone: "Save cover on this phone", "Choose cover from gallery" and "Remove saved cover" on each book, plus Settings > Covers to
  save every cover for offline use (with progress and Stop) and tidy unused files. Saved covers work offline and are included in backups
  and database exports (a zip holding the library and the covers; plain library files without covers are unchanged and old backups still restore).
- Authors: tap an author's name on a book to see all their books in the library, with how many you've read and your average rating.
- Series: set how many books a series has ("Books in the series"); the Series screen then shows how many volumes you do not have yet.
- Optional private fields (Settings > Privacy > "Heat level and content notes"): a 0-5 heat rating and content notes on each read, shown on
  the book page, a Heat chart in Stats, and left out of CSV/JSON exports unless this is switched on. Off by default.
- Books with no cover show a coloured tile with the title's first letter (done in 0.4.3; now also used with local covers).

### Changed

- Database schema 4 (adds quotes, series total, heat and content notes); upgrades from every earlier version are tested.
- Export format version 2 (adds quotes); Pagemark still reads version 1 files and refuses newer ones with a clear message.
- Restore reports how many saved covers a backup contains; zip files are checked so nothing outside the covers folder can be written.

## [0.5.0] - 2026-10-12

Bring your history in, and manage many books at once.

### Added

- Import (Settings > Import): reads a Goodreads library export, a StoryGraph export, or a Pagemark CSV/JSON export. It shows what the
  file holds (books, reads, how many you already have, shelves it would create, rows it skipped and why), lets you choose what to do with
  books you already own (skip, add the file's reads to them, or import as separate copies), saves a safety copy of your library first, imports
  everything in one all-or-nothing step, and offers Undo (the imported books go to Trash).
  Goodreads shelves become Pagemark shelves; statuses, ratings, dates, reviews, formats (print / e-book / audio) and ISBNs are mapped;
  ratings are rounded to the nearest half star. Imports never touch the locked library.
- Multi-select: long-press a book in any Library style to start selecting; tap to add or remove. Actions: select all shown, mark finished today,
  add to a shelf, move to or from the locked library, move to Trash. Back or the X closes the selection. Every action except adding to a shelf has Undo.
- Swipe actions on the Classic and Compact lists: swipe right = finished today, swipe left = Trash, both with Undo.

### Changed

- The Library list now uses one database subscription (less work when scrolling and editing).

## [0.4.3] - 2026-10-12

Trust, polish and large-text release.

### Added

- Backup warnings: if a scheduled Google Drive backup keeps failing, Pagemark posts a notification (immediately when you need to sign in
  again, otherwise after the second failure, then weekly). Android 13+ asks for notification permission when you turn on automatic backup.
- Backup page: plain-language error messages (offline, Drive full, sign-in expired, API not enabled ...), "Back up now" reports the size
  uploaded, the Web client ID is checked for a valid shape, and a card explains how to stop phone battery managers killing scheduled backups.
- Uploads to Drive are resumable, so a weak connection no longer restarts a backup from zero.
- "Hide the Locked tab" (Settings, Privacy): nothing in the app shows a private library exists; long-press the word "Library" to open it.
- Locked library: if the phone's screen lock is removed, the gate explains and links to security settings; choosing "device lock only"
  on a phone without a fingerprint now warns that it falls back to the screen lock; searching from the vault warns once that the text is sent to Open Library
  and offers adding the book by hand.
- Unsaved-changes prompts in the book and read editors; undo after deleting a read.
- Search also matches your notes and thoughts, and has a clear button; new search results stay when you go back after adding a book.
- Books with no cover get a coloured tile with the title's first letter; long descriptions collapse behind "Read more".
- Manual add asks for title and author; tags are tidied (trimmed, de-duplicated); numeric fields only accept digits; keyboards dismiss when you scroll.
- Camera denied or unavailable: the scanner explains and links to app settings.
- docs/PRIVACY.md (privacy policy and a Play "Data safety" cheat-sheet).

### Changed

- Library, Stats and every Library style survive 200% text size (compact rows and charts now grow with the font).
- Dates can no longer be set in the future; sorting by rating breaks ties by title; snackbars replace each other instead of queueing.
- Restore finishes with a proper "Close Pagemark" instead of force-quitting; predictive back is enabled.
- The Settings footer no longer shows a hard-coded version.
- Unchanged library lists no longer rebuild on unrelated database writes.

## [0.4.2] - 2026-10-12

Closing the gaps found while using and documenting 0.4.1.

### Added

- The locked library has its own Trash (unlock the vault, then ⋮ → Trash), so a locked book you delete can be restored
  within 30 days. The main Trash still never shows locked titles.
- After restoring a backup that contains locked books, Pagemark reminds you the PIN isn't part of backups and to set a new one.
- Updates page (debug builds only): "Preview update available" shows what an update looks like without publishing one.

- Library styles: choose how the Library looks — Classic, Cover wall, Bookshelf, Spines or Compact (style icon at the top of the
  Library). Remembered separately for the main and locked libraries, with a cross-fade when you switch.

- Name your shelves on the bookcase: in Bookshelf and Spines, "Group by my shelves" gives each named shelf its own wooden shelf
  under a brass nameplate (name + book count); tap a nameplate to rename the shelf. Books on no shelf collect under "Not on a shelf".
- Two new themes: Sage (light green) and Lamplight (dark, warm amber).

### Changed

- Spines look like real cloth-bound books: natural binding colours, woven-cloth grain, rounded-spine shading, hinges, headbands,
  gold-leaf serif lettering with gilt bands, a ribbon marker for the book you're reading and a gold seal for finished ones.
- Themes are renamed (no more "Him/Her"): Harbor, Midnight Ink, Rosewater and Plum Velvet; each now shows Light/Dark underneath.
  Your saved choice carries over.
- Book search ranks real editions first (cover, author matches) and tucks study guides, summaries and workbooks behind
  "Show N more results". If every result is that kind of book they are all shown.
- Pagemark no longer requests storage, media or notification permissions it never used (they were merged in by plugins).
- The book menu says "Move to Trash" instead of "Delete".

## [0.4.1] - 2026-10-12

### Fixed

- The book, read and add-book editors now release their text fields when closed (a small memory leak when opening many editors).

### Notes

- First release published after the repository went public, so it is the first update the in-app updater can find.

## [0.4.0] - 2026-10-12

Day-to-day reading features.

### Added

- Reading progress: "Update progress" on the book page stores your current page; a progress bar shows on the list and the
  "Currently reading" strip, with pages/day and an estimated days-left; reaching the last page offers to mark it finished.
- Yearly reading goal with an animated progress ring and an on-pace forecast (Stats).
- Stats dashboard: finished per month, rating spread, totals (pages, hours, average days to finish), top genres and authors.
  Locked books never count.
- Shelves: any number per book; filter the library by shelf; manage them from the menu (deleting a shelf keeps the books).
- Series: a series number per book (decimals allowed, e.g. 2.5), series badge on rows, and a Series screen that groups books,
  counts what you've read and shows what is next.
- "Currently reading" strip at the top of the library.
- Tap-to-rate stars (left half = half star) replace the rating slider; quick "started today/yesterday" chips.
- Sort order and filters (status, format, shelf) are remembered per library.
- Schema 3 (migration from v1/v2 tested): series number, current page, shelves.

- In-app updates (Settings > Updates): checks the project's GitHub Releases, shows how many releases you're behind and what
  changed in each, downloads the APK for your phone type (arm64 / 32-bit ARM), verifies size and SHA-256, and hands it to
  Android's installer. It installs over the current app, so your library and settings are kept. A quiet check runs at most
  once a day (switch it off on the Updates page); Settings shows a dot when an update is waiting.
- "What's new" after an update, and a Version history page - the changelog ships inside the app, so it works offline.

- Your logo throughout the app: launch splash (Android 12+ system splash and older launch screen), Settings header with an About dialog
  (including the Open Library credit), the Updates page, and friendly empty states on the library and Stats. iOS app icons generated from it.

### Changed

- Ratings show as stars (4.5 = ★★★★½) in the theme's accent colour instead of a fixed amber.
- The list leaves room under the last row so the Add button never covers it.
- Stats now update live as you log books.

### Fixed

- Bar charts overflowed their box by 1.5 px (caught by the new widget tests).

## [0.3.0] - 2026-10-12

Reliability and book-lookup release.

### Added

- Diagnostics page (Settings): a small rolling event log (no book titles or thoughts), with Copy and Clear.
  Uncaught Flutter/async errors and background-backup runs are logged instead of vanishing.
- Typing, pasting or scanning a valid ISBN looks the book up directly; invalid ISBNs are explained instead of searched.
- Book descriptions are now fetched from the Open Library work record (best effort, after the book is saved).
- Barcode scanner: only real book barcodes (valid ISBN, 978/979) are accepted, it returns once, has a torch button,
  and a hint line. QR codes and price labels are ignored.
- Settings shows backup health (last backup time, or "FAILED") on the Drive backup row.
- GitHub Actions CI: analyze, tests, generated-code check and a debug build on every push.
- 10 more automated tests (lookup parsing, retries, ISBN checksums, log) - 26 total.

### Changed

- Lookup is sturdier: identifies itself to Open Library, retries busy/slow responses with backoff, gives readable
  errors (offline / busy / slow), skips one malformed record instead of failing the whole list, dedupes repeated
  works, hides non-genre subjects ("Accessible book", "Protected DAISY"), and falls back to searching by ISBN.
- Lists load small cover thumbnails and decode them at display size (less data and memory).
- ISBNs are stored as ISBN-13.
- Changing the Google Web client ID after sign-in now says to restart instead of silently using the old one.
- Replaced deprecated share/sqlite/crypto calls.

## [0.2.0] - 2026-10-12

Lock and data-safety release.

### Added

- Recovery code for the locked library, shown once when a PIN is set; "Forgot PIN?" resets with it.
- PIN entry is limited: 5 misses lock it out for 30 s, doubling every further 5, capped at 1 h.
- Locked library re-locks when the app goes to the background; its screens close, its cached covers
  and temporary export files are wiped, and the screen is protected from screenshots / recents thumbnails.
- Passphrase encryption (AES-256-GCM, PBKDF2) for Drive backups and for "Export database file".
- Restore checks the file first (SQLite integrity, Pagemark tables, schema version), keeps a safety copy
  of the current library (newest 3), and swaps the file in atomically.
- Trash: deleted books are kept 30 days and can be restored (Settings > Trash).
- Duplicate-book warning when adding the same ISBN or title + author (within the same library only).
- Automated tests (16) covering the database, migration, restore validation, export, encryption and lock.

### Changed

- Changing or removing the PIN now requires the current PIN (or device auth); a new PIN is entered twice.
- PIN is stored as PBKDF2-HMAC-SHA256 with a random salt (v0.1.0 PINs keep working and upgrade on first unlock).
- "Use device lock only" is remembered.
- Database: foreign keys enforced, WAL + busy timeout, indexes, versioned migration (schema 2).
- Drive backup skips unchanged libraries, verifies the upload size before pruning old copies, and no longer
  resets the schedule when unrelated settings change.
- Stats ignore locked and trashed books. A book's status comes from its active/latest read; ratings average finished reads only.
- Finished date: setting a book to Finished fills today's date visibly; Reading/Want clears it; finished before started is rejected.
- CSV export neutralises spreadsheet formulas and has a UTF-8 BOM; JSON export carries a format version; export files have timestamps.
- Android auto-backup disabled so the library never reaches Google's cloud backup.

## [0.1.0] - 2026-10-11

### Added

- Initial release.
