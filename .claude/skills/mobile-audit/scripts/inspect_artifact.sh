#!/usr/bin/env bash
# Usage: inspect_artifact.sh <app.apk|app.ipa> [outdir]
# Collects release-integrity evidence from a built artifact. Read-only; never runs the app.
# Missing tools are reported, not fatal: an absent tool means those controls are BLOCKED, not PASS.
set -u
art="${1:?usage: inspect_artifact.sh <app.apk|app.ipa> [outdir]}"
out="${2:-audit/artifact}"
mkdir -p "$out"
have() { command -v "$1" >/dev/null 2>&1; }
note() { echo "[inspect] $*" | tee -a "$out/inspect.log"; }

sha256sum "$art" 2>/dev/null > "$out/sha256.txt" || shasum -a 256 "$art" > "$out/sha256.txt"
note "artifact sha256: $(cut -d' ' -f1 "$out/sha256.txt")"

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
unzip -q -o "$art" -d "$work" 2>/dev/null || { note "cannot unzip $art"; exit 1; }
unzip -l "$art" > "$out/file-list.txt"

case "$art" in
  *.apk)
    have aapt2 && aapt2 dump badging "$art" > "$out/badging.txt" 2>&1 || note "aapt2 missing: SDK levels/permissions not extracted"
    have apkanalyzer && apkanalyzer manifest print "$art" > "$out/merged-manifest.xml" 2>&1 || note "apkanalyzer missing: merged manifest not extracted"
    have apksigner && apksigner verify --print-certs -v "$art" > "$out/signing.txt" 2>&1 || note "apksigner missing: signing identity not verified"
    grep -E "debuggable|allowBackup|usesCleartextTraffic" "$out/merged-manifest.xml" 2>/dev/null > "$out/manifest-flags.txt"
    ;;
  *.ipa)
    app="$(find "$work/Payload" -maxdepth 1 -name '*.app' | head -1)"
    have plutil && plutil -p "$app/Info.plist" > "$out/Info.plist.txt" 2>&1 || cp "$app/Info.plist" "$out/Info.plist" 2>/dev/null
    have codesign && codesign -d --entitlements :- "$app" > "$out/entitlements.txt" 2>&1 || note "codesign missing (needs macOS): entitlements not extracted"
    [ -f "$app/embedded.mobileprovision" ] && strings "$app/embedded.mobileprovision" | grep -Ei 'get-task-allow|ProvisionedDevices|aps-environment|Name' > "$out/provisioning.txt"
    find "$work/Payload" -name 'PrivacyInfo.xcprivacy' > "$out/privacy-manifests.txt"
    ;;
esac

# Secret / endpoint smell test. Output is file:line-style hits with the value redacted to its first 4 chars.
pat='(http://[A-Za-z0-9._/-]+|api[_-]?key|secret|passwd|password|BEGIN (RSA|EC|PRIVATE) |staging|\.env|AKIA[0-9A-Z]{8})'
grep -aroE "$pat" "$work" 2>/dev/null | sed -E 's/(:[A-Za-z0-9._\/-]{4})[^:]*$/\1…[redacted]/' | sort -u | head -200 > "$out/secret-smells.txt"
note "secret-smell hits: $(wc -l < "$out/secret-smells.txt") (review manually; many are false positives)"
note "evidence written to $out/"
