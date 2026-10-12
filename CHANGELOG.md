# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

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
