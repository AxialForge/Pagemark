# Test coverage - Pagemark 0.13.0 (1.0.0 gate)

Fresh clone of HEAD b1bbf51: 289 tests pass, 1 skipped (a platform-only case in data_safety_test), twice (33 s then 22 s). `flutter analyze` clean. Generated code (`db.g.dart`) matches a fresh build_runner run.

Test files: 29 in `test/` plus the audit scripts in `docs/release-audit/scripts/`. Per-module line coverage was not measured (no coverage run).

| Area | Tests | Gap |
|---|---|---|
| Lock, PIN, encryption, restore safety | data_safety_test, restore_safety_test, audit_fixes_test, v0100_test | native secure storage on real hardware |
| Backups and folder backup | folder_backup_test, v090_test | the Android picker and real providers (native code, FolderChannel.kt) |
| Lookups (Open Library, Google Books, editions, refresh, suggestions) | lookup_test, v0130_test, pgm310 fuzz | live API shape drift |
| Reading life (streaks, year card, queue, loans, PDF) | v0120_test | timer UI flow, share sheets, notifications |
| Layouts and accessibility | a11y_test, adaptive_test | the whole Home shell at 600/840 dp (only helpers tested) |
| Promise honesty | promise_test (banned packages, allowed hosts, barcode note) | |
| Docs | guide_test (menu paths and bold names against the app) | README and manuals are not tested (PGM-324) |
| Encoding | encoding_test | |
| Migrations | v060_test (4), v090_test (4->6), v0120_test (5->6), pgm300 (1 to 5 -> 6) | |

Flakiness: two runs, same result. No test without assertions was found in the files read (v0120, v0130, adaptive, a11y).
