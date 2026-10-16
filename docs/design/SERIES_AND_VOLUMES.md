# Pagemark 1.1 proposal: Series and volumes (manga, comics, light novels)

**Status:** proposal for the owner's decision. Nothing in this document is built. Written 2026-10-16 against Pagemark 0.13.3 (schema 6).

## 1. Summary and recommendation

Manga collectors need three things a one-off book tracker does not give them: a whole series at a glance, which **volumes** they own and have read, and an easy way to **add the next volume**. Pagemark already holds most of the data for this, because a series is a name and a number on each book. What is missing is the **view** (a volume grid), the **grouping** (a library of 300 volumes must collapse into series), the **speed** (adding and scanning volumes), and one small piece of data (is a series ongoing or complete).

**Recommendation: build it as Pagemark 1.1.0, in the same app, after 1.0.0, in two steps.**

| Step | Release | Contents | New internet host |
|---|---|---|---|
| 1 | 1.1.0 "Series and volumes" | The kind field, series info table, volume parser, series page with the volume grid, group-by-series library, next-volume actions, volume chip and neighbours on the book page, Series stats | none |
| 2 | 1.2.0 (optional) | Series lookup (total volumes, ongoing or complete, cover) from one extra source, behind a switch | one (AniList suggested) |

Step 1 needs no new source, so the privacy promise, the Play Data safety answers and the allowed-hosts test stay exactly as they are.

## 2. What exists today (checked in the code)

- A series is two fields on each book: `series` (text) and `seriesNumber` (a number, decimals allowed), plus `seriesTotal` (an integer typed by the user, stored on every book of the series).
- `SeriesPage` (`lib/features.dart`) already groups books by lower-cased series name, sorts by number, shows "N of TOTAL read", the volumes "not in your library", the next unread book and the average star rating.
- The Library shows "Series #N" on each row, the book page shows "Series: X #N of TOTAL", search matches the series name, and the Read next suggestions already say "Next in <series>".
- Import (Goodreads, StoryGraph, Pagemark files) and CSV/JSON export carry `series`, `series_number` and `series_total`.
- Scan many books and the Google Books merge fill the series field only when a source supplies one, which is rare for manga.

So the grid can be computed from what is stored today. The cost is in the screens, the parser and the migration, not in new data.

## 3. What manga needs that is missing

| Need | Today | Gap |
|---|---|---|
| See a whole series quickly | Series page: a list of tiles | No grid of volume numbers 1..N with states |
| Library of hundreds of volumes | One row per volume | No grouping; the Library becomes unusable at about 100 volumes of one series |
| Add volume N quickly | Add book, search, tap | No "Add next volume" with series, number, author and cover carried over |
| Scan a shelf of volumes | Bulk scan works by ISBN | Volume number and series are not detected, so every scanned volume needs editing |
| Know if a series is finished | Not stored | No ongoing or complete flag; "20 volumes" for an ongoing series is a guess |
| Owned versus read | Library means tracked | No notion of owned; a Want to read book is not necessarily bought |
| Missing volumes to buy | "N not in your library" count | No list of which numbers are missing, no shareable shopping list |
| Tell manga from other books | Genre text | No reliable kind to filter, group or count by |

## 4. Options

| | A. Derive everything | B. Series info table (recommended) | C. Full volume entity |
|---|---|---|---|
| Idea | No schema change; all views computed from book rows | One new small table for per-series facts, plus one field on books | Volumes as their own table, separate from books |
| Schema | none | schema 7: `books.kind`, `books.owned`, table `series_info` | schema 7 with a large migration |
| Ongoing/complete, per-series total | not possible (stored per book) | yes, one place | yes |
| Risk to existing data | none | low (additive, guarded migration) | high (moves reads, shelves, quotes) |
| Effort | smallest | moderate | very large |
| Verdict | too limited: cannot say a series is ongoing | **best balance** | over-engineered; a volume is a book |

## 5. Data model changes (option B, schema 7)

- `books.kind` text, default empty. Values: empty (a plain book), `manga`, `comic`, `lightnovel`. A filter chip, grouping default and Stats split use it. Empty keeps every existing book exactly as it is.
- `books.owned` boolean, default true. False means "on my list but I do not own it" (a wishlist volume). Existing rows become owned, which matches how most people use the app; Want to read books keep their status, they are just also owned.
- New table `series_info`: `id`, `nameKey` (normalised), `name` (as typed), `locked` (so a locked library's series names never appear in the main one), `total` (integer or null), `status` (`''`, `ongoing`, `complete`), `kind`, `notes`. Unique on (`nameKey`, `locked`).
- Migration 6 to 7: add the two columns, create the table, back-fill one `series_info` row per distinct series and library from existing books, taking the largest `seriesTotal` seen. `books.seriesTotal` stays and is still read as a fallback, so old backups, CSV files and exports keep working. The migration is guarded like the earlier ones (`if (from >= N)`), and the audit's migration script is extended to schema 7.
- Backup and restore: older backups upgrade on restore; a newer backup is refused as today. CSV and JSON export gain `kind`, `owned` and `series_status` columns; import reads them when present and ignores them when not.

## 6. The volume parser

A pure function `parseVolume(title)` returning a series name, a number and a confidence. It runs when a book is added by search, by scan or by hand, and only **suggests**: the bulk scan list shows "Is this volume 3 of Dragon Ball Z?" with Yes and Not a series; it never silently renames anything.

| Title | Series | Number |
|---|---|---|
| One Piece, Vol. 12 | One Piece | 12 |
| Berserk Volume 2 | Berserk | 2 |
| Naruto, Vol. 05 | Naruto | 5 |
| Fullmetal Alchemist (3-in-1 Edition), Vol. 4 | Fullmetal Alchemist | 4 (edition kept in a note) |
| Attack on Titan #7 | Attack on Titan | 7 |
| Berserk Deluxe Edition Volume 2 | Berserk | 2 (deluxe edition kept as a note) |
| Dragon Ball Z Omnibus 3 | Dragon Ball Z | 3 (asks first) |
| Vol. 5 only, or a plain book title | none | none |

Rules to get right and to test heavily: leading zeros, "Vol", "Volume", "#", "Book", Roman numerals, ranges such as "1-3" (omnibus: store the first number and mark it), no false positives on titles like "Fahrenheit 451" or "Catch-22", and Unicode (Japanese volume marks are not parsed in 1.1).

## 7. Screen by screen

1. **Library.** New switch in the style sheet: **Group by series**. A series becomes one row with a small stack of covers, the volume count and how many are read; tap to open the series page. Books without a series stay as rows. Works in every library style; search still finds single volumes. Default: on when more than a few volumes share a series.
2. **Series page** (replaces today's list). Header: cover stack, "12 of 20 owned · 9 read", **ongoing** or **complete** (tap to change), next volume to buy. A grid of numbers 1..N with four states: read (filled), owned and unread (outlined), wanted (dashed), missing (grey). Tap a number: open that book, or **Add volume N** when missing. Buttons: **Add next volume** and **Missing list** (shares "Berserk: missing 3, 4, 7" as text). Series total editable in one place.
3. **Book page.** A chip "Volume 10 of 20" and **previous / next volume** buttons. The Edit form keeps series and number, gains **Kind** and **I own this** and moves "Books in the series" to the series page.
4. **Add book and Scan many books.** After a lookup the parser suggests series and number; Scan many shows the confirm question for uncertain guesses; **Add next volume** (from the series page or book page) creates the volume with series, kind and author copied and the title "Series, Vol. N", then offers to scan or search for its cover.
5. **Stats.** Volumes read, series completed (all volumes read and series marked complete), and a Books / Manga / Comics split. The Year in books card says "volumes" when the year is mostly volumes.
6. **Settings.** Nothing new in 1.1.0 except guide text. In 1.2.0 a switch **Also look up series online** next to Also search Google Books.
7. **Tablet.** The series page uses the two-pane layout (grid left, selected volume right) at 840 dp and up.
8. **Accessibility.** Each grid cell is a labelled button ("Volume 7, owned, read"), at least 48 dp, wrapping cleanly at 200% text; the grid announces its legend once.

## 8. Metadata source for step 2 (not needed for step 1)

| Source | Key needed | Gives series totals and status | Notes |
|---|---|---|---|
| Google Books (already used) | no | no | Good per-volume covers and ISBNs; no series object |
| AniList (GraphQL) | no | yes (volumes, chapters, status, cover, staff) | Free for non-commercial use; one POST per lookup; `volumes` is empty for ongoing series |
| MangaDex | no | partly | Community catalogue, fan-oriented; larger responses |
| Jikan (MyAnimeList unofficial) | no | yes | Rate limited, unofficial; uptime varies |

Suggestion: AniList, behind a switch that is on by default but clearly named. Adding any host means: a line on the promise page and in `promiseHosts` (a test enforces it), the PRIVACY and PLAY_STORE texts and the Data safety answers, the About credit, the one-time warning for the Locked library, and cover images from its CDN. Series titles are sent, nothing else, and never from the Locked library without the warning.

## 9. Locked library

Series, series info, the grouping, the grid, the Missing list, Stats and the new suggestions are computed per library. `series_info.locked` keeps a locked series name out of the main library even when the same name exists in both. The shared Missing list and any picture or PDF use the main library only, like the year card.

## 10. Performance

A manga collector can reach 1,000 volumes. Grouping and the grid are computed in memory from `watchLibrary` (already one join), which is fine to several thousand rows; the series page computes only its own group. Add an index on `books.series`. Test with a synthetic 5,000-book library on the emulator before release, since performance was not re-measured after 0.7.0.

## 11. Testing, audit and documentation impact

- **New tests (about 40 to 50):** parser table above and fuzz; grid state derivation; ongoing/complete; migration from every schema 1 to 6 to 7 (extend `pgm300_migration_test.dart`); locked isolation for every new view; Add next volume; group-by-series counts; export/import round trip with the new columns; accessibility and 200% text for the grid; two-pane.
- **Audit:** a focused audit of the migration, locked isolation and import of old files; a device pass on the S25 Ultra with a real 50-volume series.
- **Documentation:** User Manual (new Series and volumes section, Quick start line), in-app guide topics (the guide test checks every bold name), Package Overview, README features, screenshots, release notes; Play listing text mentions manga.
- **Promise honesty:** unchanged in step 1; the tests in `test/promise_test.dart` keep passing without edits.

## 12. Plan and size

| Phase | Work | Size |
|---|---|---|
| 1 | Schema 7 and migration, `kind`, `owned`, `series_info`, export/import | about one working session |
| 2 | Volume parser with tests | about half a session |
| 3 | Series page with grid, Add next volume, Missing list | about one session |
| 4 | Group by series in the Library; book page chip and neighbours | about one session |
| 5 | Scan many integration, Stats, guide and manual, screenshots, audit pass | about one session |
| 6 (1.2.0) | Optional AniList lookup and its promise and privacy changes | about one session |

Release 1.1.0 is therefore about four to five sessions of work plus your phone testing. It does not touch the 1.0.0 gate.

## 13. Decisions for the owner

1. **Kinds.** Is `manga`, `comic`, `lightnovel` enough, or do you also want `audiobook-series` and so on? (Recommended: just these three, extendable later.)
2. **Owned.** Do you want the owned flag and dashed "wanted" volumes (recommended for collectors), or should Pagemark keep treating everything in the library as owned?
3. **Series lookup.** Ship 1.1.0 without any lookup and decide on AniList afterwards (recommended), or include it?
4. **Library default.** Turn **Group by series** on automatically when a series has more than a few volumes (recommended), or keep it as an opt-in switch?
5. **Chapters.** Manga readers sometimes track chapters. Leave chapters out of 1.1 (recommended; volumes cover the collecting use) or add a chapter field later?

## 14. Not in scope

Chapter-level reading, reading direction, scanlation sources, importing from MyAnimeList or AniList lists, volume-level price tracking, and Japanese-language title parsing. Any of these can follow once the volume model is in use.
