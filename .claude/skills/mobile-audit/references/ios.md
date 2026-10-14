# iOS specifics

Contents: artifact inspection · plist/entitlements · storage/crypto · network · build · App Store · framework notes · tooling

Without a Mac and Xcode, iOS runtime checks are BLOCKED. Do source and IPA static analysis, mark runtime controls BLOCKED, and say so in the report.

## Artifact inspection (domain 02, 12, 13, 17, 18, 19)
```bash
unzip -q app.ipa -d audit/artifact/ipa            # Payload/<App>.app
plutil -p Payload/*.app/Info.plist                # bundle ID, versions, permission strings, ATS, URL schemes
codesign -d --entitlements :- Payload/*.app       # entitlements actually granted
codesign -dvv Payload/*.app                       # signing identity, team ID
security cms -D -i Payload/*.app/embedded.mobileprovision   # profile type (development vs distribution), expiry
otool -L Payload/*.app/<bin>                      # linked frameworks/SDKs
strings Payload/*.app/<bin> | grep -Ei 'http://|api[_-]?key|secret|staging'
find Payload -name '*.framework' ; find Payload -name 'PrivacyInfo.xcprivacy'
```
A `get-task-allow` entitlement = true, or a development provisioning profile, in a release IPA is a release-integrity finding.

## Info.plist and entitlements
- Every permission needs a specific, honest purpose string (`NSCameraUsageDescription`, `NSLocation*`, `NSPhotoLibrary*`, `NSContactsUsageDescription`, `NSFaceIDUsageDescription`, `NSUserTrackingUsageDescription`, ...). Missing or vague string for an API the binary links = store blocker.
- **ATS:** `NSAppTransportSecurity` exceptions (`NSAllowsArbitraryLoads`, per-domain exceptions) need justification.
- URL schemes and Universal Links (`apple-app-site-association`): validate every parameter; check associated domains match.
- Background modes only if used. Entitlements minimal (App Groups, keychain-access-groups, push environment `production`).
- **Privacy manifest** (`PrivacyInfo.xcprivacy`) and required-reason API declarations for the app and for bundled third-party SDKs; fetch current requirements.

## Storage and crypto (domain 12)
Keychain for secrets with an appropriate `kSecAttrAccessible*` class (`WhenUnlockedThisDeviceOnly` for sensitive data; avoid `Always*`); no secrets in `UserDefaults`, plists, plain files, or Core Data/SQLite. Note Keychain items **survive uninstall** by default, so check first-launch cleanup if that matters. Data protection class on files (`NSFileProtectionComplete` where needed). iCloud/iTunes backup inclusion (`isExcludedFromBackup`). App-switcher snapshot: blur/cover sensitive views on `willResignActive`. Pasteboard use, `NSLog`/`os_log` content (use `%{private}`), keyboard caching on sensitive fields (`autocorrectionType`, `secureTextEntry`).

## Network (domain 13)
ATS defaults on, TLS validation not overridden (`URLSessionDelegate` accepting any trust), pinning with backup pin where required, `WKWebView` JS bridge and origin handling, `SFSafariViewController` vs embedded webview for auth.

## Build and release (domain 02)
Distribution profile and certificate, bitcode n/a on current Xcode, dSYMs archived and uploaded to the crash reporter, no dev menus/`#if DEBUG` leaks, version/build monotonic, TestFlight build equals submitted build (identity gate), no test ad IDs or staging endpoints.

## App Store specifics (domain 22; fetch current guidelines)
Account deletion initiated in-app when account creation exists; Sign in with Apple when third-party social login is offered (check current exceptions); In-App Purchase for digital goods, Restore Purchases; ATT prompt only if tracking, consistent with `NSUserTrackingUsageDescription` and privacy labels; privacy nutrition labels vs actual SDK behavior; export-compliance / encryption declaration; age rating; UGC moderation, report/block if user content; reviewer notes + demo credentials; no private APIs; iPad layout if iPad is supported.

## Framework notes
- **Flutter:** `Info.plist` strings for each plugin's API; check plugin privacy manifests; `flutter_secure_storage` iOS options (accessibility class).
- **React Native:** JS bundle readable in the IPA; dev menu off in release; OTA update integrity.

## Runtime tooling (Mac + device/simulator)
Xcode Instruments (Time Profiler, Allocations, Energy, Network), `xcrun simctl` (simulate states, push, privacy permission reset: `simctl privacy <udid> reset all <bundle>`), `xcrun xctrace`, Console.app for logs during a flow, MetricKit for field data, Network Link Conditioner for degraded networks, a proxy for traffic inspection. VoiceOver and Accessibility Inspector for domain 08.
