# Publishing Pagemark on Google Play

Everything the repo can prepare is here; the steps that need your Google account are marked **You**. Verify each answer in Play Console before submitting, because Google changes its forms.

## Build

```powershell
powershell -File tool\build.ps1
```

Produces `build/release-<version>/Pagemark-<version>-play.aab` (upload to Play) and the two GitHub APKs. The bundle is signed with your release keystore, which becomes the **upload key**. Google re-signs what users download with its own **app signing key**, so:

- GitHub-APK installs (your key) and Play installs (Google's key) cannot update each other. Pick one per phone.
- Keep `~/.android/pagemark-release.jks` backed up. Losing it means asking Google to reset the upload key.

The `play` flavor has no `REQUEST_INSTALL_PACKAGES` permission and no Updates screen (checked in the merged manifest).

## Steps

1. **You:** create a Play Console developer account (one-time registration fee, identity verification). A personal account created recently must run a **closed test with about 12 testers for 14 days** before production access.
2. **You:** create the app (name Pagemark, free, no ads), opt in to **Play App Signing**, upload the `.aab` to **Internal testing** first.
3. Fill in the forms below, run the closed test, then apply for production.

## Store listing

- **Short description (80):** Your private reading log: print, e-book and audiobook, all on your phone.
- **Full description:** Pagemark is a book tracker that keeps everything on your phone. Log print, e-book and audiobook reads, rate half stars, write private thoughts, save quotes, set a yearly goal and see your stats. Scan a barcode or search to add books (covers and details come from Open Library). Keep a locked library behind a PIN or your fingerprint. Save a password-protected backup file whenever you like, with a reminder to do it. Export CSV/JSON, import from Goodreads or StoryGraph. No account, no ads, no tracking and no AI. Pagemark never collects your data.
- **Category:** Books & Reference. **Tags:** reading tracker, book log.
- **Graphics:** 512x512 icon (`assets/branding`), 1024x500 feature graphic (**You**: not yet made), at least 2 phone screenshots (use `docs/screenshots/`, regenerate for 0.7.1 first: several images are version-stamped 0.4.1-0.5.0).
- **Privacy policy URL:** `https://github.com/AxialForge/Pagemark/blob/main/docs/PRIVACY.md` (public; keep it matching the app).

## Data safety form (answers)

- Does the app collect or share user data? **Pagemark itself collects nothing and has no server.** The only thing sent anywhere is a public book lookup:
  - **Book lookup:** the title, author or ISBN you type or scan is sent to Open Library and, unless the user turns it off, Google Books. Declare as "search query / app activity", not linked to identity, optional.
- Camera: used only to read barcodes on the device; images are not stored or sent.
- No ads, no analytics, no crash-reporting SDK. Data is encrypted in transit (HTTPS). Users can delete data by clearing app storage or deleting the backup files they saved.

## Content rating

Expect **Everyone**. The optional "heat level and content notes" field is a private diary field, off by default, with no content provided by the app. Answer the questionnaire honestly (user-generated content: none shared with other users).

## Other declarations

- Target audience: 13+ (not designed for children).
- Permissions: Camera (scanner), Biometric (lock), Notifications (reading and backup reminders, Android 13+), Internet.
- Pre-launch report: Play's test robot cannot get past the lock screen if one is set; leave the app lock off in the test build.

## Before you submit (open items)

- Verify the 0.7.1 fixes on a real phone (see `docs/release-audit/MANUAL_TEST_PLAN.md`).
- Regenerate screenshots and the PDF manuals for the release you ship.
- Make the 1024x500 feature graphic.
