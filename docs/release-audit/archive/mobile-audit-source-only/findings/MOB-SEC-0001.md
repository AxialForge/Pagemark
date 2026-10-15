---
finding_id: MOB-SEC-0001
audit_domain: 15
platform: android
severity: S2
blockers: [security]
title: PIN lockout can be bypassed by moving the device clock forward
status: open
confidence: medium
evidence_basis: static
affected_component: lib/lock.dart:82-102 (lockoutRemaining, _recordFail)
references: {owasp_masvs: [MASVS-AUTH], other: [CWE-307]}
---
**Observed:** `lock_until` is stored as an absolute `DateTime.now()` epoch and compared to `DateTime.now()` (lock.dart:83-84, 100). The 5-miss lockout (30 s, doubling to 1 h) is therefore defeated by setting the system clock past `lock_until`.
**Threat:** someone holding the unlocked phone (the vault's real adversary), not a thief of a locked device. Needs Settings access and automatic time disabled.
**Impact:** unlimited PIN guessing; with the allowed 4-digit minimum (lock_ui.dart:57) that is a 10,000-guess space.
**Fix:** also store `SystemClock.elapsedRealtime`-style monotonic time (via a platform channel) and the boot count, and take the larger remaining lock; or count failures without any time dependence and require the recovery code after N total misses.
**Verify:** unit-test `lockoutRemaining` with a fake clock moved forward; on device, trip lockout, advance clock, confirm still locked.
