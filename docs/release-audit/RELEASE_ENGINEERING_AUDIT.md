# Pagemark 0.7.0 - Release engineering audit (phase 10)

Commit `045e814` = tag `v0.7.0` (`git ls-remote --tags origin`), CI run 38330000180 on that commit: success. IDs PGM-220..PGM-229, PGM-231.
Evidence: `script pgm220_release_verify.sh` (published assets of v0.4.2, v0.5.0, v0.7.0 downloaded from this repo's releases into the scratch dir, never executed), `script pgm200_apk_scan.py`, `auditor`, `code`.

## Version consistency (all agree)
| Source | Value |
|---|---|
| `pubspec.yaml` | `0.7.0+10` |
| APK arm64 / armv7 (aapt2 badging) | versionName `0.7.0`, versionCode `2010` / `1010` (Flutter split-per-abi adds 2000/1000) |
| Earlier releases | 0.4.2 = 2006/1006, 0.5.0 = 2008/1008 -> monotonic, in-place upgrade OK |
| git tag / GitHub release | `v0.7.0`, tag commit == `HEAD` (045e814), release not draft/prerelease, "Latest" |
| CHANGELOG | `## [0.7.0] - 2026-10-12`; APK-bundled `assets/flutter_assets/CHANGELOG.md` is byte-identical to the repo file |
| Settings footer / About | `PackageInfo.fromPlatform().version` (branding.dart:66-70) - dynamic, cannot drift |
| Docs | USER_MANUAL, PACKAGE_OVERVIEW, RELEASE_NOTES say 0.7.0; **INSTALL_MANUAL says 0.5.0** and its PDF too (see DOCS_TRUTH PGM-240) |
| User-Agent | `Pagemark/0.3` in `lookup.dart:29` (stale cosmetic, PGM-229) |

## Published assets
| Check | Result |
|---|---|
| Local build == published | sha256 of `build/app/outputs/flutter-apk/Pagemark-0.7.0-{arm64,armv7}.apk` equals GitHub asset digests `9c158c19...977d` / `9629e218...9719`; sizes 31,437,855 / 27,504,279 |
| Signer | `CN=Pagemark, O=AxialForge`, SHA-1 `39:04:59:AD:24:0F:35:99:4B:CD:A5:86:81:AF:9C:21:8C:FD:27:F7` on v0.4.2, v0.5.0, v0.7.0 (both ABIs for 0.7.0), SHA-256 `26b4a423...ac44` identical -> in-place upgrade across releases is sound. Same SHA-1 as INSTALL_MANUAL/DRIVE_SETUP/ps1 |
| Schemes | v2 only (v1 absent, v3/v3.1 absent). Fine for minSdk 24 (v2 is Android 7.0+). No v3 lineage, so the key can never be rotated (PGM-221) |
| SDK levels | minSdk 24, targetSdk 36, compileSdk 36 |
| Debuggable / sources | no `debuggable`; no `.dart`/`.java`/`.kt` sources, `.jks`, tests or mapping inside the APK; `META-INF` holds only library license/version stubs; `classes.dex` + `classes2.dex`, R8 on (a `mapping.txt` exists locally) |
| ABIs | arm64-v8a (31 MB) and armeabi-v7a (27 MB) published. x86_64 built locally (33.9 MB) but **not published** (PGM-227) |
| 16 KB page size | `zipalign -c -P 16 -v 4` OK for every `.so` in arm64 and armv7 APKs (v0.4.2, v0.5.0, v0.7.0); ELF PT_LOAD `p_align` = 16384 or 65536 for all arm64 libs (`pgm200_apk_scan.py`). Android 15+ 16 KB devices OK (PGM-226) |
| Secrets/personal data in package | none (`pgm200_apk_scan.py`: no 192.168, no owner name/email, no keys) |
| Size sanity | 30-31 MB per APK (ML Kit barcode models ~ 3 .tflite + `libbarhopper_v3.so` 10 MB dominate); fine |
| Release notes on GitHub | not inspected beyond existence (read-only `gh release view` shows assets only) |

## Findings

### PGM-220 INFO - signing identity and asset integrity verified
See table. Evidence `script pgm220_release_verify.sh`.

### PGM-221 INFO - single signing key, no rotation lineage, one backup location
Only v2 signatures exist, so Android 9+ APK Signature Scheme v3 key rotation is unavailable; the keystore `pagemark-release.jks` + `key.properties` (plaintext passwords) are copied by `tool/backup-to-nas.ps1` to one NAS share, "the ONLY copy outside this PC" (script header, line 10). IB-80 in ROUNDING_OUT is marked fixed ("copy on NAS") but this is still two copies in the same house. Loss = every user must uninstall (data loss) to upgrade. Not a suggestion to buy anything: just keep an offline copy (USB) and note the passwords separately. I did not inspect the keystore (rule 2).

### PGM-222 MEDIUM - release build/publish is manual and unscripted; asset naming is load-bearing and undocumented
- README/INSTALL_MANUAL say `flutter build apk --release --split-per-abi`, which produces `app-arm64-v8a-release.apk` / `app-armeabi-v7a-release.apk` (confirmed in `build/app/outputs/flutter-apk`). The published names are `Pagemark-x.y.z-arm64.apk` / `-armv7.apk`; the rename, signing check, GitHub upload and the `PAGEMARK_SCREENSHOTS` exclusion are done by hand. `Updater.pickAsset` (updater.dart:70-83) matches the substrings `arm64` and `armv7`: Flutter's default `armeabi-v7a` name does **not** contain `armv7`, so a release uploaded with default names would leave every 32-bit phone with `canInstall == false`.
- `tool/backup-to-nas.ps1` ends with "see ... tool\build.ps1" - that file does not exist (`git ls-files tool` = one file).
- CLAUDE.md "Release" says to attach APKs "by hand until a Flutter workflow exists"; the Roadmap section still lists "A Flutter CI workflow" as unbuilt though `ci.yml` exists (PGM-244).
- Fix: add `tool/release.ps1` (set `JAVA_TOOL_OPTIONS`, build, rename, `apksigner verify` against the expected SHA-1, `zipalign -c -P 16`, refuse `PAGEMARK_SCREENSHOTS`, write SHA-256 list) and document it in CLAUDE.md. Verify: run it on a clean checkout and compare with `script pgm220_release_verify.sh`.

### PGM-223 LOW - CI scope and pinning
`ci.yml` runs on push to main and PRs: `pub get`, build_runner + `git diff --exit-code lib/db.g.dart`, `flutter analyze --no-fatal-infos`, `flutter test`, `flutter build apk --debug`. It does not (a) build `--release` (so R8/minify/desugaring regressions are first seen on the owner's PC), (b) run on tags, (c) attach artifacts. Actions are pinned to major tags (`checkout@v4`, `flutter-action@v2`, `setup-java@v4`), not SHAs, and Flutter is `channel: stable` unpinned while README says "Flutter 3.47+". The documented release flow ("CI proves analyze/test/debug-build, signed APKs local") matches what CI does. Last CI failure was on `2a12a91` (fixed by the next commit); tagged commit is green.

### PGM-224 LOW - dependency hygiene
`riverpod` and `flutter_riverpod` are in `pubspec.yaml` but no file in `lib/` imports them (CLAUDE.md says "no state-management package"); `sqlite3_flutter_libs: ^0.6.0+eol` is the end-of-life marker release. `dart pub outdated`: only transitive minors behind (cross_file, cupertino_icons 2.0, material_color_utilities, test_api); nothing discontinued. No offline vulnerability scanner exists for pub (`dart pub audit` not in this SDK) - NOT RUN. `script`: `grep -rn riverpod lib` empty.

### PGM-225 LOW - machine-specific build config committed
`android/gradle.properties` has two `org.gradle.jvmargs` lines; the second adds `-Djdk.net.unixdomain.tmpdir=C:/tmpj` (a Windows path) and wins. Harmless on the Ubuntu runner (CI is green) but any other contributor gets the property pointing at a non-existent folder. Also `-Xmx8G` heap on a 7 GB hosted runner. Move the tmpdir override to `JAVA_TOOL_OPTIONS`/user-level `~/.gradle/gradle.properties` (CLAUDE.md already says the client JVM needs the env var anyway).

### PGM-226 INFO - 16 KB alignment passes
`zipalign -c -P 16 -v 4` and ELF PT_LOAD alignment (16384/65536) both pass for all native libs in all three inspected releases. `script pgm220_release_verify.sh`, `pgm200_apk_scan.py`.

### PGM-227 INFO - x86_64 not published
`pickAsset` can select `x86_64`, but no such asset exists; emulators / x86 Chromebooks cannot install via the in-app updater (`apks.length == 2` so the single-APK fallback does not apply) and the README only mentions arm64. Matches the instruction to note it; add a README line.

### PGM-228 INFO - R8 mapping is local only
`build/app/outputs/mapping/release/mapping.txt` is git-ignored and `backup-to-nas.ps1` excludes `build\`, so native-side symbols of past releases cannot be recovered. Low value (no crash reporter), noted for completeness.

### PGM-229 LOW - repo hygiene
- `android/.kotlin/` is untracked and not ignored (shows in `git status`); add to `.gitignore`.
- `.git` is 38 MB because five PDFs (2.5 MB + 2.1 MB + ...) are re-committed on each docs rebuild; acceptable, but PR template says "No new file committed that CI could rebuild" (PDFs need local Edge, so allowed).
- Stale `Pagemark/0.3` User-Agent (`lookup.dart:29`).
- No `.github/workflows` release job, no `SETUP.md` leftover (good), `CONVENTIONS.md` present, LICENSE MIT 2026 "Joseph Costarella (AxialForge)".
- Tracked: no APKs, keystores, `local.properties`, `.idea`, `build/` (verified `git ls-files`). `ios/` project is tracked (40 files, unbuilt - fine).

### PGM-231 INFO - upgrade path and stored keys
- Drift schema `currentSchema = 4`; `onUpgrade` steps 1->2 (deletedAt + 3 indexes), 2->3 (seriesNumber, currentPage, shelves, book_shelves), 3->4 (seriesTotal, heat, contentNotes, quotes). Every table/column in `db.dart` (and `lib/db.g.dart`, CI checks it is regenerated) is created either by `createAll` or one of these steps. `Exporter.inspect` accepts `user_version <= AppDb.currentSchema` (export.dart `ver > AppDb.currentSchema` rejects newer), so restore and schema agree. Missing: no index on `quotes.book_id` (minor perf).
- SharedPreferences keys in use: `theme, hide_locked, app_lock, lock_delay, adult_fields, seen_version, upd_auto, upd_last, vault_lookup_ok, goal_<year>, lib_{m,v}_{shelf,status,sort,skin,group,format}, bk_on, bk_freq, bk_wifi, bk_cid, bk_acct, bk_ok, bk_err, bk_fail, bk_hash, bk_sched`. Secure storage: `mode, pin_hash, pin_salt, rec_hash, rec_salt, fails, lock_until, bk_pass`, plus legacy `pin, salt` (v0.1.0, still read and upgraded). No rename between releases strands data; legacy keys are migrated on first successful PIN. Theme ids `light_him/...` intentionally kept. Note `bk_hash` signature changed meaning in 0.6.0 (adds covers signature) - only causes one extra upload.

## NOT tested
Installing/upgrading APKs on a device, `adb` anything, building from a clean checkout (README steps judged from files; `flutter test` was run: +193 passed, ~1 skipped (seed tool), all green), CI release behaviour on tags, the keystore itself, GitHub release body text, antivirus/Play Protect behaviour.
