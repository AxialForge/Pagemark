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
