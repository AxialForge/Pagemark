---
finding_id: MOB-STORE-0005
audit_domain: 23
platform: android
severity: S1
blockers: []
title: PLAY_STORE.md open items are stale (refers to 0.7.1) and the feature graphic is still missing
status: open
confidence: high
evidence_basis: static
affected_component: docs/PLAY_STORE.md "Before you submit"
---
Checklist still says verify 0.7.1 fixes and regenerate screenshots; 1024x500 graphic not made. Remediation: refresh the checklist for 0.13.x/1.0.0 and create the graphic. Verify: all listing assets present in Play Console.

**Fix (2026-10-14):** docs/PLAY_STORE.md checklist refreshed for the current release (real-phone pass, scanner traffic capture, screenshots, pre-launch report). Still open and owner-only: create the 1024x500 feature graphic.
