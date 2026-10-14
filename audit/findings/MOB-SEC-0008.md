---
finding_id: MOB-SEC-0008
audit_domain: 12
platform: android
severity: S1
blockers: []
title: Backup unpack inflates whole zip entries in memory
status: open
confidence: medium
evidence_basis: static
affected_component: lib/export.dart:163-175
references: {owasp_masvs: [MASVS-CODE]}
---
`entry.readBytes()` decompresses each entry fully; a crafted backup (zip bomb) can exhaust memory/storage during restore or inspect. User-chosen file, so impact is a crash, not code execution. Path traversal is correctly blocked (`CoverStore.safeName`, fixed db name). **Fix:** cap entry and total sizes before reading; stream to disk.
