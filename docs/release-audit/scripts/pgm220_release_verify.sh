#!/usr/bin/env bash
# PGM-220..PGM-228 evidence: verify the PUBLISHED GitHub release assets (read-only; downloads from this repo's own releases only).
# Usage: bash pgm220_release_verify.sh <empty_scratch_dir> [tag ...]      (default tags: v0.4.2 v0.5.0 v0.7.0)
# Never executes the APKs. Needs: gh (authenticated, read-only use), Android build-tools 36.0.0 (apksigner, aapt2, zipalign).
set -u
S="${1:?scratch dir}"; shift
TAGS=("${@:-v0.4.2 v0.5.0 v0.7.0}")
BT=/c/Android/sdk/build-tools/36.0.0
EXPECT_SHA1=390459ad240f35994bcda58681af9c218cfd27f7
for t in ${TAGS[@]}; do
  d="$S/$t"; mkdir -p "$d"; gh release download "$t" -R AxialForge/Pagemark -D "$d"
  for f in "$d"/*.apk; do
    echo "== $f"
    echo "sha256 $(sha256sum "$f" | cut -c1-64)  (compare with: gh release view $t --json assets -q '.assets[].digest')"
    cmd //c "$(cygpath -w $BT/apksigner.bat)" verify -v --print-certs "$f" | grep -E "Verifies|Verified using v[0-9.]+ scheme|certificate SHA-1"
    cmd //c "$(cygpath -w $BT/apksigner.bat)" verify --print-certs "$f" | grep -q "$EXPECT_SHA1" && echo "SIGNER-OK" || echo "SIGNER-MISMATCH"
    $BT/aapt2.exe dump badging "$f" | grep -E "^package:|sdkVersion|native-code"
    $BT/zipalign.exe -c -P 16 -v 4 "$f" | grep -E "\.so|Verification"
  done
done
