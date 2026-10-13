# Google Play readiness - Pagemark 0.7.0

Static review of manifest, Gradle, dependencies and docs (2026-10-12). Play policy details change; confirm each item in Play Console before relying on it. Nothing was uploaded or registered.

## Verdict: not ready yet, but close. Two real blockers, rest is paperwork.

| # | Item | Status | Action |
|---|---|---|---|
| 1 | **Self-updater** (`REQUEST_INSTALL_PACKAGES`, `open_filex`, `updater.dart`) | BLOCKER | Play does not allow an app to download and install APKs outside Play. Build a Play flavor with the permission and Updates screen removed; keep the GitHub-APK build for sideloaders. |
| 2 | **App Bundle (.aab)** | BLOCKER (process) | Play takes AAB, not APK. `flutter build appbundle` is not set up or tested; no release script exists (PGM-222). |
| 3 | Signing | Needs decision | Play App Signing re-signs with Google's key. Your keystore becomes the *upload* key. Sideload APKs (your key) and Play installs (Google key) cannot update each other. Keep the keystore backed up. |
| 4 | Google Drive sign-in | Needs work | The OAuth Android client is tied to a SHA-1. Add the Play App Signing SHA-1 to the Cloud project, or Drive backup breaks on Play installs. `drive.appdata` is a non-sensitive scope. |
| 5 | Developer account | Needs you | Play Console requires a one-time registration fee (about $25) and identity verification. Personal accounts created recently must run a closed test (about 12 testers for 14 days) before production. This is a Google requirement, not something I am suggesting you buy beyond it. |
| 6 | targetSdk | OK | 36, meets the current requirement. Recheck each August. |
| 7 | 16 KB page size | OK | Native libs verified aligned (PGM-226). |
| 8 | Privacy policy URL | Mostly done | `docs/PRIVACY.md` exists in the public repo; Play needs a public URL (the GitHub page works) and it must match the Data safety form. Fix PGM-201/203/243 first so the policy is true. |
| 9 | Data safety form | To do | Declare: no data collected by you; Drive backup goes to the user's own Drive; Open Library lookups send ISBN/title text; no analytics. |
| 10 | Permissions | OK after #1 | CAMERA (scanner), USE_BIOMETRIC, POST_NOTIFICATIONS, INTERNET are all justifiable. Remove REQUEST_INSTALL_PACKAGES. |
| 11 | Store listing | To do | 512 px icon, 1024x500 feature graphic, 2+ phone screenshots (you have real ones in docs/screenshots), short and full description, content rating questionnaire (expect Everyone; the optional heat/content-notes field may raise a question, answer honestly). |
| 12 | Crashes/quality | Watch | Pre-launch report from Play will run robo tests; the lock screen and FLAG_SECURE may block it, so provide test steps or a test PIN. |
| 13 | Open HIGH findings | Fix first | PGM-100, 101, 102, 200, 202 affect trust claims a store listing would repeat. |
| 14 | Doc truth | Fix first | PGM-240..243, 248 (stale/false claims). |
| 15 | Versioning | OK | versionCode is monotonic; Play needs a unique, increasing code per upload. |

## Suggested order

1. Fix PGM-100/101/102/200/202 and the false doc claims (a 0.7.1 or 0.8.0).
2. Add a `play` build flavor: no installer permission, no Updates screen. Build a signed AAB and test it on the emulator and a phone.
3. Create the Play Console account, upload the AAB to internal testing, enrol Play App Signing, copy its SHA-1 into the Drive OAuth client.
4. Run a closed test, fill the Data safety form and store listing, then apply for production.
