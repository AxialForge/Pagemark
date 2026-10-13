# Google Drive backup — one-time setup (free)

Pagemark backs up to a private app-data folder on your own Drive. Google requires you to
register the app once. No billing is needed.

1. Go to https://console.cloud.google.com and create a project (e.g. "Pagemark").
2. **APIs & Services → Library**: enable **Google Drive API**.
3. **APIs & Services → OAuth consent screen** (Google Auth Platform): choose **External**,
   fill the app name and your email, and add yourself under **Test users**.
   Add the scope `.../auth/drive.appdata`. Leaving it in "Testing" is fine for personal use
   (test-user tokens expire every 7 days, so click **Publish app** to avoid re-signing in weekly;
   the appdata scope is non-sensitive and needs no verification).
4. **Credentials → Create credentials → OAuth client ID**, two of them:
   - **Android**: package name `com.axialforge.pagemark`, SHA-1 of your signing key.
     Debug key SHA-1 on this PC: `49:F9:4A:A8:40:A7:EE:01:D1:B0:06:2E:9B:5C:35:4B:52:10:FC:CB`
     (a release key will have a different SHA-1 — add another Android client for it).
   - **Web application**: no redirect URIs needed. Copy its **Client ID**.
5. In Pagemark: **Settings → Backup and restore → Back up to Google Drive**, paste the **Web client ID**, tap **Sign in**,
   then turn on **Automatic backup**.

Notes
- Android runs the schedule via WorkManager: "daily/weekly" is approximate and may be delayed by battery saver.
- Backups include locked books. They are encrypted on the phone before upload only if you set a **backup password** (Settings > Google Drive backup); without one they sit unencrypted in your private Drive app folder. If the password is ever lost from the phone, Pagemark stops uploading and tells you instead of sending an unencrypted copy.
- Restore: **Restore from Drive…** replaces the whole library, then the app closes.

## Release key

The release APK is signed with `~/.android/pagemark-release.jks`. Add a **second Android OAuth client** for it with SHA-1 `39:04:59:AD:24:0F:35:99:4B:CD:A5:86:81:AF:9C:21:8C:FD:27:F7` (package `com.axialforge.pagemark`), or Drive sign-in fails in the release app.

## Google Play build

If you publish on Google Play, Play re-signs the app with its own key. Add a **third Android OAuth client** with the SHA-1 shown in Play Console > Setup > App signing, or Drive sign-in fails in the Play build. See [PLAY_STORE.md](PLAY_STORE.md).
