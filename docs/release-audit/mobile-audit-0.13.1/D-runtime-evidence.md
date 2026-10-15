# Appendix D - Runtime evidence

Emulator: Pixel_10_Pro_XL_test, Android 17, x86_64. Pagemark 0.13.1 (2022) was installed over an existing install with the same signing key; the library kept its data.

| Measure | Result |
|---|---|
| Cold start (am start -W TotalTime), 3 runs | 4,409 ms, 3,021 ms, 2,795 ms (ABI translation inflates this) |
| Offline launch (airplane mode) | 3,086 ms, app opened normally |
| Memory after launch | TOTAL PSS 230,927 KB, RSS 376,772 KB, Java heap 5.6 MB, native heap 27.5 MB |
| First-frame render | 1 frame, 23 ms (not a useful jank measure) |
| Fatal exceptions or ANRs in logcat | 0 of 4,881 lines; only SELinux max_map_count notices and a CPU-variant warning from the emulator |
| Debugger access to private data | `run-as` refused: package not debuggable |
| Kill and relaunch | process restarted, no crash |

![Library on launch (default text size)](artifact/rt-launch.png)

![Library at 2.0 font scale, airplane mode on](artifact/rt-font2.png)

![Library launched in airplane mode](artifact/rt-offline.png)

## Test suite tail (flutter test)
`00:16 +295 ~1: All tests passed!` (295 passed, 1 skipped). `flutter analyze`: No issues found.

## Fix verification (2026-10-14)
Signed release rebuilt with the fixes. apksigner: v2 true, v3 true, same certificate. libsqlite3.so still bundled without sqlite3_flutter_libs. x86_64 release installed over the existing install: library intact, 0 fatal or ANR lines, cold start 683, 729 and 613 ms (native, unlike the translated arm64 numbers above).

![Library after the fixes (x86_64 release build)](artifact/rt-fix-launch.png)
