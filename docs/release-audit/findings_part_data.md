# Findings - data safety / engine / hostile input (PGM-100..133)

Scripts are in `scripts/` (`run_data_audit.ps1` runs them; each prints `AUDIT|case|PASS/FAIL|detail`; run in a scratch clone).

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
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
