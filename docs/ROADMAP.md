# Pagemark - Roadmap (rewritten 2026-10-14, after v0.9.0)

Written to be picked up cold, from another computer or by a fresh Claude Code session. Pair it with [CLAUDE.md](../CLAUDE.md) (architecture and every gotcha) and [ROUNDING_OUT_REPORT.md](ROUNDING_OUT_REPORT.md) (the 430-item backlog; IDs like `FB-24` below refer to it).

**Direction (decided with the owner):** Pagemark is for **non-technical readers**. Plain words everywhere, nothing that needs a developer account or a setup guide, private by default, no paid services, no cloud account required.

---

## 1. Shakedown: where the app stands

### What is solid
| Area | State |
|---|---|
| Core log | Books, reads (print / e-book / audio), stars, thoughts, progress, goals, series, shelves, quotes, author pages, detailed ratings, 5 library styles, 6 themes, trash, undo |
| Privacy | Locked library (PIN or fingerprint, recovery code, lockouts), optional whole-app lock, no screenshots/recents of locked screens, hidden Locked tab, widget never shows locked books |
| Data safety | Verified restore with restore points, password-protected backup file, spreadsheet export, import from Goodreads/StoryGraph/Pagemark with undo, schema migrations 1 to 5 tested |
| Quality | 228 automated tests, analyzer clean, 84-finding audit (all HIGH and MEDIUM fixed in code), 5,000-book library tested (cold start 1.3 s) |
| Product | Settings in plain language, built-in guide kept honest by a test, notifications page, share target, widget, shortcuts |
| Release process | `tool/build.ps1` makes signed APKs and a Play bundle; 9 releases since the audit |

### What is weak or unproven (honest list)
1. **Nothing has had a real-phone test pass.** Fingerprint, the barcode scanner, the widget, the 10:00 reminders, the in-app update install and restore on a second phone were only checked on an emulator, or not at all (`docs/release-audit/MANUAL_TEST_PLAN.md`).
2. **Backups depend on the user.** Google Drive backup was removed (too hard to set up). The reminder helps, but a person who ignores it has no safety net, and "save a file somewhere" is still a technical idea.
3. **First run is bare.** An empty Library and a button. No welcome, no sample data, no explanation of the Locked tab.
4. **Finding a book can fail.** One search source (Open Library). Obscure titles, new releases and non-English books often come back empty, which a non-technical person reads as "the app is broken".
5. **Accessibility is unchecked.** No TalkBack pass, large text only partly checked, tap sizes unmeasured. Many readers are older or low-vision.
6. **English only, phone portrait only.** No localisation, no tablet or landscape layouts.
7. **Documentation is stale.** Manual PDFs and screenshots are from 0.4 to 0.7; the UI layout guide predates the new Settings, Notifications and ratings.
8. **Code health.** `lib/ui.dart` is about 1,700 lines holding most screens. Hard to change safely. A script silently garbled dashes in 0.7.1 to 0.8.0 and no test caught it.
9. **Audit leftovers.** 22 LOW and 12 INFO items are accepted or deferred (see `docs/release-audit/FINDINGS.md`).
10. **Not on any store.** Play Store is prepared (`docs/PLAY_STORE.md`) but nothing is registered. iOS needs a Mac.

---

## 2. Proposed order

### 0.9.1 "Prove it" (small, do first)
Goal: find out what is really broken before adding more.
- **Real-phone test pass** on your own phone using `docs/release-audit/MANUAL_TEST_PLAN.md`: fingerprint, scanner, widget, reminders arriving, update install, restore on a second phone, TalkBack basics. Record results in the repo.
- Fix whatever it finds.
- **Mojibake guard:** a test that fails if source files contain garbled dashes or a BOM (the 0.7.1 bug).
- Widget preview image in the widget picker.
- Regenerate screenshots and the UI layout PDF for the current screens.

### 0.10.0 "First run and safety" (the non-technical release)
- **Welcome screens** (3 swipes, skippable) and an **optional sample library** ("try it with 5 example books", removable in one tap). Explains the Locked tab and backups in one line each.
- **Backup to a folder you choose (FB-38).** Pick a folder once with Android's own file picker; Pagemark then saves its password-protected backup there by itself (when you open the app and a backup is due). Because Android's picker can point at **Google Drive, OneDrive, Dropbox or a USB drive**, this gives cloud backup with **no Google Cloud project, no client ID and no sign-in code in Pagemark**. This replaces the removed Drive feature. Needs a small Android file-access piece (about one session).
- **"Back up now?" nudge** in the Library when overdue, not just a notification.
- **Smarter search when nothing is found:** offer to try another spelling, search by author, or add by hand with the barcode number kept.
- **Defaults (FB-88):** date format, week start, default format (print/e-book/audio).

### 0.11.0 "Everyone can use it"
- **Accessibility pass (FB-86):** TalkBack labels for every control, 48 dp tap targets, tested at 200 % text, contrast check, no information carried by colour alone.
- **Tablet and landscape layouts (FB-84):** two-pane Library and book page at 840 dp and up.
- **Localisation (FB-85):** move all text to translation files; English plus one more language (owner to choose); check right-to-left. The in-app guide is translated too.
- **Code health:** split `ui.dart` into one file per screen group, no behaviour change, tests unchanged.
- Close out the deferred audit items that are cheap.

### 0.12.0 "Reading life" (features people enjoy)
Chosen for non-technical readers: visible, friendly, no setup.
- **Year in books (FB-34 / FB-58):** a shareable picture card ("2026: 24 books, 8,120 pages, favourite genre Fantasy"), spoiler-free and never including locked books.
- **Reading streak and calendar (FB-09):** a gentle month view of days you read, with no guilt wording.
- **Reading timer (FB-02):** start/stop while you read, pages per session feeding the progress card.
- **To-read list with order (FB-10):** drag to reorder what to read next.
- **Lending tracker (FB-67 / FB-68):** "lent to Sam on 3 Oct", with an optional reminder to ask for it back.
- **Printable reading report (FB-33):** one PDF for the year.

### 0.13.0 "Finding books"
- **Second book source (FB-15):** Google Books alongside Open Library, merged, so fewer searches come back empty.
- **Refresh details (FB-17)** for an existing book without losing your data; **edition picker (FB-16)**.
- **Bulk scan mode (FB-18):** scan a whole shelf, one beep per book.
- **"What next?" suggestions (FB-24 / FB-25)** from your own library only (same author, series, genre); nothing leaves the phone.

### 1.0.0 "Done"
Exit criteria: everything above shipped or consciously dropped; no open data-loss or leak finding; a clean real-phone pass; screenshots cover every screen.
- **Google Play release:** developer account, a 14-day closed test with about 12 testers, Data safety form (answers prepared), listing and graphics. See `docs/PLAY_STORE.md`.
- **Major-release documentation set (house rule):** regenerate the User Manual, Install Manual, Release Notes and README; write the **Package Overview in three tiers** (simple, medium, advanced); refresh the GitHub repo details (description, topics, screenshots). `python docs/_tools/build_docs.py`, `docs/_tools/build_ui_layout.py`.

### After 1.0
- **iOS (FB-83):** needs a Mac (Face ID text, Keychain, share extension, TestFlight).
- Chapter notes with spoiler hiding (FB-07), merge-restore (FB-41), edition-level dedupe (FB-23), price tracking (FB-66).

---

## 3. What I would not do (and why)
| Idea | Decision |
|---|---|
| Encrypted database (SQLCipher) | Declined by the owner, 2026-10-12. Do not re-propose. |
| Google Drive API backup | Removed in 0.9.0: needs a Cloud project and client ID. Replaced by "backup to a folder you choose" (0.10.0). |
| Accounts, social features, ads, analytics | Against the product's promise. |
| Decoy PIN, multiple vaults, custom fields, badges and challenges, LAN sync between phones | Too technical or too niche for the audience; parked. |
| Paid services or certificates | Never (owner rule). |

---

## 4. Working away from home

### Get a working checkout (any OS)
```bash
git clone https://github.com/AxialForge/Pagemark.git && cd Pagemark
flutter --version                      # needs Flutter 3.47+ (stable)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/db.g.dart
flutter analyze && flutter test        # must be green before you start (about 230 tests)
```
- **Windows + JDK 25 only:** Gradle fails with "Unable to establish loopback connection". `mkdir C:\tmpj` and set `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/tmpj` before any `flutter build`.
- **No phone?** Use an Android emulator (API 34+ x86_64). Helpers and the screenshot recipe are in `docs/_tools/screenshots/` and `docs/_tools/build_ui_layout.py`.

### What needs the home PC
| Anywhere | Home PC only |
|---|---|
| All code, tests, docs, emulator screenshots, debug APKs, pushing branches | The signing keystore `~/.android/pagemark-release.jks` and `android/key.properties` (never in git) and `tool/build.ps1` release builds |
| CI runs (analyze, tests, debug builds of both flavors) | Real-phone checks and anything using your accounts |

### House rules
- Commit as **AxialForge** (check `git config --local --get-regexp "^user\."` is empty). No attribution trailers. Imperative messages, no `feat:` prefixes.
- Bump `pubspec.yaml` and write the `CHANGELOG.md` entry in the same commit; tag `vX.Y.Z`; attach the two APKs (`arm64`, `armv7` must stay in the file names, the updater matches them).
- **Definition of done for any task:** analyzer clean, tests green with new tests; locked data never leaks (grep for places that list books); **update `assets/guide.md`** (the in-app guide, checked by `test/guide_test.dart`) and the changelog; schema change means a migration step plus a test (see the migration trap in CLAUDE.md).
- Never edit source with Windows PowerShell `Get-Content`/`Set-Content` (re-encodes UTF-8).
- Plain words in every message a user can see.

### A prompt to paste into Claude Code on another machine
> Read CLAUDE.md and docs/ROADMAP.md. Implement the next unfinished item of release **0.9.1** (or the release I name) on a new branch, with tests, following the house rules. Run `flutter analyze` and `flutter test`. Update `assets/guide.md` and `CHANGELOG.md`. Don't tag or publish; leave the branch pushed and summarise what I should test on my phone.
