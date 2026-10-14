# Coverage & Evidence Matrix - Pagemark 0.7.0+10 (commit 045e814)

Evidence mode: **source-only** (no APK, no device). Scope: **Android, Section C (Security)**. iOS excluded: `ios/` is Flutter scaffolding and the project guide says iOS is later. Domains outside Section C are NOT TESTED (not in requested scope).

| Control | State | Basis | Evidence |
|---|---|---|---|
| 12 Cloud/adb backup excluded | PASS | static | AndroidManifest.xml:16-19 allowBackup=false, data_extraction_rules.xml excludes all domains |
| 12 Secrets in secure storage | PASS | static | lock.dart uses FlutterSecureStorage for pin_hash/salt/rec_*; bk_pass in secure storage (backup.dart:142) |
| 12 Screenshots/recents blocked on locked content | PASS-WARN | static | MainActivity.kt FLAG_SECURE channel, privacy.dart; runtime behavior unverified |
| 12 Temp exports/covers wiped on relock | PASS-WARN | static | privacy.dart:30-45; not run on device |
| 12 Logs free of book data | FAIL | static | MOB-PRV-0003 |
| 12 CSV/JSON excludes locked books | PASS | static | export.dart:69 `includeLocked \|\| !b.locked`; shareCsv/shareJson default false |
| 12 CSV formula injection | PASS | static | export.dart:48-51 safeCell |
| 12 Restore path traversal / safety copy | PASS | static | export.dart:163-175 (safeName), 267-270 pre-restore copy; size caps missing: MOB-SEC-0008 |
| 12 Backup encryption (algorithm) | PASS-WARN | static | AES-256-GCM, random salt/nonce; KDF weak: MOB-CRY-0002 |
| 13 Cleartext traffic | PASS | static | no `http://` in lib/; no usesCleartextTraffic; default blocks cleartext at targetSdk>=28 (verify targetSdk in merged manifest) |
| 13 TLS validation overrides | PASS | static | no custom TrustManager/badCertificateCallback found in lib/ or Kotlin |
| 13 Pinning | N/A | static | public APIs only; threat model does not require |
| 13 Update download integrity | PASS-WARN | static | MOB-SEC-0005 |
| 14 Backend/API security | N/A | static | no own backend; only Open Library, Google Drive appDataFolder, GitHub releases |
| 15 PIN hashing (PBKDF2, salt, constant-time) | PASS | static | lock.dart:19-29, 144-151 |
| 15 Attempt limiting | FAIL | static | MOB-SEC-0001 |
| 15 Recovery code strength | PASS | static | 16 chars from 32-symbol alphabet (80 bits), PBKDF2, counted as failures (lock.dart:53-61, 137-140) |
| 15 Min PIN length | PASS-WARN | static | 4-12 digits allowed (lock_ui.dart:57) |
| 15 Account/session flows | N/A | static | no accounts; Google sign-in only for Drive |
| 12/17 Exported components | PASS | static | only MainActivity exported (launcher); no deep-link filters |
| 17 Permissions minimal | PASS | static | INTERNET, USE_BIOMETRIC, CAMERA, POST_NOTIFICATIONS, REQUEST_INSTALL_PACKAGES; storage/media removed via tools:node (merged manifest NOT verified: needs APK) |
| 02 Release signing | FAIL | static | MOB-BLD-0004 |
| 02 Secrets/keystore in git | PASS | static | key.properties, *.jks ignored; `git ls-files` shows none |
| 02 Merged manifest / R8 / debuggable | NOT TESTED | - | needs a built release APK |
| 19 Tamper/RE resistance | N/A | static | out of threat model (local hobby app); strings readable in libapp.so is expected |
| 16 Privacy declarations (Play Data Safety) | NOT TESTED | - | not on Play |
| Domains 01, 03-11, 18, 20-24 | NOT TESTED | - | outside requested scope |
| Runtime: logcat leakage, adb run-as storage inspection | BLOCKED | - | no device/emulator |
