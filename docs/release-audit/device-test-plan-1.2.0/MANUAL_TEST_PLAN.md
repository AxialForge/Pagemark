# Pagemark 1.2.0 - Phone test plan (Samsung Galaxy S25 Ultra)

How to use this sheet: print it, work top to bottom, tick **P** (pass), **F** (fail) or **S** (skipped), and write anything odd in Notes. Scan the pages and send them back; the test numbers are enough, no screenshots needed. About 45 minutes.

This plan covers only what changed in 1.2.0: the update itself, the new look, the side menu, the theme picker, the Settings order and the Manga & comics page. Everything else was tested for 0.13.1 and 1.1.x.

## Part 0 - Before you start

- Pagemark 1.1.1 on the phone with your real library.
- Wi-Fi.
- One real manga or comic volume with a barcode (for 6.4), if you have one.
- **First:** Settings > Backup and restore > **Save a copy as a file**, so nothing can be lost.

---

## Part 1 - Update to 1.2.0

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 1.1 | Open Pagemark. Wait a few seconds, or go to Settings and tap **Updates**. | Pagemark offers version 1.2.0. | ☐P ☐F | |
| 1.2 | Tap **Download & install** and let Android install it. | Installs over 1.1.1 without uninstalling. | ☐P ☐F | |
| 1.3 | Open Pagemark again. | A bar says "Updated to Pagemark 1.2.0". **What's new** lists the menu, new look, theme pills and Manga & comics. | ☐P ☐F | |
| 1.4 | Look through your Library. | All your books, reads, ratings and quotes are still there. | ☐P ☐F | |
| 1.5 | Check your theme. | The same colour theme you had before is still chosen. | ☐P ☐F | |

## Part 2 - The new look

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 2.1 | Look at the Library title and any screen title. | Titles use a serif font (like a book). Other text uses a clean sans-serif. | ☐P ☐F | |
| 2.2 | Look at bold text (book titles in the list, Settings row names). | Bold text is clearly bold, not the same weight as normal text. | ☐P ☐F | |
| 2.3 | Look at the page background in a light theme. | Warm off-white page, white panels, thin light-grey lines. No blue-grey tint. | ☐P ☐F | |
| 2.4 | Look at **Add book**, the selected status chip and any switch that is on. | They use your theme's colour (blue for Harbor, rose for Rosewater and so on). | ☐P ☐F | |
| 2.5 | Open a book, then Edit. Tap into a text box. | Box has a thin border that turns your theme colour when you type in it. | ☐P ☐F | |
| 2.6 | Do something with an Undo (for example delete a book, then Undo). | The message bar at the bottom is dark charcoal with readable text. | ☐P ☐F | |
| 2.7 | Phone Settings > Display > Font size: largest. Look at Library and Settings, then set it back. | Nothing is cut off or overlapping. | ☐P ☐F | |

## Part 3 - Side menu

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 3.1 | On the Library, look at the bottom of the screen. | No bottom bar. A menu button (three lines) is at the top left. | ☐P ☐F | |
| 3.2 | Tap the menu button. | A menu slides in: charcoal header with the Pagemark logo, then Library, Manga & comics, Locked, Stats, Settings. The clock and battery icons at the top are white and readable. | ☐P ☐F | |
| 3.3 | Tap **Stats**, then press Back. | Stats opens; Back returns to the Library. | ☐P ☐F | |
| 3.4 | Press Back again on the Library. | The app closes (goes to the home screen). | ☐P ☐F | |
| 3.5 | Open the menu by swiping in from the left edge (if Samsung's back gesture allows). | The menu opens, or Samsung's Back gesture fires instead. Note which. | ☐P ☐F ☐S | |
| 3.6 | Menu > **Locked**. Unlock, then open the menu and tap **Library**. Go back to Locked. | Leaving Locked locks it again: it asks for the PIN or fingerprint again. | ☐P ☐F ☐S | |
| 3.7 | Settings > Privacy and lock: turn on **Hide the Locked tab**. Open the menu. Turn it off again afterwards. | **Locked** is not in the menu while hidden. Press and hold "Library" at the top still opens it. | ☐P ☐F ☐S | |
| 3.8 | Open a book, then press the arrow at the top left. | Book pages still show a back arrow (not the menu button). | ☐P ☐F | |

## Part 4 - Theme picker

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 4.1 | Settings > **Appearance**. | A **Match phone** switch, then four pills: Harbor, Rosewater, Sage, Lamplight. Each shows a light and a dark set of three dots. Your theme's pill has a coloured border. | ☐P ☐F | |
| 4.2 | Tap the word **Sage**. | The app turns Sage, staying light or dark as it was. | ☐P ☐F | |
| 4.3 | Tap Sage's **dark** dots. | The app turns dark green (Sage Night). A ring appears around the dark dots. | ☐P ☐F | |
| 4.4 | Tap Lamplight's **light** dots. | The app turns light amber (Lamplight Day). Text and buttons are easy to read. | ☐P ☐F | |
| 4.5 | Turn on **Match phone**. Switch the phone between light and dark mode (quick settings). | Pagemark follows the phone within a second. The ring disappears while Match phone is on. | ☐P ☐F | |
| 4.6 | Close Pagemark fully (swipe it away in recents) and open it again. | Your last choice is remembered. | ☐P ☐F | |
| 4.7 | Press and hold a theme's light or dark dots. | A small "Light" or "Dark" label appears. | ☐P ☐F ☐S | |

## Part 5 - Settings order

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 5.1 | Open Settings. | Order from the top: Appearance, Your library, Notifications, Backup and restore, Privacy and lock, Import and export, Widget and shortcuts; a line; How to use Pagemark, Our promise to you, Help and about; a line; the Pagemark name and version, then Updates. | ☐P ☐F | |
| 5.2 | Tap each row once and come back. | Every row opens its page. | ☐P ☐F | |
| 5.3 | Settings > How to use Pagemark. | There is a **Getting around** topic about the menu, and the manga topic mentions the Manga & comics page. | ☐P ☐F | |

## Part 6 - Manga & comics

| # | Steps | Expected result | Result | Notes |
|---|---|---|---|---|
| 6.1 | If you had manga, comics or light novels before: open the Library. | They are **not** in the Library any more. | ☐P ☐F ☐S | |
| 6.2 | Menu > **Manga & comics**. | Your manga, comics and light novels are all here, with the same search, chips and style button as the Library. | ☐P ☐F ☐S | |
| 6.3 | On Manga & comics tap **Add book**, search for a manga volume (for example "One Piece Vol 1") and pick it. | It is added. Open it: its kind says **Manga**. It shows on Manga & comics, not in the Library. | ☐P ☐F | |
| 6.4 | Manga & comics > Add book > **Scan many books**. Scan a real manga or comic barcode. | The book lands on Manga & comics, not in the Library. | ☐P ☐F ☐S | |
| 6.5 | Manga & comics > Add book > **Add by hand**, title "Test Series Vol. 2". Answer **Yes** when asked about the series. | Added as manga, in the series "Test Series", on Manga & comics. | ☐P ☐F | |
| 6.6 | Change the style (list icon) on Manga & comics to Cover wall. Go to the Library. | The Library keeps its own style; the two pages remember their styles separately. | ☐P ☐F | |
| 6.7 | Library > Add book: add a normal novel. | It shows in the Library, not on Manga & comics. | ☐P ☐F | |
| 6.8 | Menu > Stats. | Stats still counts your manga (the Series and volumes card) and your books. | ☐P ☐F | |
| 6.9 | Open a series (Library or Manga ⋮ > Series), change its kind to **Comic**. | It stays on Manga & comics. | ☐P ☐F ☐S | |
| 6.10 | Delete the test books from 6.3 and 6.5 (or keep them). | Deleted books go to Deleted books as before. | ☐P ☐F ☐S | |

## Part 7 - Summary

| Item | Answer |
|---|---|
| Number of F results | |
| Anything that looked wrong or ugly | |
| Anything confusing | |
| Overall: ready to keep 1.2.0? (yes / no) | |
