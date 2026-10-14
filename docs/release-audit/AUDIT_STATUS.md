# Audit status - Pagemark 0.7.0

- Repo: C:\Project Folder\Pagemark, branch main, audited commit `045e8147c28780fd03dd0f714cce9d0225071f13` (tag v0.7.0), working tree clean at start.
- OS: Windows 11 Pro; Flutter 3.47 at C:\dev\flutter; JDK 25 (needs `-Djdk.net.unixdomain.tmpdir=C:/tmpj`); Android emulator x86_64.
- Suite from fresh clone: 193 pass + 1 skip, twice (33 s, 20 s). `flutter analyze` clean. build_runner output matches committed code.
- Real user data to avoid: none touched. Emulator used throughout; scratch data under the session scratchpad.
- Mode: full, mobile-leaning. Prefix PGM. Mine PGM-001..099, data agent 100..199, security agent 200..299.

## Phase log

| Phase | State |
|---|---|
| 0 Baseline | done |
| 1 Feature inventory | folded into FEATURE_MATRIX notes in the agents' files; no separate matrix written |
| 2 Suite audit | done (counts above); per-module coverage not measured |
| 3 Smoke | done on release x86_64 (first launch, 5k restore, cold starts) |
| 4 GUI | partial: font 2.0, landscape attempt, library/stats/settings seen; full activation sweep NOT RUN |
| 5 Data safety | done by script (findings_part_data.md) |
| 6 Engine | done by script |
| 7 Hostile input | done by script |
| 8 Security | done (SECURITY_AUDIT.md) |
| 9 Performance | done on emulator (PERFORMANCE_BASELINE.md) |
| 10 Packaging | done (RELEASE_ENGINEERING_AUDIT.md) |
| 11 Docs truth | done (DOCS_TRUTH.md) |
| 12 Compat | static only (COMPAT_MATRIX.md) |
| 13 Report | RELEASE_READINESS.md, MANUAL_TEST_PLAN.md, FINDINGS.md written |

## Not written

DATA_SAFETY_MATRIX.md, ENGINE_AUDIT.md, HOSTILE_INPUT.md, FEATURE_MATRIX.md, GUI_MATRIX.md, NAVIGATION_MATRIX.md, TEST_COVERAGE.md: the data agent could not write report files and its results live in findings_part_data.md and its scripts; the GUI/feature matrices were not produced.

## NOT RUN

Everything in MANUAL_TEST_PLAN.md: real device, fingerprint, Drive, WorkManager/Doze, updater install, TalkBack, tablets, iOS.

## 1.0.0 gate audit (2026-10-14)

- Audited: Pagemark 0.13.0, commit `b1bbf517a9152ba2b70281c03ec8b07897b23a73` (tag v0.13.0), working tree clean, CI green. New findings PGM-300 to PGM-327.
- Baseline from a fresh clone of HEAD: build_runner output identical to the committed code, `flutter analyze` clean, suite 289 pass + 1 skip, twice (33 s, 22 s).
- Run on: Windows 11, Flutter 3.47, Android emulator Pixel_10_Pro_XL_test (x86_64) with the release sideload build of 0.13.0; wm size/density and font scale restored afterwards. No real user data touched.

| Phase | State |
|---|---|
| 0 Baseline | done (above) |
| 2 Suite | counts and flakiness done; per-module coverage not measured; test files named in TEST_COVERAGE.md |
| 3 Smoke | emulator: first launch, welcome skip, empty library, search + add (live network), restart at font 2.0 |
| 4 GUI | partial. Seen: welcome, empty library, tablet rail, two-pane with a book, Stats on a tablet, font 2.0 on Library/Stats/book. Full activation sweep and every screen at every size NOT RUN |
| 5 Data safety | migrations from every schema 1 to 5 done by script (PGM-325). Restore/backup paths unchanged since the 0.7.0 audit and covered by its scripts and the suite; folder backup (SAF) NOT RUN on a real provider |
| 6 Engine | timer state tested (PGM-320); streak, year summary, queue order, suggestions covered by v0120/v0130 tests, reviewed |
| 7 Hostile input | Google Books and editions parsers fuzzed, 5,000 + 400 random shapes (PGM-303) |
| 8 Security | published asset verification, APK secret scan, manifest permissions and exported components, network host inventory (promise_test) |
| 9 Performance | NOT RUN this round (0.7.0 baseline stands; new Stats calendar and two-pane not profiled) |
| 10 Packaging | release assets verified; 16 KB alignment checked |
| 11 Docs | README and release-package read against 0.13.0 (PGM-324) |
| 12 Compat | tablet/landscape seen on the emulator; foldables, multi-window, other OEMs NOT RUN |
| 13 Report | RELEASE_READINESS.md, MANUAL_TEST_PLAN.md updated |

Scripts added: pgm300_migration_test.dart, pgm310_lookup_fuzz_test.dart, pgm320_stuck_timer_test.dart. Evidence screenshots: docs/release-audit/evidence_1.0/.

## NOT RUN this round

Everything in MANUAL_TEST_PLAN.md, plus: reading timer on a running device (only its widget logic was tested), share picture and PDF share sheets, Scan many books with a real camera, folder backup to a real cloud provider, notification delivery (loan reminders), TalkBack, performance of the new screens.
