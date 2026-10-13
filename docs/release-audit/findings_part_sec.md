# Findings - security / packaging / docs / compat (PGM-200..254)

Evidence column: `script` = rerunnable in `scripts/`, `code` = read only, `auditor` = run by the auditor. HIGH detail is in SECURITY_AUDIT.md. Gaps in the numbering were never used.

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
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
