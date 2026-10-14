# Audit domains

Contents: A (01-03) · B (04-11, 20) · C (12-15, 19) · D (16-18, 21) · E (22-23) · F (24)

Each control is recorded in `audit/coverage.md` as `domain.control | state | method | evidence`. Platform-specific mechanics live in `android.md` / `ios.md`. Not every bullet applies to every app: mark non-applicable ones N/A with a reason, never delete them.

---
## A. Scope & Build

### 01 Application identity and scope
Capture: app name; Android package / iOS bundle ID; version + build number; git commit SHA, tag, branch; build timestamp; target environment and API endpoints (prod/staging/dev); Android min/target SDK; iOS min version; ABIs/architectures; device classes; languages and countries; auth model and account types; backend services; third-party SDKs; payments; push provider; analytics; crash reporting; cloud services; external APIs; data classes handled (PII, health, financial, location, children's, user content).
Gate: artifact must be tied to the one intended for publication (version, build, commit, signing identity). Otherwise no GO.

### 02 Build and release integrity
Audit the shipped artifact, not just source. Check: debuggable/debug flags off; debug endpoints, test credentials, dev menus, mock services, test ad IDs, staging URLs absent; verbose logging off; dev certs removed; signing config correct and dev/prod keys separated; bundle/package ID and versioning correct; optimization/minification on; symbols/mapping files archived (not shipped); no secrets, `.env`, API keys, source maps in package; no unused permissions or assets; lockfiles committed; reproducible/provenance-tracked CI build; signing-key protection and backup; rollback artifact retained. Inventory APK/AAB/IPA contents when tooling allows.

### 03 Install, upgrade, removal
Fresh install -> launch -> init -> auth -> configure -> use. Upgrade previous production release -> candidate: DB/schema migration, prefs migration, credentials/tokens retained, caches, user files, encryption migration, failed-migration recovery; also upgrade after long inactivity, logged in vs out, large local data, near-full storage. Removal/reinstall: what persists (Keychain/Keystore, shared storage, cloud backup, device IDs, auth state, downloads) and whether that is intended.

---
## B. Quality

### 04 Functional completeness
Build a feature inventory: `Feature -> Entry point -> Preconditions -> Actions -> Expected -> Error paths -> Recovery -> Exit state`. For each: normal, empty, invalid, boundary, duplicate, rapid, cancelled, interrupted, retry, timeout, permission denied, auth expired, network lost, backend failure. Exercise every interactive object (buttons, links, tabs, menus, sliders, switches, dialogs, forms, gestures, search, filter, sort, upload, download, share, notifications, widgets).

### 05 GUI / visual
Layout (alignment, margins, spacing, safe areas, clipping, overlap, truncation, inconsistent sizing, scroll defects, hidden controls); typography (consistency, hierarchy, wrapping, dynamic scaling, localization expansion); control consistency; light/dark/auto, increased contrast, enlarged text, reduced motion; orientation (rotate while editing/loading/in modal/during playback).

### 06 UX / usability
Onboarding, discoverability, hierarchy, nav consistency, cognitive load, terminology, confirmations, destructive-action warnings, undo, error messages, loading/progress/empty/success/failure states, contextual help. Measure friction for key tasks as launch-to-outcome counts: taps, screens, decisions, required inputs, waits, permission prompts.

### 07 Navigation and state
Per screen: Android back and predictive back, iOS swipe-back, in-app back, home, recents/app switcher, notification launch, deep link, external link return. State restoration after backgrounding, process death, low memory, screen lock, OS kill, reboot, network transition. Interruptions: call, notification, connectivity/GPS change, system load.

### 08 Accessibility
VoiceOver and TalkBack, semantic labels/roles, focus order (flag screens readable but nonsensical in order), keyboard/switch access, touch target size (>=48dp Android, >=44pt iOS), contrast, color-only indicators, dynamic type/text scale (test 200%), zoom, orientation, reduced motion, flashing content, captions/transcripts, alt text, error identification, accessible authentication, timeout extensions. Cross-reference `design:accessibility-review` for WCAG detail.

### 09 Device and OS compatibility
Matrix, not a single device. Android: Pixel, Samsung, low-end, tablet, foldable; min/current/latest OS. Apple: small iPhone, standard, Pro Max, iPad if supported; min/current iOS. Also DPIs, notches/Dynamic Island/cutouts, gesture nav, soft/physical keyboards, multi-window/split screen, fold/unfold. Record which cells were actually exercised.

### 10 Performance
Startup (cold/warm/hot, time-to-interactive); runtime (frame rate, dropped frames, UI stalls, CPU, memory, GPU, disk I/O, network); resource (idle and background battery, cellular/Wi-Fi data, cache/storage/DB growth). Record numbers and the device used; a perf PASS without a measurement is NOT TESTED.

### 11 Reliability and failure
Inject: airplane mode, Wi-Fi/cellular drop and switch, DNS failure, packet loss, latency, timeout, HTTP 401/403/404/429/500, malformed or partial response, maintenance, expired cert, low storage/memory/battery, revoked permission, expired auth, reboot. Question: does it fail safely, tell the truth, preserve user data, and recover on its own?

### 20 Offline and degraded connectivity
Fully offline, very slow, intermittent, change mid-transaction, duplicate request on retry. Evaluate offline capability, cached content, stale-data indication, queued operations, sync, conflict resolution, retry/backoff, duplicate prevention. Matters most where users create or edit data.

---
## C. Security

Map every finding to `security-masvs.md`.

### 12 Local / device security
Inspect SQLite, preferences/SharedPreferences/UserDefaults, files, caches, temp files, logs, crash reports, clipboard, screenshots/app-switcher previews, backups, notifications, Keychain/Keystore. Search for passwords, auth/refresh tokens, API keys, session IDs, PII, payment data, private URLs, encryption keys stored in the clear.

### 13 Network / transport security
TLS versions, cert and hostname validation, cleartext HTTP, insecure WebSockets, sensitive data in URLs, pinning where the threat model calls for it, proxy/MITM behavior, custom trust managers or "accept all" overrides.

### 14 Backend / API security
Never trust the client. Test only what is in scope (staging, or the user's own prod with consent). Object and function authorization (IDOR/BOLA), privilege escalation, tenant isolation, input validation, injection, mass assignment, API versioning, rate limiting, replay, enumeration, brute force, oversized/malformed requests, upload and content-type validation, token validation, webhook auth. Principle: changing a UI flag, request field, or decompiling the app must not bypass server-side authorization. If no backend exists, mark the domain N/A with evidence and note that the trust boundary is the device.

### 15 Authentication and authorization
Register, login, logout, reset, change password, email verification, MFA, biometrics, social/SSO, token refresh, session expiry, lockout, device trust. Attacks: stolen/expired/reused/copied token, modified role or user ID, simultaneous sessions, password change or account deletion during an active session. For local-only apps (PIN/biometric app lock): KDF strength, salt, attempt limiting, recovery path, relock timing, secure-storage use.

### 19 Reverse engineering and tampering
Depends on threat model; do not demand hardening a hobby app does not need. Check decompilation exposure, symbol leakage, readable strings, embedded endpoints/secrets, config extraction, repackaging, runtime instrumentation, debugger attach, hooking, root/jailbreak behavior (MASVS-RESILIENCE). Own builds only.

---
## D. Privacy, Permissions, Supply Chain, Telemetry

### 16 Privacy and data governance
Build a data-flow inventory. For every data element: collected? why? where stored? encrypted? who receives it? third parties? retention? deletion mechanism? Then diff reality against: privacy policy, App Store privacy labels, Google Play Data Safety, consent screens, analytics config. If accounts can be created, in-app account and data deletion must exist (store blocker on both platforms). Mismatch between declared and actual collection is a privacy + store blocker.

### 17 Permissions and platform integration
Inventory each permission: platform, feature, required?, runtime?, user explanation, denial behavior. Test allow, deny, don't-ask-again, allow once, while-using, approximate vs precise location, revoke-later. Minimum necessary, contextual (lazy) requests, graceful degradation. Check the *merged* manifest / final entitlements and plist purpose strings, because plugins add permissions silently.

### 18 Dependencies and supply chain
Inventory SDKs, frameworks, native libs, package-manager deps (including transitive), ad/analytics/auth/network/crypto libraries. For each: version, age, known vulnerabilities, license, maintainer, deprecation/abandonment, necessity. Produce an SBOM when tooling allows (CycloneDX/SPDX). Check lockfile integrity and pinned versions.

### 21 Logging, telemetry, supportability
Both directions: too little (no crash/error reporting, no correlation IDs, no build metadata) and too much (passwords, tokens, PII, payment data, sensitive request bodies, private state in logs or telemetry). Verify release builds do not log sensitive data to device logs (logcat / unified log). Confirm any telemetry matches the privacy declarations (domain 16).

---
## E. Store

### 22 Store compliance
Separate Apple and Google modules; details and the fetch-current-policy requirement in `store-compliance.md`.

### 23 Store listing and assets
Name, subtitle, short/long description, keywords, category, screenshots (per device class), icon, graphics, preview video, privacy policy URL, support/marketing URL, copyright, developer identity, contact, localization. Compare every claim to observed behavior: "works fully offline" while login needs the network is a listing-accuracy defect.

---
## F. Gate

### 24 Release readiness
Aggregate per `report-template.md`: severity, blocker classes, coverage, identity gate, decision.
