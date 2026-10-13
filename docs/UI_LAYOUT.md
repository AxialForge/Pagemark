# Pagemark - UI layout and screen guide

**Version 0.8.0** - every screen, what is on it and how you get there.


## 1. The whole app at a glance

Pagemark is a four-tab app. A bar at the bottom switches between **Library**, **Locked**, **Stats** and **Settings**; everything else opens on top of those tabs with a Back arrow in its top-left corner. The look is Material 3 with six colour themes (three light, three dark) and five ways to show the library.


<div class="shots"><figure><img src="screenshots/ui/library.jpg" alt="Library tab (Classic style, Harbor theme)"><figcaption>Library tab (Classic style, Harbor theme)</figcaption></figure><figure><img src="screenshots/ui/stats.jpg" alt="Stats tab"><figcaption>Stats tab</figcaption></figure><figure><img src="screenshots/ui/settings.jpg" alt="Settings tab"><figcaption>Settings tab</figcaption></figure></div>


- **Top bar:** the screen title on the left, actions on the right (only the Library has actions).
- **Body:** a scrolling list or page. Lists never need horizontal scrolling except the filter-chip row.
- **Floating button (bottom right):** *Add book* on the Library, *Log a read* on a book page. It sits above the bottom bar.
- **Bottom bar:** four tabs with an icon and a label; the current tab has a coloured pill behind its icon.


## 2. Navigation map

Every screen and how you reach it. Indented lines open from the line above.


- **Library tab**: search box, status chips, format chips, shelf chips, *Currently reading* strip, book list
    - Library style icon: **Library style** sheet
    - Sort icon: **Sort** menu
    - Three-dot menu: **Series**, **Manage shelves**
    - Long-press a book: **selection mode** (select all, mark finished, add to shelf, move to locked, move to Trash)
    - **Add book** button: Open Library search, then results, then the book page. The scan icon opens **Scan a book barcode**; *Add manually* opens a small form
    - Tap a book: **Book page**
        - Pencil icon: **Edit book**
        - Three-dot menu: Move to locked library, Save cover on this phone, Choose cover from gallery, Move to Trash
        - **+ Shelf**: shelf picker  |  **Add quote**: quote sheet  |  **Update progress**: page dialog
        - **Log a read**: **Log a read** form  |  a read in the log: **Edit read**  |  author link: **Author page**
- **Locked tab**: first time *Set a PIN* (twice) then a recovery code; afterwards the PIN gate, then **Locked library**
    - The Locked library is the Library screen plus **Trash** in its three-dot menu; *Forgot PIN?* resets with the recovery code
- **Stats tab**: goal ring (*Set goal* / *Change goal* dialog), books per month, ratings, totals, top genres, top authors
- **Settings tab**: Updates, About, Theme, Reminders and widget, Import, Export, Google Drive backup, Database, Privacy
    - **Updates**: Version history
    - **Info icon**: About
    - **Import**, **Google Drive backup**, **Restore points**, **Covers**, **Trash**, **Diagnostics**
- **Outside the app**: home-screen **widget**, long-press **shortcuts** (Add book, Reading now), the system **Share** sheet (Share, then Pagemark), the daily **reminder** notification


## 3. Library tab

Your main library. Locked books never appear here.


<div class="shots"><figure><img src="screenshots/ui/library.jpg" alt="Top to bottom: title and actions, search, chips, Currently reading, list"><figcaption>Top to bottom: title and actions, search, chips, Currently reading, list</figcaption></figure><figure><img src="screenshots/ui/library-empty.jpg" alt="First run: an empty shelf and the Add book button"><figcaption>First run: an empty shelf and the Add book button</figcaption></figure><figure><img src="screenshots/ui/library-search.jpg" alt="Searching: text matches title, author, notes, thoughts and quotes"><figcaption>Searching: text matches title, author, notes, thoughts and quotes</figcaption></figure></div>


- **Top bar (left to right):** *Library* title (long-press it to open the Locked library when the Locked tab is hidden), **Library style** icon, **three-dot menu**, **Sort** icon.
- **Search box:** one line under the bar; typing filters the list live; X clears it.
- **Status chips:** All · Want to read · Reading · Finished · Did not finish (scroll sideways). One is always selected.
- **Format chips:** Any format · Print · E-book · Audiobook, then your **shelf chips** (one per shelf, with a small shelf icon). Tap a chip to filter; tap again to clear.
- **Currently reading:** a strip of covers with a progress bar under each, shown above the list on the *All* view.
- **Book rows:** cover, title, author, series and number, status, format, a progress bar while reading and star rating when rated.
- **Add book** button: floating, bottom right.


## 3.1 Menus and filters


<div class="shots"><figure><img src="screenshots/ui/style-picker.jpg" alt="Library style sheet"><figcaption>Library style sheet</figcaption></figure><figure><img src="screenshots/ui/more-menu.jpg" alt="three-dot menu"><figcaption>three-dot menu</figcaption></figure><figure><img src="screenshots/ui/sort-menu.jpg" alt="Sort menu"><figcaption>Sort menu</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/filter-reading.jpg" alt="Status chip: Reading"><figcaption>Status chip: Reading</figcaption></figure><figure><img src="screenshots/ui/filter-shelves.jpg" alt="Chip row scrolled: shelves"><figcaption>Chip row scrolled: shelves</figcaption></figure><figure><img src="screenshots/ui/filter-shelf-active.jpg" alt="A shelf chip selected"><figcaption>A shelf chip selected</figcaption></figure></div>


- **Library style sheet:** Classic, Cover wall, Bookshelf, Spines, Compact (one choice, ticked) and a switch **Group by my shelves** that applies to Bookshelf and Spines.
- **three-dot menu:** *Series* (every series with progress) and *Manage shelves* (create, rename, delete). The Locked library's three-dot menu also has *Trash*.
- **Sort menu:** Recently added, Title, Author, Rating. The choice is remembered per library.


## 3.2 Library styles

The same books, five ways. The style is remembered separately for the main and the locked library.


<div class="shots"><figure><img src="screenshots/ui/style-classic.jpg" alt="Classic"><figcaption>Classic</figcaption></figure><figure><img src="screenshots/ui/style-cover-wall.jpg" alt="Cover wall"><figcaption>Cover wall</figcaption></figure><figure><img src="screenshots/ui/style-bookshelf.jpg" alt="Bookshelf"><figcaption>Bookshelf</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/style-spines.jpg" alt="Spines"><figcaption>Spines</figcaption></figure><figure><img src="screenshots/ui/style-compact.jpg" alt="Compact"><figcaption>Compact</figcaption></figure><figure><img src="screenshots/ui/style-grouped.jpg" alt="Bookshelf grouped by shelf"><figcaption>Bookshelf grouped by shelf</figcaption></figure></div>


- **Classic:** cover, title, status and rating on every row.
- **Cover wall:** a grid of covers with ratings and progress.
- **Bookshelf:** covers standing on wooden shelves.
- **Spines:** cloth-bound spines sized by page count.
- **Compact:** one line per book, the most books per screen.
- **Group by my shelves:** Bookshelf and Spines show one wooden shelf per shelf you made, with a brass nameplate and count.


## 3.3 Selecting many books


<div class="shots"><figure><img src="screenshots/ui/multi-select.jpg" alt="Selection mode"><figcaption>Selection mode</figcaption></figure></div>


- Long-press a book to start. The top bar becomes **X n selected** with **Select all**, **Mark finished today**, **Add to shelf**, **Move to locked/main library** and **Move to Trash**.
- Every bulk action shows an **Undo** bar afterwards. Tap a book to add or remove it from the selection; X ends selection mode.


## 4. Adding a book

**Add book** opens a search against Open Library (free, no account). Type a title, author or ISBN, press the magnifier or Enter. A valid ISBN is looked up directly. Nothing is saved until you tap a result.


<div class="shots"><figure><img src="screenshots/ui/add-empty.jpg" alt="Add a book"><figcaption>Add a book</figcaption></figure><figure><img src="screenshots/ui/add-results.jpg" alt="Results for "dune""><figcaption>Results for "dune"</figcaption></figure><figure><img src="screenshots/ui/scan-permission.jpg" alt="Camera permission (first scan)"><figcaption>Camera permission (first scan)</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/scan.jpg" alt="Scan a book barcode"><figcaption>Scan a book barcode</figcaption></figure></div>


- **Top bar:** Back, title, **scan** icon (opens the barcode scanner).
- **Search box** with a magnifier button; **Add manually** row below (title and optional author in a small dialog) for books Open Library does not know.
- **Results:** cover, title, author · year. Study guides and summaries are hidden behind *show more*. Tap one to add it and open its page.
- **Duplicates:** if the book is already in this library you are asked *Cancel / Open it / Add anyway*.
- **Scanner:** point at the barcode on the back cover; a torch button is at the top right. Only the camera is used, nothing is recorded.


## 4.1 Share to Pagemark

From any app (browser, Goodreads, a message) choose **Share → Pagemark**. An ISBN anywhere in the text, or the title in a Goodreads or Open Library link, opens *Add a book* with the search already filled in and run.


<div class="shots"><figure><img src="screenshots/ui/share-isbn.jpg" alt="Shared ISBN 9780441172719"><figcaption>Shared ISBN 9780441172719</figcaption></figure><figure><img src="screenshots/ui/share-goodreads.jpg" alt="Shared Goodreads link (The Hobbit)"><figcaption>Shared Goodreads link (The Hobbit)</figcaption></figure></div>


- Shared text only fills the search box; it never saves anything and is cut to 300 characters.


## 5. Book page

Everything about one book. It scrolls if the reading log is long.


<div class="shots"><figure><img src="screenshots/ui/book-page.jpg" alt="Book page"><figcaption>Book page</figcaption></figure><figure><img src="screenshots/ui/book-menu.jpg" alt="three-dot menu"><figcaption>three-dot menu</figcaption></figure><figure><img src="screenshots/ui/shelf-picker.jpg" alt="Shelf picker"><figcaption>Shelf picker</figcaption></figure></div>


- **Top bar:** Back, the title, **pencil Edit**, three-dot menu (*Move to locked library*, *Save cover on this phone*, *Choose cover from gallery*, *Move to Trash*).
- **Header:** cover on the left; title, author (a link to the author page), series and number, genre, pages, ISBN on the right.
- **Shelf chips** and **+ Shelf** (opens the shelf picker: tick shelves or create one).
- **Description** (from Open Library or your own).
- **Quotes:** your saved lines with their pages, and **Add quote**.
- **Reading log:** one card per read-through (format, status, dates, stars, thoughts). While reading, a **progress card** shows the page, percent, pages per day and days left, with **Update progress**.
- **Log a read** button, bottom right.


## 5.1 Dialogs and sheets on the book page


<div class="shots"><figure><img src="screenshots/ui/update-progress.jpg" alt="Update progress"><figcaption>Update progress</figcaption></figure><figure><img src="screenshots/ui/add-quote.jpg" alt="New quote"><figcaption>New quote</figcaption></figure><figure><img src="screenshots/ui/trash-dialog.jpg" alt="Move to Trash?"><figcaption>Move to Trash?</figcaption></figure></div>


- **Update progress:** a slider and number pad for the current page (or percent for audiobooks).
- **New quote:** the passage, an optional page and an optional "why it stuck" note.
- **Move to Trash** asks first; the book waits in Trash for 30 days.


## 5.2 Logging and editing


<div class="shots"><figure><img src="screenshots/ui/log-read.jpg" alt="Log a read"><figcaption>Log a read</figcaption></figure><figure><img src="screenshots/ui/edit-book.jpg" alt="Edit book (top)"><figcaption>Edit book (top)</figcaption></figure><figure><img src="screenshots/ui/edit-book-lower.jpg" alt="Edit book (lower)"><figcaption>Edit book (lower)</figcaption></figure></div>


- **Log a read:** Print / E-book / Audiobook switch, status (Want to read, Reading, Finished, Did not finish), current page, **Started** and **Finished** dates with *Started today / yesterday* shortcuts, a five-star rating (half stars), time spent, and your thoughts. **Save** is at the top right.
- **Edit read** is the same form for an existing read, with a delete (bin) button.
- **Edit book:** title, author, series and number, books in the series, genre, tags, publisher, ISBN, cover URL, year, pages, description and private notes. Leaving with unsaved edits asks first.


## 5.3 Authors, series and shelves


<div class="shots"><figure><img src="screenshots/ui/author.jpg" alt="Author page"><figcaption>Author page</figcaption></figure><figure><img src="screenshots/ui/series.jpg" alt="Series"><figcaption>Series</figcaption></figure><figure><img src="screenshots/ui/shelves.jpg" alt="Manage shelves"><figcaption>Manage shelves</figcaption></figure></div>


- **Author page:** counts (books, read, average rating) and that author's books.
- **Series:** every series with "x of y read" and the next book, expandable.
- **Manage shelves:** your shelves with rename (pencil) and delete (bin); the **+** button adds one. Deleting a shelf never deletes books.


## 6. Stats tab

Numbers for the main library only (locked books are never counted).


<div class="shots"><figure><img src="screenshots/ui/stats-1.jpg" alt="Goal and months"><figcaption>Goal and months</figcaption></figure><figure><img src="screenshots/ui/stats-goal.jpg" alt="With a yearly goal"><figcaption>With a yearly goal</figcaption></figure><figure><img src="screenshots/ui/stats-2.jpg" alt="Totals, genres, authors"><figcaption>Totals, genres, authors</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/stats-goal-dialog.jpg" alt="Set goal dialog"><figcaption>Set goal dialog</figcaption></figure><figure><img src="screenshots/ui/stats-dark.jpg" alt="Stats in the Midnight Ink theme"><figcaption>Stats in the Midnight Ink theme</figcaption></figure><figure><img src="screenshots/ui/stats-empty.jpg" alt="Before any book is finished"><figcaption>Before any book is finished</figcaption></figure></div>


- **Reading goal:** a ring (finished / goal), books still to go, and "at this pace" projection; *Set goal* / *Change goal* opens a number dialog.
- **Finished per month:** twelve bars for the current year.
- **Your ratings:** how many books at each half-star rating, plus the average.
- **Totals:** books tracked, finished, pages, logged time, average days to finish, finished by format.
- **Top genres** and **Top authors:** horizontal bars. With *Heat level and content notes* switched on there is a Heat chart too.


## 7. Locked tab

A private library behind a PIN or your fingerprint. Its books are hidden from the main library, Stats, exports and search, and screenshots are blocked while it is open.


<div class="shots"><figure><img src="screenshots/ui/locked-setup.jpg" alt="First visit"><figcaption>First visit</figcaption></figure><figure><img src="screenshots/ui/set-pin.jpg" alt="New PIN"><figcaption>New PIN</figcaption></figure><figure><img src="screenshots/ui/confirm-pin.jpg" alt="Re-enter the PIN"><figcaption>Re-enter the PIN</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/recovery-code.jpg" alt="Recovery code (shown once)"><figcaption>Recovery code (shown once)</figcaption></figure><figure><img src="screenshots/ui/pin-gate.jpg" alt="PIN gate"><figcaption>PIN gate</figcaption></figure><figure><img src="screenshots/ui/wrong-pin.jpg" alt="Wrong PIN"><figcaption>Wrong PIN</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/forgot-pin.jpg" alt="Reset with recovery code"><figcaption>Reset with recovery code</figcaption></figure><figure><img src="screenshots/ui/vault.jpg" alt="Unlocked Locked library"><figcaption>Unlocked Locked library</figcaption></figure><figure><img src="screenshots/ui/vault-menu.jpg" alt="Locked library three-dot menu"><figcaption>Locked library three-dot menu</figcaption></figure></div>


- **First visit:** *Set a PIN* (4–12 digits, entered twice) or, if the phone has a screen lock, *Use fingerprint / device lock only*.
- **Recovery code:** shown once after setting a PIN. **Copy** puts it on the clipboard and clears it after a minute.
- **PIN gate:** PIN field, **Unlock**, **Use fingerprint / device lock** (when available), **Forgot PIN?**. Five wrong tries lock it for 30 seconds, doubling up to an hour.
- **Locked library:** the same screen as the Library (same chips, styles and search) with the title *Locked library*. Its three-dot menu adds **Trash** (kept separate from the main Trash).
- **Leaving locks it again:** switching tabs or leaving the app closes locked screens and wipes locked covers, after the delay you chose in Settings.
- If Android ever clears Pagemark's saved lock, the gate says so and asks you to confirm with the phone's own lock before setting a new PIN.


## 8. Settings tab

One long, scrolling list in sections. Section titles are bold.


<div class="shots"><figure><img src="screenshots/ui/settings-top.jpg" alt="Header, Updates, Theme"><figcaption>Header, Updates, Theme</figcaption></figure><figure><img src="screenshots/ui/settings-reminders.jpg" alt="Reminders and widget"><figcaption>Reminders and widget</figcaption></figure><figure><img src="screenshots/ui/settings-data.jpg" alt="Import, export, Drive, database"><figcaption>Import, export, Drive, database</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/settings-privacy.jpg" alt="Privacy"><figcaption>Privacy</figcaption></figure></div>


- **App header:** logo, name, version and tagline; **info icon** opens About.
- **Updates:** check for a newer version (GitHub build only).
- **Theme:** six themes, each with a colour dot and *Light/Dark*; a tick marks the current one.
- **Reminders and widget:** *Daily reading reminder* (switch, then *Reminder time*), *Show book titles on the home-screen widget* (switch).
- **Import:** from Goodreads, StoryGraph or a Pagemark export.
- **Export (main library only):** Library log as CSV, as JSON.
- **Google Drive backup:** opens the backup page.
- **Database (includes locked books):** Export database file, Restore from database file, **Restore points**, **Covers**, **Trash**.
- **Privacy:** Lock now · Lock after leaving the app (Immediately / 1 / 5 / 15 minutes) · Lock the whole app · Heat level and content notes · Hide the Locked tab · Set or change PIN · Remove lock · Diagnostics.


## 8.1 Pages opened from Settings


<div class="shots"><figure><img src="screenshots/ui/updates.jpg" alt="Updates"><figcaption>Updates</figcaption></figure><figure><img src="screenshots/ui/changelog.jpg" alt="Version history"><figcaption>Version history</figcaption></figure><figure><img src="screenshots/ui/about.jpg" alt="About"><figcaption>About</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/drive-backup.jpg" alt="Google Drive backup"><figcaption>Google Drive backup</figcaption></figure><figure><img src="screenshots/ui/restore-points.jpg" alt="Restore points"><figcaption>Restore points</figcaption></figure><figure><img src="screenshots/ui/import.jpg" alt="Import"><figcaption>Import</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/covers.jpg" alt="Covers"><figcaption>Covers</figcaption></figure><figure><img src="screenshots/ui/trash.jpg" alt="Trash"><figcaption>Trash</figcaption></figure><figure><img src="screenshots/ui/diagnostics.jpg" alt="Diagnostics"><figcaption>Diagnostics</figcaption></figure></div>


- **Updates:** installed version, whether a newer one exists, *Check again*, *Check automatically* switch, *Version history*.
- **Version history:** every release's changes, offline (bold and code are rendered).
- **About:** version, copyright, the Open Library credit, *View licenses*.
- **Google Drive backup:** Web client ID, **Sign in**, *Encrypt backups with a passphrase*, *Automatic backup*, Frequency (Daily/Weekly), *Wi-Fi only*, a battery-optimisation help card, last successful backup, **Back up now**, **Restore from Drive…**.
- **Restore points:** the copies Pagemark kept before each restore or import (newest three of each); tap one to restore it.
- **Import:** where to get the file for each source, **Choose a file**, then a preview (new books, duplicates, skipped rows) and a confirmation; **Undo import** afterwards.
- **Covers:** how many covers are saved on the phone, **Save covers on this phone**, **Remove unused cover files**.
- **Trash:** deleted books with *Restore* and *Delete forever*; items are removed automatically after 30 days.
- **Diagnostics:** a small event log with **Copy**, **Test alert** and **Clear**. It holds no book titles.


## 8.2 Reminders and the widget


<div class="shots"><figure><img src="screenshots/ui/reminder-permission.jpg" alt="Notification permission"><figcaption>Notification permission</figcaption></figure><figure><img src="screenshots/ui/reminder-time.jpg" alt="Choosing the time"><figcaption>Choosing the time</figcaption></figure><figure><img src="screenshots/ui/widget-picker.jpg" alt="Widget picker (Add)"><figcaption>Widget picker (Add)</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/widget-titles.jpg" alt="Widget with titles"><figcaption>Widget with titles</figcaption></figure><figure><img src="screenshots/ui/widget-counts.jpg" alt="Widget, counts only (whole-app lock on)"><figcaption>Widget, counts only (whole-app lock on)</figcaption></figure><figure><img src="screenshots/ui/shortcuts.jpg" alt="Long-press shortcuts"><figcaption>Long-press shortcuts</figcaption></figure></div>


- **Reminder:** off by default. Turning it on asks Android for notification permission; then pick a time. The text is generic ("A few pages tonight?") and never names a book.
- **Widget (3×2):** *Pagemark*, "8 of 12 books in 2026" (or "n books finished in 2026" with no goal), and up to three books you are reading. Tapping opens the app. It never includes locked books; with the whole-app lock on, or titles switched off, it shows only counts ("2 books in progress").
- **Shortcuts:** long-press the app icon for *Add book* and *Reading now*.


## 9. Whole-app lock

An optional second lock over everything. With it on, Pagemark asks for the PIN or fingerprint every time it opens and when you come back after the delay.


<div class="shots"><figure><img src="screenshots/ui/app-lock.jpg" alt="Pagemark is locked"><figcaption>Pagemark is locked</figcaption></figure></div>


- Nothing can be opened over the lock; Back leaves the app instead of the lock. Screenshots and the recents thumbnail are blocked while it shows.


## 10. Colour themes

Pick one in Settings. Harbor is the default.


<div class="shots"><figure><img src="screenshots/ui/theme-harbor.jpg" alt="Harbor (light)"><figcaption>Harbor (light)</figcaption></figure><figure><img src="screenshots/ui/theme-midnight.jpg" alt="Midnight Ink (dark)"><figcaption>Midnight Ink (dark)</figcaption></figure><figure><img src="screenshots/ui/theme-rosewater.jpg" alt="Rosewater (light)"><figcaption>Rosewater (light)</figcaption></figure></div>


<div class="shots"><figure><img src="screenshots/ui/theme-plum.jpg" alt="Plum Velvet (dark)"><figcaption>Plum Velvet (dark)</figcaption></figure><figure><img src="screenshots/ui/theme-sage.jpg" alt="Sage (light)"><figcaption>Sage (light)</figcaption></figure><figure><img src="screenshots/ui/theme-lamplight.jpg" alt="Lamplight (dark)"><figcaption>Lamplight (dark)</figcaption></figure></div>


## 11. What these screenshots do not show

These were taken on an Android emulator with sample data. Not captured (they involve other apps, a signed-in Google account or hardware):


- The Android share sheet for exports, the Google sign-in and Drive permission screens, and the real backup passphrase dialogs.
- The restore confirmation ("Replace your library?"), the import preview and finished screens, and the update-available screen (see the older manual screenshots in `docs/screenshots/`).
- Device-lock (fingerprint) mode, the Heat level and content fields when switched on, and the Locked tab when hidden.
- The daily reminder notification itself, and anything in landscape, on tablets or on iOS (not built).
