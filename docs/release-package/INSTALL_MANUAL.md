# Pagemark — Install Manual

**Version {{VERSION}}** · Android

---

## 1. Requirements

- An Android phone or tablet running **Android 7.0 (API 24) or newer**.
- About **100 MB** free storage (the app is ~30 MB; the library and cached covers are small).
- Optional, for specific features: a camera (barcode scanning), a screen lock or fingerprint (locked library), notifications (reminders), an internet connection (book lookup, updates). Tablets and foldables work too: the layout adapts to the screen.

## 2. Download

Releases are published at **https://github.com/AxialForge/Pagemark/releases**. Open the newest release and pick **one** APK:

| File | Use it on |
|---|---|
| `Pagemark-x.y.z-arm64.apk` | Almost every phone from the last ~8 years (64-bit ARM). **Choose this one** unless it fails to install. |
| `Pagemark-x.y.z-armv7.apk` | Older 32-bit phones. |

Not sure? Download the arm64 file. If Android says the app isn't compatible, use the armv7 one.

## 3. Install

1. Open the downloaded `.apk` (from your browser's downloads or the Files app).
2. Android will say your browser/Files app isn't allowed to install apps. On Android 8 and newer, tap **Settings** and turn on **Allow from this source**, then go back. On Android 7, turn on **Unknown sources** in Settings > Security instead.
3. Tap **Install**, then **Open**.

Pagemark is signed with the author's key, so future updates install over it and keep your data.

> Play Protect may show "unrecognised app" because Pagemark isn't distributed through the Play Store. Choose **Install anyway** (or **More details → Install anyway**).

## 4. First run

Pagemark opens with three short welcome screens (**Skip** any time), then an empty Library. Tap **Add book** to start, or **Try it with 5 sample books** to look around (remove them again with **Remove** on the card in the Library). Allow the **camera** only if you want to scan barcodes. Android 13 and newer asks once for **notifications** the first time you switch on a reminder (reading, backup or a lent book); everything else needs no permissions. The guide is always at **Settings → How to use Pagemark**, and **Settings → Our promise to you** says what Pagemark will never do.

<div class="shots one"><figure><img src="../screenshots/library.jpg" alt="Pagemark with a few books added"><figcaption>Pagemark with a few books added</figcaption></figure></div>



### Permissions Pagemark asks for

| Permission | Why |
|---|---|
| Internet | Book lookup (Open Library and Google Books), cover pictures, update check (GitHub version only) |
| Camera | Scanning ISBN barcodes (asked only when you open the scanner) |
| Biometric | Fingerprint/device unlock for the locked library |
| Notifications | Reading, backup and lent-book reminders (asked when you switch one on) |
| Run at start-up | Sets reminders again after the phone restarts |
| Vibrate | A small buzz when a barcode is scanned |
| Install packages | Lets Android offer to install a downloaded update (GitHub version only) |

Pagemark does not ask for storage, photo, contacts, location, microphone or Bluetooth permissions. Some phones list **Nearby devices** under a general "network" label for any app that uses the internet; Pagemark does not request it. Backups are saved with Android's own file and folder pickers, so no storage permission is needed.

## 5. Updating

**In the app:** Settings → **Updates** → *Download & install*. Android asks once to allow installs from Pagemark. You can also let it check once a day automatically.

**By hand:** download the newer APK from Releases and open it — it installs over the old version.

Your library, shelves, settings and PIN are all kept. **Make a backup first** if the library matters to you (Settings → Backup and restore → **Save a copy as a file**). After an update, open Pagemark once so your reminders are set again.

## 6. Uninstalling — read this first

Uninstalling Pagemark **deletes your library** from the phone (Android's own backup is disabled on purpose). Before you uninstall or switch phones:

1. Settings → Backup and restore → **Save a copy as a file** (set a password) and keep the file safely, **or** make sure the backups Pagemark saves to your chosen folder (for example one inside Google Drive) are recent.
2. On the new phone, install Pagemark and use **Restore** — a backup from an older Pagemark version restores fine; one from a newer version does not.

The PIN is not stored in backups. After restoring, set a new PIN for the locked library.

## 7. Keeping your library safe

Settings → Backup and restore → **Save a copy as a file** (protect it with a password) and keep the file somewhere other than this phone, or choose a folder (on the phone, a USB drive, or inside Google Drive, OneDrive or Dropbox) and Pagemark saves a fresh backup there by itself, keeping the newest five. Pagemark can also remind you every week, two weeks or month.

For the official release APK, the signing-key SHA-1 is:

`39:04:59:AD:24:0F:35:99:4B:CD:A5:86:81:AF:9C:21:8C:FD:27:F7`

## 8. Building from source (developers)

```bash
git clone https://github.com/AxialForge/Pagemark.git
cd Pagemark
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerates lib/db.g.dart
flutter analyze && flutter test
flutter build apk --release --split-per-abi
```

Requirements: Flutter 3.47+ (stable), Android SDK, JDK 17+.

**Windows with a very new JDK (25):** Gradle can fail with *"Unable to establish loopback connection"*. Create a short folder such as `C:\tmpj` and run the build with
`JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/tmpj`.

**Signing:** create a keystore, put its path and passwords in `android/key.properties` (this file is git-ignored; never commit it). Without it, release builds fall back to the debug key, which can't upgrade a release install. Release APKs are signed with APK Signature Scheme v2 and v3. `tool/build.ps1` builds both APKs and the Google Play bundle for the current version.

## 9. Troubleshooting

| Symptom | Fix |
|---|---|
| "App not installed" | A different signing key is already installed (e.g. a debug build). Back up, uninstall, install the release APK. |
| "There was a problem parsing the package" | The download was cut off or you picked the wrong architecture; re-download or use the other APK. |
| Install blocked | Allow "install unknown apps" for the app you opened the APK from. |
| Update says "No public releases found" | Check connection; the project's releases must be public. |
| Fingerprint option missing | Set a screen lock/fingerprint in Android settings first. |
| Scanner is black | Allow the camera permission in Android → Apps → Pagemark. |
| Reminders never appear | Settings → Notifications in Pagemark should say notifications are on; also check Android → Apps → Pagemark → Notifications and Battery (choose *Unrestricted* if offered). Versions before 0.13.2 never showed scheduled reminders; update, then open Pagemark once. |
