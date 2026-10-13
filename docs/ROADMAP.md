# Pagemark — Roadmap (0.4.2 → 1.0)

Written 2026-10-12 after v0.4.1. This file is meant to be picked up cold — from another computer, or by a fresh Claude Code
session — without the history of how we got here. Pair it with [CLAUDE.md](../CLAUDE.md) (architecture + every gotcha) and
[ROUNDING_OUT_REPORT.md](ROUNDING_OUT_REPORT.md) (the 430-item backlog; IDs like `IB-41` below refer to it).

## 0. Working away from home

### Get a working checkout (any OS)
```bash
git clone https://github.com/AxialForge/Pagemark.git && cd Pagemark
flutter --version                      # needs Flutter 3.47+ (stable)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/db.g.dart
flutter analyze && flutter test        # must be green before you start (44 tests, ~20 s)
```
- **Windows + JDK 25 only:** Gradle fails with "Unable to establish loopback connection". `mkdir C:\tmpj` and set
  `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/tmpj` before any `flutter build`. (macOS/Linux/CI are not affected.)
- **No phone?** Use an Android emulator (API 34+ x86_64 image). Drive it with `docs/_tools/screenshots/` helpers.
  Seed realistic data with `SEED_OUT=... flutter test test/tool_seed_demo_test.dart` (see that folder's README).
- **Tests that must stay green:** `test/data_safety_test.dart` (DB, migration, restore, export, encryption, lock),
  `lookup_test.dart`, `updater_test.dart`, `features_test.dart`, `branding_test.dart`.

### What can and can't be done away from home
| Can do anywhere | Needs the home PC (or setup first) |
|---|---|
| All Dart/Flutter code, tests, docs, screenshots (emulator) | **Signing a release APK** — the keystore `~/.android/pagemark-release.jks` and `android/key.properties` exist only on the home PC (never in git) |
| Pushing branches, opening PRs, CI runs | Testing on the real phone (biometrics, camera scanner, Drive sign-in) |
| Building *debug* APKs | Anything needing the user's Google account (Drive backup end-to-end) |

**Task R0 (do this first if you want to ship releases from elsewhere):** add a CI release workflow
`.github/workflows/release.yml` that, on a pushed tag `v*`, builds signed split APKs and attaches them to the GitHub Release.
It needs four repository secrets the owner must add once (Settings → Secrets and variables → Actions):
`KEYSTORE_BASE64` (`base64 -w0 pagemark-release.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS` (`pagemark`), `KEY_PASSWORD`.
The workflow decodes the keystore to `android/key.properties` + a temp file (`storeFile=<abs path>`), runs
`flutter build apk --release --split-per-abi`, renames to `Pagemark-<ver>-arm64.apk` / `-armv7.apk` (the updater matches `arm64`/`armv7`
in the name — see CLAUDE.md), and uploads with `gh release create`. **Do not** commit the keystore or passwords; if secrets are
missing the job must fail loudly rather than fall back to debug signing (a debug-signed APK can't upgrade release installs).
*Accept:* pushing tag `v0.0.0-test` on a throwaway branch produces a release whose APK verifies with `apksigner` to SHA-1
`39:04:59:AD:24:0F:35:99:4B:CD:A5:86:81:AF:9C:21:8C:FD:27:F7`. Delete the test release/tag afterwards.

### Conventions (house rules)
- Commit as **AxialForge** (`git config user.name/user.email` global; check `git config --local --get-regexp "^user\."` is empty). No
  `Co-Authored-By` / "Generated with" trailers.
- Commit messages: imperative, lower-case after the first word, no trailing period, no `feat:`/`fix:` prefixes — describe the behaviour change.
- Version in `pubspec.yaml` + a `CHANGELOG.md` entry in the **same commit** as the bump; tag `vX.Y.Z`; CI/maintainer attaches APKs.
  The changelog is shipped in the app (`## [x.y.z]` / `### Section` / `- bullet` shape matters — see CLAUDE.md).
- Every behaviour change gets a test. DB schema change ⇒ bump `AppDb.currentSchema`, add the `onUpgrade` step, extend the migration test.
- Never let locked-library data leak (Stats, Trash, duplicates, exports, search all filter on `locked`) — CLAUDE.md "Non-negotiables".
- Don't add paid services, telemetry or new network destinations without updating the privacy text in the manuals + CLAUDE.md.
- After UI changes, re-shoot affected screenshots and run `python docs/_tools/build_docs.py`.

### A prompt to paste into Claude Code on another machine
> Read CLAUDE.md and docs/ROADMAP.md. Implement task **0.4.2-A** from the roadmap on a new branch, with tests, following the
> conventions in section 0. Run `flutter analyze` and `flutter test`. Don't tag or publish; open a PR (or leave the branch pushed)
> and summarise what changed and what I should test on my phone.

---

> **Status (2026-10-12):** v0.7.0 prepared on `main` (auto-lock delay + whole-app lock = 0.7.0-B; 0.7.0-A encrypted DB DROPPED by the owner; 0.7.0-C notifications shipped in 0.4.3; 0.7.0-D R8 was already on; 0.7.0-E privacy doc shipped in 0.4.3); v0.6.0 prepared on `main` (quotes 0.6.0-A, local covers + bundled backups 0.6.0-B, optional heat/content fields 0.6.0-C, author pages + series totals 0.6.0-D; sub-ratings 0.6.0-E NOT done); v0.5.0 prepared on `main` (import: 0.5.0-A/B/C done; multi-select, swipe and undo: 0.5.0-E done; grid view done earlier); v0.4.2 and v0.4.3 are done and shipped/prepared; start from section 2 (0.5.0) unless the owner says otherwise.

## 1. v0.4.2 — "Close the gaps" (small, high value)

Everything here was found while using or documenting 0.4.1. Target: one sitting.

> **Status:** 0.4.2-A..E are implemented on `main` (not yet tagged). 0.4.2-F needs the owner's secrets.

### 0.4.2-A Vault Trash (restore locked books you deleted)
- **Problem:** deleting a book from the locked library soft-deletes it, but `TrashPage` hides locked titles, so it can never be restored
  and silently purges after 30 days. (Report: "Found while writing the documentation".)
- **Do:** make `AppDb.watchTrash({required bool locked})`. Show the normal Trash only for `locked: false`. Add a "Trash" entry inside the
  unlocked vault (`Library(locked: true)` menu, next to Series/Shelves) that opens `TrashPage(locked: true)`. Close it through
  `wipeLockedTraces()` like every other vault route.
- **Accept:** delete a locked book → it is absent everywhere → unlock vault → Trash → restore → it's back. Main-library Trash never lists it.
- **Tests:** db test for `watchTrash(locked:)`; widget test that `TrashPage(locked:false)` omits a locked row.

### 0.4.2-B Strip unused permissions
- **Problem:** plugins merge `READ_MEDIA_IMAGES/VIDEO/AUDIO`, `READ_EXTERNAL_STORAGE`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE*`,
  `RECEIVE_BOOT_COMPLETED` into the manifest. Pagemark reads no media.
- **Do:** in `android/app/src/main/AndroidManifest.xml` add `xmlns:tools` and
  `<uses-permission android:name="…" tools:node="remove"/>` for the media/storage/notification ones. **Keep** `RECEIVE_BOOT_COMPLETED`,
  `WAKE_LOCK`, `FOREGROUND_SERVICE*` if WorkManager needs them (verify scheduled backup still registers; if unsure keep them).
- **Accept:** `aapt2 dump badging app-release.apk | grep uses-permission` shows only INTERNET, USE_BIOMETRIC/FINGERPRINT, CAMERA,
  REQUEST_INSTALL_PACKAGES, ACCESS_NETWORK_STATE, WAKE_LOCK (+ what WorkManager needs). Update the permissions table in INSTALL_MANUAL.md
  (remove the "bundled permissions" sentence).

### 0.4.2-C PIN note after restore
- **Do:** at the end of `restoreFlow` (`lib/backup_page.dart`), before "Close app", add: "Your PIN isn't part of backups — open the Locked tab and
  set a new PIN." (Only if the backup contains locked books: query `SELECT 1 FROM books WHERE locked=1` on the candidate in `inspect`.)
  Extend `RestoreCheck` with `lockedBooks`.
- **Accept/Tests:** `inspect()` reports `lockedBooks > 0` for a DB with a locked row.

### 0.4.2-D Search clean-up (Open Library noise)
- **Problem:** popular titles return study guides/summaries/workbooks (see the `add-book` screenshot).
- **Do:** in `lib/lookup.dart` add `Lookup.rank(List<BookMeta>, query)`: score +3 cover present, +2 author name appears in the query or the
  top author, −5 for titles matching `^(summary|study guide|workbook|analysis|trivia|quiz)\b|summary of|study guide`. Sort stable by score.
  In `AddBook` show the top 12; put the rest behind a "Show N more results" tile.
- **Accept:** with the recorded fixture for "circe madeline miller" the real *Circe* is first and the four guides are behind "Show more".
- **Tests:** unit test with fixture JSON in `test/lookup_test.dart`.

### 0.4.2-E Debug-only updater preview
- **Do:** in `UpdatePage`, when `kDebugMode`, a menu item "Pretend a newer version exists" injects a fake `UpdateInfo` (version +0.0.1, two
  fake notes, no asset). Lets docs/screenshots show the "available" state.
- **Accept:** release builds don't contain the menu (`kDebugMode` guard); add the screenshot `updates-available.jpg` to the manual §13.

### 0.4.2-F Release workflow (R0 above) — only if the owner has added the secrets.

**Release 0.4.2:** bump to `0.4.2+6`, changelog, tag, publish. Then check Settings → Updates on a phone running 0.4.1 finds it.

---

## 2. v0.5.0 — "Bring your books, see your books"

Theme: getting existing history in, and a nicer way to browse.

### 0.5.0-A Import: Pagemark CSV/JSON round-trip (FB-31, IB-82)
- Parse the files `Exporter` writes (`formatVersion` in JSON). Preview screen: N books / N reads found, N duplicates (same ISBN or
  title+author), choices **Skip duplicates / Add anyway**. Write in one DB transaction; never touch locked books (exports exclude them).
- New file `lib/importer.dart` (pure Dart, testable) + `ImportPage` in `lib/features.dart` or a new `lib/import_ui.dart`; entry in Settings → "Import".
- **Tests:** export → import into an empty memory DB → rows equal; duplicate handling; malformed file → readable error, nothing written.

### 0.5.0-B Import: Goodreads CSV (FB-27)
- Goodreads export columns: `Title, Author, ISBN, ISBN13, My Rating, Date Read, Date Added, Exclusive Shelf, Bookshelves, My Review, Number of Pages, Year Published, Publisher, Binding`.
  Map: `Exclusive Shelf` read→finished, currently-reading→reading, to-read→want; `My Rating` 0 → no rating; `Date Read` → finished;
  `Bookshelves` → shelves (create); `My Review` → thoughts; `Binding` Audiobook/Audible→audio, Kindle/ebook→ebook else print.
  Strip Goodreads' `="978…"` ISBN quoting. Cover via `https://covers.openlibrary.org/b/isbn/<isbn13>-L.jpg` (no per-book lookup).
- **Tests:** a 5-row fixture in `test/fixtures/goodreads_sample.csv` (invent titles; don't commit real personal data).

### 0.5.0-C Import: StoryGraph CSV (FB-28) — same pipeline, different column map (`Read Status`, `Star Rating`, `Last Date Read`, `Format`).

### 0.5.0-D Grid / cover-wall view (FB-73, UI-09) — **DONE in 0.4.2 as part of Library styles (`lib/skins.dart`)**; the notes below are kept for reference
- Toggle in the Library AppBar (list ⇄ grid, remembered like sort). `SliverGrid` of `Cover(w: …)` with a rating star overlay and a progress strip
  for active reads. Keep `Hero` tags (`'cover-${id}'`) so the transition to `BookPage` still works.
- **Tests:** widget test pumping `Library` with a memory DB is awkward (global `db`); instead extract `LibraryGrid(rows:)` as a pure widget and test that.

### 0.5.0-E Multi-select + bulk actions (FB-70, FM-04), swipe actions (FM-03), undo (FM-01)
- Long-press enters selection mode: set status, add to shelf, move to locked/main, move to Trash. Undo snackbar for Trash and bulk moves
  (restore within the snackbar duration using `restoreBook`). Swipe-end = Trash with undo; swipe-start = quick "Finished today".
- Moving to locked must call `wipeLockedTraces()` semantics only on lock; moving *to* locked is allowed from the main library.

**Release 0.5.0:** manuals get an "Importing" section + screenshots (seed an import fixture); Release Notes; `Package Overview` mention.

---

## 3. v0.6.0 — "Capture more of what you read"

### 0.6.0-A Quotes & highlights (FB-06) — schema 4
- New table `quotes(id, bookId→books cascade, text, page int?, note text, created)`. Book page section "Quotes" with add/edit/delete; share a quote as text.
  Search (`Library` search box) also matches quote text (FB-72 partial). Include in CSV/JSON (new `quotes.csv`? or a `quotes` array in JSON v2 —
  bump `Exporter.formatVersion` to 2 and keep v1 import working). Locked books' quotes never leave the vault.

### 0.6.0-B Local covers (FB-19, IB-52, IB-59)
- Pick from gallery/camera (`image_picker`) or "Save cover offline": copy the image into app documents `covers/<bookId>.jpg` (downscale to ≤600 px),
  new column `books.coverPath`. `Cover` prefers `coverPath`. Backups (Drive + DB export) must include covers: switch the backup container to a zip
  (`archive` package) of `pagemark.sqlite` + `covers/`, keep the old plain-sqlite path readable. **Update restore validation and tests.**
- Locked-book covers are stored in the same folder but listed only by the vault; wipe nothing on relock (they're local files, not cache) — but they must be
  in the encrypted backup.

### 0.6.0-C Content/heat rating & content notes (FB-05, FB-65)
- Per-read optional `heat` (0–5) and free-text `contentNotes` (reads table, schema 4/5). Private; stats card "Heat" only in the main library and only if the
  user enabled it (Settings toggle, default off — adult readers only). Never exported to CSV unless the toggle is on.

### 0.6.0-D Author pages (FB-13) & series total (FB-12)
- Tap author on the book page → list of that author's books in the current library + average rating. Series: optional `seriesTotal` field to show "3 of 7".

### 0.6.0-E Multi-dimension ratings (FB-04) — optional sub-ratings (plot, characters, prose, pacing, emotion) behind a toggle.

---

## 4. v0.7.0 — "Security depth"

### 0.7.0-A Encrypted database at rest (IB-11) — **DROPPED**
> **Decision (2026-10-12, owner): no encrypted database.** Android already isolates app storage and encrypts it with the screen lock; an on-device key would sit on the same phone, so it only raises the bar against root-level attackers, while the one-time conversion risks the user's data and adds APK size, plugin and test complexity. Exports and Drive backups can already be passphrase-encrypted. Only reopen if the owner asks for it as an opt-in setting.

*(original plan, kept for reference)*
- Replace `NativeDatabase` with SQLCipher (`sqlcipher_flutter_libs` + `drift`'s `sqlite3` override). Key = random 32 bytes in `flutter_secure_storage`.
  **Migration:** on first launch of this version, `sqlcipher_export` the old plaintext DB into an encrypted one, verify row counts, keep a
  `pre-encrypt-*.sqlite` safety copy in app storage for one release, then delete. The background backup isolate needs the same key.
  Restore/`inspect` must open candidates plain (backups are re-encrypted by the container, not by SQLCipher).
- **Risk: high.** Test on an emulator with a seeded DB; add an integration-style test with a temp file. Ship behind a clear changelog note.

### 0.7.0-B Auto-lock timeout + whole-app lock (FB-47, FB-50)
- Settings: lock the vault after N minutes in the background (default immediate = today's behaviour; options 1/5/15 min). Optional "Lock the whole app"
  (PIN/biometric at launch). Reuse `LockService`; gate in `Home` before building tabs.

### 0.7.0-C Backup failure notifications (IB-42) — `flutter_local_notifications`; notify once per failure streak; deep-link to the backup page.

### 0.7.0-D Release hardening (IB-68, IB-17)
- Turn on R8 (`isMinifyEnabled = true`, `isShrinkResources = true`) with keep rules for plugins that use reflection (drift's sqlite3, google_sign_in,
  workmanager, local_auth). **Must be device-tested**: scheduled backup, biometrics, scanner, updater install, restore. Biometric strength: require
  `BiometricType.strong` via `AuthenticationOptions(biometricOnly: …)` where supported.

### 0.7.0-E Privacy review & Play-readiness (IB-81)
- Write `docs/PRIVACY.md` (what is stored, what leaves the device, retention), a Play "Data safety" cheat-sheet, and a threat-model paragraph.

---

## 5. v0.8.0 — "Always at hand"

- **Reminders (FB-77):** optional daily reading reminder + goal nudges (local notifications; time picker; off by default).
- **Home-screen widget (FB-78/79):** "Currently reading" + goal ring using `home_widget`; widget data must exclude locked books.
- **Share target (FB-80):** accept shared ISBN / text / Goodreads & Open Library URLs → opens Add book prefilled (`receive_sharing_intent` or an intent filter + platform channel).
- **App shortcuts (FB-82):** Add book, Log progress (static + pinned shortcuts).
- **Quick progress from notification (FB-81)** — only if time allows.

## 6. v0.9.0 — "Everywhere"

- **iOS (FB-83):** needs a Mac. Info.plist usage strings (`NSCameraUsageDescription`, `NSFaceIDUsageDescription`), Keychain accessibility, background
  backup via BGTaskScheduler (WorkManager iOS setup), signing + TestFlight. Icons already generated (1024 px is upscaled — supply a larger master).
- **Localization (FB-85):** move strings to ARB files (`flutter gen-l10n`), start with en + one more language; check RTL.
- **Accessibility pass (FB-86):** TalkBack/VoiceOver labels, 48 dp targets, 200 % text; fix anything that overflows (the widget tests show how to catch it).
- **Tablet/landscape layouts (FB-84):** two-pane library/detail at ≥ 840 dp.

## 7. v1.0.0 — "Done"

Exit criteria: all v0.4.2–v0.8.0 items shipped or consciously dropped; no open **Big** issue in the report that can lose or leak data; 100 % of
screens covered by the screenshots in the manuals; real-phone test pass (biometrics, scanner, Drive, update install, restore on a second device).
**A major release triggers the documentation set** (user's global rule): regenerate User Manual, Install Manual, Release Notes, README, Package
Overview (simple/medium/advanced) and the GitHub repo details (description, topics, README screenshots) — `python docs/_tools/build_docs.py`.

---

## 8. Parking lot (valuable, not scheduled)
Goodreads-style recommendations from your own data (FB-24) · Year-in-books image cards (FB-34) · PDF reading report (FB-33) · Markdown/Obsidian export (FB-35) ·
WebDAV/Dropbox backup targets (FB-46) · LAN transfer between two phones (FB-42) · decoy PIN (FB-49) · custom fields (FB-89) · challenges/badges (FB-90).
Full list with IDs: `docs/ROUNDING_OUT_REPORT.md`.

## 9. Definition of done for any task
1. `flutter analyze` clean, `flutter test` green, new tests for the new behaviour.
2. Locked-library leak check (grep your change for places that list books: does each filter `locked`?).
3. Docs: CHANGELOG entry; manual section + screenshot if the UI changed; CLAUDE.md gotcha if something bit you.
4. Version bump only in the release commit; tag only after the owner has tried it on a phone (or explicitly says to ship).
