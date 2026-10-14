# Finding schema

One file per finding: `audit/findings/<finding_id>.md`, YAML front matter then prose. Keep it factual; omit fields that truly do not apply instead of writing "n/a" filler (except fields marked required).

```yaml
finding_id: MOB-SEC-0042        # required; MOB-<DOMAIN>-<nnnn>
audit_domain: 12                # required; number from domains.md
platform: android|ios|both      # required
severity: S0..S5                # required
blockers: []                    # any of: store, security, functional, data-loss, privacy, quality
title: ""                       # required; one line, states the defect
status: open|fixed-verified|accepted-risk|wont-fix
confidence: high|medium|low     # low = hypothesis, also list under MANUAL REVIEW
evidence_basis: runtime|artifact|static   # required

affected_component: ""          # file:line, class, endpoint
affected_screen: ""
affected_version: ""            # version+build+commit

description: ""
preconditions: ""
steps_to_reproduce: []
expected_behavior: ""
observed_behavior: ""
evidence: []                    # command output, file:line, screenshots; REDACT secrets/PII

impact:
  security: ""
  privacy: ""
  user: ""
  business: ""
root_cause: ""
recommended_remediation: ""
verification_procedure: ""      # how Phase 22 will prove it fixed

references:
  owasp_masvs: []               # e.g. MASVS-STORAGE-1
  owasp_maswe: []
  owasp_mastg: []
  apple_requirement: ""         # guideline number + date checked
  google_requirement: ""        # policy name + date checked
  other: []                     # CWE, WCAG SC, CVE
```

## Severity

| Level | Meaning |
|---|---|
| S0 | Informational / improvement opportunity |
| S1 | Low: minor defect |
| S2 | Moderate: noticeable quality issue |
| S3 | High: significant functionality or security issue |
| S4 | Critical: serious security, data, or reliability defect |
| S5 | Release blocker: must not publish |

## Blocker classes (independent of severity)

- **store** - likely prevents approval or causes later removal (missing account deletion, inaccurate Data Safety, missing purpose strings, target-API below requirement)
- **security** - unacceptable exposure
- **functional** - core function fails
- **data-loss** - can destroy or corrupt user data (failed migration, restore overwrites with no safety copy)
- **privacy** - collection, processing, sharing, or deletion is unacceptable or contradicts declarations
- **quality** - works but below the release threshold

Any S5, or any open finding with a store/security/privacy/data-loss blocker class, drives NO-GO.

## Severity guidance

Rate by realistic exploitability and impact, not by how alarming the category sounds. A world-readable file holding a refresh token on a backend-connected app is S4; the same file holding a UI theme is S0. A finding needing physical device access plus a debugger on an app with no sensitive data is low. State your reasoning in `description` when severity is not obvious.
