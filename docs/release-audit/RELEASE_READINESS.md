# Release readiness - Pagemark 0.7.0

Audited commit `045e8147c28780fd03dd0f714cce9d0225071f13` (tag v0.7.0), 2026-10-12. Mobile-leaning full audit.

## Verdict: READY WITH CONDITIONS

0 BLOCKER, 0 CRITICAL, 6 HIGH, 17 MEDIUM, 41 LOW, 20 INFO (84 findings, see FINDINGS.md). Nothing loses data on a normal path, the 193-test suite passes from a fresh clone twice, and the signed release builds and runs. The six HIGH findings are on failure paths, but two of them (PGM-100, PGM-200) affect the promises the app makes about restore and lock, so fix or knowingly accept them before calling 0.7.x done.

## HIGH findings (fix unless accepted)

| ID | One line | Verify with |
|---|---|---|
| PGM-100 | The "safety copy kept in the app" after a restore/import has no way to be restored in the UI | add a restore-from-safety-copy action; manually restore twice and recover the first state |
| PGM-101 | PIN lockout overflows (negative at 300 fails, 0 s from 320), so attempt limiting stops | `scripts/pgm_engine_audit_test.dart` case K-lockout-overflow |
| PGM-102 | Changing the backup passphrase does not trigger a new upload | change passphrase, run backup, expect a new file |
| PGM-103 | restoreDb and safetyCopy have no tests | the new tests exist and run in `flutter test` |
| PGM-200 | A secure-storage reset leaves no lock config; gate offers "Set a PIN" and opens | `scripts/pgm200_securestorage_loss_test.dart` |
| PGM-202 | After that reset, scheduled Drive backups upload unencrypted with no warning | backup refuses or notifies when the passphrase key is gone |

Suggested direction: PGM-101 `steps >= 7 ? 3600 : 30 * (1 << steps)` (lock.dart:98); PGM-200/202 set `resetOnError: false` and treat a missing key as "storage lost", fail closed and notify; PGM-102 clear `bk_hash` in `setPassphrase` (backup.dart:145).

## Coverage

| Area | Result |
|---|---|
| Automated suite (fresh clone, x2) | 193 pass, 1 skip by design, analyzer clean, generated code current |
| Smoke / launch (release x86_64, emulator) | first launch OK; cold 1.3 s at 5k books |
| Scale (5,000 books, restore via picker) | OK, ~120 MB PSS, Stats correct |
| Data safety / engine / hostile input | script-driven, 33 findings, rest passed (see findings_part_data.md) |
| Security / packaging / docs / compat | static + APK inspection, 44 findings; signing and assets verified |
| Mobile emulator passes | font scale 2.0 (PGM-001), landscape inconclusive (PGM-004) |
| Real device | NOT RUN (see MANUAL_TEST_PLAN.md) |

## Top risks

1. Lock/backup trust after a Keystore reset (PGM-200, 202, 204).
2. Restore is the one destructive path and it is the least tested (PGM-100, 103, 104-106).
3. Docs promise things the code does not do (PGM-203, 240-243, 248).
