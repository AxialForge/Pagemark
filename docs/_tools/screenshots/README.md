# Regenerating the documentation screenshots

The screenshots in `docs/screenshots/` come from the app running in an Android emulator with a seeded sample library
(sample books, ratings, shelves, one locked title). Nothing here touches a real library.

1. **Seed a demo database** (uses the app's own schema, so it never drifts):
   `SEED_OUT=<path>\seed.sqlite flutter test test/tool_seed_demo_test.dart`
2. **Build a debuggable x86_64 APK** (needed so `run-as` can place the database):
   `flutter build apk --debug --target-platform android-x64` (set `JAVA_TOOL_OPTIONS` as in CLAUDE.md on Windows).
3. **Start the emulator**, install the APK, launch it once, `adb shell am force-stop com.axialforge.pagemark`, then
   `adb push seed.sqlite /data/local/tmp/` and
   `adb shell "run-as com.axialforge.pagemark sh -c 'rm -f app_flutter/pagemark.sqlite*; cp /data/local/tmp/seed.sqlite app_flutter/pagemark.sqlite'"`.
4. **Tidy the status bar:** `adb shell settings put global sysui_demo_allowed 1`, then broadcast
   `com.android.systemui.demo` commands (clock `0941`, battery 100, wifi shown, mobile hidden, notifications hidden).
   **Turn off stylus handwriting** (`adb shell settings put secure stylus_handwriting_enabled 0`) or its toolbar appears over text fields.
5. **Drive the app** with `emu.ps1` (`Tap`, `Swipe`, `Txt`, `Shot "01_library"` ...) and save PNGs to `out/shots/`.
   The names `process.py` expects are listed at the top of that script.
6. (Locked screens are black in screenshots by design - build with `--dart-define=PAGEMARK_SCREENSHOTS=true` to disable FLAG_SECURE for documentation builds only.)
7. `python process.py` writes the 540 px JPEGs into `docs/screenshots/`; then `python docs/_tools/build_docs.py` rebuilds the PDFs.

Gotchas: `FLAG_SECURE` makes screenshots of the *open* locked library black (by design - that screen isn't documented);
pressing Back on the library root leaves the app; the Android `input text` command can't type some punctuation.
