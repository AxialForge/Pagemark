# Coverage - Pagemark 0.13.1+22, Android (sideload arm64 APK + play AAB), evidence mode: artifact + static + runtime smoke on Android 17 x86_64 emulator (arm64 APK, ABI-translated) + test suite
Method tags: [artifact] [static] [runtime-suite] (unit/widget tests only, no device).
| Control | State | Evidence |
|---|---|---|
| 01 identity: pkg com.axialforge.pagemark, 0.13.1 (2022), target/compile 36, min 24, arm64 | PASS [artifact] | artifact/badging.txt |
| 01 identity gate: tag v0.13.1 == HEAD e42cc26, tree clean, APK built after commit | PASS [static] | git rev-parse |
| 02 not debuggable, no debuggable attr | PASS [artifact] | merged-manifest.txt |
| 02 signing release key (CN=Pagemark), same cert on arm64+armv7, key.properties gitignored | PASS [artifact] fixed: v2+v3 signing verified 2026-10-14 (MOB-BLD-0003) | signing.txt |
| 02 R8 mapping present; no secrets/staging URLs found (hits are license/library strings) | PASS-WARN [artifact] | secret-smells.txt |
| 02 16 KB page alignment of .so | PASS [artifact] | zipalign -P 16 OK |
| 02 play AAB lacks REQUEST_INSTALL_PACKAGES | PASS [artifact] | AAB manifest grep |
| 03 upgrade: 0.13.1 installed over existing emulator install, data kept (library shows Dune) | PASS [runtime] | rt-launch.png, rt-package.txt |
| 03 fresh install, removal/reinstall, upgrade from a published release | NOT TESTED; migrations covered by suite [runtime-suite] | test.txt |
| 05/08 text scale 2.0 on Library: no overflow or clipping | PASS [runtime] | rt-font2.png |
| 11/20 launch in airplane mode, no crash; process kill then relaunch restores app | PASS [runtime] | rt-offline.png, logcat 0 fatal |
| 07 back/rotation/state restore, deep paths | NOT TESTED |  |
| 04,06,08 (TalkBack),09 (device matrix: one emulator only) | NOT TESTED / MANUAL REVIEW (MANUAL_TEST_PLAN.md) | |
| 10 performance: cold start 2.8-4.4 s, PSS 231 MB (emulator, ABI translation, not representative) | PASS-WARN [runtime] MANUAL REVIEW on real phone | rt-perf.txt |
| 12 local storage: allowBackup=false, extraction rules exclude all | PASS [artifact] | merged-manifest.txt |
| 12 locked DB unencrypted | accepted-risk MOB-SEC-0006 | |
| 12/15 PIN PBKDF2-SHA256 150k, random 16B salt, attempt limiting, const-time compare; backup AES-256-GCM | PASS-WARN [static] | lib/lock.dart, crypto_backup.dart |
| 12 logcat: 0 fatal/ANR, no PIN/title/token content from the app; run-as refused (not debuggable) | PASS [runtime] | rt-logcat.txt |
| 12 clipboard, recents thumbnail (FLAG_SECURE on lock) | NOT TESTED (static only) | |
| 13 network: only https hosts, no cleartext config, no custom TrustManager | PASS [static] | grep lib |
| 14 backend | N/A (no backend, no accounts) | CLAUDE.md, lib grep |
| 15 accounts / account deletion | N/A (no accounts) | |
| 17 permissions (runtime-granted set matches manifest; Android 17 auto-grants ACCESS_LOCAL_NETWORK to this older target, not declared) : INTERNET, CAMERA, BIOMETRIC, POST_NOTIFICATIONS justified; extras | PASS fixed in docs/PRIVACY.md (MOB-PRV-0001) | badging.txt |
| PLATFORM exported components: MainActivity (MAIN+SEND text, whitelisted), others permission-guarded or unexported | PASS-WARN [artifact] (untrusted-intent handling static only) | merged-manifest.txt |
| 18 deps: 187 pub packages, OSV query: 0 known vulnerabilities; SBOM list; sqlite3_flutter_libs +eol | PASS [artifact] fixed: sqlite3_flutter_libs removed, OSV clean (MOB-AND-0004) | sbom-pub.txt |
| 19 tamper/resilience | N/A for threat model (local hobby app) | |
| 21 telemetry: none declared; no analytics SDK | PASS [static] | pubspec.yaml |
| 22 target API 36 meets Play rule (new apps/updates need 36 from 2026-08-31; page dated 2026-10-01) | PASS [artifact] | developer.android.com/google/play/requirements/target-sdk |
| 22 Data safety, content rating, declarations | MANUAL REVIEW MOB-PRV-0002 | |
| 23 listing claims vs behaviour | PASS-WARN [static] MOB-STORE-0005 | PLAY_STORE.md |
| Suite: flutter analyze clean; flutter test 295 pass, 1 skip | PASS [runtime-suite] | analyze.txt, test.txt |

| Fix verification 2026-10-14: signed release rebuilt, v2+v3 verified; analyze clean; 295 tests pass; x86_64 release on emulator opens existing DB, 0 fatal, cold start 613-729 ms | PASS [runtime] | rt-fix-startup.txt, rt-fix-launch.png |
