---
finding_id: MOB-PRV-0006
audit_domain: 16
platform: android
severity: S1
blockers: []
title: Drive backups are plaintext by default and include the locked library
status: accepted-risk
confidence: high
evidence_basis: static
affected_component: lib/backup.dart:150-175
references: {owasp_masvs: [MASVS-PRIVACY, MASVS-STORAGE]}
---
**Observed:** encryption happens only when a passphrase is set. The snapshot includes locked books (documented in the UI per CLAUDE.md). Data sits in the app's private `appDataFolder` of the user's own Google account.
**Impact:** anyone with access to that Google account's app data can read the vault when no passphrase is set.
**Fix (optional):** prompt for a passphrase when enabling backup and treat "no passphrase" as an explicit choice; keep the existing disclosure.
