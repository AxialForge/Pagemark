# Pagemark — Package Overview

**Version {{VERSION}}** · for readers outside the project. Three tiers: read the first for the idea, the second for what it does, the third for how it works.

---

# Tier 1 — Simple

**What it is.** Pagemark is an app for your phone that keeps a diary of the books you read and listen to. For each book you note what you thought, give it a star rating, and track how far you've got. You can look books up by title or by scanning the barcode on the back.

**What it's for.** Remembering. Which book was that? Did I like it? When did I finish it? It works for any kind of book — fantasy, romance, science, anything — and for audiobooks as well as print. It also helps you plan: a list of what to read next, a note of who you lent a book to, and a calendar of the days you read.

**What makes it different.**
- It is **private**. Everything stays on your phone. There's no account to make, no ads, no tracking and no AI inside the app. A page in the app, "Our promise to you", says so in plain words, and the project's tests fail if the app stops keeping the promise.
- It has a **hidden shelf** for books you'd rather keep to yourself, locked with a PIN or your fingerprint.
- It is **made for people who don't want to learn software**: plain words, a short guide inside the app, sample books to try, and reminders to save a backup.
- It's **free**, and it uses only free sources for book information.

**How you'd use it.** Install it, tap *Add book*, scan or search, and start logging. Once a year, look at the *Stats* tab for your year in books and share the picture if you like.

---

# Tier 2 — Medium

**Purpose.** A local-first reading tracker for Android (iOS planned). It replaces cloud services such as Goodreads with a log you fully own, including audiobooks and a private vault.

**Main capabilities**

| Area | What you get |
|---|---|
| Capture | Search Open Library and Google Books together (switchable), look up by ISBN, scan barcodes one by one or a whole shelf, add by hand; duplicate warning; refresh a book's details and pick another edition |
| Logging | Multiple *reads* per book (print / e-book / audio); status, dates, half-star rating, optional detailed ratings (story, characters, writing, pace, feeling, narrator), private thoughts, time |
| Progress | Current page, progress bars, pages per day, estimated days left, and a reading timer with a saved history |
| Organise | Shelves (many per book), series with a volume grid (read, owned, wanted, missing) for manga, comics and light novels, series totals and ongoing or complete status, tags, filters, sort, "Currently reading" strip, a "read next" order with suggestions from your own list, lending notes with a reminder |
| Library looks | Classic list, cover wall, bookshelf, book spines, compact — switchable, remembered per library; side-by-side Library and book on tablets |
| Insight | Yearly goal ring with pace forecast, "Days you read" calendar, a shareable "Year in books" picture and a printable PDF report, books per month, rating spread, top genres and authors, totals |
| Privacy | Locked library (PIN with attempt limits and recovery code, or device biometrics), auto-relock with a configurable delay, an optional whole-app lock, screenshot blocking |
| Quotes & covers | Save passages with pages and stars; save covers on the phone for offline use and backups; author pages |
| Import / export | Goodreads, StoryGraph and Pagemark files in, with a preview, duplicate handling, a safety copy and Undo; CSV and JSON out |
| Backup | Password-protected (AES-256) backup file or spreadsheet saved wherever the user chooses; automatic backups into a folder (including one inside Google Drive, OneDrive or Dropbox) through Android's own picker; a "time to back up" reminder; safe restore with automatic restore points |
| Care | Trash with 30-day recovery, in-app updates with release notes, offline version history, plain-words diagnostics log |
| Reach | Home-screen widget, icon shortcuts, Share to Pagemark, reminders |
| Look | Six named themes (Harbor, Midnight Ink, Rosewater, Plum Velvet, Sage, Lamplight); large text and display size tested; a screen-reader-friendly star control |

<div class="shots "><figure><img src="../screenshots/library.jpg" alt="Library"><figcaption>Library</figcaption></figure><figure><img src="../screenshots/book-finished.jpg" alt="Book page"><figcaption>Book page</figcaption></figure><figure><img src="../screenshots/stats-goal.jpg" alt="Stats"><figcaption>Stats</figcaption></figure></div>

**Principles.** No accounts, no analytics, no ads, no paid services, no AI inside the app. The network is used for book lookup (Open Library and Google Books), cover pictures, and — in the GitHub version only — the update check.

**Who it's for.** Readers who want a durable, private record; people leaving other tracking sites; anyone who wants their data in a plain file they can open elsewhere; and people who find most apps too fussy.

**Distribution.** Free APKs on GitHub Releases (MIT-licensed source in a public repository). In-app updates install over the old version and keep your data. A Google Play version is being prepared.

---

# Tier 3 — Advanced

## Stack
Flutter 3.47 (Dart) app, about 16,000 lines, with a little Kotlin for the home-screen widget, the share and shortcut intents, and the Android folder picker. **Drift** over **SQLite** for storage; plain `StatefulWidget`s with database streams (no state-management package); `flutter_secure_storage` for secrets; `cryptography` for PBKDF2 and AES-GCM; `flutter_local_notifications` with `timezone` for reminders; `home_widget` for the widget; `http` for Open Library, Google Books and GitHub; `mobile_scanner` for barcodes; `local_auth` for biometrics; `pdf` to build the yearly report on the phone; `share_plus`, `file_picker`, `archive` for sharing, restore and zip backups. `lib/ui.dart` is one library split into part files; wide-screen layout helpers live in `lib/adaptive.dart`.

## Data model (schema 6)
- `books` — catalog entry: title, author, ISBN-13, cover URL, genre, series, `seriesNumber`, `seriesTotal`, `kind`, `owned`, publisher, year, pages, description, tags, notes, `locked`, `added`, `deletedAt` (soft delete), `queuePos` (read-next order).
- `reads` — one read-through: format, status, started/finished, rating (0.5–5), optional aspect ratings, thoughts, narrator, minutes, `currentPage`, optional heat and content notes; FK to `books` with cascade.
- `quotes` (with a star rating), `shelves`, `book_shelves` (many-to-many).
- `reading_sessions` — one timer sitting: book, day, minutes, pages.
- `loans` — who has a book, lent date, optional reminder date, returned date.
- Indexes on the hot columns. WAL journal, 5 s busy timeout, `foreign_keys=ON` in `beforeOpen`. Versioned migrations 1→6; every historic schema (built by the code of the matching release) is migrated and checked in an audit script. Migrations guard later `addColumn` steps so a table created by an old step with the current definition is never altered twice.

## Privacy and security design
- **Vault is a flag, not a second database**, enforced at every read path: library queries, Stats, the year card, the PDF report, the calendar, suggestions, Trash, duplicate check, the home-screen widget and CSV/JSON export all filter on `locked`. Full database backups include it by design and can be encrypted.
- **PIN:** PBKDF2-HMAC-SHA256, 150 000 iterations, random 16-byte salt, constant-time compare, persistent attempt counter with exponential lockout (30 s doubling, cap 1 h). One-time recovery code stored only as a PBKDF2 hash.
- **Vault lifecycle:** on background/leave the app pops locked routes, empties the locked-cover cache and deletes temporary exports; `FLAG_SECURE` is set while the vault is open so the recents thumbnail is blank. On a tablet the two-pane view is never used for the Locked library.
- **Backups:** container `PGMKENC1 | salt | nonce | AES-256-GCM ciphertext | tag`, key from PBKDF2. Folder backups use Android's Storage Access Framework (no storage permission), run when the app opens and one is due, keep the newest 5 and only commit the chosen folder after the password question.
- **Restore:** open the candidate read-only, `PRAGMA integrity_check`, require `books`/`reads`, reject newer schemas, snapshot the current database as a restore point (newest 3 kept), close the connection, delete `-wal/-shm`, rename the staged copy into place; the app restarts.
- **Android:** `allowBackup=false` plus data-extraction rules exclude everything; no analytics SDKs; scheduled-notification receivers declared (and guarded by a test); release builds are signed with APK Signature Scheme v2 and v3; native libraries are 16 KB aligned.

## Networking
Open Library search, ISBN, works and editions endpoints and Google Books volumes (no key) with an identifying User-Agent, retry with backoff on 429/5xx/timeouts, per-record fault tolerance, ISBN-10→13 normalisation and checksum validation, page and year bounds, and a merge that only fills gaps. Updates (GitHub flavour only) use the unauthenticated GitHub releases API: newest-first list → APK chosen by ABI → streamed download with size and SHA-256 verification → system installer. A test lists every host the app may contact and fails if a new one appears without a line on the promise page. The barcode reader uses Google's on-device ML Kit; the promise page says so.

## Quality and process
- About 300 automated tests: database behaviour and migrations, restore validation, export safety, encryption round-trip and tamper detection, lock service, lookup parsing and retries (mock HTTP), merge and refresh logic, reading-life logic (streaks, year summary, queue, loans, PDF), layout and accessibility checks at 200% text, guide-to-app consistency, promise honesty (banned packages, allowed hosts) and an encoding guard.
- Independent audits: a pre-release audit (0.7.0, 84 findings, all fixed), a 1.0.0 gate audit of 0.13.0, a mobile audit (MASVS and Play compliance), and a hands-on test of 0.13.1 on a Galaxy S25 Ultra (70 passed, 13 failed, 10 skipped; every app problem found has a fix, including reminders that never appeared because of a missing manifest entry). Reports are kept in `Documentation/` and `docs/release-audit/`.
- GitHub Actions CI: analyze, tests, generated-code check, debug builds of both flavors. Signed release APKs and the Play bundle are built locally with `tool/build.ps1`; the keystore never leaves the owner's machine.
- Release flow: version bump + `CHANGELOG.md` in one commit → tag `vX.Y.Z` → APKs (`arm64`, `armv7`) attached to a GitHub Release. The changelog ships inside the app as an asset.

## Known limits
- The library file is not separately encrypted by the app (a deliberate choice: Android already isolates and encrypts app storage, and an on-phone key adds little). Exports and backups can be passphrase-encrypted.
- Backups are saved by the user or into a folder the user picks; there is no Pagemark cloud. Reminders use inexact alarms and may arrive a few minutes late on phones with aggressive battery managers.
- English only; no iOS build yet (the project is configured; it needs a Mac to build and sign).
- Book data quality depends on the free sources (genres and editions can be noisy; Refresh details lets the user correct them). The PDF report uses built-in fonts, so letters outside Western European ones print as `?`.
- TalkBack has been designed for but tested less than the rest.
- Release builds are shrunk with R8; the mapping file stays with the owner.

## Roadmap highlights
A second interface language, the Google Play release (closed test first), then iOS.
