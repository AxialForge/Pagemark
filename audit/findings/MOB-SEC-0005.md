---
finding_id: MOB-SEC-0005
audit_domain: 13
platform: android
severity: S1
blockers: []
title: In-app updater makes the SHA-256 check optional
status: open
confidence: high
evidence_basis: static
affected_component: lib/updater.dart:126, 154-160
references: {owasp_masvs: [MASVS-CODE, MASVS-NETWORK]}
---
**Observed:** the digest is verified only when GitHub supplies `digest`; otherwise only size is checked. Android's same-signing-key rule is the real backstop, and transport is HTTPS to github.com.
**Impact:** low; defense in depth. A compromised release asset signed with the real key would pass either way.
**Fix:** require a digest (publish a `.sha256` asset and verify it) or refuse to auto-install without one; optionally pin the expected signer cert in-app.
