---
finding_id: MOB-PRV-0001
audit_domain: 16
platform: android
severity: S1
blockers: []
title: Privacy policy permission list and Drive wording do not match the shipped manifest
status: fixed-verified
confidence: high
evidence_basis: artifact
affected_component: docs/PRIVACY.md (Permissions, Locked library); artifact/badging.txt
affected_version: 0.13.1+22 e42cc26
---
Merged manifest also holds VIBRATE, WAKE_LOCK, RECEIVE_BOOT_COMPLETED, FOREGROUND_SERVICE, USE_FINGERPRINT (from plugins/WorkManager/notifications); the policy lists none of them. The Locked-library paragraph still says exports include "Drive backups", but Drive backup was removed in 0.8.2.
Remediation: list the extra permissions with one-line reasons (or strip unused ones with tools:node="remove" if confirmed unused, e.g. FOREGROUND_SERVICE), replace "Drive backups" with "folder backups". Verify: aapt2 dump badging vs the policy list.

**Fix (2026-10-14):** docs/PRIVACY.md now lists WAKE_LOCK, RECEIVE_BOOT_COMPLETED, FOREGROUND_SERVICE, VIBRATE and USE_FINGERPRINT with reasons and says folder backups instead of Drive; verified against the merged manifest list. The permissions themselves were kept (WorkManager and notifications use them).
