# Manual test plan - what a human must still do (on a real phone)

Ordered by risk. Nothing here was run by the audit.

- [ ] **Restore twice, recover the first state** (PGM-100). Restore a backup, restore a second one within a minute, look for any way back. Pass: the original library is recoverable.
- [ ] **FLAG_SECURE and recents** (PGM-204). Open the hidden Locked tab, press Home, open recents. Pass: the thumbnail is blank.
- [ ] **Fingerprint unlock** on a real device: unlock, cancel, wrong finger, fingerprint added after setup.
- [ ] **Drive sign-in and scheduled backup**: sign in, run now, wait one scheduled cycle, restore from the Drive file. Pass: file appears, size matches, restore works.
- [ ] **Passphrase change** (PGM-102): change the backup passphrase, run backup, check a new file appears and decrypts.
- [ ] **Updater install**: from 0.6.0 install 0.7.0 through Settings > Updates. Pass: installs over the top, data intact, same signing certificate.
- [ ] **Battery managers / Doze**: on a phone with an aggressive battery manager (Samsung, Xiaomi), confirm scheduled backups still run after two days.
- [ ] **Notifications**: deny and re-grant the permission; backup-failure notification shows.
- [ ] **Storage full**: fill storage, try an export and a restore. Pass: clear error, library untouched.
- [ ] **Shared exports left behind** (PGM-203): export CSV, share it, inspect `cache/share_plus` (needs a debug build or adb on a rooted device).
- [ ] **Landscape and tablet/foldable** (PGM-004, 254): rotate every main screen; check split-screen.
- [ ] **TalkBack**: add a book, rate it, open Settings with TalkBack on; icon buttons have names.
- [ ] **Edge-to-edge and predictive back** (PGM-253) on Android 14/15/16.
- [ ] **Large font / display size** on a phone (PGM-001): font 2.0 and largest display size on Library and Book pages.
- [ ] **Offline use**: airplane mode, add a book by hand, open covers, run lookup. Pass: no crash, clear message.
- [ ] **Real timezone change** (PGM-128): finish a book, change timezone, check the date.
- [ ] **iOS**: not built yet; everything above is Android only.

## Added for the 1.0.0 gate (0.13.0)

- [ ] **Reading timer**: start on a book, lock the phone for 2 minutes, stop, enter a page. Pass: the minutes and page are saved and the day lights up in Stats. Then start a timer and finish the book: pass only once PGM-320 is fixed (other books can still stop the timer).
- [ ] **Share picture and PDF report**: Stats, Year in books, Share picture and Report (PDF) into Messages or Drive. Pass: the picture and PDF open, show no locked book.
- [ ] **Lending reminder**: lend a book with a reminder for the next day (set the phone clock forward). Pass: a notification at 10:00 that names neither book nor person; Got it back cancels it.
- [ ] **Scan many books**: scan 5 real books including one you own. Pass: one click each, duplicates skipped, a not-found one listed. Try in the Locked library: the internet warning appears once.
- [ ] **Refresh details and edition picker** on a book you edited by hand. Pass: your edits are not ticked; choosing an edition changes only the cover, publisher, year, pages and ISBN.
- [ ] **Google Books switch**: turn it off, search; turn on, search. Pass: results differ only in coverage; nothing breaks offline.
- [ ] **Folder backup** to a Google Drive or OneDrive folder through Android's picker; wait one scheduled run; restore on a second phone.
- [ ] **Tablet and landscape on a real device or foldable**: rail, two panes, rotate with a book open, split-screen.
- [ ] **TalkBack** through: add a book, rate with swipe, calendar days, Read next reorder, Lend.
- [ ] **Updater**: install 0.13.0 over 0.12.0 from Settings > Updates. Pass: data intact, same signature.
