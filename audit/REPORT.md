# Mobile Application Release Audit - Pagemark

**App:** Pagemark `com.axialforge.pagemark` · 0.7.0+10 · commit 045e814 · branch `branch/inspiring-franklin-sawwzg`
**Platform:** Android only (iOS is scaffolding, out of scope) · **Evidence mode:** source-only · **Scope:** Section C, Security
**Identity gate:** FAIL (no built artifact to tie to a release) · **Policies checked:** none needed for this scope

## DECISION: CONDITIONAL NO-GO (overall release), no blockers in the security section

Why not GO: source-only audit, identity gate not satisfied, and most domains are outside this run's scope. Within the security section there are no S4/S5 findings and no store blockers.

**Coverage:** 20 controls evaluated (12 PASS, 5 PASS-WARN, 3 FAIL), 4 N/A with reasons; NOT TESTED / BLOCKED: merged manifest and release flags (no APK), runtime log/storage/FLAG_SECURE checks (no device), Play Data Safety (not on Play).
**Security score:** 85/100 (4 S2 at -3, 3 S1 at -1) on source-only coverage; treat as an upper bound until the runtime checks below are done.

## Findings (fix first -> last)

| ID | Sev | Domain | Title |
|---|---|---|---|
| MOB-PRV-0003 | S2 | 21 Logging | Log can record searched titles/ISBNs via exception text; contradicts the project's own rule and the vault's privacy promise |
| MOB-SEC-0001 | S2 | 15 Auth | PIN lockout bypass by moving the device clock |
| MOB-CRY-0002 | S2 | 12 Crypto | Backup passphrase KDF at 150k PBKDF2 iterations; parameters not stored, so no upgrade path |
| MOB-BLD-0004 | S2 | 02 Build | Release build silently signs with the debug key if `key.properties` is absent |
| MOB-SEC-0005 | S1 | 13 Network | Updater SHA-256 check is optional |
| MOB-SEC-0008 | S1 | 12 Storage | Restore unpack inflates whole zip entries in memory |
| MOB-PRV-0006 | S1 | 16 Privacy | Drive backup plaintext by default, includes vault (documented; accepted risk) |
| MOB-STORE-0007 | S0 | 22 Store | `REQUEST_INSTALL_PACKAGES` is Play-restricted; only matters if you ever list on Play |

Details, evidence, and fixes: `audit/findings/`.

## What is solid
Cloud and adb backup fully disabled; PIN stored as salted PBKDF2 in secure storage with constant-time compare and escalating lockout; recovery code is 80 bits and counts as a failed attempt; AES-256-GCM backups with random salt/nonce; locked books excluded from CSV/JSON exports; CSV formula injection neutralized; restore blocks path traversal and keeps a pre-restore safety copy; only the launcher activity is exported; no cleartext HTTP; keystore and `key.properties` are not in git; permissions pruned with `tools:node="remove"`.

## What is missing for a GO
1. Build a signed release APK and run `scripts/inspect_artifact.sh` (merged manifest, signer SHA-256, `debuggable`, secret strings). Currently NOT TESTED.
2. Runtime pass on a device or emulator: `adb logcat` through a lock/unlock/search flow, `run-as` inspection of the app's files, FLAG_SECURE in recents. Currently BLOCKED.
3. Fix or consciously accept the four S2 findings.
4. Run Sections B and D (quality, privacy/permissions/dependencies) before a release decision.

## Method note
Static reading only. The `ClientException` URI claim in MOB-PRV-0003 depends on the pinned `http` package version and was not executed; confidence medium. Nothing here was run on a device.
