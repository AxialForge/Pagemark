# Pagemark — rounding-out report (after v0.1.0)

Written 2026-10-11 from a read-through of the 0.1.0 source (`lib/*.dart`, Android config, build setup). The **issues** are findings from reading the code and the build, not from user bug reports; each is tagged with where it lives, and a few are design risks rather than reproduced failures. Severity (big / medium / small) is a judgement of user harm × likelihood, not effort.

| Section | Big | Medium | Small |
|---|---|---|---|
| Features (FB / FM / FS) | 90 | 40 | 60 |
| Issues (IB / IM / IS) | 90 | 40 | 60 |
| UI improvements (UI) | 50 | | |

**Suggested order:** (1) data-safety + lock issues IB-01…IB-52 (they can lose or leak data), (2) tests/CI/migrations (IB-71…IB-82) so everything after is safe to change, (3) round-out features that make daily use better (progress, goals, shelves, series, stats, import), (4) UI polish, (5) iOS parity.

**Fixed in 0.2.0:** IB-01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 12, 13 (opt-in encryption), 14, 15, 16, 19, 20, 21, 22, 23, 24, 25, 28, 29, 30, 32, 33, 35, 36, 43, 44, 47, 71, 75 (partly), 82; IM-02, 07, 08, 09, 29, 30, 34; IS-50, 51; features FB-37, FB-45, FB-50 (on background), FB-52, FB-56, FM-02 (duplicate warning).

**Fixed in 0.3.0:** IB-34, 41, 53, 54, 55, 56, 57, 58, 60 (dedupe), 61, 62, 69, 72, 73, 74, 76; IM-33 (torch + feedback), IM-38, IM-39; FM-19 (pasted ISBN), FM-29 (backup status), FS-01 (checksum), FS-53 (diagnostics log).

**Added in 0.4.0:** FB-01, FB-08, FB-11, FB-12 (series number + Series screen; no series entity yet), FB-57 (stats dashboard), FB-59/60 (pages, hours, days-to-finish), FM-07, FM-11, FM-12 (started chips), FM-14, FM-15, FM-16; FS-07, FS-08, FS-29, FS-30; IM-05, IM-18, IM-35; UI-12, UI-13, UI-24, UI-27, UI-38, UI-41.

**Animations (done in this pass, not in the lists below):** page transitions (fade-forwards on Android, Cupertino on iOS), cover Hero between list and detail, animated tab switching, staggered list entrance, cover fade-in, count-up on Stats numbers. Further motion ideas are UI-33…UI-42.

---

# Part 1 — Features

## Big features (90)

### Logging & tracking
- **FB-01** Reading progress (page / % / minutes position) with a progress bar on the card.
- **FB-02** Reading-session log: start/stop timer, pages per session, per-day totals.
- **FB-03** Re-read timeline per book comparing ratings and thoughts across reads.
- **FB-04** Multi-dimension ratings (plot, characters, prose, pacing, emotional impact) with an overall.
- **FB-05** Private "heat/spice" level and content-warning tags per book (romance and adult readers).
- **FB-06** Quotes & highlights per book with page/chapter reference.
- **FB-07** Per-chapter notes with spoiler-hidden thoughts (tap to reveal).
- **FB-08** Reading goals (year/month: books, pages, hours) with a progress ring.
- **FB-09** Streaks and a reading-calendar heatmap.
- **FB-10** To-read queue with priority and drag-to-reorder.
- **FB-11** Custom shelves/collections (a book can be on many) beyond free-text tags.
- **FB-12** Series as a real entity: reading order, volume number, next-up, missing volumes.
- **FB-13** Author pages: all books, average rating, books-read count.
- **FB-14** Audiobook tracking: narrator entity, playback speed, duration, listening sessions.

### Discovery & metadata
- **FB-15** Google Books as a second free metadata source, merged with Open Library.
- **FB-16** Edition picker (formats, publishers, years, ISBNs) after choosing a work.
- **FB-17** "Refresh metadata" for an existing book without losing your data.
- **FB-18** Continuous bulk ISBN-scan mode to add a shelf in one go.
- **FB-19** Cover from camera/gallery, stored locally and shown offline.
- **FB-20** Cover color extraction to tint the book detail page.
- **FB-21** Wikidata/Open Library work data for series, genres and descriptions.
- **FB-22** Genre/tag suggestions from the book's subjects.
- **FB-23** Work-level dedupe: merge editions of the same book into one entry.
- **FB-24** Local-only recommendations ("because you rated X highly") from your own data.
- **FB-25** "Similar to this" by author/genre/tags within your library.
- **FB-26** Offline metadata cache for searches and works already viewed.

### Import / export
- **FB-27** Goodreads CSV import with field mapping and preview.
- **FB-28** StoryGraph CSV import.
- **FB-29** Libby/OverDrive history import.
- **FB-30** Audible library import (from the user's data export).
- **FB-31** Round-trip import of Pagemark CSV/JSON.
- **FB-32** Merge-import another device's database with conflict resolution.
- **FB-33** PDF reading report (year/period) for printing or sharing.
- **FB-34** "Year in books" shareable image cards (spoiler-free, no locked items).
- **FB-35** Export to Markdown files per book (Obsidian-friendly).
- **FB-36** Export finished dates as an ICS calendar.

### Backup & sync
- **FB-37** Passphrase-encrypted backups (AES-GCM) for Drive and file export.
- **FB-38** Backup to a user-chosen folder (Storage Access Framework) for Syncthing/NAS users.
- **FB-39** Backup-on-change (debounced) in addition to the schedule.
- **FB-40** Backup history screen with integrity verification and restore preview.
- **FB-41** Restore-with-merge from a backup instead of replace-all.
- **FB-42** Device-to-device transfer over local Wi-Fi/QR with no cloud.
- **FB-43** Optional two-phone LAN sync.
- **FB-44** Include covers and attachments in backups.
- **FB-45** Automatic safety snapshot before restore, import or bulk delete.
- **FB-46** Additional user-supplied targets: WebDAV, Dropbox, OneDrive.

### Privacy & security
- **FB-47** Optional whole-app lock (not only the locked library).
- **FB-48** Multiple locked vaults with separate PINs.
- **FB-49** Decoy/duress PIN that opens an empty or alternate library.
- **FB-50** Auto-lock timeout and lock-on-background.
- **FB-51** Disguised launcher icon/name option.
- **FB-52** Hide locked content from recents, screenshots and widgets (FLAG_SECURE).
- **FB-53** Encrypted database at rest (SQLCipher).
- **FB-54** Rule-based locking (lock by tag/genre automatically).
- **FB-55** Failed-attempt log (and optional intruder photo).
- **FB-56** PIN recovery code generated at setup.

### Stats & insights
- **FB-57** Stats dashboard with charts (books per month, genre breakdown, rating histogram).
- **FB-58** Auto-generated "Year in review".
- **FB-59** Pages and hours totals by format.
- **FB-60** Fastest/slowest reads and average days-to-finish.
- **FB-61** Author, genre and series diversity analytics.
- **FB-62** Rating-distribution insight ("you rate generously/harshly").
- **FB-63** Pace forecast: will you hit your goal at this rate.
- **FB-64** Year-over-year comparison.
- **FB-65** Private heat/spice breakdown statistics.
- **FB-66** Price/cost tracking: price paid, cost per read, library value.

### Library management
- **FB-67** Ownership states: own / borrowed / library / wishlist, plus lent-to-whom with due date.
- **FB-68** Library due-date reminders.
- **FB-69** Wishlist with user-supplied store links.
- **FB-70** Multi-select and bulk actions (status, shelf, lock, delete).
- **FB-71** Advanced filters and saved smart shelves.
- **FB-72** Full-text search across thoughts, quotes and notes.
- **FB-73** Grid/cover-wall and compact list views.
- **FB-74** Grouping with section headers by author/series/genre/year.
- **FB-75** Trash with restore for deleted books/reads.
- **FB-76** Per-book edit history.

### Notifications & widgets
- **FB-77** Reading reminders and goal nudges.
- **FB-78** Home-screen widget: currently reading with progress.
- **FB-79** Home-screen widget: goal progress.
- **FB-80** Android share target: share an ISBN/link/title into Pagemark.
- **FB-81** Ongoing notification with quick progress log.
- **FB-82** Quick-settings tile / app shortcuts (Add book, Log session).

### Platform & polish
- **FB-83** iOS parity (Face ID, permissions, TestFlight build).
- **FB-84** Tablet/foldable and landscape layouts.
- **FB-85** Localization (multi-language, RTL).
- **FB-86** Full accessibility pass (TalkBack/VoiceOver, text scaling).
- **FB-87** First-run onboarding with optional sample data.
- **FB-88** Defaults: rating scale (5/10/100), default format, date format, week start.
- **FB-89** User-defined custom fields per book.
- **FB-90** Reading challenges and achievements (e.g. 50 books, genre bingo).

## Medium features (40)

- **FM-01** Undo snackbar after deleting a book or read.
- **FM-02** Duplicate-book warning when adding the same ISBN/title+author.
- **FM-03** Swipe actions on list rows (change status, lock, delete).
- **FM-04** Long-press to multi-select.
- **FM-05** Pull-to-refresh metadata on the detail page.
- **FM-06** Share a book as a text card (title, author, rating; no thoughts).
- **FM-07** Tappable half-star rating widget.
- **FM-08** Tag chip editor with autocomplete.
- **FM-09** Author autocomplete from existing library.
- **FM-10** Genre picker from a curated list plus custom.
- **FM-11** Series-number field on the edit screen.
- **FM-12** Date quick-chips (Today / Yesterday / Pick).
- **FM-13** Finish-book celebration (confetti / badge).
- **FM-14** "Currently reading" strip at the top of Library.
- **FM-15** Remember sort order across launches.
- **FM-16** Remember filters across tab switches and launches.
- **FM-17** Reopen on last-used tab.
- **FM-18** Recent searches list.
- **FM-19** Detect pasted ISBN in the search box and look it up directly.
- **FM-20** Torch toggle and gallery-image scan in barcode scanner.
- **FM-21** Open the book on Open Library in the browser.
- **FM-22** Export only selected books.
- **FM-23** Copy a read's thoughts to clipboard.
- **FM-24** Word counter in the thoughts editor.
- **FM-25** Autosave drafts of thoughts.
- **FM-26** Light Markdown (bold/italic/lists) in thoughts.
- **FM-27** Per-book accent color override.
- **FM-28** Empty-state illustrations with a call to action.
- **FM-29** Backup status badge on Settings (last OK / failing).
- **FM-30** About page with version, licenses and changelog viewer.
- **FM-31** Storage usage and "clear image cache".
- **FM-32** Import validation report (what was skipped and why).
- **FM-33** Theme preview before applying.
- **FM-34** Follow-system light/dark option.
- **FM-35** AMOLED black dark variant.
- **FM-36** Font-size setting independent of system.
- **FM-37** Haptics on/off setting.
- **FM-38** "Pick my next read" random chooser from the TBR.
- **FM-39** "Continue where I left off" shortcut for the last book.
- **FM-40** Quick log: one-tap "finished today" with rating prompt.

## Small features (60)

- **FS-01** ISBN-10 ⇄ ISBN-13 conversion and checksum validation.
- **FS-02** Long-press ISBN to copy.
- **FS-03** Tooltips on all icon buttons.
- **FS-04** Sort by date finished.
- **FS-05** Show page count in list rows.
- **FS-06** Show publication year in list rows.
- **FS-07** Series badge (e.g. "#3") on tiles.
- **FS-08** Star glyphs instead of "4.5" in tiles.
- **FS-09** "DNF at page N" field.
- **FS-10** Format icons in tile subtitle.
- **FS-11** Tap cover to view full size.
- **FS-12** Paste cover URL button.
- **FS-13** "Clear filters" button.
- **FS-14** Result count under the search box.
- **FS-15** Alphabet fast-scroll when sorted by title/author.
- **FS-16** Show "last read" date on tiles.
- **FS-17** Copy title/author actions.
- **FS-18** Share cover image.
- **FS-19** Rating scale labels (Loved it / Liked it …).
- **FS-20** "Reading since N days" label on active reads.
- **FS-21** Hide-rating-until-finished option.
- **FS-22** Default format preference when logging.
- **FS-23** Default status preference when logging.
- **FS-24** Minutes-or-hours input toggle for time.
- **FS-25** Narrator autocomplete.
- **FS-26** Publisher autocomplete.
- **FS-27** Language field per book.
- **FS-28** Format-specific fields (print edition, audio length, e-reader).
- **FS-29** Pages-per-day readout.
- **FS-30** Estimated finish date on active reads.
- **FS-31** Total library count in the AppBar subtitle.
- **FS-32** Keyboard "next" navigation through edit fields.
- **FS-33** Numeric keyboard for year/pages (done) plus input limits.
- **FS-34** Trim whitespace on all saved fields.
- **FS-35** Title-case suggestion for pasted titles.
- **FS-36** Strip trailing series text from titles (e.g. "(Book 2)").
- **FS-37** "Add another read" on the detail header.
- **FS-38** Mark all reads of a book finished.
- **FS-39** Duplicate a read entry (for re-read logging).
- **FS-40** Export filename with date stamp.
- **FS-41** Backup filename shows format/version.
- **FS-42** Show backup size on the backup page.
- **FS-43** "Test connection" button for Drive.
- **FS-44** Paste-and-validate for the Web client ID.
- **FS-45** Link to setup guide from the backup page.
- **FS-46** "Lock now" shortcut in the app bar of the locked tab.
- **FS-47** Optional PIN length 6.
- **FS-48** Show/hide PIN toggle.
- **FS-49** Vibrate on wrong PIN.
- **FS-50** Remember last backup error history (last 5).
- **FS-51** Version string from the package, not hard-coded.
- **FS-52** Credits for Open Library (attribution link).
- **FS-53** "Report a problem" that copies diagnostic info.
- **FS-54** Settings search.
- **FS-55** Reset-theme-to-default.
- **FS-56** Clear all filters on Library double-tap of the tab.
- **FS-57** Haptic tick on rating slider detents.
- **FS-58** Scroll-to-top on re-tapping the Library tab.
- **FS-59** Show total reading time on the detail page.
- **FS-60** Per-book "last modified" timestamp.

---

# Part 2 — Issues

## Big issues (90)

### Lock & privacy
- **IB-01** `Change PIN` / `Remove PIN` (`ui.dart` SettingsPage) need no current PIN — anyone holding the unlocked phone can reset the lock and open the locked library.
- **IB-02** PIN hash is a single SHA-256 with a timestamp salt (`lock.dart`); a 4-digit PIN falls to offline brute force in milliseconds if secure storage is extracted. Use PBKDF2/Argon2 with a high cost.
- **IB-03** No attempt limiting or lockout on PIN entry.
- **IB-04** "Use device lock only" is never persisted: the gate offers "Set a PIN" again every time, and there is no stored lock mode.
- **IB-05** Locked tab does not re-lock on app background or after a timeout; it stays open in recents.
- **IB-06** A pushed locked `BookPage`/`EditBook`/`ReadEditor` route stays open after backgrounding; only tab-leave resets `unlocked`.
- **IB-07** No `FLAG_SECURE`: locked content appears in the recents thumbnail and screen recordings.
- **IB-08** Stats screen counts locked books and their reads (`Stats` queries all tables) — leaks totals.
- **IB-09** Covers of locked books are cached on disk by `cached_network_image` and remain after relock.
- **IB-10** Share temp files (CSV, JSON, DB snapshot) stay in the cache dir indefinitely; the DB snapshot contains locked books.
- **IB-11** Database is unencrypted at rest; rooted devices or backup tools can read locked books.
- **IB-12** Android `allowBackup` is on by default, so system auto-backup/adb can copy the database to the cloud — contradicts "fully local".
- **IB-13** Drive backups are unencrypted and include locked books in the user's Google account.
- **IB-14** Whole-DB share (`Exporter.shareDb`) has only a label warning; no confirm that locked books are included.
- **IB-15** No recovery path for a forgotten PIN — locked books become unreachable or the user must wipe.
- **IB-16** After removing the PIN the gate says "Set a PIN"; whoever has the phone becomes the vault owner (no re-auth) — ties to IB-01.
- **IB-17** `local_auth` is called without specifying biometric strength; any weak biometric/device credential unlocks.
- **IB-18** Adding a locked book sends its title to Open Library over the network and leaves it in the lookup flow; there's no offline-only add for sensitive titles.

### Data integrity
- **IB-19** Foreign keys are not enabled (no `PRAGMA foreign_keys = ON` in `beforeOpen`), so `ON DELETE CASCADE` may not run and orphan reads can accumulate.
- **IB-20** No migration strategy: `schemaVersion = 1` with no `onUpgrade`; the first schema change will break installs.
- **IB-21** Restore does not validate that the file is SQLite/Pagemark or run `PRAGMA integrity_check`; a bad file crashes the app after the old DB is gone.
- **IB-22** No automatic safety snapshot before a restore.
- **IB-23** After restore the app calls `exit(0)`; an interrupted Drive download could replace the DB with a truncated file.
- **IB-24** Restoring a DB from a newer schema into an older app is not detected.
- **IB-25** The background isolate and UI isolate open separate connections with no busy timeout → "database is locked" and failed backups.
- **IB-26** Drift isn't using a shared isolate/server, so two `AppDb` instances can write concurrently.
- **IB-27** Backup runs while the user is editing; the snapshot is consistent but there's no write coordination or retry.
- **IB-28** No indexes on `reads.bookId`, `books.locked`, `books.title`.
- **IB-29** `BookRow.status` uses `reads.first` from an unordered join, so the status badge can show the wrong read.
- **IB-30** `avgRating` averages ratings across DNF/want/re-reads without weighting.
- **IB-31** Deleting a read is permanent, with no history or soft delete.
- **IB-32** Deleting a book is an immediate hard delete including all thoughts.
- **IB-33** Duplicate books can be added repeatedly (no ISBN or title+author uniqueness).
- **IB-34** The saved ISBN is "the first ISBN of the search doc", often another edition; later lookups are wrong.
- **IB-35** `ReadEditor`: choosing *finished* silently sets finished=now; switching back to *reading* doesn't clear finished.
- **IB-36** No validation that finished ≥ started.
- **IB-37** Dates are stored as local `DateTime`; date-only meaning is lost across time zones/DST.
- **IB-38** Tags are one comma-separated string: no normalisation, and search matches partial tags.
- **IB-39** Genre and series are free text, creating duplicate spellings and no grouping.
- **IB-40** `EditBook` writes all fields, can blank `coverUrl`, and has no unsaved-changes guard.

### Backup
- **IB-41** `DriveBackup._init` is a static flag: changing the Web client ID requires restarting the app.
- **IB-42** Scheduled backup failures are silent (only an error string in prefs); no notification.
- **IB-43** No "unchanged since last backup" check — full upload every run.
- **IB-44** Prune deletes old files after upload without verifying size/checksum of the new one.
- **IB-45** No resumable upload; a large DB on flaky mobile data fails repeatedly.
- **IB-46** Background token refresh uses lightweight auth that fails after revocation or the 7-day test-mode token expiry, leaving permanent silent failure.
- **IB-47** `applySchedule` re-registers with `ExistingPeriodicWorkPolicy.update` on every settings change, resetting the interval.
- **IB-48** No guidance for Doze/OEM battery killers (Xiaomi, Samsung, Huawei) that kill WorkManager.
- **IB-49** iOS has no background backup path at all (no BGTaskScheduler setup).
- **IB-50** PIN/lock mode and theme are not part of a backup; a restored DB on a new device has locked books but no PIN (see IB-16).
- **IB-51** Drive 403/quota/storage errors aren't translated into readable messages.
- **IB-52** Covers aren't backed up; a restored library offline shows blank covers.

### Network & metadata
- **IB-53** Open Library requests don't include contact info in the User-Agent as their policy asks — throttling/ban risk.
- **IB-54** No retry/backoff or offline detection; one generic snack hides the real cause.
- **IB-55** One malformed search doc (e.g. `publisher` not a list) throws and fails the whole result list.
- **IB-56** ISBN lookup uses only `/api/books`; there's no fallback to search by ISBN.
- **IB-57** The scanner accepts any barcode (UPC/QR) and sends it to lookup without ISBN checksum validation.
- **IB-58** Large `-L.jpg` covers are used in lists; wasteful bandwidth/memory.
- **IB-59** Covers are hotlinked, not stored; cache eviction, offline use or a removed cover leaves permanent blanks.
- **IB-60** Search results show one row per edition, cluttering results.
- **IB-61** `description` is never fetched (works endpoint not called), so it's always empty.
- **IB-62** No timeout/cancel handling when leaving AddBook mid-request beyond `mounted` checks.

### Performance
- **IB-63** `Library` filters and sorts the full list inside `build()` on every rebuild.
- **IB-64** `watchLibrary` returns one row per read, with no pagination/limit.
- **IB-65** `Stats` re-runs two full-table queries inside `build()` on every rebuild.
- **IB-66** The whole list rebuilds on any DB change (even editing one read).
- **IB-67** Release APK is 76 MB (28 MB split) mainly from ML Kit; no AAB.
- **IB-68** No R8/minify/resource shrinking configured for release.
- **IB-69** `CachedNetworkImage` has no `memCacheWidth`, decoding full-size covers for 48 px tiles.
- **IB-70** CSV/JSON export builds everything in memory.

### Quality & process
- **IB-71** There are zero automated tests (the default widget test was removed).
- **IB-72** No CI for analyze/test/build.
- **IB-73** No global error handling (`FlutterError.onError`, `PlatformDispatcher`); failures can go unseen.
- **IB-74** The background task has no logging.
- **IB-75** No tests of the backup/restore path or schema migration.
- **IB-76** `Share.shareXFiles` is deprecated and will break.
- **IB-77** Kotlin Gradle plugin warning: future Flutter will fail to build with plugins that apply KGP.
- **IB-78** 14 packages are behind and constrained; no update policy.
- **IB-79** Builds depend on a machine-specific workaround (`C:\tmpj` + `JAVA_TOOL_OPTIONS`).
- **IB-80** The release keystore exists in one place only, with no backup/rotation plan.
- **IB-81** No privacy policy or Play Data-safety content, needed for Play Store.
- **IB-82** Export formats carry no version number, so future importers can't tell them apart.

### Platform
- **IB-83** iOS `Info.plist` lacks `NSCameraUsageDescription` and `NSFaceIDUsageDescription` — crash on scan/auth.
- **IB-84** iOS Keychain/iCloud backup behaviour of the DB and PIN is unmanaged.
- **IB-85** Android 14+ background-execution limits could delay uploads for long periods.
- **IB-86** Edge-to-edge (targetSdk 35) and predictive back aren't handled; content can sit under system bars.
- **IB-87** Camera permission denial isn't handled — scanner shows a blank screen.
- **IB-88** With no screen lock/biometric enrolled and no PIN, the locked gate can be stuck or open depending on `isDeviceSupported`.
- **IB-89** `exit(0)` after restore is a poor pattern on Android and disallowed on iOS; use a proper restart flow.
- **IB-90** Bottom navigation + FAB aren't tested on small/large font and display-size settings.

## Medium issues (40)

- **IM-01** TextEditingControllers in `EditBook`, `ReadEditor`, `AddBook`, `LockGate` are never disposed.
- **IM-02** Deleting a read has no confirmation.
- **IM-03** No unsaved-change prompt in editors.
- **IM-04** Date pickers allow 1950–2100 and future finished dates without warning.
- **IM-05** Rating slider is imprecise and not accessible; no star tap input.
- **IM-06** "Time spent" vs audio length is ambiguous in the single `minutes` field.
- **IM-07** CSV formula injection: cells beginning `= + - @` execute in Excel.
- **IM-08** CSV lacks a UTF-8 BOM, so Excel garbles accents.
- **IM-09** Shared files have no MIME type; the share sheet may offer wrong targets.
- **IM-10** CSV/JSON include private `notes` and thoughts with no warning.
- **IM-11** Search ignores thoughts and notes.
- **IM-12** Filter and sort state resets on tab switch (pages are recreated).
- **IM-13** Status/format chips are single-select only.
- **IM-14** Rating sort has unstable ties.
- **IM-15** "Finished in year" ignores finished reads with no date.
- **IM-16** Stats Future is recreated every build.
- **IM-17** Theme labels "Him/Her" may read as exclusionary; palette names would be neutral.
- **IM-18** The hard-coded amber star is not themed and has poor contrast on light surfaces.
- **IM-19** All strings are hard-coded English; no l10n scaffolding.
- **IM-20** AddBook's search state is lost after saving (pushReplacement).
- **IM-21** Manual add only asks for title; other fields require a second step.
- **IM-22** Missing-cover placeholder is the same icon for every book.
- **IM-23** Long titles overflow in the detail layout.
- **IM-24** Description is not collapsible and can push the log off-screen.
- **IM-25** The backup page shows raw exception strings.
- **IM-26** Web client ID field has no format validation.
- **IM-27** "Back up now" shows no progress or uploaded size.
- **IM-28** Restore list shows size but not creation date.
- **IM-29** Setting a PIN has no confirmation entry; a typo locks the user out.
- **IM-30** Change PIN has no confirmation either.
- **IM-31** Settings doesn't explain what Remove PIN does to locked books.
- **IM-32** The always-visible Locked tab reveals that a private library exists.
- **IM-33** Scanner has no torch, gallery fallback or success feedback.
- **IM-34** `AddBook.save()` isn't guarded; a double tap adds the book twice.
- **IM-35** The FAB overlaps the last list item (no bottom padding).
- **IM-36** `BookPage` shows an endless spinner if the book is removed elsewhere.
- **IM-37** `Home` rebuilds all four pages for the index each build.
- **IM-38** Lookup `year` takes the first 4 digits of a string that may be a range or edition note.
- **IM-39** Genre `subject` list from Open Library is noisy ("Accessible book", "Protected DAISY").
- **IM-40** Numeric fields accept non-numeric input silently (`int.tryParse` → null).

## Small issues (60)

- **IS-01** Version text "Pagemark 0.1.0" is hard-coded in Settings.
- **IS-02** `use_build_context_synchronously` lint at `ui.dart` (AddBook flow).
- **IS-03** `use_null_aware_elements` lint on the ISBN lookup list.
- **IS-04** Deprecated share_plus lints in `export.dart`.
- **IS-05** `pagemark.iml` is untracked-noise in the project root.
- **IS-06** `.metadata` and IDE files may churn in git.
- **IS-07** The README's Releases link assumes a public repo; the repo is private.
- **IS-08** `CHANGELOG.md` has empty Unreleased headings.
- **IS-09** `analysis_options.yaml` is the Flutter default; no project lints.
- **IS-10** No `.vscode` launch config or tasks.
- **IS-11** `docs/DRIVE_SETUP.md` has an earlier numbered list that can drift from the UI.
- **IS-12** Magic numbers (5 backups, 20 results, 15 s timeout) aren't named constants.
- **IS-13** `ui.dart` is ~700 lines and holds every screen; hard to navigate.
- **IS-14** Global `db`/`themeId` in `main.dart` complicates testing.
- **IS-15** Unused `path` import risk after refactors; no import sorting.
- **IS-16** `Exporter` mixes file IO, formatting and sharing.
- **IS-17** `BookMeta` fields are mutable public.
- **IS-18** `LockService` is all-static, so it can't be faked in tests.
- **IS-19** Strings like 'print'/'audio' are repeated literals, not enums.
- **IS-20** `statuses`/`formats` maps are top-level mutable-looking consts.
- **IS-21** Drift `Constant('')` defaults mean empty strings instead of NULL everywhere.
- **IS-22** `Books.year` and `pages` allow negatives.
- **IS-23** No max length on thoughts/notes fields.
- **IS-24** No `textCapitalization` on title/author fields.
- **IS-25** No `autofillHints`/`autocorrect` choices on fields.
- **IS-26** Keyboard doesn't dismiss on scroll.
- **IS-27** `DropdownButtonFormField` for status has no leading icons.
- **IS-28** Date tiles show "—" with no hint they're tappable.
- **IS-29** No `Semantics` labels on cover images or stars.
- **IS-30** Tap targets of icon buttons rely on defaults.
- **IS-31** The empty-state text says "tap Add book" even in the locked library.
- **IS-32** "Recently added" sort label doesn't reflect asc/desc (no toggle).
- **IS-33** Chips row doesn't scroll to the selected chip.
- **IS-34** `VerticalDivider` height in chip row isn't constrained.
- **IS-35** No "no results" differentiation for each filter.
- **IS-36** Snack bars stack instead of replacing.
- **IS-37** Backup page shows the account email without a way to copy.
- **IS-38** Time strings use `DateFormat.yMMMd()` without locale injection.
- **IS-39** No haptic feedback anywhere.
- **IS-40** ~~The app icon is the default Flutter icon.~~ Done: logo icons added (legacy + adaptive); iOS icon set and monochrome themed icon still missing.
- **IS-41** Splash screen is the default white.
- **IS-42** App label in iOS `Info.plist` may still be the default lowercase.
- **IS-43** No adaptive/monochrome Android icon.
- **IS-44** `flutter_secure_storage` options not set (e.g. `resetOnError`).
- **IS-45** `shared_preferences` keys are bare strings spread over files.
- **IS-46** `bk_*` pref names are cryptic.
- **IS-47** `workmanager` task names are constants but not documented.
- **IS-48** `keepBackups` is not user-configurable.
- **IS-49** The CSV header uses internal column names, not human labels.
- **IS-50** JSON export has no top-level metadata (version, date).
- **IS-51** Export filenames lack a timestamp so shares overwrite.
- **IS-52** `restoreDb` does not clear image cache.
- **IS-53** `BookTile` subtitle joins with `\n` and may truncate the format list.
- **IS-54** `Stats` has no empty state.
- **IS-55** `Stats` "Logged time" omits unfinished reads.
- **IS-56** `ScanPage` has no cancel hint or manual-entry fallback.
- **IS-57** Search `TextField` has no clear (×) button.
- **IS-58** No `PopScope` handling for dialogs on Android back.
- **IS-59** `docs/` has no screenshots yet; README has none.
- **IS-60** `CONVENTIONS.md` mentions workflows that don't apply to a Flutter project.

---

# Part 3 — UI improvements (50)

### Navigation & structure
- **UI-01** Replace the four-tab bar with Library · Stats · Settings, and open Locked from a long-press or a hidden entry (stealth).
- **UI-02** Add a "Today" home view: currently reading, goal ring, quick log.
- **UI-03** Sticky search bar that collapses on scroll, with a filter sheet instead of two chip rows.
- **UI-04** Use `SliverAppBar` large titles on Library/Stats/Settings.
- **UI-05** Bottom sheet "Add book" with three choices: Search, Scan, Manual.
- **UI-06** Extended FAB that shrinks to an icon on scroll.
- **UI-07** Settings grouped into expandable sections with icons and a search field.
- **UI-08** Breadcrumb-style context in detail pages (series → book).

### Library & cards
- **UI-09** Grid/cover-wall view option with rating overlay.
- **UI-10** Taller cards with larger covers (64–72 px) and clearer hierarchy: title, author, status chip.
- **UI-11** Status shown as a coloured chip, not subtitle text.
- **UI-12** Progress bar under active reads.
- **UI-13** Star glyphs (★★★★½) instead of a numeric rating.
- **UI-14** Section headers (Currently reading / Finished this year / TBR).
- **UI-15** Swipe-to-act rows with coloured reveal backgrounds.
- **UI-16** Fast-scroll bubble with letters when sorted by title/author.
- **UI-17** Skeleton shimmer while the library stream loads.
- **UI-18** Illustrated empty states (shelf, lock, chart) with a single call to action.

### Book detail
- **UI-19** Hero cover with blurred background and palette-tinted header.
- **UI-20** Collapsing app bar with the cover shrinking into the title.
- **UI-21** Reading log as a vertical timeline with format icons.
- **UI-22** Expandable description ("Read more").
- **UI-23** Tag chips editable inline.
- **UI-24** Large tappable star rating on the log card.
- **UI-25** Metadata block as a tidy two-column facts grid (pages, year, publisher, ISBN).
- **UI-26** Floating "Log a read" replaced with a contextual primary button (Start / Update / Re-read).

### Forms & editors
- **UI-27** Replace the rating slider with a half-star tap row.
- **UI-28** Segmented date control: Today · Yesterday · Pick.
- **UI-29** Thoughts editor gets a toolbar, word count and fullscreen mode.
- **UI-30** Step form with sections (Details / Reading / Notes) instead of one long scroll.
- **UI-31** Inline validation and helper text on each field.
- **UI-32** Sticky Save bar, with unsaved-changes confirmation on back.

### Motion (beyond what's already added)
- **UI-33** Animated rating stars that pop when set.
- **UI-34** Status chip morph animation when status changes.
- **UI-35** Shared-element transition from search result to detail.
- **UI-36** Container-transform from the FAB to the Add flow.
- **UI-37** Animated reorder/insert/remove in the list (`AnimatedList` or implicit animations).
- **UI-38** Progress ring/bar fill animation on goals and reading progress.
- **UI-39** Confetti or badge animation on finishing a book.
- **UI-40** Lock/unlock animation (padlock opens) and a gentle shake on a wrong PIN.
- **UI-41** Chart draw-in animations on Stats.
- **UI-42** Theme-change cross-fade instead of a hard swap.

### Theming & style
- **UI-43** Rename "Him/Her" to named palettes (Slate, Midnight, Rose, Plum) plus more (Forest, Sand, Ink).
- **UI-44** Theme-aware star/accent colours and checked contrast (WCAG AA) in all themes.
- **UI-45** AMOLED black and system-follow options in a clear theme picker with live previews.
- **UI-46** Custom typography (a readable serif for titles, sans for UI).
- **UI-47** Consistent corner radii, elevation and spacing tokens.

### Accessibility & ergonomics
- **UI-48** TalkBack labels for covers, stars and status, with 48 dp tap targets.
- **UI-49** Respect large font and display scale; test with 200% text.
- **UI-50** Larger numeric PIN keypad with show/hide, dot indicators and haptic feedback.

---

## Found while writing the documentation (0.4.1)

Not part of the numbered lists above:

- **Vault Trash gap:** books deleted from the locked library are soft-deleted but the Trash screen hides locked titles, so they cannot be restored from the app (they purge after 30 days). Needs a Trash section inside the unlocked vault.
- **Permission bloat:** plugins add `READ_MEDIA_IMAGES/VIDEO/AUDIO`, `READ_EXTERNAL_STORAGE`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE*` and `RECEIVE_BOOT_COMPLETED` to the merged manifest. Pagemark does not use storage/media access; remove them with `tools:node="remove"` entries.
- **PIN is not in backups** (by design) - after restoring on a new phone the vault needs a new PIN; the UI could say so at restore time.
- **Search noise (seen in the real app while taking screenshots):** Open Library returns study guides, "Summary of ..." and workbook records for popular titles (e.g. searching "circe madeline miller" lists four of them below the real book). Rank results with a cover and a matching author first, and hide titles starting with "Summary of", "Study Guide" or "Workbook" behind a "Show more" row.
- **Updates page cannot show an "update available" state without an older build installed**, so the manual's screenshot shows "up to date"; consider a hidden debug switch to preview the available state.
