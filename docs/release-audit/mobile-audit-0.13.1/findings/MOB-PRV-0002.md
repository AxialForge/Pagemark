---
finding_id: MOB-PRV-0002
audit_domain: 22
platform: android
severity: S2
blockers: [store]
title: Play Data safety draft does not address ML Kit barcode scanner telemetry
status: open
confidence: medium
evidence_basis: static
affected_component: docs/PLAY_STORE.md (Data safety form); docs/PRIVACY.md (barcode paragraph)
---
PRIVACY.md admits Google's ML Kit "may report anonymous technical information to Google", yet the Data safety answers say nothing is collected except lookups. Google can flag a form that omits SDK collection. Unverified at runtime (no traffic capture), so MANUAL REVIEW.
Remediation: capture the scanner's network traffic once on a device, then declare diagnostics/device identifiers accordingly (or confirm none), and align both documents. Verify: traffic log + Play Console form.

**Fix (2026-10-14):** docs/PLAY_STORE.md Data safety answers now state that the ML Kit reader may send diagnostics and give the exact rule for declaring Diagnostics after a traffic capture. The capture on a real phone is still needed before the form is submitted.
