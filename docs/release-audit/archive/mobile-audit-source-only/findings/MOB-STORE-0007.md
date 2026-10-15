---
finding_id: MOB-STORE-0007
audit_domain: 22
platform: android
severity: S0
blockers: []
title: REQUEST_INSTALL_PACKAGES is a Google Play restricted permission (conditional)
status: open
confidence: high
evidence_basis: static
affected_component: android/app/src/main/AndroidManifest.xml:5
references: {google_requirement: "Play policy on REQUEST_INSTALL_PACKAGES - fetch current text before relying on this"}
---
Not an issue while distribution is GitHub sideload only. If Pagemark ever ships on Play, the self-updater and this permission must be removed (store blocker).
