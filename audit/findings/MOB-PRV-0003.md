---
finding_id: MOB-PRV-0003
audit_domain: 21
platform: android
severity: S2
blockers: [privacy]
title: Log may record searched titles/ISBNs through exception text, contradicting the "never log book data" rule
status: open
confidence: medium
evidence_basis: static
affected_component: lib/lookup.dart:52, 174; lib/log.dart:8; lib/ui.dart:1398-1412 (Diagnostics Copy)
references: {owasp_masvs: [MASVS-STORAGE, MASVS-PRIVACY]}
---
**Observed:** `Log.w('lookup', 'network error: $e')` writes the raw exception. Search and ISBN URLs carry the title/ISBN as query parameters (lookup.dart:118, 140), and `package:http`'s `ClientException.toString()` appends `uri=...` (verify against the pinned http version; not run here). log.dart:7 and CLAUDE.md both state titles are never logged. Lookups also run when adding books to the vault.
**Impact:** pagemark.log (200 KB, persists across relock) can hold titles/ISBNs of private books; Diagnostics > Copy puts the log on the clipboard for pasting into bug reports.
**Fix:** log only the exception type (`e.runtimeType`) plus status code in `lookup.dart`, or strip the query from any URI in log lines inside `Log._write`; add a test that logs a ClientException with a titled URI and asserts the title is absent.
**Verify:** go offline, search a distinctive title, open Diagnostics, confirm the title is not present.
