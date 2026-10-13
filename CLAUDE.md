# Pagemark — project guide for Claude Code

Pagemark is a fully local book tracker for Android (iOS later): a log of what you read or listened to, with ratings and private thoughts, for any genre. Metadata and covers come from the free Open Library API; everything else lives in a SQLite file on the phone. It exports the log (CSV/JSON) and the whole database, and can back the database up to the user's own Google Drive on a schedule. It is not a social network, has no accounts of its own and no server.

## Non-negotiables (don't regress these)

- **Local-first.** The only network calls are Open Library lookups/covers, the user-initiated or scheduled Drive backup, and the update check against GitHub Releases (a plain release-list request; switchable off). No analytics, no telemetry, no backend.
- **No paid services.** Open Library (no key) and Drive's free `appDataFolder` only. Don't add paid APIs or require code-signing certs.
- **Locked library never leaks.** CSV/JSON exports exclude locked books; the locked tab re-locks when you leave it. The full database export and Drive backup *do* include them (documented in the UI).
- **No secrets in source.** The Google Web client ID is typed into the app (SharedPreferences), never committed. PIN is PBKDF2-HMAC-SHA256 with a random salt in `flutter_secure_storage`.
- **Android first, iOS later.** Keep code platform-neutral; Android-only calls (WorkManager) are guarded by `defaultTargetPlatform`.

## Commands

```bash
flutter pub get
dart run build_runner build          # regenerate lib/db.g.dart after editing lib/db.dart
flutter analyze
flutter run                          # device/emulator
flutter build apk --debug            # build/app/outputs/flutter-apk/app-debug.apk
```

Flutter 3.47 (`C:\dev\flutter`), Android SDK at `C:\Android\sdk`, Android Studio JBR is JDK 25. **On this machine set `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/tmpj` (and `mkdir C:\tmpj`) before any Gradle build** — see Gotchas. Windows builds live under `C:\Project Folder\Pagemark` (no UNC paths).

## Architecture

Plain Flutter, no state-management package: screens read the Drift database through streams (`watchLibrary`, `watchReads`), so the UI updates itself. One global `db` and one `themeId` notifier live in `main.dart`.

A **Book** is the catalog entry (metadata, tags, notes, `locked` flag). A **Read** is one read-through of it (format print/ebook/audio, status, dates, rating 0.5–5, thoughts, narrator, minutes), so re-reads and print+audio of the same title are separate rows.

### Directory map

```
lib/
  main.dart         entrypoint, global db + theme notifier, prefs-backed theme
  db.dart           Drift tables (Books, Reads), AppDb, library join stream; db.g.dart is generated
  updater.dart      GitHub release check, APK pick/download/verify/install; updater_ui.dart = Updates page, badge, changelog
  skins.dart        Library skins (Classic / Cover wall / Bookshelf / Spines / Compact) + the style picker; SkinView takes ready-filtered rows
  features.dart     StarRating/GoalRing/BarChart widgets, ProgressCard, shelves UI, SeriesPage, Stats
  ui.dart           all screens: Home/tabs, Library, AddBook, BookPage, EditBook, ReadEditor, Stats, LockGate, Settings
  lookup.dart       Open Library search/ISBN/description (retry + backoff, injectable http client), cover URLs
  isbn.dart         ISBN-10/13 checksums, normalise to 13, scanner filter
  log.dart          rolling event log (batched writes, 200 KB cap) + global error handlers
  themes.dart       6 themes (ids light_him/dark_him/light_her/dark_her are kept for saved prefs; names are Harbor, Midnight Ink, Rosewater, Plum Velvet, Sage, Lamplight)
  lock.dart         PIN (PBKDF2, attempt limiting, recovery code) + device auth; lock_ui.dart = gate, setup, confirm-current
  privacy.dart      FLAG_SECURE channel, locked-cover cache, temp-export cleanup, navigator key
  crypto_backup.dart  AES-256-GCM passphrase container for backups/exports (PGMKENC1)
  export.dart       CSV/JSON of main library, VACUUM INTO db snapshot, restore
  backup.dart       Google Drive appDataFolder backup, WorkManager schedule, background dispatcher
  backup_page.dart  backup settings/restore UI
docs/DRIVE_SETUP.md one-time Google Cloud OAuth setup for the user
android/            MainActivity is FlutterFragmentActivity (needed by local_auth); manifest has INTERNET/USE_BIOMETRIC/CAMERA
```

## The extension point

There is no plugin system. To add a metadata source, add a function to `lookup.dart` returning `BookMeta` and call it from `AddBook` in `ui.dart`. Schema changes: edit `lib/db.dart`, bump `schemaVersion`, add a migration, rerun build_runner.

## Gotchas / constraints

- **Gradle: "Unable to establish loopback connection".** Symptom: every Gradle/Flutter Android build fails instantly. Cause: JDK 25 (Android Studio JBR) creates a unix-domain-socket pipe in `java.io.tmpdir`, which here is the 8.3 short path `C:\Users\JOSEPH~1\...` and fails with `Invalid argument: connect` (plain `Selector.open()` reproduces it). NordVPN is *not* the cause. Fix: `-Djdk.net.unixdomain.tmpdir=C:/tmpj` via `JAVA_TOOL_OPTIONS` (the client JVM needs it; the daemon also gets it from `org.gradle.jvmargs` in `android/gradle.properties`). Overriding `java.io.tmpdir` alone does not help.
- **Background backups run in a separate isolate.** `backupDispatcher` opens its own `AppDb()`; never reuse the UI isolate's `db` there. Silent token refresh uses `attemptLightweightAuthentication` + `authorizationForScopes`, which only works after the user has signed in and granted the scope once in the foreground.
- **Restore must delete `-wal`/`-shm`** next to `pagemark.sqlite` before copying the backup over, then the app exits (the open connection is stale). `restoreDb` does this.
- **google_sign_in 7 on Android needs a *Web* client ID** (`serverClientId`) plus an *Android* client with the package name and signing SHA-1; a release key needs its own Android client.
- `file_picker` 13 uses `FilePicker.pickFile()`, not `FilePicker.platform.pickFiles()`; `csv` 8 uses `csv.encode(rows)`.

- **Foreign keys are OFF by default in SQLite.** `AppDb.beforeOpen` runs `PRAGMA foreign_keys = ON`; without it `ON DELETE CASCADE` silently does nothing. Don't remove it (a test guards it).
- **Schema changes need a migration + test.** `schemaVersion` is `AppDb.currentSchema`; add the step in `onUpgrade`, bump `currentSchema` (restore refuses newer-schema backups), and extend the v1->v2 migration test.
- **Locked-library traces.** Anything that shows locked content must (a) use `Cover(locked: true)` so images go to `lockedCache`, (b) be a route that `wipeLockedTraces()` can pop (it pops to the first route), (c) never be counted/listed outside the vault (Stats, Trash, duplicate check, exports all filter on `locked`).
- **FLAG_SECURE ordering.** `Secure.set(true)` when unlocking; on `paused` the vault relocks but the flag stays on until `resumed`, otherwise the recents thumbnail is captured unprotected.
- **Restore swaps the file under a closed connection.** `Exporter.restoreDb` validates, snapshots the current DB to `pre-restore-*.sqlite` (newest 3), closes the DB, deletes `-wal/-shm`, then renames a staged copy; the app must be restarted afterwards (the UI exits).
- **Backup passphrase lives in secure storage** (`bk_pass`) so the background isolate can encrypt unattended. A new phone needs the passphrase typed again to restore.
- **Tests use `AppDb.memory()`** and `FlutterSecureStorage.setMockInitialValues`; PBKDF2 at 150k iterations makes lock tests take a few seconds.

- **Lookup tests inject `Lookup.client`** (a `MockClient`) and set `Lookup.retryDelay = Duration.zero`. Don't add a real network call to tests. Await each `expectLater` that uses the shared client - two unawaited expects race on it.
- **Log writes are batched** (one file open per burst). Per-line `flush: true` made 4000 lines take >30 s on Windows; only error bursts flush. Never log titles, thoughts or other book data.
- **MobileScanner `onDetect` fires repeatedly** - guard with a `done` flag or `Navigator.pop` runs several times and pops extra routes.
- **CI does not sign.** Signed APKs are built locally with `android/key.properties`; CI only proves analyze/test/debug-build pass.

- **Drift singularises table names** (`Shelves` -> `Shelve`). Use `@DataClassName('Shelf')` or the generated row class won't match what you type.
- **Stats is main-library only on purpose** (`watchLibrary(locked: false)`); the vault must never feed totals, goals or top lists.
- **Prefs are a global `prefs`** (set in `main()`); the library remembers sort/filters per library under `lib_m_*` / `lib_v_*`.
- **Widget tests caught a layout bug** (chart overflow) - keep rendering tests for custom-painted/sized widgets; tap tests need `pumpAndSettle` between taps (animated scale).

- **Updates only work for a public repo.** `Updater.check` calls the unauthenticated GitHub releases API; a private repo answers 404 and the app says so. Never embed a token to work around it. Release assets must keep `arm64`/`armv7` in their names (`Updater.pickAsset`) and be signed with the same key as the installed app, or Android refuses the in-place upgrade.
- **`CHANGELOG.md` is a Flutter asset** (shown offline in Version history); keep its `## [x.y.z]` / `### Section` / `- bullet` shape - the in-app renderer depends on it.
- The install step can't be unit-tested (needs a device); download/verify/selection/version logic is.

- **Merged-manifest permissions:** plugins add permissions you didn't ask for (media/storage/notifications came from file/open plugins). `AndroidManifest.xml` removes them with `tools:node="remove"`; after adding a plugin, run `aapt2 dump badging <apk> | grep uses-permission` and strip anything Pagemark doesn't use.
- **Two Trashes:** `AppDb.watchTrash(locked:)` is per library; the vault's Trash is a route opened from the unlocked vault (so `wipeLockedTraces()` closes it).
- **Search results are ranked and filtered client-side** (`Lookup.rank`, `Lookup.isJunk`); fixtures in `test/v042_test.dart`. Don't filter in `Lookup.search` itself beyond ordering - the UI decides what to hide.

- **Backup failures are classified** in `backup_errors.dart` (`friendlyBackupError`, `isAuthProblem`, `shouldNotifyBackupFailure`). A failing run increments `bk_fail`; success resets it and clears the notification. Add new Drive/Google failure modes there, with a test.
- **flutter_local_notifications needs core-library desugaring** (`isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs` in `android/app/build.gradle.kts`) or the build fails at `checkAarMetadata`.
- **`LockService.debugDeviceSupported`** lets tests fake a phone with/without a screen lock (the local_auth plugin has no test implementation).
- **Large-text safety:** fixed-height rows must scale with `MediaQuery.textScalerOf(context)` (see Compact and BarChart); `test/v043_ui_test.dart` draws every Library style at 200%.
- **Hidden Locked tab:** `hideLockedTab` (prefs `hide_locked`); the vault is then a pushed `VaultPage` opened by long-pressing the Library title. It relocks/wipes on dispose and on background like the tab version.
- **Release APKs are already R8-minified** by Flutter's default release config (`build/app/outputs/mapping/release/mapping.txt` exists); don't add rules blindly.
- **NAS backup:** `tool/backup-to-nas.ps1` mirrors source, a git bundle, the signed APKs and the signing key to the home NAS (`\\192.168.1.204\Apocrypha_Main_Pool\Libary_Pool\APP Projects\PageMark`). Run it after every release.

- **Import is two layers:** `importer.dart` (pure parsing, no DB, tested with fixtures in `test/fixtures/`) and `ImportRunner` (plan + one DB transaction). Never write imports outside `ImportRunner.run`, or the all-or-nothing and Undo guarantees go. Imports only ever compare against / write to the *main* library. Fixtures must use invented titles only.
- **Selection:** `SelectionScope` (selection.dart) is an InheritedWidget shared with every Library style; a new style must route taps through `_open` and long-press through `_hold` in skins.dart, and draw `SelectedBadge`. `Dismissible` rows return `false` from `confirmDismiss` so the database stream, not the widget, removes the row.
- **Bulk operations live in `AppDb`** (`softDeleteMany`, `setLockedMany`, `markFinishedToday` -> `FinishUndo`, ...) so they are unit-tested without UI.

- **Covers have two forms:** a web URL, or `local:<file>` resolved by `CoverStore` (never build paths from a book's value by hand - `CoverStore.fileFor` rejects anything that is not a plain file name). Anything that reads a restore/zip must go through `Exporter.unpack` (extracts only `pagemark.sqlite` and plain-named `covers/*`). Close `InputFileStream`s: Windows cannot delete an open file.
- **Backups are now zips when covers exist** (`pagemark.sqlite` + `covers/`); `Exporter.bundle` / `unpack` / `inspectBackup` are the only readers/writers. Old plain-sqlite backups must keep restoring.
- **Schema 4:** quotes table (`body`, not `text`: Drift's `text()` builder clashes), `books.series_total`, `reads.heat`, `reads.content_notes`. Heat/content notes are opt-in (`adultFields`) and excluded from exports unless that switch is on.
- Tests that touch exports/covers use `Exporter.debugTmp` and `CoverStore.useDir`; image-decoding widget tests need `tester.runAsync` + a short real delay.

- **Whole-app lock lives in `MaterialApp.builder`** (`AppLockOverlay`, app_lock.dart), above the Navigator, so no pushed route can cover it. The gate has its own `Navigator` wrapped in `HeroControllerScope.none` (sharing the app's Hero controller throws). `shouldRelock(away, delay)` is the single rule for both the vault and the app lock; delay 0 locks on `paused`/`hidden` (before the recents thumbnail), a delay is checked against a timestamp on `resumed` (timers don't run while backgrounded).
- **Screenshots of locked screens are black by design** (FLAG_SECURE). For documentation builds use `--dart-define=PAGEMARK_SCREENSHOTS=true`; never ship it.

## Docs & screenshots

- Documentation lives in `docs/release-package/*.md`; `python docs/_tools/build_docs.py` builds the four PDFs plus the combined `Pagemark-Documentation.pdf` (needs Python `markdown` and Edge). Figures are inline HTML (`<div class="shots">`) pointing at `../screenshots/*.jpg`.
- Screenshots are real captures from the emulator with a seeded sample library - see `docs/_tools/screenshots/README.md` (seed generator is `test/tool_seed_demo_test.dart`, skipped unless `SEED_OUT` is set).
- Re-shoot and rebuild the docs whenever a screen changes; bump the version text in the manuals each release.

## Roadmap (unbuilt)

**Start here: [docs/ROADMAP.md](docs/ROADMAP.md)** - the planned releases 0.4.2 → 1.0 with self-contained task specs, how to work away from home, and a prompt to paste into a fresh Claude Code session. The list below is the older, shorter version.

- (An encrypted database / SQLCipher was considered and **declined by the owner** on 2026-10-12 - do not re-propose; see docs/ROADMAP.md 0.7.0-A.)
- A Flutter CI workflow (the template has none for Flutter). Release signing is local: `android/key.properties` (gitignored) points at `~/.android/pagemark-release.jks` — back that keystore up; losing it means users can't upgrade in place.
- Reading goals/streaks, series grouping, CSV/Goodreads import, iOS build (needs a Mac).

## Release

Bump `version:` in `pubspec.yaml` and update `CHANGELOG.md` in one commit, then:

```bash
git tag v0.1.0 && git push origin v0.1.0
```

No CI builds the APK yet, so attach it to the GitHub Release by hand until a Flutter workflow exists.
