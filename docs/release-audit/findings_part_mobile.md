# Findings - mobile pass (auditor, PGM-001..099)

| ID | Sev | Category | Component | Finding | Evidence | Fix commit | Status |
|---|---|---|---|---|---|---|---|
| PGM-001 | LOW | Accessibility | Library filter chips | At system font scale 2.0 the "All" status chip text is clipped at the bottom (chip height does not grow with text); other chips scroll horizontally and are fine. | auditor (shots/c_font2.png) | | OPEN |
| PGM-002 | LOW | UX | Empty library | The empty state shows both an "Add a book" button and the "Add book" FAB, two controls for one action. | auditor (shots/a_first_launch.png) | | OPEN |
| PGM-003 | INFO | Packaging | Release assets | Only arm64 and armv7 APKs are published; x86_64 emulators cannot install the release. Release behaviour was verified on a locally built, release-signed x86_64 APK. | auditor | | OPEN |
| PGM-004 | INFO | Compat | Orientation | Landscape/tablet layout NOT SEEN: the emulator did not rotate the app when user_rotation=1 was set, and the manifest has no screenOrientation lock. Needs a real device or a rotating emulator. | auditor | | OPEN |
| PGM-005 | INFO | Tests | bulk_test | Three "tap() missed hit test" warnings in the bulk-selection tests; tests pass but the taps may not hit the intended widget. | auditor (suite1.log) | | OPEN |
| PGM-006 | INFO | Positive | Restore / scale | Restore of a 5,000-book backup works through the picker; dialog counts are correct; locked-books/PIN message is correct; cold start 1.3 s and ~120 MB PSS at 5k books; Stats totals exclude locked books as designed. | auditor | | VERIFIED |
