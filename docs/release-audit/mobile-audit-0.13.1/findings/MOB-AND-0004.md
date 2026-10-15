---
finding_id: MOB-AND-0004
audit_domain: 18
platform: android
severity: S1
blockers: []
title: Dependency sqlite3_flutter_libs is on its "+eol" release; OSV scan found no known CVEs
status: fixed-verified
confidence: medium
evidence_basis: static
affected_component: pubspec.yaml (sqlite3_flutter_libs ^0.6.0+eol), pubspec.lock
---
The package version string marks end of life; the bundled libsqlite3.so will not receive upstream updates through it. OSV batch query of all 187 locked pub packages returned no vulnerabilities (artifact/sbom-pub.txt); the concern is maintenance only. Remediation: move to the maintained sqlite3 native-assets path (sqlite3 ^3.x is already a dependency) and rerun the scan. Verify: pubspec has no +eol package and the OSV scan is clean.

**Fix (2026-10-14):** sqlite3_flutter_libs removed from pubspec.yaml; the sqlite3 package bundles SQLite itself. flutter analyze clean, 295 tests pass, release APK still contains libsqlite3.so, and on the emulator the app opened the existing database (library intact), 0 fatal errors, cold start 613-729 ms (native x86_64).
