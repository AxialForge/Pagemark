# Findings register - Pagemark 0.7.0 (commit 045e8147)

IDs are permanent. Severity counts: BLOCKER 0, CRITICAL 0, HIGH 6, MEDIUM 17, LOW 41, INFO 20 (total 84).

Source parts: findings_part_mobile.md (PGM-001..), findings_part_data.md (PGM-100..133), findings_part_sec.md (PGM-200..254). HIGH detail: SECURITY_AUDIT.md (PGM-200, 202); repro scripts in scripts/.

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
| PGM-001 | LOW | Accessibility | Library filter chips | At system font scale 2.0 the "All" status chip text is clipped at the bottom (chip height does not grow with text); other chips scroll horizontally and are fine. | auditor (shots/c_font2.png) | | OPEN |
| PGM-002 | LOW | UX | Empty library | The empty state shows both an "Add a book" button and the "Add book" FAB, two controls for one action. | auditor (shots/a_first_launch.png) | | OPEN |
| PGM-003 | INFO | Packaging | Release assets | Only arm64 and armv7 APKs are published; x86_64 emulators cannot install the release. Release behaviour was verified on a locally built, release-signed x86_64 APK. | auditor | | OPEN |
| PGM-004 | INFO | Compat | Orientation | Landscape/tablet layout NOT SEEN: the emulator did not rotate the app when user_rotation=1 was set, and the manifest has no screenOrientation lock. Needs a real device or a rotating emulator. | auditor | | OPEN |
| PGM-005 | INFO | Tests | bulk_test | Three "tap() missed hit test" warnings in the bulk-selection tests; tests pass but the taps may not hit the intended widget. | auditor (suite1.log) | | OPEN |
| PGM-006 | INFO | Positive | Restore / scale | Restore of a 5,000-book backup works through the picker; dialog counts are correct; locked-books/PIN message is correct; cold start 1.3 s and ~120 MB PSS at 5k books; Stats totals exclude locked books as designed. | auditor | | VERIFIED |
| PGM-100 | HIGH | Data safety | export.dart:241-286, backup_page.dart:45, import_ui.dart:133 | The restore/import "safety copy kept in the app (newest 3)" cannot be restored from anywhere in the UI (USER_MANUAL.md:299 promises it) | code | | OPEN |
| PGM-101 | HIGH | Security | lock.dart:98 | PIN lockout integer overflow: `30*pow(2,n~/5-1)` goes negative at 300 failures and is 0 s from 320; counter resets only on success, so attempt limiting silently stops | script pgm_engine_audit_test [K-lockout-overflow] | | OPEN |
| PGM-102 | HIGH | Data safety | backup.dart:145,157 | Changing the backup passphrase does not change the upload signature (`bk_hash` not cleared), so scheduled backups skip; Drive keeps only old-passphrase backups | code (not run against Drive) | | OPEN |
| PGM-103 | HIGH | Test coverage | export.dart restoreDb, safetyCopy | No tests in the repo for restore and safety copy (destructive path) | code | | OPEN |
| PGM-104 | MEDIUM | Data safety | export.dart restore | Failure after the DB swap (e.g. cover import) shows "restore failed" but the live file is already replaced and the connection closed | script [R-fail-after-swap] | | OPEN |
| PGM-105 | MEDIUM | Data safety | export.dart safetyCopy | Safety-copy names have minute resolution; a second restore/import in the same minute overwrites the first restore point | script [R-safety-copy-collision, R-pre-import-collision] | | OPEN |
| PGM-106 | MEDIUM | Data safety | export.dart inspect() | No column checks: id-only tables or user_version 0 pass inspection, then fail to open after the swap | script [D-inspect-no-column-check, D-inspect-user-version-0] | | OPEN |
| PGM-107 | MEDIUM | Robustness | export.dart:163-176 | unpack has no size cap and decompresses ignored entries in memory; a 537 KB zip uses 120 MB RAM and disk | script | | OPEN |
| PGM-108 | MEDIUM | Data safety | importer | Undo import leaves reads/quotes added to existing books and created shelves | script [I-undo-addreads, I-undo-shelves] | | OPEN |
| PGM-109 | MEDIUM | Data safety | CSV/JSON export-import | Round trip loses series_number, current_page, description, cover | script [RT-*-lossless] | | OPEN |
| PGM-110 | MEDIUM | Privacy | shelves | Shelf names are global; vault shelf names show in main-library chips/picker | script [V-leak[shelf names]] | | OPEN |
| PGM-111 | MEDIUM | Privacy | book_extras.dart:219-235 | Covers page counts locked books and "Save all" downloads vault covers into the plain covers folder | code (UI not run) | | OPEN |
| PGM-112 | LOW | Robustness | importer | Raw UnsupportedError on NaN/Infinity/1e400 in year/pages/minutes cells; TypeError for non-list JSON `books` | script | | OPEN |
| PGM-113 | LOW | Engine | date parsing | Lenient ISO dates (02-30 becomes 03-02, month 13 rolls, offset shifts day, years 0001/9999) | script | | OPEN |
| PGM-114 | LOW | Robustness | export.dart | Zip entry `covers/.` throws raw PathAccessException and leaks the temp dir | script | | OPEN |
| PGM-115 | LOW | Engine | covers | removeUnused race can delete a just-saved cover | code | | OPEN |
| PGM-116 | LOW | Engine | importer | Same ISBN with different titles merged silently | script | | OPEN |
| PGM-117 | LOW | Engine | Goodreads import | Read-shelf row without Date Read gets finished = Date Added | script | | OPEN |
| PGM-118 | LOW | Engine | CSV | Leading tab/CR gains an apostrophe; text starting `'=` loses it on round trip | script | | OPEN |
| PGM-119 | LOW | Robustness | updater.dart | Raw TypeError for non-list assets; missing tag_name becomes release "null" | script | | OPEN |
| PGM-120 | LOW | Robustness | import | `pagemark_export` as string/double bypasses the newer-format guard | script | | OPEN |
| PGM-121 | LOW | Engine | compareVersions | int64 overflow gives 0; `-rc` suffix ignored | script | | OPEN |
| PGM-122 | LOW | Engine | Stats pace | Off by one day in the first hour after midnight under DST; 365 constant | script (expression replicated) | | OPEN |
| PGM-123 | LOW | Engine | series number | Accepts NaN/Infinity; 1e20 displays 9223372036854775807 | script | | OPEN |
| PGM-124 | LOW | Security | lock.dart | Concurrent checkPin undercounts failures (6 attempts count as 2) | script | | OPEN |
| PGM-125 | LOW | Engine | backup passphrase | Not Unicode-normalised (same visible passphrase can fail to decrypt) | code | | OPEN |
| PGM-126 | LOW | Robustness | bulk ops | 40,000-id bulk operation raises "too many SQL variables" | script | | OPEN |
| PGM-127 | LOW | Engine | undo | Undo of mark-finished deletes a created read the user has since edited | code | | OPEN |
| PGM-128 | LOW | Engine | dates | Stored as instants; a timezone change shifts the finished date | code | | OPEN |
| PGM-129 | LOW | Robustness | lookup.dart | `byIsbn` has unguarded infinite paging, nameless suggestions, FormatException on bad bodies (UI shows a generic snackbar) | code | | OPEN |
| PGM-130 | INFO | Engine | duplicates | Trashed titles are invisible to duplicate check and import; shelf names can differ only by case | code | | OPEN |
| PGM-131 | INFO | Privacy | watchQuoteText | Carries vault quote text into main-screen state (not displayed) | code | | OPEN |
| PGM-132 | INFO | Security | updater | Update download with no size/sha has no integrity check (see PGM-209) | code | | OPEN |
| PGM-133 | LOW | Data safety | export.dart | Crash window between DB rename and cover import | code | | OPEN |
| PGM-200 | HIGH | Security | lock.dart, lock_ui.dart | Default `FlutterSecureStorage()` has `resetOnError` on; a Keystore failure wipes all keys, so the vault gate and whole-app lock offer "Set a PIN" and open without the old PIN | script pgm200_securestorage_loss_test.dart | | OPEN |
| PGM-201 | MEDIUM | Privacy | log.dart, import_ui.dart, backup.dart | Diagnostics log can hold titles/notes: sqlite exceptions embed bound parameters and `Log.e/w` write raw exceptions | script pgm201_log_param_leak_test.dart | | OPEN |
| PGM-202 | HIGH | Security | backup.dart:146-176 | Backup encryption depends on `bk_pass` in secure storage; after the same wipe scheduled Drive backups silently upload plaintext (locked books included) with no notification | code | | OPEN |
| PGM-203 | MEDIUM | Privacy | privacy.dart:30-38 | Plaintext exports and picked backups persist in `cache/share_plus` and `cache/file_picker`, which `cleanTempExports` never touches; contradicts manual section 8 and IB-10 "fixed" | code (plugin sources; not run on device) | | OPEN |
| PGM-204 | MEDIUM | Security | ui.dart:172-187 VaultPage | `dispose` clears FLAG_SECURE on pause for the hidden-tab vault; unverified | code | | OPEN |
| PGM-205 | LOW | Security | lock.dart, crypto_backup.dart | PBKDF2 150k iterations, 8-character passphrase minimum | code | | OPEN |
| PGM-206 | LOW | Security | lock.dart, app_lock.dart | Lockout and delay use wall-clock time (clock change bypasses) | code | | OPEN |
| PGM-207 | LOW | Security | ui.dart:1344-1350 | Remove lock leaves the app-lock pref on and the vault open to anyone | code | | OPEN |
| PGM-208 | LOW | Security | lock_ui.dart:84 | Recovery code copied to clipboard and never cleared | code | | OPEN |
| PGM-209 | LOW | Security | updater.dart:117,133-156 | Asset URL host/scheme not validated; digest check skipped when absent | code | | OPEN |
| PGM-210 | LOW | Privacy | backup.dart:186-189 | Temp snapshots not deleted on failure | code | | OPEN |
| PGM-211 | LOW | Privacy | tool/backup-to-nas.ps1, CLAUDE.md, LICENSE | Public repo shows NAS IP/share name, keystore location, owner's full name | auditor (git grep) | | OPEN |
| PGM-212 | INFO | Security | repo, history, APK, PDFs | Secret scans clean | script pgm200_apk_scan.py | | VERIFIED |
| PGM-213 | LOW | Release | privacy.dart:19 | `PAGEMARK_SCREENSHOTS` value cannot be proven from the binary; no release guard | code | | OPEN |
| PGM-214 | INFO | Security | backup.dart | Drive backups are plaintext by default (design) | code | | OPEN |
| PGM-215 | LOW | Robustness | export.dart:128-150 | Zip entries read fully into memory | code | | OPEN |
| PGM-216 | INFO | Security | manifest | Manifest review OK | auditor (aapt2) | | VERIFIED |
| PGM-217 | INFO | Privacy | network | Outbound hosts match PRIVACY.md | code grep, APK strings | | VERIFIED |
| PGM-220 | INFO | Release | release assets | Signing, digests, versionCodes verified | script pgm220_release_verify.sh | | VERIFIED |
| PGM-221 | INFO | Release | signing | v2-only signature; one off-PC key copy | auditor (apksigner) | | OPEN |
| PGM-222 | MEDIUM | Release | release process | No release script; README output name `app-armeabi-v7a-release.apk` does not match the `armv7` name the updater needs; `tool\build.ps1` missing | code updater.dart:70-83 | | OPEN |
| PGM-223 | LOW | Release | ci.yml | Debug build only, no release job, floating tags | code | | OPEN |
| PGM-224 | LOW | Hygiene | pubspec | Unused riverpod; `+eol` sqlite3_flutter_libs | auditor | | OPEN |
| PGM-225 | LOW | Hygiene | gradle.properties | Windows tmpdir in committed jvmargs | code | | OPEN |
| PGM-226 | INFO | Release | native libs | 16 KB alignment OK | script pgm220_release_verify.sh | | VERIFIED |
| PGM-227 | INFO | Release | updater | x86_64 not published | code | | OPEN |
| PGM-228 | INFO | Release | R8 mapping | Kept local only | auditor | | OPEN |
| PGM-229 | LOW | Hygiene | repo | `android/.kotlin` untracked; stale User-Agent `Pagemark/0.3` | auditor | | OPEN |
| PGM-231 | INFO | Data | db.dart | Migrations 1 to 4 complete; prefs/secure keys inventoried | code | | VERIFIED |
| PGM-240 | MEDIUM | Docs | INSTALL_MANUAL | Says 0.5.0 and "no notification permission"; manifest has POST_NOTIFICATIONS | auditor (aapt2) | | OPEN |
| PGM-241 | MEDIUM | Docs | PACKAGE_OVERVIEW | Stale: schema 3, "not minified", "no failure notification", SQLCipher on roadmap | code | | OPEN |
| PGM-242 | MEDIUM | Docs | DRIVE_SETUP | Claims backups are "not encrypted by Pagemark" | code | | OPEN |
| PGM-243 | MEDIUM | Docs | manual 8/15, PRIVACY | "Temp exports deleted" and "log never has titles" are false on failure paths (see PGM-201/203) | cross-ref | | OPEN |
| PGM-244 | LOW | Docs | CLAUDE.md | Stale permission list and roadmap; missing `tool\build.ps1` | code | | OPEN |
| PGM-245 | LOW | Docs | screenshots | Version-stamped images are 0.4.1-0.5.0 | auditor | | OPEN |
| PGM-246 | LOW | Docs | README, ROADMAP | "330" backlog is actually 430 entries | auditor | | OPEN |
| PGM-247 | LOW | Docs | USER_MANUAL | Section numbering out of order | code | | OPEN |
| PGM-248 | MEDIUM | Docs | ROUNDING_OUT | "Fixed" claims untrue or partial for IB-10, IB-16, IB-80, IB-44 | code | | OPEN |
| PGM-249 | LOW | Docs | manual section 8 | Remove-lock description incomplete | code | | OPEN |
| PGM-250 | LOW | Compat | ui.dart:39 | Dates en_US, 12-hour clock, no localisation | code | | OPEN |
| PGM-251 | INFO | Compat | manifest | English-only; RTL moot | code | | OPEN |
| PGM-252 | LOW | Docs | INSTALL_MANUAL:27 | Unknown-sources step is Android 8+ only (minSdk is 24) | code | | OPEN |
| PGM-253 | INFO | Compat | edge-to-edge / predictive back | NOT RUN | - | | OPEN |
| PGM-254 | INFO | Compat | tablet / multi-window | NOT RUN | - | | OPEN |
