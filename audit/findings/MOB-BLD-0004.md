---
finding_id: MOB-BLD-0004
audit_domain: 02
platform: android
severity: S2
blockers: [functional]
title: Release build silently falls back to debug signing when key.properties is missing
status: open
confidence: high
evidence_basis: static
affected_component: android/app/build.gradle.kts:55-57
references: {owasp_masvs: [MASVS-CODE]}
---
**Observed:** `signingConfig = if (keyProps.containsKey("storeFile")) release else debug`. A `flutter build apk --release` on a machine or CI without the key yields a debug-signed APK that looks like a release.
**Impact:** a debug-signed APK attached to a GitHub Release cannot upgrade installed copies (signature mismatch) and the in-app updater would offer it to every user; the failure surfaces on user devices.
**Fix:** fail the build for release tasks when the key is absent (throw in `signingConfigs`/`afterEvaluate` for `assembleRelease`), keeping debug builds unaffected; add `apksigner verify --print-certs` against the pinned release-cert SHA-256 to the release checklist.
**Verify:** build release without key.properties -> build fails with a clear message.
