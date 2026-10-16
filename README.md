# Pagemark

> **Our promise:** Pagemark never collects your data. No accounts, no ads, no tracking, no AI. Your books stay on your phone. [Read it in full](docs/PRIVACY.md#our-promise).

A private, fully local book tracker for Android (iOS planned): log what you read and listen to, rate it, and keep your thoughts — with nothing leaving your phone unless you choose.

<img src="assets/branding/logo.png" width="96" alt="Pagemark logo" />

<p align="center">
  <img src="docs/screenshots/library.jpg" width="190" alt="Library" />
  <img src="docs/screenshots/book-reading.jpg" width="190" alt="Reading progress" />
  <img src="docs/screenshots/stats-goal.jpg" width="190" alt="Stats" />
  <img src="docs/screenshots/dark-library.jpg" width="190" alt="Dark theme" />
</p>

*Screenshots use sample books.*

## Features

- **Log any book**: print, e-book or audiobook, any genre; several reads per book, half-star ratings (and optional detailed ratings for story, characters, writing, pace and feeling), private thoughts, quotes with stars.
- **Fast capture**: search Open Library and Google Books together, paste or scan an ISBN barcode, scan a whole shelf in one go, or add by hand. Free book data and covers, no key needed. **Refresh details** and **Choose another edition** fix a book later without losing your own notes.
- **Track progress**: current page, progress bars, pages per day, days left, a **reading timer**, and a **Days you read** calendar with a gentle streak.
- **Plan**: a **Read next** order you drag into place, suggestions from your own list, and **lending** notes with an optional reminder.
- **Your year**: yearly goal ring, stats dashboard, a shareable **Year in books** picture and a printable PDF report.
- **Five library looks**: classic list, cover wall, bookshelf, book spines or compact. On tablets the Library and the open book sit side by side.
- **Organise**: shelves, series with numbers, tags, filters, sort, "Currently reading" strip, multi-select with Undo.
- **Locked library**: PIN (attempt limits + recovery code) or fingerprint; re-locks when you leave (or after 1/5/15 minutes); optional **whole-app lock**; blocks screenshots.
- **Your data, your files**: CSV/JSON export; import from Goodreads and StoryGraph with a preview and Undo; whole-database export with optional password encryption.
- **Backups**: a password-protected copy as a file or spreadsheet, or pick a folder (including one in Google Drive, OneDrive or Dropbox) and Pagemark saves backups there by itself; reminders every week, two weeks or month; safe restore with restore points.
- **Made for everyone**: plain words, a searchable in-app guide, sample books to try, a home-screen widget, icon shortcuts and Share to Pagemark; large text and display size tested.
- **Six themes**: Harbor, Midnight Ink, Rosewater, Plum Velvet, Sage and Lamplight, with smooth transitions.
- **Updates**: in-app updater with release notes and an offline version history (GitHub version).

## Documentation

Finished PDF and Word documents live in the [`Documentation`](Documentation/) folder (named `<document> Rev <n.n>`); the Markdown sources are in `docs/release-package/`.

| | |
|---|---|
| [User Manual](docs/release-package/USER_MANUAL.md) | Every feature, step by step, with a quick start |
| [Install Manual](docs/release-package/INSTALL_MANUAL.md) | Download, install, update, build from source |
| [Release Notes](docs/release-package/RELEASE_NOTES.md) | What changed in each version |
| [Package Overview](docs/release-package/PACKAGE_OVERVIEW.md) | Simple / medium / advanced description |
| [Privacy and our promise](docs/PRIVACY.md) | What Pagemark never does, and the few places it uses the internet |
| [Audit reports](docs/release-audit/) | The pre-release audits and the device test, with findings and fixes |

## Install

Download the **arm64** APK from the [Releases page](https://github.com/AxialForge/Pagemark/releases), open it, and allow installs from your browser/Files app when asked. Android 7.0 or newer. Later updates: **Settings → Updates**.

## Build from source

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test
flutter build apk --release --split-per-abi --flavor sideload
```

Flutter 3.47+, Android SDK, JDK 17+. On Windows with JDK 25 see the loopback note in [CLAUDE.md](CLAUDE.md) (Gotchas).

## Privacy

No accounts, analytics, ads or AI inside the app, and nothing is sent to the developer. The network is used for book lookup (Open Library and, unless you turn it off, Google Books), cover pictures, and the update check in the GitHub version. A page in the app (Settings → Our promise to you) says so in plain words, and tests fail if the code stops keeping the promise. Details in [docs/PRIVACY.md](docs/PRIVACY.md) and the User Manual, §16.

## Development

Architecture, conventions and every hard-won gotcha are in [CLAUDE.md](CLAUDE.md). Planned releases are in [docs/ROADMAP.md](docs/ROADMAP.md); the full 430-item backlog is in [docs/ROUNDING_OUT_REPORT.md](docs/ROUNDING_OUT_REPORT.md).

Book data and covers: [Open Library](https://openlibrary.org) and Google Books.
