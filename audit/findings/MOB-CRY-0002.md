---
finding_id: MOB-CRY-0002
audit_domain: 12
platform: both
severity: S2
blockers: []
title: Backup/export passphrase KDF uses 150k PBKDF2 iterations with no stored parameters
status: open
confidence: high
evidence_basis: static
affected_component: lib/crypto_backup.dart:13-17, 33
references: {owasp_masvs: [MASVS-CRYPTO], other: ["OWASP Password Storage Cheat Sheet: current PBKDF2-HMAC-SHA256 guidance is far above 150k (verify current figure)"]}
---
**Observed:** the PGMKENC1 container is the one secret that is attackable offline (a copy on Drive or a shared .pgbak). Key = PBKDF2-HMAC-SHA256, 150,000 iterations, fixed in code; the header stores only magic, salt and nonce, so iterations cannot be raised without a new magic.
**Impact:** a weak passphrase falls to GPU brute force far faster than current guidance assumes. AES-256-GCM, 16-byte random salt and 12-byte nonce are correct.
**Fix:** introduce PGMKENC2 with the iteration count (or Argon2id parameters) in the header; keep decrypting PGMKENC1; enforce a minimum passphrase length/strength in the UI.
**Verify:** round-trip tests for v1 and v2; decrypt a v1 fixture.
