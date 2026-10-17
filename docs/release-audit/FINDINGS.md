# Findings register - Pagemark 0.7.0 (audited commit 045e8147)

IDs are permanent. Found: HIGH 6, MEDIUM 17, LOW 41, INFO 20 (total 84).

Fixed in code, with new tests, awaiting the auditor's verify pass (and real-device checks listed in MANUAL_TEST_PLAN.md): HIGH 6, MEDIUM 17, LOW 30, INFO 1. Accepted or deferred with a reason: LOW 11. Still open (observations, positives, not-run notes): INFO 12.

Fix commits are on main: 6052bc8..19f74f1 (0.7.1 shipped as v0.7.1; later commits are in 0.7.2 prep).

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
| PGM-001 | LOW | Accessibility | Library filter chips | At system font scale 2.0 the "All" status chip text is clipped at the bottom (chip height does not grow with text); other chips scroll horizontally and are fine. | auditor (shots/c_font2.png) | 8ca6bbe | READY FOR VERIFICATION |
| PGM-002 | LOW | UX | Empty library | The empty state shows both an "Add a book" button and the "Add book" FAB, two controls for one action. | auditor (shots/a_first_launch.png) | 8ca6bbe | READY FOR VERIFICATION |
| PGM-003 | INFO | Packaging | Release assets | Only arm64 and armv7 APKs are published; x86_64 emulators cannot install the release. Release behaviour was verified on a locally built, release-signed x86_64 APK. | auditor | | OPEN |
| PGM-004 | INFO | Compat | Orientation | Landscape/tablet layout NOT SEEN: the emulator did not rotate the app when user_rotation=1 was set, and the manifest has no screenOrientation lock. Needs a real device or a rotating emulator. | auditor | | OPEN |
| PGM-005 | INFO | Tests | bulk_test | Three "tap() missed hit test" warnings in the bulk-selection tests; tests pass but the taps may not hit the intended widget. | auditor (suite1.log) | | OPEN |
| PGM-006 | INFO | Positive | Restore / scale | Restore of a 5,000-book backup works through the picker; dialog counts are correct; locked-books/PIN message is correct; cold start 1.3 s and ~120 MB PSS at 5k books; Stats totals exclude locked books as designed. | auditor | | VERIFIED |
| PGM-100 | HIGH | Data safety | export.dart:241-286, backup_page.dart:45, import_ui.dart:133 | The restore/import "safety copy kept in the app (newest 3)" cannot be restored from anywhere in the UI (USER_MANUAL.md:299 promises it) | code | f272ec6 | READY FOR VERIFICATION |
| PGM-101 | HIGH | Security | lock.dart:98 | PIN lockout integer overflow: `30*pow(2,n~/5-1)` goes negative at 300 failures and is 0 s from 320; counter resets only on success, so attempt limiting silently stops | script pgm_engine_audit_test [K-lockout-overflow] | 6052bc8 | READY FOR VERIFICATION |
| PGM-102 | HIGH | Data safety | backup.dart:145,157 | Changing the backup passphrase does not change the upload signature (`bk_hash` not cleared), so scheduled backups skip; Drive keeps only old-passphrase backups | code (not run against Drive) | 6052bc8 | READY FOR VERIFICATION |
| PGM-103 | HIGH | Test coverage | export.dart restoreDb, safetyCopy | No tests in the repo for restore and safety copy (destructive path) | code | f272ec6 | READY FOR VERIFICATION |
| PGM-104 | MEDIUM | Data safety | export.dart restore | Failure after the DB swap (e.g. cover import) shows "restore failed" but the live file is already replaced and the connection closed | script [R-fail-after-swap] | f272ec6 | READY FOR VERIFICATION |
| PGM-105 | MEDIUM | Data safety | export.dart safetyCopy | Safety-copy names have minute resolution; a second restore/import in the same minute overwrites the first restore point | script [R-safety-copy-collision, R-pre-import-collision] | f272ec6 | READY FOR VERIFICATION |
| PGM-106 | MEDIUM | Data safety | export.dart inspect() | No column checks: id-only tables or user_version 0 pass inspection, then fail to open after the swap | script [D-inspect-no-column-check, D-inspect-user-version-0] | f272ec6 | READY FOR VERIFICATION |
| PGM-107 | MEDIUM | Robustness | export.dart:163-176 | unpack has no size cap and decompresses ignored entries in memory; a 537 KB zip uses 120 MB RAM and disk | script | f272ec6 | READY FOR VERIFICATION |
| PGM-108 | MEDIUM | Data safety | importer | Undo import leaves reads/quotes added to existing books and created shelves | script [I-undo-addreads, I-undo-shelves] | 91d4e2c | READY FOR VERIFICATION |
| PGM-109 | MEDIUM | Data safety | CSV/JSON export-import | Round trip loses series_number, current_page, description, cover | script [RT-*-lossless] | a8f05d4 | READY FOR VERIFICATION |
| PGM-110 | MEDIUM | Privacy | shelves | Shelf names are global; vault shelf names show in main-library chips/picker | script [V-leak[shelf names]] | 19f74f1 | READY FOR VERIFICATION |
| PGM-111 | MEDIUM | Privacy | book_extras.dart:219-235 | Covers page counts locked books and "Save all" downloads vault covers into the plain covers folder | code (UI not run) | 6fdb6b8 | READY FOR VERIFICATION |
| PGM-112 | LOW | Robustness | importer | Raw UnsupportedError on NaN/Infinity/1e400 in year/pages/minutes cells; TypeError for non-list JSON `books` | script | a8f05d4 | READY FOR VERIFICATION |
| PGM-113 | LOW | Engine | date parsing | Lenient ISO dates (02-30 becomes 03-02, month 13 rolls, offset shifts day, years 0001/9999) | script | a8f05d4 | READY FOR VERIFICATION |
| PGM-114 | LOW | Robustness | export.dart | Zip entry `covers/.` throws raw PathAccessException and leaks the temp dir | script | 19f74f1 | READY FOR VERIFICATION |
| PGM-115 | LOW | Engine | covers | removeUnused race can delete a just-saved cover | code | 91d4e2c | READY FOR VERIFICATION |
| PGM-116 | LOW | Engine | importer | Same ISBN with different titles merged silently | script |  | ACCEPTED RISK |
| PGM-117 | LOW | Engine | Goodreads import | Read-shelf row without Date Read gets finished = Date Added | script |  | ACCEPTED RISK |
| PGM-118 | LOW | Engine | CSV | Leading tab/CR gains an apostrophe; text starting `'=` loses it on round trip | script | 91d4e2c | READY FOR VERIFICATION |
| PGM-119 | LOW | Robustness | updater.dart | Raw TypeError for non-list assets; missing tag_name becomes release "null" | script | a8f05d4 | READY FOR VERIFICATION |
| PGM-120 | LOW | Robustness | import | `pagemark_export` as string/double bypasses the newer-format guard | script | a8f05d4 | READY FOR VERIFICATION |
| PGM-121 | LOW | Engine | compareVersions | int64 overflow gives 0; `-rc` suffix ignored | script | a8f05d4 | READY FOR VERIFICATION |
| PGM-122 | LOW | Engine | Stats pace | Off by one day in the first hour after midnight under DST; 365 constant | script (expression replicated) | 91d4e2c | READY FOR VERIFICATION |
| PGM-123 | LOW | Engine | series number | Accepts NaN/Infinity; 1e20 displays 9223372036854775807 | script | 91d4e2c | READY FOR VERIFICATION |
| PGM-124 | LOW | Security | lock.dart | Concurrent checkPin undercounts failures (6 attempts count as 2) | script | 6052bc8 | READY FOR VERIFICATION |
| PGM-125 | LOW | Engine | backup passphrase | Not Unicode-normalised (same visible passphrase can fail to decrypt) | code |  | DEFERRED |
| PGM-126 | LOW | Robustness | bulk ops | 40,000-id bulk operation raises "too many SQL variables" | script | 91d4e2c | READY FOR VERIFICATION |
| PGM-127 | LOW | Engine | undo | Undo of mark-finished deletes a created read the user has since edited | code | 91d4e2c | READY FOR VERIFICATION |
| PGM-128 | LOW | Engine | dates | Stored as instants; a timezone change shifts the finished date | code |  | ACCEPTED RISK |
| PGM-129 | LOW | Robustness | lookup.dart | `byIsbn` has unguarded infinite paging, nameless suggestions, FormatException on bad bodies (UI shows a generic snackbar) | code | 19f74f1 | READY FOR VERIFICATION |
| PGM-130 | INFO | Engine | duplicates | Trashed titles are invisible to duplicate check and import; shelf names can differ only by case | code | | OPEN |
| PGM-131 | INFO | Privacy | watchQuoteText | Carries vault quote text into main-screen state (not displayed) | code | | OPEN |
| PGM-132 | INFO | Security | updater | Update download with no size/sha has no integrity check (see PGM-209) | code | a8f05d4 | READY FOR VERIFICATION |
| PGM-133 | LOW | Data safety | export.dart | Crash window between DB rename and cover import | code | f272ec6 | READY FOR VERIFICATION |
| PGM-200 | HIGH | Security | lock.dart, lock_ui.dart | Default `FlutterSecureStorage()` has `resetOnError` on; a Keystore failure wipes all keys, so the vault gate and whole-app lock offer "Set a PIN" and open without the old PIN | script pgm200_securestorage_loss_test.dart | 6052bc8 | READY FOR VERIFICATION |
| PGM-201 | MEDIUM | Privacy | log.dart, import_ui.dart, backup.dart | Diagnostics log can hold titles/notes: sqlite exceptions embed bound parameters and `Log.e/w` write raw exceptions | script pgm201_log_param_leak_test.dart | 6fdb6b8 | READY FOR VERIFICATION |
| PGM-202 | HIGH | Security | backup.dart:146-176 | Backup encryption depends on `bk_pass` in secure storage; after the same wipe scheduled Drive backups silently upload plaintext (locked books included) with no notification | code | 6052bc8 | READY FOR VERIFICATION |
| PGM-203 | MEDIUM | Privacy | privacy.dart:30-38 | Plaintext exports and picked backups persist in `cache/share_plus` and `cache/file_picker`, which `cleanTempExports` never touches; contradicts manual section 8 and IB-10 "fixed" | code (plugin sources; not run on device) | 6fdb6b8 | READY FOR VERIFICATION |
| PGM-204 | MEDIUM | Security | ui.dart:172-187 VaultPage | `dispose` clears FLAG_SECURE on pause for the hidden-tab vault; unverified | code | 6052bc8 | READY FOR VERIFICATION |
| PGM-205 | LOW | Security | lock.dart, crypto_backup.dart | PBKDF2 150k iterations, 8-character passphrase minimum | code |  | ACCEPTED RISK |
| PGM-206 | LOW | Security | lock.dart, app_lock.dart | Lockout and delay use wall-clock time (clock change bypasses) | code | 19f74f1 | READY FOR VERIFICATION |
| PGM-207 | LOW | Security | ui.dart:1344-1350 | Remove lock leaves the app-lock pref on and the vault open to anyone | code | 6052bc8 | READY FOR VERIFICATION |
| PGM-208 | LOW | Security | lock_ui.dart:84 | Recovery code copied to clipboard and never cleared | code | 6052bc8 | READY FOR VERIFICATION |
| PGM-209 | LOW | Security | updater.dart:117,133-156 | Asset URL host/scheme not validated; digest check skipped when absent | code | a8f05d4 | READY FOR VERIFICATION |
| PGM-210 | LOW | Privacy | backup.dart:186-189 | Temp snapshots not deleted on failure | code | 6fdb6b8 | READY FOR VERIFICATION |
| PGM-211 | LOW | Privacy | tool/backup-to-nas.ps1, CLAUDE.md, LICENSE | Public repo shows NAS IP/share name, keystore location, owner's full name | auditor (git grep) | 19f74f1 | READY FOR VERIFICATION |
| PGM-212 | INFO | Security | repo, history, APK, PDFs | Secret scans clean | script pgm200_apk_scan.py | | VERIFIED |
| PGM-213 | LOW | Release | privacy.dart:19 | `PAGEMARK_SCREENSHOTS` value cannot be proven from the binary; no release guard | code | 19f74f1 | READY FOR VERIFICATION |
| PGM-214 | INFO | Security | backup.dart | Drive backups are plaintext by default (design) | code | | OPEN |
| PGM-215 | LOW | Robustness | export.dart:128-150 | Zip entries read fully into memory | code |  | ACCEPTED RISK |
| PGM-216 | INFO | Security | manifest | Manifest review OK | auditor (aapt2) | | VERIFIED |
| PGM-217 | INFO | Privacy | network | Outbound hosts match PRIVACY.md | code grep, APK strings | | VERIFIED |
| PGM-220 | INFO | Release | release assets | Signing, digests, versionCodes verified | script pgm220_release_verify.sh | | VERIFIED |
| PGM-221 | INFO | Release | signing | v2-only signature; one off-PC key copy | auditor (apksigner) | | OPEN |
| PGM-222 | MEDIUM | Release | release process | No release script; README output name `app-armeabi-v7a-release.apk` does not match the `armv7` name the updater needs; `tool\build.ps1` missing | code updater.dart:70-83 | 6fdb6b8 | READY FOR VERIFICATION |
| PGM-223 | LOW | Release | ci.yml | Debug build only, no release job, floating tags | code |  | DEFERRED |
| PGM-224 | LOW | Hygiene | pubspec | Unused riverpod; `+eol` sqlite3_flutter_libs | auditor | a8f05d4 | READY FOR VERIFICATION |
| PGM-225 | LOW | Hygiene | gradle.properties | Windows tmpdir in committed jvmargs | code |  | ACCEPTED RISK |
| PGM-226 | INFO | Release | native libs | 16 KB alignment OK | script pgm220_release_verify.sh | | VERIFIED |
| PGM-227 | INFO | Release | updater | x86_64 not published | code | | OPEN |
| PGM-228 | INFO | Release | R8 mapping | Kept local only | auditor | | OPEN |
| PGM-229 | LOW | Hygiene | repo | `android/.kotlin` untracked; stale User-Agent `Pagemark/0.3` | auditor | a8f05d4 | READY FOR VERIFICATION |
| PGM-231 | INFO | Data | db.dart | Migrations 1 to 4 complete; prefs/secure keys inventoried | code | | VERIFIED |
| PGM-240 | MEDIUM | Docs | INSTALL_MANUAL | Says 0.5.0 and "no notification permission"; manifest has POST_NOTIFICATIONS | auditor (aapt2) | 8b18d68 | READY FOR VERIFICATION |
| PGM-241 | MEDIUM | Docs | PACKAGE_OVERVIEW | Stale: schema 3, "not minified", "no failure notification", SQLCipher on roadmap | code | 8b18d68 | READY FOR VERIFICATION |
| PGM-242 | MEDIUM | Docs | DRIVE_SETUP | Claims backups are "not encrypted by Pagemark" | code | 8b18d68 | READY FOR VERIFICATION |
| PGM-243 | MEDIUM | Docs | manual 8/15, PRIVACY | "Temp exports deleted" and "log never has titles" are false on failure paths (see PGM-201/203) | cross-ref | 8b18d68 | READY FOR VERIFICATION |
| PGM-244 | LOW | Docs | CLAUDE.md | Stale permission list and roadmap; missing `tool\build.ps1` | code | 19f74f1 | READY FOR VERIFICATION |
| PGM-245 | LOW | Docs | screenshots | Version-stamped images are 0.4.1-0.5.0 | auditor |  | DEFERRED |
| PGM-246 | LOW | Docs | README, ROADMAP | "330" backlog is actually 430 entries | auditor | 8b18d68 | READY FOR VERIFICATION |
| PGM-247 | LOW | Docs | USER_MANUAL | Section numbering out of order | code |  | DEFERRED |
| PGM-248 | MEDIUM | Docs | ROUNDING_OUT | "Fixed" claims untrue or partial for IB-10, IB-16, IB-80, IB-44 | code | 8b18d68 | READY FOR VERIFICATION |
| PGM-249 | LOW | Docs | manual section 8 | Remove-lock description incomplete | code | 8b18d68 | READY FOR VERIFICATION |
| PGM-250 | LOW | Compat | ui.dart:39 | Dates en_US, 12-hour clock, no localisation | code |  | DEFERRED |
| PGM-251 | INFO | Compat | manifest | English-only; RTL moot | code | | OPEN |
| PGM-252 | LOW | Docs | INSTALL_MANUAL:27 | Unknown-sources step is Android 8+ only (minSdk is 24) | code | 8b18d68 | READY FOR VERIFICATION |
| PGM-253 | INFO | Compat | edge-to-edge / predictive back | NOT RUN | - | | OPEN |
| PGM-254 | INFO | Compat | tablet / multi-window | NOT RUN | - | | OPEN |

## 1.0.0 gate audit (Pagemark 0.13.0, commit b1bbf51, 2026-10-14)

Rows PGM-300 to PGM-327 come from the gate audit. Counts: MEDIUM 4, LOW 4, INFO 4 (3 verified positives). No BLOCKER, CRITICAL or HIGH.

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
| PGM-300 | MEDIUM | GUI / tablet | Stats page (lib/features.dart Stats; calendar in reading_life_ui.dart StreakCard) | On screens 840 dp and wider the Stats page is not width-capped, so the month calendar's square day cells grow with the screen: at 1200 dp wide each cell is about 250 px tall and one month fills several screens. Landscape phones get the same, milder. | auditor (evidence_1.0/f12_stats.png) | 2707555 | VERIFIED (emulator, tablet size) |
| PGM-301 | LOW | GUI / tablet | Guide, Add a book, Our promise and other pushed pages | Only the Settings sub-pages and Read next use NarrowColumn. The guide and Add a book are full width on a tablet (text lines about 1900 px long, search box edge to edge). | auditor (evidence_1.0/f4_tablet_land.png); code lib/ui/add_book.dart, lib/guide.dart | 2707555 | READY FOR VERIFICATION |
| PGM-302 | MEDIUM | Data quality | Lookup genre (lib/lookup.dart genres()) | Open Library subjects are copied into Genre as-is: a lookup for Dune filled it with "Dune (Imaginary place), Fiction, science fiction, general, Dune (imaginary place), fiction" (duplicates, places, a subject that itself contains commas). Stats Top genres, the year card's favourite genre and the suggestions take the first comma-separated word, so they would report "Dune (Imaginary place)" as the genre. | auditor (evidence_1.0/f11_pane_book.png); code lib/features.dart:~470, lib/reading_life.dart yearSummary, lib/finding.dart suggestNext | 2707555 | READY FOR VERIFICATION |
| PGM-303 | LOW | Hostile input | Lookup parsers (Google pageCount, Open Library number_of_pages_median) | A negative or absurd page count in a lookup answer is accepted and saved by Add (Refresh already rejects them), which would give negative or huge totals in Stats. 5,000 random shapes did not crash anything else. | script pgm310_lookup_fuzz_test.dart | 2707555 | READY FOR VERIFICATION |
| PGM-320 | MEDIUM | Engine / state | ReadingTimerCard (lib/reading_life_ui.dart) | A running reading timer can be stranded: start it on book A, then finish or delete A. A's timer card disappears (it only shows on a read that is Reading) but the saved timer stays, and every other book shows "The reading timer is running for another book" with no Stop button. It is recoverable only by logging A as Reading again. | script pgm320_stuck_timer_test.dart (fails as expected) | 2707555 | READY FOR VERIFICATION |
| PGM-321 | LOW | Privacy / tablet | Two-pane book pane (lib/adaptive.dart, lib/ui/book_page.dart) | In the two-pane layout, choosing Move to locked library on the open book leaves that book showing in the main Library's right-hand pane (and it stays after switching tabs) until another book is chosen. Phone layout leaves the page open too but Back removes it. | code book_page.dart 'lock' handler (no closeBook), home.dart pane | 2707555 | READY FOR VERIFICATION |
| PGM-322 | LOW | UX | Empty library | "See how Pagemark works" carries a + icon like an Add button but opens the guide; the empty-state shows it beside the Add book button. | auditor (evidence_1.0/f2_after_skip.png) | 2707555 | READY FOR VERIFICATION |
| PGM-323 | INFO | Packaging | armeabi-v7a libbarhopper_v3.so (ML Kit) | Its ELF segments are 4 KB aligned. 32-bit libraries are exempt from the 16 KB rule; all 64-bit libraries are 16 KB aligned. | script pgm200_apk_scan.py |  | ACCEPTED RISK |
| PGM-324 | MEDIUM | Docs | README.md, docs/release-package/*, docs/UI_LAYOUT.md | README names only Open Library and GitHub as network use and lists none of the 0.10 to 0.13 features. The User Manual, Install Manual, Release Notes and Package Overview are versions 0.7.0 to 0.8.0; UI_LAYOUT.md is 0.9.1. The 1.0.0 house rule (regenerate all four plus README and GitHub details) is not done yet. | auditor (docs read) | docs commit | READY FOR VERIFICATION |
| PGM-325 | INFO | Positive | Migrations | All five historic schemas (built by the code of v0.1.0, v0.2.0, v0.4.2, v0.6.0 and v0.9.0, with books, reads, shelves, quotes, a locked book and a trashed book) open in the current app with every row kept, user_version 6, integrity_check ok, foreign_key_check empty, and accept every 0.12 and 0.13 write. | script pgm300_migration_test.dart |  | VERIFIED |
| PGM-326 | INFO | Positive | Release integrity | Published v0.13.0 APKs verify (v2 scheme), are signed by the expected certificate (SHA-1 390459ad...), their SHA-256 matches the local build and the GitHub digest, no secrets or personal data in the built APK, allowBackup=false, no storage permissions, only the expected library components exported. CI is green on the tagged commit b1bbf51. | script pgm220_release_verify.sh, pgm200_apk_scan.py |  | VERIFIED |
| PGM-327 | INFO | Positive | Layouts and large text | Side rail at 600 dp and two panes at 840 dp render and work (a tapped book fills the right pane). At font scale 2.0 the Library, Stats and a book page show no clipping or overflow. | auditor (evidence_1.0/f11_pane_book.png, g2_stats_f2.png, g3_book_f2.png) |  | VERIFIED |

## S25 Ultra device test, 0.13.1 (2026-10-14)

Rows PGM-330 to PGM-341. Full results: DEVICE_TEST_S25_ULTRA_0.13.1.md. 70 passed, 13 failed, 10 skipped, no crashes. PGM-330, 331, 332, 333, 334, 335, 336 and 337 are app problems; 338 to 341 are observations. Needs-info items (6.8, 8.3, 11.3) have no ID yet.

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
| PGM-330 | MEDIUM | GUI / landscape | Library (lib/ui/library.dart) | In landscape the Library cannot scroll past the Currently reading strip: search, chips and the strip fill the height. | device test 9.6 (S25 Ultra) | 0.13.2 | READY FOR VERIFICATION |
| PGM-331 | MEDIUM | Navigation | Home shell (lib/ui/home.dart) | The back gesture on Stats, Locked or Settings closes the app instead of returning to Library. | device test 9.4 | 0.13.2 | READY FOR VERIFICATION |
| PGM-332 | HIGH | Notifications | Reminders, Notifier (lib/reminders.dart, lib/notifier.dart) | The daily reading reminder set 2 minutes ahead never appeared on the S25 Ultra. ROOT CAUSE FOUND 2026-10-15: AndroidManifest.xml lacked the plugin's ScheduledNotificationReceiver and ScheduledNotificationBootReceiver, so alarms fired with no receiver. Fixed in 0.13.2; verified on the emulator (release build): alarm registered for the receiver, notification A few pages tonight? delivered (evidence_1.0/pgm332_reminder_delivered.png). Real-phone check still to do. | device test 8.2, 5.4 | 0.13.2 | VERIFIED (emulator and S25 Ultra) |
| PGM-333 | LOW | Input | EditBook (lib/ui/book_page.dart) | Edit accepts 0 or 99999 pages and any year; only lookups were bounded in 0.13.1. | device test 3.9 | 0.13.2 | READY FOR VERIFICATION |
| PGM-334 | LOW | UX | Library bulk actions (lib/ui/library.dart _bulkShelf) | Add to shelf for selected books has no Undo, unlike Trash, Finished and Lock. | device test 4.6 | 0.13.2 | READY FOR VERIFICATION |
| PGM-335 | LOW | Lookup | Refresh details (lib/finding.dart) | Choose another edition is missing when the lookup returned no Open Library work id. | device test 2.8 | 0.13.2 | VERIFIED (emulator, Dune) |
| PGM-336 | LOW | Messaging | Scan many books (lib/bulk_scan.dart) | A failed or busy lookup is shown as No internet; the real reason is lost, which looked like an internet issue on a not-found book. | device test 2.4 + owner note | 0.13.2 | READY FOR VERIFICATION |
| PGM-337 | LOW | Messaging | Add a book (lib/ui/add_book.dart) | Offline search shows the Nothing found card in addition to the connection message. | device test 11.2 | 0.13.2 | READY FOR VERIFICATION |
| PGM-338 | INFO | UX / design | Settings, Privacy and lock | No fingerprint switch in Settings after a PIN exists; fingerprint is a setup choice and a lock-screen button. Owner asks for other lock methods in Settings. | device test 6.6 |  | OPEN |
| PGM-339 | INFO | Permissions | Samsung permission list | Settings shows Nearby devices for Pagemark. The manifest has no Bluetooth or Nearby permission; believed to be an Android 16 label for network access. Confirm it is not Allowed. | device test 13.1; code aapt2 dump permissions |  | OPEN |
| PGM-340 | LOW | UX / testability | Lend this book (lib/reading_life_ui.dart) | The reminder choices start at 2 weeks, so a loan reminder cannot be tried in a day. Add Tomorrow and In a week. | device test 5.4 | 0.13.2 | READY FOR VERIFICATION |
| PGM-341 | INFO | Test plan | Device test plan Rev 1.2 | Plan mistakes: 3.2 expected a slider, 5.4 expected a Tomorrow option, 6.6 expected a fingerprint switch. Plan to be corrected in Rev 1.3. | device test |  | OPEN |
| PGM-342 | LOW | Data quality | Lookup genres (lib/lookup.dart) | Seen in the documentation pass: Refresh details for Dune offered genres "Science fiction, Science-fiction, American literature" (a hyphen variant counted as a new genre). Fixed: hyphens ignored when removing repeats. | auditor (emulator) | 0.13.3 | READY FOR VERIFICATION |

Follow-up 2026-10-16: PGM-332 verified on the S25 Ultra. Device-test notes 6.8 and 11.3 closed (not bugs); 8.3 not re-verified; TalkBack tests 10.1 to 10.5 passed; reinstall-and-restore passed; 9.5 (scheduled backups, Samsung battery manager) pending.
| PGM-343 | MEDIUM | GUI / landscape | Library header (lib/ui/library.dart) | Owner re-test on the S25 Ultra: landscape is still cramped. After 0.13.2 removed the Currently reading strip the search box and chips still used most of the 360 to 456 dp height. Fixed: on screens under 500 dp tall the header collapses while scrolling and returns at the top. Checked on the emulator at S25 Ultra landscape and at a larger display zoom. | auditor (emulator) | 0.13.4 | READY FOR VERIFICATION |
Verification pass 2026-10-16 (groups B and C): PGM-203 and PGM-113 FAILED verification and were fixed in 0.13.4 with tests (test/v0134_test.dart). PGM-206 (clock changes bypass the lockout and delay) is PARTIAL and left as an accepted low risk.
