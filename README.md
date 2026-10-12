# Pagemark

A private, fully local book tracker for Android (iOS later): log what you read and listen to, rate it, and keep your thoughts.

Track print, e-book and audiobook reads of any genre. Look up book details and covers from the free Open Library, keep a locked library behind a PIN or fingerprint, pick a light/dark × him/her theme, export your log, and optionally back the database up to your own Google Drive on a schedule. All data stays on your phone; there is no server and no account.

## Requirements

- Flutter 3.47+ and the Android SDK (to build)
- Android 7.0+ (minSdk from Flutter), a phone or emulator
- Optional: a free Google Cloud OAuth client for Drive backup — see [docs/DRIVE_SETUP.md](docs/DRIVE_SETUP.md)

## Install

```bash
flutter pub get
dart run build_runner build
```

## Run

```bash
flutter run
```

## Build

```bash
flutter build apk --debug
```

On the author's Windows machine, set `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/tmpj` first (see CLAUDE.md, Gotchas).

## Download

Tagged releases will publish an APK on the
[Releases page](https://github.com/AxialForge/Pagemark/releases).

## Development

Architecture and the accumulated gotchas are in [CLAUDE.md](CLAUDE.md). Read it before changing anything structural.
