# Pagemark — Privacy Policy

*Last updated 2026-10-22 · applies to Pagemark 0.13.2 and later on Android, and to the iPhone version*

Pagemark is a private reading log. It has no accounts, no servers of its own, no advertising and no analytics. This page says exactly what the app stores and when anything leaves your phone.

## Our promise

- **We never collect your data.** No account, no analytics, no tracking, no advertising ID, no crash-reporting service. There is no Pagemark server to send anything to.
- **No ads, no selling, no sharing.**
- **No AI inside the app.** No assistant, no AI features, and nothing you write is sent to or used to train an AI service.
- **Your books stay on your phone** unless you save a backup, and then only where you put it.
- **Free and open to inspect:** the code is public.
- **The only internet use:** book searches (to Open Library and, unless turned off in Settings, Google Books), the GitHub build's update check, and whatever a cloud app does with a backup folder you choose.
- **About the barcode reader:** it uses Google's on-device ML Kit vision tool. Pagemark never saves or sends the camera picture, but the Google library may report anonymous technical information to Google.

A test in the project fails if a tracking, advertising or AI package is added or the app contacts a new internet address.

## What Pagemark stores on your phone
- **Your library:** books, reads (dates, ratings, your thoughts), shelves, series, notes, tags and the Trash — in one database file inside the app's private storage.
- **Settings:** theme, library style, filters, backup options.
- **Your PIN (if you set one)** as a salted hash, and its recovery code as a hash, in Android's secure storage. The PIN itself is never stored.
- **A backup passphrase (if you set one)** in Android's secure storage, so scheduled backups can encrypt without you.
- **Reminders and widget:** the reminder is a notification scheduled on your phone and never names a book. The widget is drawn from the main library only (never the locked library) and shows counts only when the whole-app lock is on.
- **Share target:** text another app shares with Pagemark only fills the search box; it is never saved or sent anywhere until you pick a result, and then only the usual Open Library lookup happens.
- **Folder backups:** if you choose a folder for automatic backups, Pagemark writes its backup files only into that folder (Android gives it access to that one folder and nothing else). If the folder belongs to a cloud app such as Google Drive, that app uploads the files under its own rules.
- **A small event log** (Settings → Help and about → Problem report): error messages and backup run results. Database error details are removed before anything is written, so it does not keep book titles or your writing.
- **Cached cover images.** Covers of locked books use a separate cache that is erased when the locked library closes.

Android's own cloud backup and device-transfer are switched off for this app, so Google does not receive this data through Android.

## When data leaves your phone
| What | Where it goes | When | What is sent |
|---|---|---|---|
| Book search / ISBN lookup / covers | Open Library (openlibrary.org, Internet Archive) and Google Books (googleapis.com; can be turned off in Settings) | when you search, scan, or a cover is shown | the text you typed or the ISBN; your IP address is visible to them as for any website |
| Update check | GitHub (api.github.com) | at most once a day while the app is open, if you leave "Check automatically" on | a request for the public release list; nothing about you or your library |
| Update download | GitHub | when you tap Download & install | a request for the APK file |

Pagemark does **not** send anything to its developer or to any analytics, advertising or crash-reporting service.

## Locked library
Locked books stay in the same database but are hidden from the main library, Stats, Trash, search and CSV/JSON exports. They **are** included in whole-database exports and folder backups, which is why encrypting those with a passphrase is recommended. Searching for a book while in the locked library sends your search text to Open Library; add the book manually to avoid that.

## Permissions
Internet (lookup, updates, backup) · Camera (barcode scanner, only when you open it) · Biometric (fingerprint/device unlock) · Install packages (to install a downloaded update) · Notifications (a warning when scheduled backups keep failing) · Background work, network state, wake lock, foreground service and start-after-reboot (scheduled backups and reminders; they let the system run those jobs and re-schedule reminders after a restart) · Vibrate (notification vibration) · Fingerprint (older-Android fingerprint unlock). Pagemark does not ask for location, contacts, microphone, storage or accounts.


## On iPhone

The iPhone version follows the same rules, with these differences:
- Your PIN hash, recovery code and backup passphrase are kept in the iPhone Keychain instead of Android's secure storage.
- Face ID or Touch ID is handled by iOS; Pagemark only learns whether it succeeded.
- The barcode reader uses Apple's on-device Vision framework. Nothing from the camera is saved or sent, and no Google library is involved.
- There is no update check or download: the App Store updates the app. There are no folder backups and no home-screen widget yet; you save backups yourself with the Share sheet.
- While the locked library is open, Pagemark covers its screen when you switch apps, so the app switcher does not show your private books.
- Permissions asked for: camera (barcode scanner), Face ID, photos (only when you pick a cover picture) and notifications (reminders).

## Your control
- Export everything any time (Settings → Import and export), or back it up yourself.
- Delete everything by uninstalling the app. Backup files you saved yourself stay wherever you put them; delete them there.
- Turn off automatic update checks and automatic backups in Settings.

## Children
Pagemark is a general-purpose tool and collects no personal information from anyone, including children.

## Changes
If this policy changes, the new version ships with the app (Settings → Updates → Version history) and in the repository: https://github.com/AxialForge/Pagemark

## Contact
Questions or concerns: open an issue at https://github.com/AxialForge/Pagemark/issues.

---

# Google Play "Data safety" cheat-sheet (if you ever publish there)
- **Data collected:** none by the developer. (Data is processed on-device; Open Library receives search text and GitHub receives update-check requests; backup files are saved only where the user chooses.)
- **Data shared:** none.
- **Encryption in transit:** yes (HTTPS). **Encryption at rest:** the library file is not separately encrypted by the app; it lives in Android's private app storage, which Android encrypts with the screen lock. Backups and database exports are encrypted when the user sets a passphrase.
- **Deletion:** uninstall; saved backup files are deleted by the user.
- **Permissions justification:** see the Permissions section above.
