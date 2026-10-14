# Android specifics

Contents: artifact inspection · manifest · storage/crypto · network · build · Play · Flutter/RN notes

## Artifact inspection (domain 02, 12, 13, 17, 18, 19)
```bash
aapt2 dump badging app.apk                      # package, versionCode/Name, min/target SDK, uses-permission, ABIs
aapt2 dump permissions app.apk
apkanalyzer manifest print app.apk              # MERGED manifest (what actually ships)
apkanalyzer files list app.apk ; apkanalyzer apk summary app.apk
apksigner verify --print-certs -v app.apk       # signing scheme versions + cert SHA-256 (identity gate)
unzip -l app.aab | head                         # AAB: bundletool build-apks / dump manifest
bundletool dump manifest --bundle=app.aab
```
Search the unpacked package for: `http://`, `api_key`, `secret`, `BEGIN PRIVATE KEY`, `.env`, `google-services.json` content, staging hostnames, `debuggable`. `scripts/inspect_artifact.sh <apk>` runs the common set and writes `audit/artifact/`.

## Manifest checks
- `android:debuggable` absent/false in release; `android:allowBackup` and `dataExtractionRules`/`fullBackupContent` match intent (backup of tokens/DB is a finding unless documented).
- `usesCleartextTraffic` false or scoped by `networkSecurityConfig`; no user-CA trust in release.
- Exported components: every `activity/service/receiver/provider` with intent-filter or `exported=true` is an entry point; check permission guards and input validation. Android 12+ requires explicit `exported`.
- Deep links / App Links: `autoVerify`, assetlinks.json, parameter validation.
- `uses-permission`: each must map to a feature (domain 17). Plugins add some silently; `tools:node="remove"` strips them. Check `minSdk`/`targetSdk` against current Play requirement (fetch current deadline, do not assume).
- Foreground services: type declared + Play declaration.
- `FLAG_SECURE` on sensitive screens; recents thumbnail behavior (set flag before backgrounding, clear after resume).

## Storage and crypto (domain 12)
Look in app-private dirs (`/data/data/<pkg>`: databases, shared_prefs, files, cache, no_backup) via `adb run-as` on debuggable builds or an emulator. Tokens/keys belong in Keystore-backed storage (EncryptedSharedPreferences/Keystore, or `flutter_secure_storage`), not plain prefs/SQLite. Check external storage/MediaStore writes, clipboard use, logcat output (`adb logcat` through a full user flow, grep for tokens/PII), notification content on lock screen, share-intent leakage, and key derivation (PBKDF2/Argon2 iterations, random salt, no hardcoded keys, GCM not ECB).

## Network (domain 13)
`network_security_config.xml`, pinning (`<pin-set>` with backup pin and expiry), TrustManager/HostnameVerifier overrides, WebView settings (`setJavaScriptEnabled`, `addJavascriptInterface`, file access, mixed content).

## Build and release (domain 02)
R8/minify and shrink on, `mapping.txt` archived not shipped, `signingConfigs` not using debug keys, `key.properties`/keystore not in git, Play App Signing enrolled, versionCode monotonic, no test ad unit IDs, `BuildConfig.DEBUG` paths dead.

## Play-specific (domain 22; fetch current policy)
Target API level requirement, Data Safety form vs real behavior, account deletion (in-app + web link), permissions declaration forms (SMS, call log, background location, all-files, accessibility), foreground-service types, ads declaration, content rating, target audience / Families, billing (Play Billing for digital goods), 64-bit, AAB, Play pre-launch report. Android Vitals thresholds (crash and ANR rates) are a post-release extension.

## Framework notes
- **Flutter:** release is AOT, but strings/endpoints remain readable in `libapp.so`; `--obfuscate --split-debug-info` is optional hardening, not a security boundary. Check `flutter_secure_storage` use, plugin permission additions, `assets/` for bundled secrets, platform channel inputs.
- **React Native:** check the JS bundle (`index.android.bundle`) for secrets/endpoints; Hermes bytecode still decompiles; disable dev menu/remote debugging in release; CodePush/OTA update integrity.
- **Hybrid/WebView:** bridge exposure and origin allowlists.

## Runtime tooling (when a device/emulator is available)
`adb shell dumpsys package <pkg>`, `adb shell am start -W` (startup time), `adb shell dumpsys gfxinfo <pkg>` (frames), `adb shell dumpsys meminfo <pkg>`, `adb shell dumpsys batterystats`, Perfetto/Macrobenchmark, `adb logcat`, Android Studio profilers, `adb shell pm revoke` / `appops` for permission denial tests. Network faults: emulator `-netdelay/-netspeed`, or a proxy (mitmproxy/Charles) on a test device.
