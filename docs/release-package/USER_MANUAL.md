# Pagemark — User Manual

**Version 0.4.1** · A private, fully local book tracker for Android

---

## 1. What Pagemark is

Pagemark is a reading log that lives only on your phone. You record what you read or listen to — print, e-book or audiobook, any genre — with your rating, dates, progress and private thoughts. Book details and cover art come from the free **Open Library**; everything you write stays on your device unless you choose to export or back it up.

There is no account, no server and no tracking. The only times Pagemark uses the internet are: looking up a book, checking for an app update, and — if you set it up — backing up to your own Google Drive.

## 2. The four tabs

| Tab | What it is |
|---|---|
| **Library** | Your books. Search, filter, sort, shelves, series. |
| **Locked** | A private library behind a PIN and/or your fingerprint. |
| **Stats** | Your reading goal and charts. |
| **Settings** | Themes, updates, export, backup, privacy, trash, diagnostics. |

A small dot on **Settings** means an app update is waiting.

## 3. Adding a book

Tap **Add book** (bottom of the Library).

1. **Search** — type a title or author and press search. Tap a result to add it.
2. **By ISBN** — type or paste an ISBN into the same box and it is looked up directly. Invalid ISBNs are explained instead of searched.
3. **Scan** — tap the barcode icon at the top and point the camera at the ISBN barcode on the back cover. Only real book barcodes are accepted; the torch button helps in dim light.
4. **Manually** — if a book isn't found, choose **Add manually** and enter a title; fill in the rest later with **Edit**.

If the book is already in the same library (same ISBN, or the same title and author) Pagemark warns you and offers to open the existing one. The main and locked libraries never compare against each other, so the main library can't reveal a locked title.

Descriptions are fetched a moment after the book is saved when Open Library has one.

## 4. The book page

Tap a book to open it. You'll see the cover, details, tags and shelves, your notes, and the **Reading log**.

- **Edit** (pencil) — title, author, series and series number, genre, tags, publisher, ISBN, cover URL, year, pages, description and private notes.
- **⋮ menu** — move the book to or from the Locked library, or **Move to Trash**.
- **Log a read** — records a new read-through (see §5). A book can have many reads: a re-read, or a print copy and an audiobook of the same title.

### Shelves
Tap **+ Shelf** on a book to put it on any number of shelves ("Comfort reads", "Book club", "Lent out"). Create new shelves from there. Remove a book from a shelf by tapping the × on its chip.

### Series
In **Edit**, type the series name and the number in the series (decimals work: `2.5`). Rows show the badge, and the **Series** screen (Library ⋮ menu) groups your books, shows how many you've read, and names what's next. It knows only the books you've added, not how long the series really is.

## 5. Logging a read

Choose **Log a read** (or tap an existing read to edit it).

- **Format** — Print, E-book or Audiobook. Audiobooks add a **Narrator** field.
- **Status** — Want to read, Reading, Finished, or Did not finish.
  - Choosing *Finished* fills in today's date (change it if needed); choosing *Reading* or *Want* clears the finished date.
  - A finished date earlier than the start date is refused.
- **Started / Finished** — tap to pick a date; **Started today / yesterday** are quick chips.
- **Current page** — shown while *Reading*.
- **Rating** — tap stars. Tap the **left half** of a star for a half star, the right half for a whole one; tap the same value again to clear.
- **Time** — minutes read or listened.
- **Your thoughts** — free text, private.

Delete a read with the bin icon (you'll be asked to confirm).

### Reading progress
While a book has an active read, its page shows a **progress card**. Tap **Update progress** and enter the page you're on. If the book has a page count you get a progress bar, pages per day, and an estimate of days left at your pace. Reaching the last page offers to mark the read finished. Progress bars also appear on the Library list and in the **Currently reading** strip.

## 6. The Library

- **Search** — title, author, tags, genre and series.
- **Filters** — status chips (All / Want / Reading / Finished / DNF), format chips, and one chip per shelf. Tap a shelf chip again to clear it.
- **Sort** (⇅ icon) — Recently added, Title, Author, Rating.
- **Currently reading** — a strip of covers at the top when nothing is filtered.
- **Remembered** — your sort and filters are remembered separately for the main and locked libraries.
- **Ratings** show as stars (4.5 = ★★★★½) and average only your **finished** reads.
- **⋮ menu** — **Series** and **Manage shelves** (rename or delete shelves; deleting a shelf never deletes books).

## 7. Stats

The Stats tab counts your **main library only** — locked books never appear in it.

- **Reading goal** — set how many books you want to finish this year. An animated ring shows progress, and Pagemark estimates how many you'll finish by 31 December at your current pace.
- **Finished per month** and **Your ratings** (how your ratings are spread, and your average).
- **Totals** — books tracked, finished, pages, logged time, average days to finish, and finished books by format.
- **Top genres** and **Top authors**.

## 8. The Locked library

A second library for books you want kept private. Nothing in it shows in the main library, Stats, Trash, exports or searches.

### Setting up
Open the **Locked** tab the first time and choose:

- **Set a PIN** — 4 to 12 digits, entered twice. Pagemark then shows a **recovery code** once. **Write it down.** It is the only way back in if you forget your PIN.
- **Use fingerprint / device lock only** — uses your phone's screen lock. Needs a screen lock to be set up on the phone.

### Using it
Enter the PIN (or use the fingerprint button). Add books while the Locked tab is open, or move any book across with its ⋮ menu.

### Protection you can rely on
- **Wrong PINs are limited.** After 5 misses the PIN is locked out for 30 seconds, doubling after every further 5 misses (up to 1 hour).
- **It re-locks itself** when you leave the tab or put Pagemark in the background. Open locked screens close, locked covers are wiped from the image cache, and temporary export files are deleted.
- **No screenshots.** While the vault is open the screen can't be captured and the app-switcher thumbnail is blank.
- **Changing the lock needs the lock.** Changing or removing the PIN asks for the current PIN (or your fingerprint first).

### Forgot your PIN?
On the lock screen tap **Forgot PIN?**, enter the recovery code and a new PIN. You'll receive a **new** recovery code; the old one stops working.

### Settings → Privacy
**Lock now**, **Set or change PIN**, and **Remove lock** (which asks for the current PIN first; locked books stay in the locked library).

## 9. Themes

Settings → Theme: **Light** or **Dark**, in a **blue** ("Him") or **rose/plum** ("Her") palette. Your choice is remembered.

## 10. Exporting your data

Settings → Export (main library only — locked books are never included):

- **CSV** — opens in Excel, Numbers or Sheets (accents display correctly; cells that look like formulas are made safe).
- **JSON** — structured, with a format version.

Settings → Database (**includes locked books**):

- **Export database file** — a complete copy you can restore on another device. You'll be asked for a **passphrase**; leave it empty only if you understand the file will be readable by anyone who gets it.
- **Restore from database file** — see §12.

## 11. Google Drive backup

Settings → **Google Drive backup**. One-time setup (a free Google Cloud project) is described in `docs/DRIVE_SETUP.md`. After that:

1. Paste your **Web client ID** and tap **Sign in**.
2. Turn on **Encrypt backups with a passphrase** (recommended — your locked books are inside every backup). **Remember the passphrase:** without it a backup can't be opened by anyone.
3. Turn on **Automatic backup**, choose **Daily** or **Weekly**, and **Wi-Fi only** if you like.

Backups go to Pagemark's private app-data area on your Drive (they don't appear among your normal files). The **newest 5** are kept. An unchanged library isn't uploaded again, and each upload is verified before older copies are removed. **Back up now** uploads immediately. The Settings page shows the last backup time, or **FAILED** if something went wrong (details are on the backup page).

Android decides exactly when scheduled work runs, so a "daily" backup may be a few hours late, especially with battery saver on.

## 12. Restoring

**From a file** (Settings → Restore from database file) or **from Drive** (Backup page → Restore from Drive…):

1. Pick the backup. If it is encrypted you'll be asked for its passphrase.
2. Pagemark checks it is a healthy Pagemark database from this or an older version, and tells you how many books and reads it holds.
3. It keeps a **safety copy of your current library** (the newest 3 are retained inside the app), then replaces the library and asks you to close and reopen the app.

A damaged, foreign, or too-new file is rejected before anything changes.

## 13. Updates

Settings → **Updates** (or the dot on the Settings tab).

- Shows the version you have and whether a newer one exists, how many releases you're behind, the download size, and **what changed** in each.
- **Download & install** fetches the right file for your phone, checks its size and checksum, and opens Android's installer. The first time, Android asks you to allow installs from Pagemark. The update installs over the current app, so your library and settings are kept.
- **Check automatically** (on by default) does a quiet check at most once a day. The only thing sent is a request to GitHub for the release list. Switch it off any time.
- **Version history** shows every change in every release, offline. After an update, a **What's new** prompt links to it.

## 14. Trash

Deleting a book moves it to **Settings → Trash**. Restore it, or delete it forever; anything left is removed automatically after **30 days**. **Known limitation (0.4.1):** books deleted from the *locked* library also wait 30 days, but the Trash screen deliberately doesn't list locked titles, so they can't be restored from the app — delete a locked book only if you mean it.

## 15. Diagnostics

Settings → **Diagnostics** shows a small rolling event log (errors, background backup runs, lookup problems). It never contains book titles or your thoughts. **Copy** it when asking for help; **Clear** it when done.

## 16. Your privacy, in plain terms

- Your library is stored only in a database file inside the app, and Android's own cloud backup is switched off for it.
- Pagemark sends **book searches** to Open Library, **update checks** to GitHub, and — only if you set it up — **backups** to your Google Drive.
- Nothing is sent to the developer. There are no accounts, ads or analytics.
- Cover images are downloaded from Open Library and cached on the phone; locked covers use a separate cache that is cleared whenever the vault closes.

## 17. Troubleshooting

| Problem | What to do |
|---|---|
| Search says it couldn't reach Open Library | Check your connection and try again; Pagemark retries busy servers automatically. You can always **Add manually**. |
| A scanned barcode does nothing | Only ISBN book barcodes (starting 978 or 979) are accepted. Try the torch, or type the ISBN. |
| Covers are blank offline | Covers are downloaded on demand and cached; they appear once they've loaded online. |
| Forgot the PIN and lost the recovery code | The locked library can't be opened — that is the point of the lock. Removing the lock also needs the PIN, and the PIN is not part of backups, so a restore won't help. Keep the recovery code safe. |
| Drive sign-in fails | Check the Web client ID, and that the Android OAuth client matches your app's signing key (see DRIVE_SETUP). After changing the client ID, close and reopen Pagemark. |
| Backup shows FAILED | Open the backup page for the message; also see Settings → Diagnostics. |
| Update says no releases found | The project's releases page must be public. Check your connection. |
| "App not installed" during an update | Usually a different signing key (e.g. a debug build over a release build). Back up, uninstall, and install the release APK. |

## 18. Glossary

- **Read** — one read-through of a book (format, dates, rating, thoughts).
- **Shelf** — a free-form group of books; a book can be on many.
- **Locked library** — the PIN-protected second library.
- **Recovery code** — one-time code that resets a forgotten PIN.
- **ISBN** — the number on a book's barcode that identifies an edition.
