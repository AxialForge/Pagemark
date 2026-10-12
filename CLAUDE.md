# Pagemark — project guide for Claude Code

Pagemark is a fully local book tracker for Android (iOS later): a log of what you read or listened to, with ratings and private thoughts, for any genre. Metadata and covers come from the free Open Library API; everything else lives in a SQLite file on the phone. It exports the log (CSV/JSON) and the whole database, and can back the database up to the user's own Google Drive on a schedule. It is not a social network, has no accounts of its own and no server.

## Non-negotiables (don't regress these)

- **Local-first.** The only network calls are Open Library lookups/covers and the user-initiated or scheduled Drive backup. No analytics, no telemetry, no backend.
- **No paid services.** Open Library (no key) and Drive's free `appDataFolder` only. Don't add paid APIs or require code-signing certs.
- **Locked library never leaks.** CSV/JSON exports exclude locked books; the locked tab re-locks when you leave it. The full database export and Drive backup *do* include them (documented in the UI).
- **No secrets in source.** The Google Web client ID is typed into the app (SharedPreferences), never committed. PIN is a salted SHA-256 in `flutter_secure_storage`.
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
  ui.dart           all screens: Home/tabs, Library, AddBook, BookPage, EditBook, ReadEditor, Stats, LockGate, Settings
  lookup.dart       Open Library search + ISBN lookup, cover URLs (covers.openlibrary.org)
  themes.dart       4 themes: light/dark × him (blue) / her (rose/plum)
  lock.dart         PIN (salted hash) + device biometric/screen-lock auth
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

## Roadmap (unbuilt)

- Encrypted Drive backups (passphrase) and `FLAG_SECURE` on the locked tab.
- A Flutter CI workflow (the template has none for Flutter). Release signing is local: `android/key.properties` (gitignored) points at `~/.android/pagemark-release.jks` — back that keystore up; losing it means users can't upgrade in place.
- Reading goals/streaks, series grouping, CSV/Goodreads import, iOS build (needs a Mac).

## Release

Bump `version:` in `pubspec.yaml` and update `CHANGELOG.md` in one commit, then:

```bash
git tag v0.1.0 && git push origin v0.1.0
```

No CI builds the APK yet, so attach it to the GitHub Release by hand until a Flutter workflow exists.
