# Reruns the PGM-100..199 data/engine/hostile audit scripts. Run from a SCRATCH CLONE of the repo, never the real folder:
#   git clone "C:\Project Folder\Pagemark" <scratch>\clone ; cd <scratch>\clone ; flutter pub get
#   powershell -File <path-to>\run_data_audit.ps1 -Repo <scratch>\clone
param([Parameter(Mandatory=$true)][string]$Repo)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($f in 'pgm_restore_audit_test.dart','pgm_ops_audit_test.dart','pgm_engine_audit_test.dart','pgm_hostile_audit_test.dart') {
  Copy-Item "$here\$f" "$Repo\test\$f" -Force
  Push-Location $Repo
  flutter test "test/$f" 2>&1 | Select-String 'AUDIT\||INFO|Some tests|All tests'
  Pop-Location
}
# Every line "AUDIT|<case>|FAIL|..." is a finding; the test run itself stays green by design.
