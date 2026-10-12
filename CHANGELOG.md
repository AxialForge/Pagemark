# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

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
