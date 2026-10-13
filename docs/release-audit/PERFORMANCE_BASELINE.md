# Performance baseline - Pagemark 0.7.0

Audited commit `045e8147`. Build: signed release, x86_64 (local build, `flutter build apk --release --target-platform android-x64`, release key SHA-1 matches the published APKs).
Device: Android emulator (x86_64, 898x2000 preview), not a real phone. Numbers are a baseline to diff next release, not a promise for real hardware.

| Scenario | Result | Notes |
|---|---|---|
| Cold start, empty profile | 2026 ms (`am start -W`) | first launch |
| Warm start, empty profile | 1931 ms | |
| Cold start, 5,000-book library | 1297 / 1273 / 2394 ms (3 runs) | restored via Settings > Restore |
| Restore of 5,000 books / 5,011 reads / 1,667 quotes (1.45 MB) | dialog shows correct counts; completed without error | message about 100 locked books and PIN is correct |
| Memory, 5k library, after scrolling | PSS 116-130 MB, RSS 221-232 MB | no growth seen over 15 fast scrolls |
| Stats tab, 5k library | renders within the 4.4 s tap-to-screenshot window | numbers correct: 4,900 tracked (5,000 minus 100 locked) |
| Synthetic data generation | 5,000 books in 6.8 s | test-only |

## Not measured

- Frame time / jank: `dumpsys gfxinfo` reports 0 frames for a Flutter surface, so scroll smoothness was judged by screenshots only. NOT RUN: profile-mode timeline on a real device.
- Search and skin-switch latency at 5k: not timed (no scripted driver); a manual stopwatch pass is in MANUAL_TEST_PLAN.
- Battery drain, WorkManager wake behaviour, thermal: need a real device over hours.
- 50k-book library: not generated (5k is already above any realistic personal library).
