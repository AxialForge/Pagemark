---
finding_id: MOB-BLD-0003
audit_domain: 02
platform: android
severity: S1
blockers: []
title: Release APK signed with APK Signature Scheme v2 only (no v3/rotation lineage)
status: fixed-verified
confidence: high
evidence_basis: artifact
affected_component: build/release-0.13.1/*.apk (artifact/signing.txt)
---
apksigner: v1 false, v2 true, v3 false. Valid for minSdk 24. Without v3 a compromised or lost key cannot be rotated for sideload users, and CLAUDE.md already warns that losing the key blocks in-place upgrades. Play App Signing covers the Play build, not the GitHub APKs.
Remediation: keep the keystore backed up (NAS script exists); optionally sign with v3 so a rotation lineage can be added later. Verify: apksigner verify shows v3 true.

**Fix (2026-10-14):** android/app/build.gradle.kts release signing now sets enableV1Signing=false, enableV2Signing=true, enableV3Signing=true. A signed release build verified v2 true and v3 true with the same certificate SHA-256 (26b4a423...). Takes effect on the next versioned release build.
