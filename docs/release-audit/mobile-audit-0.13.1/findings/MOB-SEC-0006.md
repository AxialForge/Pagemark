---
finding_id: MOB-SEC-0006
audit_domain: 12
platform: android
severity: S0
blockers: []
title: Locked library is not encrypted at rest (owner decision)
status: accepted-risk
confidence: high
evidence_basis: static
affected_component: lib/db.dart, lib/lock.dart
---
The PIN gates the UI; the SQLite file is plain inside app-private storage (backup, adb and cloud transfer disabled). Owner declined SQLCipher on 2026-10-12; recorded, not re-proposed. Exposure needs a rooted device or forensic access; the encrypted backup option covers exported copies.
