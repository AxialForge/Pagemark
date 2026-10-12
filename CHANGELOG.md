# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

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
