# Pagemark — Privacy Policy

*Last updated 2026-10-12 · applies to Pagemark 0.4.3 and later*

Pagemark is a private reading log. It has no accounts, no servers of its own, no advertising and no analytics. This page says exactly what the app stores and when anything leaves your phone.

## What Pagemark stores on your phone
- **Your library:** books, reads (dates, ratings, your thoughts), shelves, series, notes, tags and the Trash — in one database file inside the app's private storage.
- **Settings:** theme, library style, filters, backup options.
- **Your PIN (if you set one)** as a salted hash, and its recovery code as a hash, in Android's secure storage. The PIN itself is never stored.
- **A backup passphrase (if you set one)** in Android's secure storage, so scheduled backups can encrypt without you.
- **A small event log** (Settings → Diagnostics): error messages and backup run results. Database error details are removed before anything is written, so it does not keep book titles or your writing.
- **Cached cover images.** Covers of locked books use a separate cache that is erased when the locked library closes.

Android's own cloud backup and device-transfer are switched off for this app, so Google does not receive this data through Android.

## When data leaves your phone
| What | Where it goes | When | What is sent |
|---|---|---|---|
| Book search / ISBN lookup / covers | Open Library (openlibrary.org, Internet Archive) | when you search, scan, or a cover is shown | the text you typed or the ISBN; your IP address is visible to them as for any website |
| Update check | GitHub (api.github.com) | at most once a day while the app is open, if you leave "Check automatically" on | a request for the public release list; nothing about you or your library |
| Update download | GitHub | when you tap Download & install | a request for the APK file |
| Google Drive backup | your own Google Drive, in a private app-data area | only if you set it up, and then on schedule or when you tap Back up now | a copy of your library file — **including locked books** — encrypted with your passphrase if you set one |

Pagemark does **not** send anything to its developer or to any analytics, advertising or crash-reporting service.

## Locked library
Locked books stay in the same database but are hidden from the main library, Stats, Trash, search and CSV/JSON exports. They **are** included in whole-database exports and Drive backups, which is why encrypting those with a passphrase is recommended. Searching for a book while in the locked library sends your search text to Open Library; add the book manually to avoid that.

## Permissions
Internet (lookup, updates, backup) · Camera (barcode scanner, only when you open it) · Biometric (fingerprint/device unlock) · Install packages (to install a downloaded update) · Notifications (a warning when scheduled backups keep failing) · Background work and network state (scheduled backups).

## Your control
- Export everything any time (Settings → Export), or back it up yourself.
- Delete everything by uninstalling the app. Backups you made to Google Drive are managed in your Google account (Drive → Settings → Manage apps → Pagemark → Delete hidden app data).
- Turn off automatic update checks and automatic backups in Settings.

## Children
Pagemark is a general-purpose tool and collects no personal information from anyone, including children.

## Changes
If this policy changes, the new version ships with the app (Settings → Updates → Version history) and in the repository: https://github.com/AxialForge/Pagemark

## Contact
Questions or concerns: open an issue at https://github.com/AxialForge/Pagemark/issues.

---

# Google Play "Data safety" cheat-sheet (if you ever publish there)
- **Data collected:** none by the developer. (Data is processed on-device; Open Library receives search text, GitHub receives update-check requests, and Google Drive stores backups the user chooses to make — all user-initiated, none developer-collected.)
- **Data shared:** none.
- **Encryption in transit:** yes (HTTPS). **Encryption at rest:** the library file is not separately encrypted by the app; it lives in Android's private app storage, which Android encrypts with the screen lock. Backups and database exports are encrypted when the user sets a passphrase.
- **Deletion:** uninstall; Drive backups deletable by the user.
- **Permissions justification:** see the Permissions section above.
