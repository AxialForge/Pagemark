# Pagemark — project guide for Claude Code

Pagemark is a fully local book tracker for Android (iOS later): a log of what you read or listened to, with ratings and private thoughts, for any genre. Metadata and covers come from the free Open Library API; everything else lives in a SQLite file on the phone. It exports the log (CSV/JSON) and the whole database, and reminds the user to save backups (the user saves the file wherever they like; there is no cloud sync). It is not a social network, has no accounts of its own and no server.

## Non-negotiables (don't regress these)

- **Local-first.** The only network calls are Open Library lookups/covers, and the update check against GitHub Releases (a plain release-list request; switchable off). No analytics, no telemetry, no backend.
- **No paid services.** Open Library (no key) only. Don't add paid APIs or require code-signing certs.
- **Locked library never leaks.** CSV/JSON exports exclude locked books; the locked tab re-locks when you leave it. The full database export (backup file) *does* include them (documented in the UI).
- **No secrets in source.** PIN is PBKDF2-HMAC-SHA256 with a random salt in `flutter_secure_storage`.
- **Android first, iOS later.** Keep code platform-neutral; Android-only calls (notifications) are guarded by `defaultTargetPlatform`.

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
  backup_reminder.dart  the "time to back up" notification (counts from the last saved copy)
  restore_ui.dart   restore flow and the Restore points page
android/            MainActivity is FlutterFragmentActivity (needed by local_auth); manifest has INTERNET/USE_BIOMETRIC/CAMERA
```

## The extension point

There is no plugin system. To add a metadata source, add a function to `lookup.dart` returning `BookMeta` and call it from `AddBook` in `ui.dart`. Schema changes: edit `lib/db.dart`, bump `schemaVersion`, add a migration, rerun build_runner.

## Gotchas / constraints

- **Gradle: "Unable to establish loopback connection".** Symptom: every Gradle/Flutter Android build fails instantly. Cause: JDK 25 (Android Studio JBR) creates a unix-domain-socket pipe in `java.io.tmpdir`, which here is the 8.3 short path `C:\Users\JOSEPH~1\...` and fails with `Invalid argument: connect` (plain `Selector.open()` reproduces it). NordVPN is *not* the cause. Fix: `-Djdk.net.unixdomain.tmpdir=C:/tmpj` via `JAVA_TOOL_OPTIONS` (the client JVM needs it; the daemon also gets it from `org.gradle.jvmargs` in `android/gradle.properties`). Overriding `java.io.tmpdir` alone does not help.
- **Restore must delete `-wal`/`-shm`** next to `pagemark.sqlite` before copying the backup over, then the app exits (the open connection is stale). `restoreDb` does this.
- **google_sign_in 7 on Android needs a *Web* client ID** (`serverClientId`) plus an *Android* client with the package name and signing SHA-1; a release key needs its own Android client.
- `file_picker` 13 uses `FilePicker.pickFile()`, not `FilePicker.platform.pickFiles()`; `csv` 8 uses `csv.encode(rows)`.

- **Foreign keys are OFF by default in SQLite.** `AppDb.beforeOpen` runs `PRAGMA foreign_keys = ON`; without it `ON DELETE CASCADE` silently does nothing. Don't remove it (a test guards it).
- **Schema changes need a migration + test.** `schemaVersion` is `AppDb.currentSchema`; add the step in `onUpgrade`, bump `currentSchema` (restore refuses newer-schema backups), and extend the v1->v2 migration test.
- **Locked-library traces.** Anything that shows locked content must (a) use `Cover(locked: true)` so images go to `lockedCache`, (b) be a route that `wipeLockedTraces()` can pop (it pops to the first route), (c) never be counted/listed outside the vault (Stats, Trash, duplicate check, exports all filter on `locked`).
- **FLAG_SECURE ordering.** `Secure.set(true)` when unlocking; on `paused` the vault relocks but the flag stays on until `resumed`, otherwise the recents thumbnail is captured unprotected.
- **Restore swaps the file under a closed connection.** `Exporter.restoreDb` validates, snapshots the current DB to `pre-restore-*.sqlite` (newest 3), closes the DB, deletes `-wal/-shm`, then renames a staged copy; the app must be restarted afterwards (the UI exits).
- **Folder backups use Android's folder picker (SAF), not a Google API.** `FolderChannel.kt` (channel `pagemark/folder`) picks a tree URI, keeps the permission, writes files with `DocumentsContract`, lists and deletes old copies. `FolderBackup` (prefs `fb_*`, password in secure storage `fb_pass`) writes a backup when the app opens/resumes and one is due; **the folder is only saved (`commit`) after the password question is answered**, because the picker closing resumes the app and would otherwise start a plain backup. Pruning only touches files named `Pagemark-backup-*`. Prefs starting `bk_` are wiped at start (old Drive keys), so never use that prefix.
- **Backups are saved by the user, not uploaded.** Google Drive backup was removed in 0.8.2 (too hard for non-technical users to set up). `Exporter.onSaved` (set in main.dart) restarts the "time to back up" countdown whenever a copy or list is shared; `BackupReminder` schedules the next notifications (ids 200-205). Old `bk_*` prefs and the `bk_pass` secure value are cleaned at start.
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

- **flutter_local_notifications needs core-library desugaring** (`isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs` in `android/app/build.gradle.kts`) or the build fails at `checkAarMetadata`.
- **`LockService.debugDeviceSupported`** lets tests fake a phone with/without a screen lock (the local_auth plugin has no test implementation).
- **Large-text safety:** fixed-height rows must scale with `MediaQuery.textScalerOf(context)` (see Compact and BarChart); `test/v043_ui_test.dart` draws every Library style at 200%.
- **Hidden Locked tab:** `hideLockedTab` (prefs `hide_locked`); the vault is then a pushed `VaultPage` opened by long-pressing the Library title. It relocks/wipes on dispose and on background like the tab version.
- **Release APKs are already R8-minified** by Flutter's default release config (`build/app/outputs/mapping/release/mapping.txt` exists); don't add rules blindly.
- **NAS backup:** `tool/backup-to-nas.ps1` mirrors source, a git bundle, the signed APKs and the signing key to the home NAS (the path is read from the `PAGEMARK_NAS` environment variable, so it stays out of the public repo). Run it after every release.

- **Import is two layers:** `importer.dart` (pure parsing, no DB, tested with fixtures in `test/fixtures/`) and `ImportRunner` (plan + one DB transaction). Never write imports outside `ImportRunner.run`, or the all-or-nothing and Undo guarantees go. Imports only ever compare against / write to the *main* library. Fixtures must use invented titles only.
- **Selection:** `SelectionScope` (selection.dart) is an InheritedWidget shared with every Library style; a new style must route taps through `_open` and long-press through `_hold` in skins.dart, and draw `SelectedBadge`. `Dismissible` rows return `false` from `confirmDismiss` so the database stream, not the widget, removes the row.
- **Bulk operations live in `AppDb`** (`softDeleteMany`, `setLockedMany`, `markFinishedToday` -> `FinishUndo`, ...) so they are unit-tested without UI.

- **Covers have two forms:** a web URL, or `local:<file>` resolved by `CoverStore` (never build paths from a book's value by hand - `CoverStore.fileFor` rejects anything that is not a plain file name). Anything that reads a restore/zip must go through `Exporter.unpack` (extracts only `pagemark.sqlite` and plain-named `covers/*`). Close `InputFileStream`s: Windows cannot delete an open file.
- **Backups are now zips when covers exist** (`pagemark.sqlite` + `covers/`); `Exporter.bundle` / `unpack` / `inspectBackup` are the only readers/writers. Old plain-sqlite backups must keep restoring.
- **Schema 4:** quotes table (`body`, not `text`: Drift's `text()` builder clashes), `books.series_total`, `reads.heat`, `reads.content_notes`. Heat/content notes are opt-in (`adultFields`) and excluded from exports unless that switch is on.
- Tests that touch exports/covers use `Exporter.debugTmp` and `CoverStore.useDir`; image-decoding widget tests need `tester.runAsync` + a short real delay.

- **Whole-app lock lives in `MaterialApp.builder`** (`AppLockOverlay`, app_lock.dart), above the Navigator, so no pushed route can cover it. The gate has its own `Navigator` wrapped in `HeroControllerScope.none` (sharing the app's Hero controller throws). `shouldRelock(away, delay)` is the single rule for both the vault and the app lock; delay 0 locks on `paused`/`hidden` (before the recents thumbnail), a delay is checked against a timestamp on `resumed` (timers don't run while backgrounded).
- **Screenshots of locked screens are black by design** (FLAG_SECURE). For documentation builds use `--dart-define=PAGEMARK_SCREENSHOTS=true`; never ship it.

- **Two flavors:** `sideload` (default, GitHub APK, has `REQUEST_INSTALL_PACKAGES` via `android/app/src/sideload/AndroidManifest.xml`, self-updates) and `play` (no installer permission, no Updates screen; `appFlavor == 'play'` in Dart). Never add the installer permission to the main manifest. Build Play with `--flavor play`.
- **Secure storage never silently resets:** `LockService` uses `AndroidOptions(resetOnError: false)`, and a plain pref `lock_set` records that a lock existed, so empty storage reads as mode `'lost'` (vault stays closed) instead of "no lock". The backup passphrase has the same guard (`bk_enc`). Don't switch either back to a default `FlutterSecureStorage()`.
- **Restore points:** `Exporter.safetyCopy` / `restoreDb` keep `pre-import-*` / `pre-restore-*` copies (named to the second); Settings > Restore points lists them. `Exporter.inspect` checks columns and `user_version`, so test fixtures must create real `books`/`reads` columns.
- **Log scrubbing:** `Log.scrub` removes SQL details from exceptions (bound values can be titles). Keep logging through `Log`, never `print`.
- **Shelves are visible per library:** `watchShelves(locked:)` hides shelves that only hold the other library's books.

- **Widget never sees the vault:** `WidgetSync` reads `db.watchLibrary(locked: false)` only and `payload` re-checks `locked`/`deletedAt`; with `appLockEnabled` it sends counts only. Keep any new widget data going through `payload` and its test (`test/v080_test.dart`).
- **Share/shortcut intents are untrusted text:** `MainActivity.describe` caps and whitelists them, `Incoming.queryFromShared` only produces a search string for `AddBook(initialQuery:)`, which saves nothing by itself. A fresh start reads the intent once (`savedInstanceState == null`) so process death cannot replay a share.
- **Reminders are 21 separate inexact notifications** (ids 100-120, exact local times from `Reminders.upcoming`, so DST cannot shift them), rebuilt by `Reminders.apply()` at every start; no exact-alarm permission. Cancel with `Notifier.cancelReminders` (not `cancelAll`, which would drop the backup-problem notification).

- **Never edit source with PowerShell `Get-Content`/`Set-Content` (Windows PowerShell 5.1):** it reads UTF-8 as ANSI and writes a BOM, turning every en/em dash into mojibake (this shipped in 0.7.1 to 0.8.0 on the lock screens). Edit with the Edit tool or Python (`encoding='utf-8'`, `newline=''`), and check `git diff` for non-ASCII changes.

- **Migration trap:** `m.createTable(t)` in an old step builds the table from the CURRENT definition (new columns included), so a later `addColumn` for a column of a table created in the same upgrade throws "duplicate column". Guard later steps with `if (from >= N)` where N is the schema that created the table (see the quotes rating in the `from < 5` step).

## The in-app guide (keep it true)

`assets/guide.md` is the manual inside the app (Settings > How to use Pagemark, the Library three-dot menu and the empty-library screen). It is written for non-technical readers: short steps, plain words, the exact on-screen names in **bold**. **Whenever you change a screen, a button name, a setting or a behaviour a user can see, update `assets/guide.md` in the same commit** (and add a line to `CHANGELOG.md`). `test/guide_test.dart` fails if the guide names a Settings page or a **bold** label that no screen in the app contains, so a rename without a guide update breaks the build. Lines starting with `[github] ` appear only in the GitHub build (the Play build has no updater). The `SettingsTitles` constants in `lib/guide.dart` are the single source for the Settings page names.

## Docs & screenshots

- Documentation lives in `docs/release-package/*.md`; `python docs/_tools/build_docs.py` builds the four PDFs plus the combined `Pagemark-Documentation.pdf` (needs Python `markdown` and Edge). Figures are inline HTML (`<div class="shots">`) pointing at `../screenshots/*.jpg`.
- Screenshots are real captures from the emulator with a seeded sample library - see `docs/_tools/screenshots/README.md` (seed generator is `test/tool_seed_demo_test.dart`, skipped unless `SEED_OUT` is set).
- Re-shoot and rebuild the docs whenever a screen changes; bump the version text in the manuals each release.

## Roadmap (unbuilt)

**Start here: [docs/ROADMAP.md](docs/ROADMAP.md)** - the planned releases with self-contained task specs, how to work away from home, and a prompt to paste into a fresh Claude Code session.

- (An encrypted database / SQLCipher was considered and **declined by the owner** on 2026-10-12 - do not re-propose; see docs/ROADMAP.md 0.7.0-A.)
- Release signing is local: `android/key.properties` (gitignored) points at `~/.android/pagemark-release.jks` - back that keystore up; losing it means users can't upgrade in place. CI (`.github/workflows/ci.yml`) analyzes, tests and builds debug APKs for both flavors only.
- iOS build (needs a Mac).

## Release

Bump `version:` in `pubspec.yaml` and update `CHANGELOG.md` in one commit, then build everything with `powershell -ExecutionPolicy Bypass -File tool/build.ps1` (signed `Pagemark-x.y.z-arm64.apk` / `-armv7.apk` for GitHub, plus `Pagemark-x.y.z-play.aab` for Google Play). Then:

```bash
git tag vX.Y.Z && git push origin vX.Y.Z
gh release create vX.Y.Z build/release-X.Y.Z/*.apk --title "Pagemark X.Y.Z" --notes-file <changelog section>
```

Attach only the two APKs to the GitHub Release (the updater picks by `arm64` / `armv7` in the name); the `.aab` goes to Play Console. Publishing to Play is described in [docs/PLAY_STORE.md](docs/PLAY_STORE.md).
