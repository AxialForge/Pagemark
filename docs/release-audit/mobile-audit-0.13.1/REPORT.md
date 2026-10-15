# Mobile Application Release Audit - Pagemark (Android)
Version 0.13.1 (2022), commit e42cc26 = tag v0.13.1. Platform: Android only (iOS out of scope, scaffolding). Environment: production candidate.
Artifacts: Pagemark-0.13.1-arm64.apk sha256 3a0f7e78...351be9; armv7.apk f5151fdc...ded0b4; play.aab fd5ee9b5...016b0734.
Evidence mode: artifact + static + runtime smoke on one Android 17 x86_64 emulator (arm64 APK, ABI-translated) + unit/widget suite. No real phone. Identity gate: PASS. Audited 2026-10-14. Store policy checked 2026-10-14: developer.android.com/google/play/requirements/target-sdk (page dated 2026-10-01). MASVS: control groups used by name; IDs not cited.

## DECISION
- GitHub sideload APKs: CONDITIONAL GO. No blocker, no S3+ finding.
- Google Play upload: CONDITIONAL NO-GO until the Data safety form is checked (MOB-PRV-0002) and a real-device pass is done.

Coverage: ~24 controls tested (PASS/PASS-WARN), 0 FAIL; NOT TESTED or MANUAL REVIEW: fresh install/removal, navigation/state, TalkBack, device matrix, clipboard/recents, real-phone performance, Data safety. See coverage.md.
Scores (coverage): Security 99 (~70%), Privacy 98 (~50%), Store 97 (~40%), Reliability 100 (~30%), UX/Perf not scored (emulator only).
Counts after fixes: blockers 0, S4 0, S3 0, open S2 1, open S1 1, fixed 3, S0 1 (accepted). Fixes are uncommitted and ship with the next versioned build (the signing change only affects new builds).

## Findings
- MOB-PRV-0002 S2 (store) OPEN: Data safety draft now covers ML Kit diagnostics; scanner traffic capture on a real phone still needed
- MOB-PRV-0001 S1 FIXED-VERIFIED: privacy policy permission list and Drive wording
- MOB-BLD-0003 S1 FIXED-VERIFIED: v2+v3 signing enabled
- MOB-AND-0004 S1 FIXED-VERIFIED: end-of-life sqlite3_flutter_libs removed
- MOB-STORE-0005 S1 OPEN (owner): PLAY_STORE.md refreshed; 1024x500 feature graphic still to make
- MOB-SEC-0006 S0 locked DB unencrypted - owner-accepted

## Passed highlights
Not debuggable; backup and device-transfer off; no cleartext or custom TLS; https hosts only; Play AAB has no install permission; target 36 and 16 KB alignment OK; same signing cert on both APKs; PIN PBKDF2 150k + salt + lockout; backup AES-256-GCM; analyze clean; 295 tests pass. Runtime: 0 crashes/ANRs, upgrade keeps data, offline launch and 2.0 text scale render cleanly, 0 OSV vulnerabilities in 187 packages.

## Missing for a full GO
Device pass (MANUAL_TEST_PLAN.md: timer, folder backup to cloud, fingerprint, notifications, TalkBack, updater, upgrade from 0.13.0), logcat/clipboard/recents check, scanner traffic capture, real-phone performance numbers, and verification that the 0.13.1 fixes for PGM-300/302/320 work on a device.

Details: findings/*.md, coverage.md, artifact/.
