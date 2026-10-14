# Store compliance and listing (domains 22, 23)

**These rules change often. Do not use remembered values.** At audit time, fetch the current official pages, and record in the report the URL, the date, and the specific requirement version or deadline you relied on. If you cannot fetch (offline), mark the affected controls BLOCKED, not PASS.

Sources to fetch:
- Apple: App Store Review Guidelines; App Privacy details / privacy manifest and required-reason API docs; account-deletion requirement; App Store Connect submission checklist; export-compliance docs.
- Google: Play Developer Program Policies; target-API-level requirement page; Data safety form help; account-deletion requirement; Permissions and restricted-permission declaration policies; Families policy (if applicable); foreground-service type requirements.

## Method
1. From Phase 1-2 inventories, derive what the app *does* (accounts, payments, UGC, tracking, location, kids, subscriptions, background work).
2. For each store-policy area below, decide applicable / not applicable with evidence.
3. Compare the store declarations (privacy labels, Data Safety, age rating, permission forms) to observed behavior and SDK inventory. A mismatch is a **store + privacy blocker**.
4. Treat a likely rejection or later takedown as a blocker class `store`; treat a missing optional improvement as S1-S2.

## Apple checklist (domain 22, iOS)
- Account deletion in-app if account creation exists
- Sign in with Apple applicability (third-party/social login present)
- In-App Purchase for digital goods, subscriptions terms shown, Restore Purchases
- Tracking: ATT prompt only when tracking; matches privacy labels and `NSUserTrackingUsageDescription`
- Privacy labels and privacy manifests (app + SDKs) match actual data use
- Permission purpose strings present, specific, truthful
- Age rating answers, export compliance / encryption declaration, content rights
- UGC: filtering, report, block, contact, if user content exists
- Reviewer access: notes, demo credentials, backend reachable for review
- No private API use, minimum functionality (not a thin web wrapper), accurate metadata
- iPad support claims match iPad layout

## Google Play checklist (domain 22, Android)
- Target API level meets the current requirement; 64-bit; AAB
- Data safety form matches actual collection/sharing, including SDK behavior
- Privacy policy URL live, accurate, reachable without login
- Account deletion: in-app path plus web path, and data-deletion disclosure
- Permissions: only needed; declaration forms for restricted ones (SMS, call log, background location, all-files access, accessibility, exact alarm, etc.)
- Foreground-service types and background-work compliance
- Ads declaration, content rating, target audience / Families, if applicable
- Play Billing for digital goods; subscription behavior and cancellation clarity
- Pre-launch report results, Android Vitals baseline (post-release)
- Store listing policy: no misleading claims, impersonation, or metadata spam

## Listing audit (domain 23)
Check: name, subtitle/short description, long description, keywords, category, screenshots per device class, icon, promo graphics, preview video, privacy policy URL, support and marketing URL, copyright, developer identity, contact, localization. **Claim-vs-reality pass:** list every factual claim in the listing ("offline", "no ads", "private", "free", "syncs across devices", "no account needed") and verify each against the app and the audit evidence. Inaccurate claim = listing-accuracy defect (S2-S3, store blocker if it contradicts privacy or data declarations).

## Output
Add a "Store disclosure diff" table to the report appendix: declared vs observed, per data type and per permission, with evidence references.
