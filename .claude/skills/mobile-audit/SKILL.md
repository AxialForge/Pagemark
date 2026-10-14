---
name: mobile-audit
description: Run a structured, evidence-based release audit of an Android and/or iOS mobile app (native, Flutter, React Native, or hybrid) and end with a Go / Conditional / No-Go decision. Covers build integrity, functional/UX/accessibility/performance/reliability, local + network + backend security (OWASP MASVS/MASWE/MASTG traceability), privacy and data governance, permissions, supply chain, and Apple/Google store compliance and listing accuracy. Use whenever the user wants to audit, review, vet, harden, or "check before release" a mobile app, asks if an app is ready for the App Store or Google Play, wants a security/privacy/compliance review of an APK/AAB/IPA or a mobile codebase, or mentions MASVS, Data Safety, privacy labels, or release readiness - even if they do not say "audit".
---

# Mobile App Audit

Produces a traceable release audit: every control ends in an explicit state backed by evidence, every problem is a structured finding, and the output is a release decision rather than a pass count.

**Why it is built this way.** An LLM audit's characteristic failure is silence being read as safety: "I found no problems" gets reported as "there are no problems". So this skill never lets an untested item pass. It also separates what was *run* from what was *inferred from code*, because a static read of Dart/Kotlin/Swift cannot prove runtime behavior on a device.

## Authorization and scope

Audit only apps the user owns or is authorized to assess. Tamper, instrumentation, and reverse-engineering checks (domain 19) run against the user's own builds. Do not run active tests against third-party backends or production services without the user confirming they are in scope; static analysis and test/staging targets are the default.

## Workflow

Work phase by phase. Each phase writes evidence to `audit/` (create it in the repo root, or ask where) and later phases consume it, e.g. Discovery -> Data Inventory -> Privacy -> Store Disclosure. Do not re-derive facts an earlier phase established.

| Section | Phases | Domains (see `references/domains.md`) |
|---|---|---|
| **A. Scope & Build** | 0 Init, 1 Discovery, 2 Architecture/attack surface | 01 Identity, 02 Build integrity, 03 Install/upgrade/removal |
| **B. Quality** | 3 Feature inventory, 4 Functional, 5 GUI, 6 UX/A11y, 7 Compat, 8 Perf, 9 Reliability | 04-11, 20 Offline |
| **C. Security** | 10 Local, 11 Network, 12 API/backend, 13 Authn/Authz, 17 Tamper | 12-15, 19 |
| **D. Privacy & Supply chain** | 14 Privacy, 15 Permissions, 16 Dependencies/SBOM, 18 Logging/telemetry | 16, 17, 18, 21 |
| **E. Store** | 19 Apple, 20 Google, 21 Listing | 22, 23 |
| **F. Gate** | 22 Regression verify, 23 RC audit, 24 Decision | 24 |

The user may ask for one section or one domain ("just the security section", "just Google Play compliance"). Run what was asked, still do Phase 0-1 (they are cheap and everything depends on them), and mark everything else NOT TESTED in the report instead of omitting it.

### Phase 0 - Initialization
1. Ask or detect: platforms in scope, the artifact under audit (path/hash of APK/AAB/IPA, or "source only"), target environment, threat model/data sensitivity, and what the user wants (full audit vs section).
2. Choose an **evidence mode** and state it up front:
   - **Source-only** - repo access, no build. Static findings only; runtime states become NOT TESTED or MANUAL REVIEW.
   - **Artifact** - APK/AAB/IPA inspected (`scripts/inspect_artifact.sh` for Android helpers). Verifies what actually ships.
   - **Runtime** - app executed on emulator/device by the user or via tooling; dynamic checks possible.
3. Create `audit/coverage.md` (see Evidence states) and `audit/findings/`.

### Phase 1 - Discovery (domain 01)
Capture the identity record from `references/domains.md` section 01 (IDs, version, build, commit SHA, SDK levels, backends, SDKs, data classes). Pull from manifests, `Info.plist`, `pubspec.yaml`/`package.json`/Gradle, CI config, and git.

**Identity gate:** if the audited artifact cannot be tied to the artifact intended for publication (same version/build/commit/signing), the final decision may not be "Go". Say so in the report header.

### Phase 2 - Architecture and attack surface
Draw the flow `Client -> Network -> Edge -> API -> Auth -> Services -> Storage`, list every entry point (deep links, intents, URL schemes, exported components, push payloads, share targets, file imports, widgets) and every outbound host. This map drives Sections C and D; refer back to it rather than re-scanning.

### Phases 3-9 - Quality, 10-18 - Security/Privacy/Supply chain, 19-21 - Store
For each domain, open its entry in `references/domains.md`, then load only the platform file(s) in scope:
- `references/android.md` - manifest, Gradle, Keystore, Play specifics, tooling commands
- `references/ios.md` - plist, entitlements, ATS, Keychain, App Store specifics, tooling commands
- `references/security-masvs.md` - control-group traceability (MASVS-STORAGE/CRYPTO/AUTH/NETWORK/PLATFORM/CODE/RESILIENCE/PRIVACY) for every security finding
- `references/store-compliance.md` - store checks. **Store policies change; fetch or version-check current Apple and Google requirements at audit time** (WebSearch/WebFetch) and record the date and source you used. Never rely on memory for target-API deadlines, Data Safety rules, or review guidelines.

For each control: test or inspect, record the state and evidence, and raise a finding if it fails. Prefer cheap deterministic checks (grep, plist/manifest parse, dependency listing, `aapt2`) over reasoning from impressions. Fan independent domains out to subagents when many are in scope; give each the Phase 1-2 artifacts and the finding schema, and have it return findings plus coverage rows, not prose.

### Phases 22-24 - Verification and decision
Re-test every FAIL that the user fixed during the audit, on the same artifact lineage, and record the result. Then compute the decision with `references/report-template.md`.

## Evidence states (the Coverage & Evidence Matrix)

Every control gets exactly one state. There is no implicit pass.

| State | Meaning | Requires |
|---|---|---|
| PASS | Tested, requirement met | Evidence (command output, file+line, screenshot, log) |
| PASS-WARN | Met, with a concern | Evidence + concern |
| FAIL | Requirement violated | Evidence + a finding ID |
| BLOCKED | Could not test (no device, no creds, no network) | What was missing |
| N/A | Demonstrably not applicable | Why (e.g. "no accounts exist: manifest + code search show no sign-up") |
| NOT TESTED | Audit did not evaluate it | - |
| MANUAL REVIEW | A human must verify | What to check and how |

Also tag each PASS/FAIL with how it was established: `[runtime]`, `[artifact]`, or `[static]`. A `[static]` PASS on a runtime behavior (e.g. "screenshots are blocked", "token not logged") is capped at PASS-WARN unless backed by a test. The report's headline must show the coverage ratio (tested vs NOT TESTED/BLOCKED) next to every score, because a score over thin coverage is misleading.

## Findings

One structured finding per issue, using the schema in `references/findings-schema.md`, saved as `audit/findings/<ID>.md`. IDs: `MOB-<DOMAIN>-<nnnn>` (`SEC`, `API`, `PRV`, `UX`, `PERF`, `REL`, `STORE`, `BLD`, `A11Y`, `IOS`, `AND`). Severity S0-S5 plus blocker flags (store / security / functional / data-loss / privacy / quality) are defined there. Rules:
- Evidence is mandatory; a finding without a reproducible observation is a hypothesis - mark confidence `low` and route it to MANUAL REVIEW.
- Never print secrets, tokens, or PII found during the audit. Cite location and type, redact the value.
- Recommend a concrete remediation and a verification procedure so Phase 22 can close it.
- Server-side trust: any control enforced only by the client is a finding (the client is attacker-controlled).

## Decision and report

Follow `references/report-template.md`: header (identity + evidence mode + coverage), scores per area, decision (GO / CONDITIONAL GO / CONDITIONAL NO-GO / NO-GO), blockers, critical findings, then the coverage matrix and appendix. Rules for the decision:
- Any S5, or any unresolved store/security/privacy/data-loss blocker -> NO-GO.
- Identity gate failed -> cannot be GO.
- Large NOT TESTED / BLOCKED areas in security, privacy, or store -> cannot be GO; say what is missing to get there.
- Be direct: lead with the decision and blockers, not the methodology.

Offer to publish the report as an artifact or write it to `audit/REPORT.md`.
