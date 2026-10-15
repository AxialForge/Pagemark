# Appendix A - Scope, method and evidence index

## Scope and environment
- App: Pagemark, `com.axialforge.pagemark`, version 0.13.1 (versionCode 2022), commit e42cc26 = tag v0.13.1, clean working tree.
- Platform: Android only. The iOS folder is scaffolding (needs a Mac) and is out of scope.
- Flavors: sideload (GitHub APK, self-updates, has REQUEST_INSTALL_PACKAGES) and play (AAB, no installer permission). Both audited from the build artifacts.
- Threat model: local-only personal app, no accounts, no backend. Data classes: reading log (user content), optional PIN-gated "locked library", backup files. Attackers considered: lost or stolen device, co-resident malicious app, network observer, malicious share intent. Reverse engineering and tamper resistance are out of profile (MASVS-RESILIENCE not required).
- Evidence modes used: artifact inspection, source review, unit and widget suite, and a runtime smoke on one Android 17 x86_64 emulator. The arm64 APK ran through ABI translation, so timings are not representative. No real phone was used.
- Tools: aapt2 and apksigner (build-tools 36.0.0), zipalign (16 KB check), adb, flutter analyze and flutter test, OSV batch query (api.osv.dev) for dependencies.
- OWASP MASVS control groups are named by group only. No MASWE or MASTG IDs are cited because they were not looked up at audit time.

## Artifacts audited
| File | Size (bytes) | SHA-256 |
|---|---|---|
| Pagemark-0.13.1-arm64.apk | 32,947,434 | 3a0f7e78b6081018119ed667206f453b4ed68f0dd8b41c3a5d93f6fcf0351be9 |
| Pagemark-0.13.1-armv7.apk | 29,161,302 | f5151fdca3c9f003cc13f85d93cc89c46ddc9ec8f7c7f2e07f9eeece40ded0b4 |
| Pagemark-0.13.1-play.aab | 80,344,732 | fd5ee9b589106beeae3599b85deb96e3a1b79c541b315900b6aca14e016b0734 |

## Identity gate (PASS)
- Git: tag v0.13.1 resolves to HEAD e42cc2674f928e8f0063a910ef9332daff532825; `git status` clean; release files were written after the commit (19:02 vs 18:59).
- Manifest: package, versionName 0.13.1, versionCode 2022, compile and target SDK 36, minSdk 24, native code arm64-v8a (arm64 APK).
- Signing: one signer, CN=Pagemark, O=AxialForge, RSA 2048, certificate SHA-256 26b4a4234bc4346eb7e63ebee49c114cbdadd1fa10e60a5cc34f324d6b1bac44, identical on arm64 and armv7. Scheme: v2 only (see MOB-BLD-0003). The keystore and `key.properties` are not tracked by git.

## Store policy sources checked
- Google Play target API requirement, https://developer.android.com/google/play/requirements/target-sdk, fetched 2026-10-14 (page last updated 2026-10-01): new apps and updates must target API 36 from 2026-08-31; Pagemark targets 36.
- Apple checks: not applicable (Android only).
- Data safety, content rating and account-deletion policies were not fetched; those controls are MANUAL REVIEW.

## Evidence files (folder `artifact/`)
badging.txt, merged-manifest.txt, signing.txt, sha256.txt, file-list.txt, secret-smells.txt, manifest-flags.txt, analyze.txt, test.txt, sbom-pub.txt, rt-perf.txt, rt-logcat.txt, rt-launch.png, rt-offline.png, rt-font2.png.

## Automated results
- `flutter analyze`: No issues found.
- `flutter test`: 295 passed, 1 skipped, 0 failed.
- Secret smell scan of the unpacked APK: 200 hits, all reviewed as license URLs, XML namespaces and strings inside libflutter, libapp and classes.dex (words such as "password" and "staging"). No keys, tokens, private-key blocks or .env content found. Values were redacted by the script.
- 16 KB page alignment: `zipalign -c -P 16` reports OK for every native library checked in the arm64 APK.
- Play AAB manifest: no REQUEST_INSTALL_PACKAGES, not debuggable.
- Runtime on emulator: 0 fatal exceptions or ANRs in 4,881 logcat lines; process kill then relaunch recovers; airplane-mode launch works; Library at 2.0 font scale renders without overflow.
