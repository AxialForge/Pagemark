# Release readiness - Pagemark 1.0.0 (update of 2026-10-16, commit after v0.13.4)

**Verdict: READY WITH CONDITIONS (conditions now owner-only).** No open finding above INFO. Fixes from the gate (0.13.1), the S25 Ultra device test (0.13.2 to 0.13.3) and the verification pass (0.13.4) are in. 310 tests pass, analyzer clean, schema 6 migration script passes.

Remaining before tagging v1.0.0, all owner checks:
1. Re-test 0.13.4 on the phone: landscape header collapse, How you unlock (device lock switch), restore from the oldest restore point, Tidy genres.
2. Scheduled backups with the Samsung battery manager (plan 9.5); confirm "Nearby devices" is Allowed (PGM-339); device checks PGM-111, 204, 207, 208.
3. Google Play: developer account, 14-day closed test with about 12 testers, Data safety form, listing. Listing graphics are ready in `docs/play/`.

Documentation set for 1.0.0 (User Manual, Install Manual, Release Notes, Package Overview, README) is regenerated in `Documentation/`.

---

# Release readiness - Pagemark 1.0.0 gate (audited 0.13.0, commit b1bbf51)

**Verdict: READY WITH CONDITIONS.** No blocker, critical or high finding. The code is in good shape for 1.0.0; the conditions are a few small fixes, the documentation set, and a real-phone pass nobody has done yet.

(The 0.7.0 verdict and its 84 findings are in `FINDINGS.md` above the 1.0.0 section; all were fixed in 0.7.1 to 0.8.1. Their READY FOR VERIFICATION status was not re-run one by one in this gate; the suite, migrations and release checks cover the same ground.)

## Counts (new this round)

| Severity | Count | IDs |
|---|---|---|
| BLOCKER / CRITICAL / HIGH | 0 | |
| MEDIUM | 4 | PGM-300, PGM-302, PGM-320, PGM-324 |
| LOW | 4 | PGM-301, PGM-303, PGM-321, PGM-322 |
| INFO | 4 | PGM-323 (accepted), PGM-325 to PGM-327 (verified positives) |

## Conditions for tagging 1.0.0

1. **Fix PGM-320** (stuck timer), **PGM-300** (Stats width on tablets), **PGM-302** (genre noise). These are the three a user would notice. PGM-301, 303, 321, 322 are small and should go in the same release.
2. **Documentation set (house rule for a major release):** regenerate User Manual, Install Manual, Release Notes and README, write the Package Overview (simple, medium, advanced) and refresh the GitHub details (PGM-324).
3. **Real-phone pass** from `MANUAL_TEST_PLAN.md`, in particular the timer, folder backup to a real cloud folder, fingerprint, notifications, TalkBack and the updater.
4. **Google Play steps** (account, 14-day closed test, Data safety form, listing) are outside the code. The Play bundle builds; see `docs/PLAY_STORE.md`.

Localisation is not a gate item; it needs a second language chosen first.

## What was and was not tested

| Phase | Result |
|---|---|
| Baseline, suite, generated code | pass, twice |
| Migrations schema 1 to 5 to 6 | pass, all rows kept, integrity and foreign keys clean |
| Release assets | signature, hash, secrets, permissions, 16 KB alignment checked; CI green |
| Hostile input (new parsers) | fuzzed, only PGM-303 |
| GUI | tablet rail, two panes, Stats, font 2.0 seen; full activation sweep NOT RUN |
| Data safety (backup, restore, folder) | unchanged since the 0.7.0 audit; real providers NOT RUN |
| Performance | NOT RUN this round |
| Real hardware, TalkBack, notifications, camera | NOT RUN |

## Top risks

- Anything that touches Android itself (folder picker, notifications, camera, share sheets, TalkBack) has only emulator or no coverage. The folder backup is the one with real data consequences.
- Lookup data quality: free sources return noisy genres and occasional wrong editions (PGM-302). Refresh details lets users fix it, but they must notice.
- The timer is the only new feature that holds state outside the database (PGM-320).

## Build-session handoff

**PGM-320 stuck timer.** Repro: copy `scripts/pgm320_stuck_timer_test.dart` into `test/` and run it; it fails on the missing Stop. Cause: `lib/reading_life_ui.dart` `_other` blocks other books and the Stop button only shows for the timed book (`_mine`). Fix direction: when a timer belongs to another book, offer Stop (save or discard that session), and clear the saved timer when its book is finished, trashed or purged. Verify: the same test passes, plus a new test that finishing the book clears `timer_start`.

**PGM-300 Stats width.** Repro: emulator `wm size 2400x1440; wm density 280`, open Stats (`evidence_1.0/f12_stats.png`). Fix direction: wrap the Stats list in `NarrowColumn` and give the calendar grid a fixed cell height (`mainAxisExtent: 40`). Verify: same screenshot shows a one-screen month; add a widget test pumping Stats at 1200 dp asserting the grid is under 400 tall.

**PGM-302 genre noise.** Repro: search "dune frank herbert", add the first result, read the Genre line (`evidence_1.0/f11_pane_book.png`). Fix direction: in `Lookup.genres()` and Google categories, split subjects on commas, drop duplicates case-insensitively, drop "(imaginary place)" entries and the book's own title, keep three. Verify: a lookup_test with the Dune subject list returns clean genres.

**PGM-301, 303, 321, 322:** cap the guide and Add a book with `NarrowColumn`; reject `pages <= 0` or above 20,000 in `parseVolume` and `_parseDoc`; call `closeBook` after Move to locked library; give the empty-state button a book or help icon. Verify with the v0130 and pgm310 tests plus one widget test each.
