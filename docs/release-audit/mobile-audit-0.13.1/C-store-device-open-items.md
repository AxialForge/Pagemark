# Appendix C - Store disclosure, device matrix and open items

## C1. Store disclosure diff (Google Play Data safety)
| Data type | Declared in docs/PLAY_STORE.md | Observed | Match |
|---|---|---|---|
| Search queries, app activity | sent to Open Library and Google Books, optional, not linked to identity | confirmed in source (lookup.dart) | yes |
| Personal info, financial, health, location, contacts, messages, photos, audio | none | none found in the manifest or source | yes |
| Camera images | processed on device, not stored or sent | the app never stores or sends them; the ML Kit library may report technical info to Google per the privacy policy | UNVERIFIED (MOB-PRV-0002) |
| Device or other IDs, diagnostics | none | not verified at runtime for the ML Kit component | UNVERIFIED |
| Encryption in transit | HTTPS | all hosts HTTPS, no cleartext | yes |
| Deletion | clear storage, delete backups | no accounts; uninstall removes app data | yes |
| Permissions in the privacy policy | internet, camera, biometric, install packages, notifications, background work and network state | five more in the merged manifest | NO (MOB-PRV-0001) |
| Listing claims "no account, no ads, no tracking, no AI, never collects your data" | | no accounts, ads, analytics or AI SDKs found; lookups expose search text and IP to third parties, which the policy discloses | yes, with the ML Kit caveat |

## C2. Play checklist status
| Item | State |
|---|---|
| Target API meets the requirement (36) | PASS |
| 64-bit and AAB | PASS (arm64 and armv7 APKs, AAB built) |
| 16 KB page alignment | PASS |
| Installer permission absent from the Play flavor | PASS |
| Data safety form | MANUAL REVIEW |
| Privacy policy URL (public GitHub page) | present; content needs the MOB-PRV-0001 fix |
| Content rating and target audience (13+) | MANUAL REVIEW (answers drafted) |
| Account deletion | N/A, no accounts |
| Ads declaration | none |
| Restricted-permission declarations | none needed (no SMS, call log, background location, all-files access) |
| Feature graphic 1024x500 and current screenshots | OPEN (MOB-STORE-0005) |
| Pre-launch report | NOT RUN (needs Play Console); the test robot cannot pass a PIN lock |

## C3. Device and OS matrix actually exercised
| Cell | Exercised |
|---|---|
| Pixel_10_Pro_XL_test emulator, Android 17, x86_64 with arm64 translation, 1344x2992 | yes: install-over, launch, offline, 2.0 font scale, process kill |
| Real phone (any) | NO |
| Low-end device, Samsung, tablet or foldable | NO (a tablet two-pane layout was exercised in the earlier 1.0.0 gate audit, emulator only) |
| Min SDK 24 device | NO |
| Android 13 notification prompt, biometric hardware, camera hardware | NO |

## C4. Manual review queue
1. Capture the barcode scanner's network traffic once on a device, then fix or confirm the Data safety form (MOB-PRV-0002).
2. Update PRIVACY.md (permission list and Drive wording) and decide whether FOREGROUND_SERVICE can be stripped (MOB-PRV-0001).
3. Real-phone pass from docs/release-audit/MANUAL_TEST_PLAN.md: reading timer, folder backup to a real cloud folder, fingerprint, notifications on Android 13+, camera scan, share sheet, widget, TalkBack, in-app updater install, upgrade from the published 0.13.0 APK.
4. Check the recents-screen thumbnail and clipboard behavior with the locked library open.
5. Fresh install, uninstall and reinstall, and what survives (keystore data, backup folder).
6. Confirm on a device that the 0.13.1 fixes for PGM-300 (Stats width), PGM-302 (genre noise) and PGM-320 (stuck timer) work; they are marked ready for verification in the repository audit.
7. Real-phone performance: cold start and scrolling a large library (the earlier 5,000-book test was emulator only).
8. Create the Play listing assets and run Play's pre-launch report.

## C5. What is missing for a clean GO
Items 1, 2 and 3 above. With those closed and no new S2 or higher findings, the Play decision moves to GO; the sideload APKs are already a conditional go.
