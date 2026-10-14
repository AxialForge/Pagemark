# Report template and scoring

Write to `audit/REPORT.md`. Lead with the decision. Use this structure.

```
MOBILE APPLICATION RELEASE AUDIT
================================
Application:   <name>
Version/Build: <x.y.z> (<build>)     Commit: <sha>    Tag: <tag>
Platform(s):   Android | iOS | both  Environment: <production candidate | staging | ...>
Artifact:      <file + sha256, or "source only">
Evidence mode: source-only | artifact | runtime
Identity gate: PASS | FAIL (<why>)
Audited on:    <date>     Store policies checked: <date + sources>

DECISION: GO | CONDITIONAL GO | CONDITIONAL NO-GO | NO-GO
<one-sentence reason>

Coverage: <tested>/<total> controls (PASS+PASS-WARN+FAIL), <n> BLOCKED, <n> NOT TESTED, <n> MANUAL REVIEW

SCORES (value / coverage)
  Security     87/100  (coverage 64%)
  Privacy      ...
  Reliability  ...
  UX           ...
  Store        ...
  Overall      ...

COUNTS  Blockers: n  S4: n  S3: n  S2: n  S1: n  S0: n

RELEASE BLOCKERS      <ID - one line each>
CRITICAL / HIGH       <ID - one line each>
WHAT IS MISSING FOR A GO   <the BLOCKED/NOT TESTED areas that matter, and what is needed>
MANUAL REVIEW QUEUE   <items needing a human, with how to check>

Appendix A: Findings index (ID, severity, domain, status)
Appendix B: Coverage & Evidence Matrix
Appendix C: Data-flow, permission, and dependency inventories
Appendix D: Platform/device matrix actually exercised
```

## Decision rules

1. Any S5, or any open store/security/privacy/data-loss blocker -> **NO-GO**.
2. Identity gate FAIL -> cannot be GO.
3. Security, privacy, or store domains mostly NOT TESTED/BLOCKED -> cannot be GO; use CONDITIONAL NO-GO and list what unblocks it.
4. No blockers, S3/S4 remain with accepted fixes/mitigations -> **CONDITIONAL GO**, listing the conditions.
5. GO only when: identity gate passed, no open blockers, no open S4, security/privacy/store coverage adequate for the stated threat model, and no unreviewed MANUAL REVIEW items in those areas.

## Scoring

Score = 100 minus weighted open findings in the area (S5 -40, S4 -20, S3 -8, S2 -3, S1 -1, floor 0). Always print coverage beside the score: a 95 on 30% coverage means "little was checked", and the report must say so. Do not average scores to hide a blocker; the decision rules above override any number.

## Style

Direct and concise. Decision and blockers first, method last. Cite `file:line` or artifact path for every claim. Redact secrets and PII. Do not pad the report with passing checks; they live in Appendix B.
