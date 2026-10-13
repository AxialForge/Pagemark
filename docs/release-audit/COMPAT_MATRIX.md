# Pagemark 0.7.0 - Compatibility matrix (phase 12, static part)

Source: merged manifest and resources of the published `Pagemark-0.7.0-arm64.apk` (`aapt2 dump xmltree/badging/resources`), `lib/`, `android/` sources. **Nothing here was run on a device or emulator** (off-limits to this auditor); every row is "static" unless noted. IDs PGM-250..PGM-254.

## Platform facts
`minSdk 24 (Android 7.0)`, `targetSdk 36 (Android 16)`, `compileSdk 36`; Flutter 3.47; APK signing v2 only (valid from API 24); ABIs arm64-v8a + armeabi-v7a published (x86_64 not published, PGM-227); `extractNativeLibs=false`; 16 KB aligned (PGM-226).

| Area | Implication / what the code does | Static verdict |
|---|---|---|
| Predictive back (Android 13+, default on for targetSdk 36) | `android:enableOnBackInvokedCallback="true"` is in the merged manifest. App uses `PopScope(onPopInvokedWithResult)` for the app-lock gate (Back leaves the app, `SystemNavigator.pop`) | OK on paper; back-gesture animation + gate behaviour NOT RUN |
| Edge-to-edge enforcement (Android 15+, targetSdk 35+) | No `SystemChrome`/inset code in `lib/`; `windowSoftInputMode=adjustResize`; launch themes `Theme.Light.NoTitleBar` / `DeviceDefault.NoActionBar`; screenshots from the emulator show correct top/bottom padding (those are 0.4-0.5 builds) | Likely OK via Flutter embedding; NOT RUN on API 35/36 (PGM-253) |
| Display cutout | no `windowLayoutInDisplayCutoutMode` | default; NOT RUN |
| Notification permission (API 33+) | `POST_NOTIFICATIONS` declared; requested when the user turns on automatic backup (`backup_page.dart:202`); denial only suppresses the failure notice (`Notifier` try/catch) | OK |
| Foreground service types (API 34+) | WorkManager `SystemForegroundService` declared with `foregroundServiceType=0x800` (shortService) and `FOREGROUND_SERVICE_SHORT_SERVICE` permission present | consistent; app never starts a foreground service itself |
| Background execution limits / Doze / OEM killers (API 31-36) | Periodic WorkManager, `NetworkType.unmetered/connected`, exponential backoff; in-app battery-optimisation guidance and button (`backup_page.dart:228-233`); manual §11 warns about delay | OK, timing NOT RUN |
| Exact alarms | not used (`SCHEDULE_EXACT_ALARM` absent) | n/a |
| Storage / media permissions | none: `READ_EXTERNAL_STORAGE`, `READ_MEDIA_*` removed with `tools:node="remove"`; gallery cover uses `image_picker` (system Photo Picker via `photopicker_activity` metadata); backups via SAF `file_picker` | OK |
| Install unknown apps | `REQUEST_INSTALL_PACKAGES`; `OpenFilex` returns `permissionDenied` -> friendly message. On API 24-25 "Unknown sources" is one global switch, whereas INSTALL_MANUAL §3 step 2 describes the Android 8+ per-app switch (PGM-252) | LOW doc |
| Camera | `uses-feature android.hardware.camera required=false`; scanner has a permission-denied/`errorBuilder` state; tablets/Chromebooks without camera can still install | OK |
| Biometrics | `USE_BIOMETRIC` + legacy `USE_FINGERPRINT`; `FlutterFragmentActivity`; `local_auth` default allows device credential fallback; weak-biometric warning exists | OK |
| Desugaring / java.time on API 24-25 | `isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs 2.1.4` | OK |
| Large screens / foldables / orientation | no `screenOrientation`, no `resizeableActivity=false` (resizable by default at targetSdk >= 24); `configChanges` covers orientation, screenSize, smallestScreenSize, screenLayout, density, uiMode, layoutDirection, fontScale; Android 16 ignores orientation/aspect opt-outs on >= 600 dp anyway | OK statically; tablet layouts of the five Library styles NOT RUN (PGM-254) |
| Multi-window / split-screen | resizable; `AppLifecycleState.paused` is not delivered to the unfocused-but-visible window on Android 10+ multi-resume devices, so the delay-0 relock may not fire while another app is focused alongside | edge case, NOT RUN (PGM-254) |
| Large text | `test/v043_ui_test.dart` draws every Library style at 200 % (CLAUDE.md gotcha); suite green | OK |
| Dark mode | six themes; launch themes have `values-night` / `values-night-v31` variants | OK |
| Per-app language / RTL | no `localeConfig`, no `supportsRtl` attribute; no `flutter_localizations`/`localizationsDelegates`/`supportedLocales` in `main.dart`/`pubspec.yaml`, i.e. the UI is English only and Flutter never receives an RTL locale (PGM-250) | INFO |
| Locale-dependent formats | `DateFormat.yMMMd()` / `.add_jm()` (ui.dart:39, backup_page.dart:129,264, updater_ui.dart:140,185) never pass a locale and no `initializeDateFormatting` is called, so dates are always en_US ("Oct 12, 2026") and times always 12-hour with AM/PM even on 24 h / non-US phones; decimals use `toStringAsFixed` (always "."), e.g. "3.5" for a comma-decimal phone; filenames use fixed `yyyyMMdd-HHmm` | LOW (PGM-250) |
| Time zones / clock | wall-clock `DateTime.now()` for lockout/delay (PGM-206), dates stored via Drift `dateTime` (local) | see security |
| ABIs | arm64, armv7 only; x86_64 devices cannot use the in-app updater (PGM-227) | INFO |
| Android 7.0 (API 24) TLS roots | not verifiable statically (GitHub, Google, openlibrary.org certificate chains on a 2016 trust store) | NOT RUN |

## Findings
- **PGM-250 LOW** - Dates/times and number formats ignore the device locale (always en_US, 12-hour clock); the app has no localisation. Evidence: `code ui.dart:39`, `backup_page.dart:129`, `updater_ui.dart:140`; `grep localizationsDelegates|supportedLocales|flutter_localizations` empty. Fix options: declare `supportedLocales: [Locale('en')]` explicitly and document "English only", or pass `Localizations.localeOf(context).toString()` and add `flutter_localizations` + `initializeDateFormatting`. Verify: device set to `de-DE`, 24 h clock: Updates page "Last checked" should show 24 h.
- **PGM-251 INFO** - English-only UI means RTL is moot today; `android:supportsRtl` is unset (framework default false). Revisit only if localisation is added.
- **PGM-252 LOW** - INSTALL_MANUAL step 2 ("turn on Allow from this source") is Android 8.0+ behaviour; on Android 7.0/7.1 (supported minimum) the user must enable global "Unknown sources". `code docs/release-package/INSTALL_MANUAL.md:27`.
- **PGM-253 INFO** - Edge-to-edge (API 35+), predictive back animation and cutout handling cannot be confirmed statically; the device auditor should run the three screens with the keyboard open (Add book search, ReadEditor, PIN gate) on an API 35/36 image.
- **PGM-254 INFO** - Tablet/foldable layout of Cover wall / Bookshelf / Spines and the multi-window relock edge case are unverified.

## NOT run
Everything on a device or emulator (API 24, 29, 33, 35, 36 images; tablet/foldable; 24-hour and non-US locale; display scaling; font scale beyond the existing widget tests; Android 15/16 enforcement behaviour). Windows/other Flutter/SDK versions beyond the machine's Flutter 3.47 / SDK 36.0.0 build-tools.
