"""Builds docs/UI_LAYOUT.md and docs/Pagemark-UI-Layout.pdf (portrait) from the screen list below.

    python docs/_tools/build_ui_layout.py [path-to-raw-screenshots]

The raw PNGs come from an emulator run (see docs/_tools/screenshots/README.md); the default folder is the one used for the 0.8.0 pass.
Each shot is resized to 480 px wide and saved to docs/screenshots/ui/<name>.jpg.
"""
import re
import os
import pathlib
import subprocess
import sys

import markdown
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"
OUT_IMG = DOCS / "screenshots" / "ui"
RAW = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(r"C:\Users\JOSEPH~1\AppData\Local\Temp\claude\C--Users-Joseph-Costarella\0c11867f-7a9a-4d2c-a7c8-6c9a62be2e31\scratchpad\ui\shots")
VERSION = "0.9.1"

# (raw file, output name) - every image the document uses
SHOTS = {}


def S(raw, name=None):
    SHOTS[name or raw] = raw
    return name or raw


# ----------------------------------------------------------------------------------------------------------------------
# Content. Each section: (heading level, title, [paragraphs], [(shot, caption)], [bullets])
# ----------------------------------------------------------------------------------------------------------------------
SECTIONS = []


def sec(title, paras=(), shots=(), bullets=(), level=2, per_row=3):
    SECTIONS.append((level, title, list(paras), [(S(r, n), c) for r, n, c in shots], list(bullets), per_row))


# 1 -----------------------------------------------------------------------------------------------------------------------
sec("1. The whole app at a glance", [
    "Pagemark is a four-tab app. A bar at the bottom switches between **Library**, **Locked**, **Stats** and **Settings**; everything else opens on top of those tabs with a Back arrow in its top-left corner. "
    "The look is Material 3 with six colour themes (three light, three dark) and five ways to show the library.",
], [
    ("01_library", "library", "Library tab (Classic style, Harbor theme)"),
    ("27_stats_top", "stats", "Stats tab"),
    ("30_settings_1", "settings", "Settings tab"),
], [
    "**Top bar:** the screen title on the left, actions on the right (only the Library has actions).",
    "**Body:** a scrolling list or page. Lists never need horizontal scrolling except the filter-chip row.",
    "**Floating button (bottom right):** *Add book* on the Library, *Log a read* on a book page. It sits above the bottom bar.",
    "**Bottom bar:** four tabs with an icon and a label; the current tab has a coloured pill behind its icon.",
])

sec("2. Navigation map", [
    "Every screen and how you reach it. Indented lines open from the line above.",
], [], [
    "**Library tab**: search box, status chips, format chips, shelf chips, *Currently reading* strip, book list",
    "   Library style icon: **Library style** sheet",
    "   Sort icon: **Sort** menu",
    "   Three-dot menu: **Series**, **Manage shelves**",
    "   Long-press a book: **selection mode** (select all, mark finished, add to shelf, move to locked, move to Trash)",
    "   **Add book** button: Open Library search, then results, then the book page. The scan icon opens **Scan a book barcode**; *Add manually* opens a small form",
    "   Tap a book: **Book page**",
    "      Pencil icon: **Edit book**",
    "      Three-dot menu: Move to locked library, Save cover on this phone, Choose cover from gallery, Move to Trash",
    "      **+ Shelf**: shelf picker  |  **Add quote**: quote sheet  |  **Update progress**: page dialog",
    "      **Log a read**: **Log a read** form  |  a read in the log: **Edit read**  |  author link: **Author page**",
    "**Locked tab**: first time *Set a PIN* (twice) then a recovery code; afterwards the PIN gate, then **Locked library**",
    "   The Locked library is the Library screen plus **Trash** in its three-dot menu; *Forgot PIN?* resets with the recovery code",
    "**Stats tab**: goal ring (*Set goal* / *Change goal* dialog), books per month, ratings, totals, top genres, top authors",
    "**Settings tab**: Updates, About, Appearance, Notifications, Widget and shortcuts, Import, Export, Backup and restore, Your library, Privacy",
    "   **Updates**: Version history",
    "   **Info icon**: About",
    "   **Import**, **Backup and restore**, **Restore points**, **Covers**, **Trash**, **Diagnostics**",
    "**Outside the app**: home-screen **widget**, long-press **shortcuts** (Add book, Reading now), the system **Share** sheet (Share, then Pagemark), the daily **reminder** notification",
])

# 3 -----------------------------------------------------------------------------------------------------------------------
sec("3. Library tab", [
    "Your main library. Locked books never appear here.",
], [
    ("01_library", "library", "Top to bottom: title and actions, search, chips, Currently reading, list"),
    ("70_first_run_empty", "library-empty", "First run: an empty shelf and the Add book button"),
    ("05_search", "library-search", "Searching: text matches title, author, notes, thoughts and quotes"),
], [
    "**Top bar (left to right):** *Library* title (long-press it to open the Locked library when the Locked tab is hidden), **Library style** icon, **three-dot menu**, **Sort** icon.",
    "**Search box:** one line under the bar; typing filters the list live; X clears it.",
    "**Status chips:** All · Want to read · Reading · Finished · Did not finish (scroll sideways). One is always selected.",
    "**Format chips:** Any format · Print · E-book · Audiobook, then your **shelf chips** (one per shelf, with a small shelf icon). Tap a chip to filter; tap again to clear.",
    "**Currently reading:** a strip of covers with a progress bar under each, shown above the list on the *All* view.",
    "**Book rows:** cover, title, author, series and number, status, format, a progress bar while reading and star rating when rated.",
    "**Add book** button: floating, bottom right.",
])

sec("3.1 Menus and filters", [], [
    ("02_library_style_picker", "style-picker", "Library style sheet"),
    ("03_library_more_menu", "more-menu", "three-dot menu"),
    ("04_sort_menu", "sort-menu", "Sort menu"),
    ("06_filter_reading", "filter-reading", "Status chip: Reading"),
    ("63_filter_chips_scrolled_2", "filter-shelves", "Chip row scrolled: shelves"),
    ("64_shelf_filter_active", "filter-shelf-active", "A shelf chip selected"),
], [
    "**Library style sheet:** Classic, Cover wall, Bookshelf, Spines, Compact (one choice, ticked) and a switch **Group by my shelves** that applies to Bookshelf and Spines.",
    "**three-dot menu:** *Series* (every series with progress) and *Manage shelves* (create, rename, delete). The Locked library's three-dot menu also has *Trash*.",
    "**Sort menu:** Recently added, Title, Author, Rating. The choice is remembered per library.",
])

sec("3.2 Library styles", [
    "The same books, five ways. The style is remembered separately for the main and the locked library.",
], [
    ("01_library", "style-classic", "Classic"),
    ("07_style_cover_wall", "style-cover-wall", "Cover wall"),
    ("08_style_bookshelf", "style-bookshelf", "Bookshelf"),
    ("09_style_spines", "style-spines", "Spines"),
    ("10_style_compact", "style-compact", "Compact"),
    ("11_style_bookshelf_grouped", "style-grouped", "Bookshelf grouped by shelf"),
], [
    "**Classic:** cover, title, status and rating on every row.",
    "**Cover wall:** a grid of covers with ratings and progress.",
    "**Bookshelf:** covers standing on wooden shelves.",
    "**Spines:** cloth-bound spines sized by page count.",
    "**Compact:** one line per book, the most books per screen.",
    "**Group by my shelves:** Bookshelf and Spines show one wooden shelf per shelf you made, with a brass nameplate and count.",
])

sec("3.3 Selecting many books", [], [
    ("23_multi_select", "multi-select", "Selection mode"),
], [
    "Long-press a book to start. The top bar becomes **X n selected** with **Select all**, **Mark finished today**, **Add to shelf**, **Move to locked/main library** and **Move to Trash**.",
    "Every bulk action shows an **Undo** bar afterwards. Tap a book to add or remove it from the selection; X ends selection mode.",
])

# 4 -----------------------------------------------------------------------------------------------------------------------
sec("4. Adding a book", [
    "**Add book** opens a search against Open Library (free, no account). Type a title, author or ISBN, press the magnifier or Enter. "
    "A valid ISBN is looked up directly. Nothing is saved until you tap a result.",
], [
    ("25_add_book", "add-empty", "Add a book"),
    ("26_add_book_results", "add-results", "Results for \"dune\""),
    ("49_scan_permission", "scan-permission", "Camera permission (first scan)"),
    ("49_scan", "scan", "Scan a book barcode"),
], [
    "**Top bar:** Back, title, **scan** icon (opens the barcode scanner).",
    "**Search box** with a magnifier button; **Add manually** row below (title and optional author in a small dialog) for books Open Library does not know.",
    "**Results:** cover, title, author · year. Study guides and summaries are hidden behind *show more*. Tap one to add it and open its page.",
    "**Duplicates:** if the book is already in this library you are asked *Cancel / Open it / Add anyway*.",
    "**Scanner:** point at the barcode on the back cover; a torch button is at the top right. Only the camera is used, nothing is recorded.",
])

sec("4.1 Share to Pagemark", [
    "From any app (browser, Goodreads, a message) choose **Share → Pagemark**. An ISBN anywhere in the text, or the title in a Goodreads or Open Library link, "
    "opens *Add a book* with the search already filled in and run.",
], [
    ("e_share", "share-isbn", "Shared ISBN 9780441172719"),
    ("e_warm_share", "share-goodreads", "Shared Goodreads link (The Hobbit)"),
], [
    "Shared text only fills the search box; it never saves anything and is cut to 300 characters.",
])

# 5 -----------------------------------------------------------------------------------------------------------------------
sec("5. Book page", [
    "Everything about one book. It scrolls if the reading log is long.",
], [
    ("12_book_page", "book-page", "Book page"),
    ("13_book_menu", "book-menu", "three-dot menu"),
    ("16_shelf_picker", "shelf-picker", "Shelf picker"),
], [
    "**Top bar:** Back, the title, **pencil Edit**, three-dot menu (*Move to locked library*, *Save cover on this phone*, *Choose cover from gallery*, *Move to Trash*).",
    "**Header:** cover on the left; title, author (a link to the author page), series and number, genre, pages, ISBN on the right.",
    "**Shelf chips** and **+ Shelf** (opens the shelf picker: tick shelves or create one).",
    "**Description** (from Open Library or your own).",
    "**Quotes:** your saved lines with their pages, and **Add quote**.",
    "**Reading log:** one card per read-through (format, status, dates, stars, thoughts). While reading, a **progress card** shows the page, percent, pages per day and days left, with **Update progress**.",
    "**Log a read** button, bottom right.",
])

sec("5.1 Dialogs and sheets on the book page", [], [
    ("14_update_progress", "update-progress", "Update progress"),
    ("15_add_quote", "add-quote", "New quote"),
    ("50_move_to_trash_dialog", "trash-dialog", "Move to Trash?"),
], [
    "**Update progress:** a slider and number pad for the current page (or percent for audiobooks).",
    "**New quote:** the passage, an optional page and an optional \"why it stuck\" note.",
    "**Move to Trash** asks first; the book waits in Trash for 30 days.",
])

sec("5.2 Logging and editing", [], [
    ("17_log_read", "log-read", "Log a read"),
    ("19_edit_book", "edit-book", "Edit book (top)"),
    ("19b_edit_book_lower", "edit-book-lower", "Edit book (lower)"),
], [
    "**Log a read:** Print / E-book / Audiobook switch, status (Want to read, Reading, Finished, Did not finish), current page, **Started** and **Finished** dates with *Started today / yesterday* shortcuts, a five-star rating (half stars), time spent, and your thoughts. **Save** is at the top right.",
    "**Edit read** is the same form for an existing read, with a delete (bin) button.",
    "**Edit book:** title, author, series and number, books in the series, genre, tags, publisher, ISBN, cover URL, year, pages, description and private notes. Leaving with unsaved edits asks first.",
])

sec("5.3 Authors, series and shelves", [], [
    ("18_author_page", "author", "Author page"),
    ("21_series_page", "series", "Series"),
    ("22_shelves_page", "shelves", "Manage shelves"),
], [
    "**Author page:** counts (books, read, average rating) and that author's books.",
    "**Series:** every series with \"x of y read\" and the next book, expandable.",
    "**Manage shelves:** your shelves with rename (pencil) and delete (bin); the **+** button adds one. Deleting a shelf never deletes books.",
])

# 6 -----------------------------------------------------------------------------------------------------------------------
sec("6. Stats tab", [
    "Numbers for the main library only (locked books are never counted).",
], [
    ("27_stats_top", "stats-1", "Goal and months"),
    ("29b_stats_with_goal", "stats-goal", "With a yearly goal"),
    ("28_stats_bottom", "stats-2", "Totals, genres, authors"),
    ("29_stats_set_goal", "stats-goal-dialog", "Set goal dialog"),
    ("61_theme_midnight_stats", "stats-dark", "Stats in the Midnight Ink theme"),
    ("71_stats_empty", "stats-empty", "Before any book is finished"),
], [
    "**Reading goal:** a ring (finished / goal), books still to go, and \"at this pace\" projection; *Set goal* / *Change goal* opens a number dialog.",
    "**Finished per month:** twelve bars for the current year.",
    "**Your ratings:** how many books at each half-star rating, plus the average.",
    "**Totals:** books tracked, finished, pages, logged time, average days to finish, finished by format.",
    "**Top genres** and **Top authors:** horizontal bars. With *Heat level and content notes* switched on there is a Heat chart too.",
])

# 7 -----------------------------------------------------------------------------------------------------------------------
sec("7. Locked tab", [
    "A private library behind a PIN or your fingerprint. Its books are hidden from the main library, Stats, exports and search, and screenshots are blocked while it is open.",
], [
    ("72_locked_empty_gate", "locked-setup", "First visit"),
    ("42_set_pin", "set-pin", "New PIN"),
    ("43_confirm_pin", "confirm-pin", "Re-enter the PIN"),
    ("44_recovery_code", "recovery-code", "Recovery code (shown once)"),
    ("46_pin_gate", "pin-gate", "PIN gate"),
    ("47_wrong_pin", "wrong-pin", "Wrong PIN"),
    ("48_forgot_pin", "forgot-pin", "Reset with recovery code"),
    ("45_vault_state", "vault", "Unlocked Locked library"),
    ("45_vault_more_menu", "vault-menu", "Locked library three-dot menu"),
], [
    "**First visit:** *Set a PIN* (4–12 digits, entered twice) or, if the phone has a screen lock, *Use fingerprint / device lock only*.",
    "**Recovery code:** shown once after setting a PIN. **Copy** puts it on the clipboard and clears it after a minute.",
    "**PIN gate:** PIN field, **Unlock**, **Use fingerprint / device lock** (when available), **Forgot PIN?**. Five wrong tries lock it for 30 seconds, doubling up to an hour.",
    "**Locked library:** the same screen as the Library (same chips, styles and search) with the title *Locked library*. Its three-dot menu adds **Trash** (kept separate from the main Trash).",
    "**Leaving locks it again:** switching tabs or leaving the app closes locked screens and wipes locked covers, after the delay you chose in Settings.",
    "If Android ever clears Pagemark's saved lock, the gate says so and asks you to confirm with the phone's own lock before setting a new PIN.",
])

# 8 -----------------------------------------------------------------------------------------------------------------------
sec("8. Settings tab", [
    "A short list of eight plain-language pages. At the top: **Updates** (GitHub build only) and **How to use Pagemark**. Each row has an icon, a title and one plain sentence.",
], [
    ("95_settings_home2", "settings-home", "Settings"),
    ("96_notifications", "settings-notifications", "Notifications"),
    ("C1_widget", "settings-widget", "Widget and shortcuts"),
    ("C2_privacy", "settings-privacy", "Privacy and lock"),
    ("A1_backup_page", "settings-backup", "Backup and restore"),
    ("C3_importexport", "settings-importexport", "Import and export"),
    ("C4_library", "settings-library", "Your library"),
    ("C5_help", "settings-help", "Help and about"),
], [
    "**Appearance:** six colour themes, each with a colour dot and Light/Dark; a tick marks the current one.",
    "**Notifications:** a red box with a **Turn on** button when Android has notifications off for Pagemark; the **Daily reading reminder** (switch and time) and **Remind me to back up** with **How often**.",
    "**Widget and shortcuts:** whether the widget shows book titles, how to add it, and the two icon shortcuts.",
    "**Privacy and lock:** Lock now, Lock when I leave Pagemark (delay), Ask for my PIN to open Pagemark, Hide the Locked tab, Change my PIN, Turn off the lock.",
    "**Backup and restore:** a status card (when you last saved a backup, red if overdue), Save a copy as a file, Save my list as a spreadsheet, **Save backups to a folder automatically**, Restore from a file, Go back to an earlier copy, and the backup reminder.",
    "**Import and export:** bring in books from another app; save your list as a spreadsheet or a JSON file (locked books are never included).",
    "**Your library:** Deleted books, Cover pictures, **Rate books in more detail**, Heat level and content notes.",
    "**Help and about:** How to use Pagemark, What's new, Problem report.",
])

sec("8.1 Backups to a folder", [
    "Pick a folder once with Android's own file picker. It can be on the phone, a USB drive, or inside Google Drive, OneDrive or Dropbox (Android then copies it to the cloud). Pagemark saves a fresh backup there when the app opens and one is due, and keeps the newest 5.",
], [
    ("A2_picker", "folder-picker", "Android's folder picker"),
    ("B4_password_question", "folder-password", "Protect with a password?"),
    ("B7", "folder-backup-on", "Saving to a folder"),
], [
    "**Back up now**, **Change folder** and **Turn off** are under the folder name; **How often** is Every day, week, 2 weeks or month.",
    "With a password the files are encrypted (`.pgbak`); without one they are plain copies.",
])

sec("8.2 Other pages", [], [
    ("32_updates", "updates", "Updates"),
    ("38_changelog", "changelog", "What's new"),
    ("33_about", "about", "About"),
    ("35_restore_points", "restore-points", "Go back to an earlier copy"),
    ("36_import", "import", "Bring in books"),
    ("39_covers", "covers", "Cover pictures"),
    ("40_trash", "trash", "Deleted books"),
    ("37_diagnostics", "diagnostics", "Problem report"),
], [
    "**Updates:** installed version, whether a newer one exists, *Check again*, *Check automatically*, **What's new**.",
    "**What's new:** every change in every version, offline.",
    "**Go back to an earlier copy:** the copies Pagemark kept before each restore and import; tap one to restore it.",
    "**Bring in books:** where to get the file for each source, **Choose a file**, a preview, then **Undo import** afterwards.",
    "**Cover pictures:** how many covers are saved on the phone, **Save covers on this phone**, **Remove unused cover files**.",
    "**Deleted books:** restore or delete forever; removed automatically after 30 days.",
    "**Problem report:** a small log with **Copy**, **Clear**; it holds no book titles.",
])

sec("8.3 Notifications, widget and shortcuts", [], [
    ("31b_reminder_permission", "reminder-permission", "Notification permission"),
    ("31d_time_picker", "reminder-time", "Choosing the reminder time"),
    ("66_widget_tap", "widget-picker", "Widget picker (Add)"),
    ("66_widget_with_titles", "widget-titles", "Widget with titles"),
    ("66_widget_on_home", "widget-counts", "Widget, counts only (whole-app lock on)"),
    ("68_app_shortcuts", "shortcuts", "Long-press shortcuts"),
], [
    "**Reminders:** off for reading by default; the text never names a book. The backup reminder counts from the last saved backup.",
    "**Widget (3x2):** up to three books you are reading and your yearly goal; never includes locked books; counts only with the whole-app lock on.",
    "**Shortcuts:** long-press the app icon for *Add book* and *Reading now*.",
])

sec("8.4 The built-in guide", [
    "**How to use Pagemark** has short topics in plain words with a search box (\"What do you need help with?\"). It works without internet and is kept in step with the app by a test.",
], [
    ("91_guide", "guide", "Guide topics"),
    ("92_guide_open", "guide-open", "A topic opened"),
], [])

sec("8.5 Rating in more detail", [
    "Settings, Your library, **Rate books in more detail** adds optional stars to every read, quotes can have stars, and the Series page shows an average.",
], [
    ("99c_rated", "detail-editor", "Edit read with detailed stars"),
    ("99d_book_after", "detail-card", "Shown on the book page"),
    ("99e_stats", "detail-stats", "Your detailed ratings in Stats"),
    ("99f_quote_editor", "quote-stars", "Quote with stars"),
    ("99g_series", "series-average", "Series average"),
], [])

# 9 -----------------------------------------------------------------------------------------------------------------------
sec("9. Whole-app lock", [
    "An optional second lock over everything. With it on, Pagemark asks for the PIN or fingerprint every time it opens and when you come back after the delay.",
], [
    ("62_app_lock_overlay", "app-lock", "Pagemark is locked"),
], [
    "Nothing can be opened over the lock; Back leaves the app instead of the lock. Screenshots and the recents thumbnail are blocked while it shows.",
])

sec("10. Colour themes", [
    "Pick one in Settings. Harbor is the default.",
], [
    ("01_library", "theme-harbor", "Harbor (light)"),
    ("60_theme_midnight_ink", "theme-midnight", "Midnight Ink (dark)"),
    ("60_theme_rosewater", "theme-rosewater", "Rosewater (light)"),
    ("60_theme_plum_velvet", "theme-plum", "Plum Velvet (dark)"),
    ("60_theme_sage", "theme-sage", "Sage (light)"),
    ("60_theme_lamplight", "theme-lamplight", "Lamplight (dark)"),
], [])

sec("11. What these screenshots do not show", [
    "These were taken on an Android emulator with sample data. Not captured (they involve other apps, a signed-in Google account or hardware):",
], [], [
    "The Android share sheet for exports, the backup password dialogs.",
    "The restore confirmation (\"Replace your library?\"), the import preview and finished screens, and the update-available screen (see the older manual screenshots in `docs/screenshots/`).",
    "Device-lock (fingerprint) mode, the Heat level and content fields when switched on, and the Locked tab when hidden.",
    "The daily reminder notification itself, and anything in landscape, on tablets or on iOS (not built).",
])


# ----------------------------------------------------------------------------------------------------------------------
def build():
    OUT_IMG.mkdir(parents=True, exist_ok=True)
    for name, raw in SHOTS.items():
        src = RAW / f"{raw}.png"
        if not src.exists():
            alt = ROOT / "docs" / "screenshots" / "ui" / f"{name}.jpg"
            if alt.exists():
                continue
            raise SystemExit(f"missing screenshot {src}")
        im = Image.open(src).convert("RGB")
        w = 480
        im = im.resize((w, round(im.height * w / im.width)), Image.LANCZOS)
        im.save(OUT_IMG / f"{name}.jpg", quality=80, optimize=True)

    md = [f"# Pagemark - UI layout and screen guide\n\n**Version {VERSION}** - every screen, what is on it and how you get there.\n"]
    for level, title, paras, shots, bullets, per_row in SECTIONS:
        md.append(f"\n{'#' * level} {title}\n")
        for p in paras:
            md.append(p + "\n")
        if shots:
            rows = [shots[i:i + per_row] for i in range(0, len(shots), per_row)]
            for row in rows:
                figs = "".join(f'<figure><img src="screenshots/ui/{n}.jpg" alt="{c}"><figcaption>{c}</figcaption></figure>' for n, c in row)
                md.append(f'\n<div class="shots">{figs}</div>\n')
        if bullets:
            md.append("")
            for b in bullets:
                md.append(("- " + b) if not b.startswith("   ") else (" " * ((len(b) - len(b.lstrip())) // 3 * 4) + "- " + b.strip()))
            md.append("")
    text = "\n".join(md)
    (DOCS / "UI_LAYOUT.md").write_text(text, encoding="utf-8")

    css = """
@page{size:Letter portrait;margin:16mm 14mm}
body{font-family:'Segoe UI',Arial,sans-serif;font-size:10pt;line-height:1.4;color:#1b1b1f}
h1{font-size:20pt;border-bottom:2px solid #2F5D8A;padding-bottom:4px}
h2{font-size:14pt;color:#2F5D8A;margin-top:22px;break-after:avoid}
h3{font-size:11.5pt;margin:16px 0 4px;break-after:avoid}
ul{padding-left:18px;margin:4px 0}li{margin:2px 0}
code{background:#eef1f5;padding:0 3px;border-radius:3px;font-size:9pt}
.shots{display:flex;gap:10px;justify-content:center;margin:10px 0;break-inside:avoid}
.shots figure{margin:0;flex:1 1 0;max-width:32%;text-align:center}
.shots img{width:100%;border:1px solid #cfd5dd;border-radius:6px}
figcaption{font-size:8pt;color:#555;margin-top:2px}
"""
    html = markdown.markdown(text, extensions=["tables", "md_in_html"])
    page = DOCS / "_ui_layout.html"
    page.write_text(f"<html><head><meta charset=utf-8><base href='{DOCS.as_uri()}/'><style>{css}</style></head><body>{html}</body></html>", encoding="utf-8")
    edge = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if not os.path.exists(edge):
        edge = r"C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    pdf = DOCS / "Pagemark-UI-Layout.pdf"
    subprocess.run([edge, "--headless", "--disable-gpu", "--no-pdf-header-footer", f"--print-to-pdf={pdf}", page.as_uri()], check=True)
    page.unlink()
    # house rule: every generated PDF also goes to <project>/Documentation
    import shutil
    out = DOCS.parent / "Documentation"
    out.mkdir(exist_ok=True)
    ver = re.search(r"^version:\s*([0-9.]+)", (DOCS.parent / "pubspec.yaml").read_text(encoding="utf-8"), re.M).group(1)
    shutil.copyfile(pdf, out / f"Pagemark-UI-Layout Rev {ver}.pdf")
    print(len(SHOTS), "images;", pdf.stat().st_size // 1024, "KB pdf")


if __name__ == "__main__":
    build()
