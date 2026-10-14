# Security traceability: OWASP MASVS / MASWE / MASTG

Use the OWASP Mobile standards as the spine instead of inventing a private framework. **MASVS** = what must hold (control groups), **MASWE** = the weakness catalogue, **MASTG** = test procedures. IDs and wording evolve: look up the current MASVS version and the specific MASWE/MASTG IDs at audit time (https://mas.owasp.org) and record the version used in the report. Do not cite an ID you have not verified; cite the control group and name the weakness in words instead.

## Control groups and where they land

| MASVS group | Covers | Audit domains |
|---|---|---|
| MASVS-STORAGE | Sensitive data at rest, logs, backups, clipboard, screenshots | 12, 21 |
| MASVS-CRYPTO | Algorithms, key management, randomness, KDFs | 12, 15 |
| MASVS-AUTH | Authn/authz, biometrics, sessions, local auth | 15, 14 |
| MASVS-NETWORK | TLS, validation, pinning, cleartext | 13 |
| MASVS-PLATFORM | IPC, deep links, WebViews, UI exposure, permissions | 12, 17, 07 |
| MASVS-CODE | Update enforcement, dependencies, input handling, debug code | 02, 18 |
| MASVS-RESILIENCE | Anti-tamper, obfuscation, root/jailbreak, anti-debug | 19 |
| MASVS-PRIVACY | Data minimization, transparency, user control | 16 |

## Verification levels
MASVS defines baseline security plus optional resilience and privacy profiles. Pick the profile from the threat model captured in Phase 0 (a local hobby app does not need MASVS-RESILIENCE; a banking app does) and state it. Controls outside the chosen profile are N/A with that reason, not silently skipped.

## Per-finding procedure
1. Identify the control group the failed behavior violates.
2. Look up the matching MASWE weakness and MASTG test for the platform; put verified IDs in `references.owasp_*`.
3. Rate by real exploitability (attacker model: lost/stolen device, malicious app on device, network attacker, malicious backend input, rooted/jailbroken device) and data sensitivity.
4. Write the verification procedure as a MASTG-style test: setup, steps, expected result.

## Attacker models to name in findings
- **Physical (unlocked or locked device):** storage, app-switcher previews, notifications, backups.
- **Co-resident malicious app:** exported components, content providers, clipboard, shared storage, intent redirection.
- **Network:** MITM, captive portal, TLS downgrade, DNS.
- **Malicious or compromised client:** modified requests, replayed tokens, forged IDs (domain 14 is the defense).
- **Reverse engineer:** extracts keys/endpoints from the binary; assume everything in the package is public.

## Common high-value checks (quick list)
- Secrets or long-lived tokens in plain prefs/SQLite/files; keys hardcoded or derivable from the package.
- Weak KDF or missing salt for PIN/passphrase; no attempt limiting on a local lock; recovery path that bypasses the lock.
- Sensitive data in logs, crash reports, analytics events, notifications, or the clipboard.
- Cleartext traffic allowed; trust-all TLS; user-CA trust in release.
- Exported components or deep links that act on unvalidated input.
- WebView with JS bridge and untrusted origins.
- Client-side-only authorization or feature gating.
- Backups (cloud or adb) that include secrets or locked/private data without disclosure.
- Debug flags, dev endpoints, or test credentials in the release artifact.
