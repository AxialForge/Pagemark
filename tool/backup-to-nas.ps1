<#
  Backs the Pagemark project up to the home NAS. Safe to re-run: it only ever writes inside the target folder.

    powershell -ExecutionPolicy Bypass -File tool\backup-to-nas.ps1
    powershell -ExecutionPolicy Bypass -File tool\backup-to-nas.ps1 -Nas "\\host\share\folder" -SkipKeys

  Layout written to the NAS folder:
    source\         mirror of the working tree (no build output, caches, .git or secrets)
    git-bundles\    full git history as a single file per run (restore: git clone <bundle> Pagemark)
    releases\<ver>\ the signed APKs of the current version, if they exist in build\
    signing-keys\   release keystore + key.properties (the ONLY copy outside this PC; keep the share private)
    BACKUP-INFO.txt what/when/which commit, and how to restore
#>
param(
  [string]$Nas = "\\192.168.1.204\Apocrypha_Main_Pool\Libary_Pool\APP Projects\PageMark",
  [switch]$SkipKeys,
  [int]$KeepBundles = 10
)
$ErrorActionPreference = 'Continue'   # native tools (git, robocopy) print progress on stderr; we check exit codes explicitly
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path -LiteralPath $Nas)) { throw "NAS folder not reachable: $Nas" }
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$ver = ((Select-String -Path pubspec.yaml -Pattern '^version:\s*([\d.]+)').Matches[0].Groups[1].Value)
$commit = (git rev-parse --short HEAD).Trim()
$dirty = if (@(git status --porcelain).Count -gt 0) { 'yes (uncommitted changes are in source\, not in the bundle)' } else { 'no' }
Write-Host "Backing up Pagemark $ver ($commit) to $Nas"

# 1. source mirror (/MIR keeps source\ identical to the tree; it never touches the other folders)
$src = Join-Path $Nas 'source'
New-Item -ItemType Directory -Force -Path $src | Out-Null
robocopy $root $src /MIR /R:2 /W:2 /NFL /NDL /NJH /NP `
  /XD build .dart_tool .git .idea .gradle .kotlin out node_modules `
  /XF local.properties key.properties *.jks *.keystore *.iml | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed with exit code $LASTEXITCODE" }

# 2. git history as one verifiable file
$bdir = Join-Path $Nas 'git-bundles'
New-Item -ItemType Directory -Force -Path $bdir | Out-Null
$bundle = Join-Path $bdir "pagemark-$stamp-v$ver.bundle"
$null = git bundle create $bundle --all 2>&1
if ($LASTEXITCODE -ne 0) { throw "git bundle create failed" }
$null = git bundle verify $bundle 2>&1
if ($LASTEXITCODE -ne 0) { throw "git bundle verification failed" }
Get-ChildItem $bdir -Filter *.bundle | Sort-Object LastWriteTime -Descending | Select-Object -Skip $KeepBundles | Remove-Item -Force

# 3. signed APKs of this version
$apks = Get-ChildItem 'build\app\outputs\flutter-apk' -Filter "Pagemark-$ver-*.apk" -ErrorAction SilentlyContinue
if ($apks) {
  $rdir = Join-Path $Nas "releases\$ver"
  New-Item -ItemType Directory -Force -Path $rdir | Out-Null
  $apks | Copy-Item -Destination $rdir -Force
}

# 4. signing keys (needed to publish updates that install over existing installs)
$keysNote = 'skipped (-SkipKeys)'
if (-not $SkipKeys) {
  $kdir = Join-Path $Nas 'signing-keys'
  New-Item -ItemType Directory -Force -Path $kdir | Out-Null
  $jks = Join-Path $env:USERPROFILE '.android\pagemark-release.jks'
  if (Test-Path $jks) { Copy-Item $jks $kdir -Force }
  if (Test-Path 'android\key.properties') { Copy-Item 'android\key.properties' $kdir -Force }
  Set-Content -Path (Join-Path $kdir 'README.txt') -Value @"
Pagemark release signing key.
pagemark-release.jks  - the keystore (alias: pagemark). key.properties holds its passwords in plain text.
Restore on a new PC: copy the .jks to %USERPROFILE%\.android\, copy key.properties to <project>\android\,
and fix the storeFile= line in key.properties to the new path. Keep this folder private.
Without this key, new versions can't be installed over existing ones (users would have to uninstall first).
Release certificate SHA-1: 39:04:59:AD:24:0F:35:99:4B:CD:A5:86:81:AF:9C:21:8C:FD:27:F7
"@
  $keysNote = if (Test-Path (Join-Path $kdir 'pagemark-release.jks')) { 'copied' } else { 'NOT FOUND on this PC' }
}

# 5. verify the mirror and write the info file
$expected = (Get-ChildItem $root -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -notmatch '\\(build|\.dart_tool|\.git|\.idea|\.gradle|\.kotlin|out|node_modules)\\' -and
    $_.Name -notin @('local.properties', 'key.properties') -and $_.Extension -notin @('.jks', '.keystore', '.iml') }).Count
$actual = (Get-ChildItem $src -Recurse -File -Force -ErrorAction SilentlyContinue).Count
Set-Content -Path (Join-Path $Nas 'BACKUP-INFO.txt') -Value @"
Pagemark backup
When:        $(Get-Date -Format 'yyyy-MM-dd HH:mm')
Version:     $ver
Git commit:  $commit   (uncommitted changes: $dirty)
Files:       $actual in source\ (expected $expected)
Bundle:      $(Split-Path -Leaf $bundle)
APKs:        $(if ($apks) { ($apks.Name -join ', ') } else { 'none found in build\' })
Signing key: $keysNote

Restore the project:
  git clone "$bundle" Pagemark          # full history, then: flutter pub get
  (or copy source\ anywhere and run: flutter pub get; dart run build_runner build)
Build notes (Windows + JDK 25): see CLAUDE.md "Gotchas" or tool\build.ps1.
"@
Write-Host "Done. source\ files: $actual (expected $expected). Bundle: $(Split-Path -Leaf $bundle). Keys: $keysNote."
if ($actual -ne $expected) { Write-Warning "File count differs from the working tree; check the NAS folder." }
