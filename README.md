# Pagemark

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

- **Log any book**: print, e-book or audiobook, any genre; several reads per book, half-star ratings, private thoughts.
- **Fast capture**: search Open Library, paste or scan an ISBN barcode, or add by hand. Free book data and covers, no key needed.
- **Track progress**: current page, progress bars, pages per day, days left; yearly goal ring; stats dashboard.
- **Five library looks**: classic list, cover wall, bookshelf, book spines or compact — switch any time.
- **Quotes**, author pages, and **covers saved on your phone** (offline, included in backups).
- **Import** from Goodreads, StoryGraph or a Pagemark export (preview, safety copy, Undo); **multi-select** and swipe actions.
- **Organise**: shelves, series with numbers, tags, filters, sort, "Currently reading" strip.
- **Locked library**: PIN (attempt limits + recovery code) or fingerprint; re-locks when you leave (or after 1/5/15 minutes); optional **whole-app lock**; blocks screenshots.
- **Your data, your files**: CSV/JSON export; whole-database export with optional password encryption.
- **Backups**: save a password-protected copy of your whole library as a file, or a spreadsheet; a reminder every week, two weeks or month; safe restore with restore points.
- **Six themes**: Harbor, Midnight Ink, Rosewater, Plum Velvet, Sage and Lamplight, with smooth transitions.
- **Updates**: in-app updater with release notes and an offline version history.

## Documentation

| | |
|---|---|
| [User Manual](docs/release-package/USER_MANUAL.md) | Every feature, step by step ([PDF](docs/release-package/Pagemark-User-Manual.pdf)) |
| [Install Manual](docs/release-package/INSTALL_MANUAL.md) | Download, install, update, build from source ([PDF](docs/release-package/Pagemark-Install-Manual.pdf)) |
| [Release Notes](docs/release-package/RELEASE_NOTES.md) | What changed in each version ([PDF](docs/release-package/Pagemark-Release-Notes.pdf)) |
| [Package Overview](docs/release-package/PACKAGE_OVERVIEW.md) | Simple / medium / advanced description ([PDF](docs/release-package/Pagemark-Package-Overview.pdf)) |
| [Complete documentation (one PDF)](docs/release-package/Pagemark-Documentation.pdf) | The four documents above in one file, with a cover and contents |

## Install

Download the **arm64** APK from the [Releases page](https://github.com/AxialForge/Pagemark/releases), open it, and allow installs from your browser/Files app when asked. Android 7.0 or newer. Later updates: **Settings → Updates**.

## Build from source

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test
flutter build apk --release --split-per-abi
```

Flutter 3.47+, Android SDK, JDK 17+. On Windows with JDK 25 see the loopback note in [CLAUDE.md](CLAUDE.md) (Gotchas).

## Privacy

No accounts, analytics or ads. The network is used for book lookup (Open Library) and the update check (GitHub Releases). Details in the User Manual, §16.

## Development

Architecture, conventions and every hard-won gotcha are in [CLAUDE.md](CLAUDE.md). Planned releases are in [docs/ROADMAP.md](docs/ROADMAP.md); the full 430-item backlog is in [docs/ROUNDING_OUT_REPORT.md](docs/ROUNDING_OUT_REPORT.md).

Book data and covers: [Open Library](https://openlibrary.org).
