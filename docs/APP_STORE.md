# Publishing Pagemark on the App Store

Paste-ready answers for App Store Connect. Keep them in step with `docs/PRIVACY.md` and the app (the iPhone build has no updater, folder backup or widget).

## Build and upload (on the Mac)

1. Pull `ios-first-build` (later `main`), `flutter pub get`, `cd ios && pod install`.
2. Xcode → Runner → Signing & Capabilities: pick your team (bundle id `com.axialforge.pagemark`).
3. `flutter build ipa --release`, then upload `build/ios/ipa/*.ipa` with Transporter (or Xcode → Organizer).
4. TestFlight first: check Face ID/Touch ID unlock, the blank app switcher on the Locked tab, a reminder, and a backup + restore.

## App information

- **Name (30):** Pagemark: Reading Log
- **Subtitle (30):** Private book tracker & journal
- **Category:** Primary **Books**, secondary **Lifestyle**.
- **Bundle ID / SKU:** `com.axialforge.pagemark` / `pagemark-ios`
- **Content rights:** No third-party content. Book details and covers come from Open Library and Google Books at the user's request.
- **Copyright:** © 2026 AxialForge
- **Privacy policy URL:** `https://axialforge.github.io/Pagemark/privacy.html` (needs GitHub Pages on, `main` / `/docs`).
- **Support URL:** `https://github.com/AxialForge/Pagemark/issues`
- **Price:** Free. No in-app purchases.

## Version page

**Promotional text (170):**
A private reading log that lives only on your phone. No account, no ads, no tracking and no AI. Your books, ratings and thoughts never leave your iPhone.

**Keywords (100, comma-separated, no spaces):**
`reading log,book tracker,reading journal,manga,audiobook,tbr,quotes,library,isbn,scanner,stats,goal`
(Don't add competitor names such as Goodreads or StoryGraph; Apple rejects them.)

**Description:**

Pagemark is a book tracker that keeps everything on your phone.

LOG EVERY READ
• Print, e-book and audiobook, with dates, half-star ratings and private thoughts
• Re-reads are kept as separate reads, so nothing gets overwritten
• Save favourite quotes and set a yearly reading goal

ADD BOOKS IN SECONDS
• Scan the barcode or search by title, author or ISBN
• Covers and details come from Open Library (and Google Books, which you can switch off)
• Import your history from a CSV export of another reading app

MANGA, COMICS AND SERIES
• Track collections volume by volume: what you own, what you have read and what you still need

YOUR STATS
• Books per month, ratings, pages and listening time, and your year in books

A LOCKED LIBRARY
• Keep some books behind a PIN or Face ID / Touch ID
• Locked books stay out of stats, search and exports, and the app switcher shows a blank screen while they are open

YOUR DATA STAYS YOURS
• No account, no ads, no analytics, no tracking and no AI
• Save a password-protected backup wherever you like (Files, iCloud Drive, email), with a reminder to do it
• Export your log as CSV or JSON at any time

Pagemark never collects your data. The code is public.

**What's New (first release):**
First iPhone release of Pagemark.

## Age rating

Answer **None / No** to every content question (no violence, sexual content, profanity, gambling, medical, etc.). Unrestricted web access: **No** (the app only queries book catalogues). User-generated content shared with others: **No**. Expected rating: **4+**.

The optional "heat level and content notes" fields are a private diary entry, off by default, with no content provided by the app. They don't change the answers above.

## App Privacy ("nutrition label")

**Recommended answer: "Data Not Collected".**

Why this is accurate under Apple's definitions:
- AxialForge has no server and receives nothing. There are no analytics, ads, crash-reporting or tracking SDKs (a test in the project enforces this).
- Library data, ratings, thoughts, PIN hash and backups stay on the device, or go only where the user saves them.
- Book searches go straight from the phone to Open Library / Google Books to answer that one request. Apple does not count data used only to service a request in real time as "collected", and neither service is a partner of the developer.
- On iPhone the barcode reader is Apple's on-device Vision framework. Unlike Android, no Google ML Kit is involved.

More conservative alternative, if you'd rather declare the lookups: **Search History**: *not linked to the user*, *not used for tracking*, purpose **App Functionality**. Don't mix the two: either "Data Not Collected" or this one entry.

Tracking: **No** (no ATT prompt needed). The privacy manifest `ios/Runner/PrivacyInfo.xcprivacy` already says the same.

## Export compliance

`ITSAppUsesNonExemptEncryption = false` is set in `Info.plist`, so App Store Connect won't ask on each build. Reason: encryption is used only for HTTPS and to protect the user's own backup files (exempt).

## App Review notes

> Pagemark is a local reading log with no account or login. To test: tap + to add a book (search "Dune" or scan any book barcode). The Locked tab asks you to set a PIN; any PIN works and a recovery code is shown. No server; the only network calls are book lookups to openlibrary.org and googleapis.com (Google Books).

Demo account: not needed. Contact: your name, email and phone (App Store Connect only, not public).

## Screenshots

- Required: **6.9" iPhone** (1320 × 2868 or 2868 × 1320), 3 to 10 images. Smaller sizes are scaled from it.
- iPad: not needed (the app is iPhone only, `TARGETED_DEVICE_FAMILY = 1`).
- Capture on the 6.9" simulator (iPhone 16/17 Pro Max) with the seeded demo library (`docs/_tools/screenshots/README.md`). Use a `--dart-define=PAGEMARK_SCREENSHOTS=true` build for the Locked tab, and never ship that build.
- Suggested set: Library (cover wall), Book page with a read, Stats, Add book / scanner, Series volumes, Locked tab.
- Don't show Android UI, "fingerprint" wording or the Updates screen (Apple rejects references to other platforms).

## Before you submit (open items)

- [ ] GitHub Pages on, and the privacy URL opens.
- [ ] Signing team set; TestFlight build tested on a real iPhone (checklist in "Build and upload").
- [ ] 6.9" screenshots captured.
- [ ] App Privacy, age rating and review notes entered as above.
