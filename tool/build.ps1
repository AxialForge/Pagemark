# Builds the release files for a version: signed sideload APKs named the way the in-app updater expects,
# plus the Google Play bundle. Needs android/key.properties (the keystore stays on this PC).
#   powershell -File tool/build.ps1
$ErrorActionPreference = 'Stop'
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:/tmpj'   # JDK 25 + Gradle on Windows (see CLAUDE.md)
Set-Location (Split-Path $PSScriptRoot -Parent)
$version = ((Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9.]+)').Matches[0].Groups[1].Value)
$out = "build/release-$version"
New-Item -ItemType Directory -Force $out | Out-Null

flutter build apk --release --split-per-abi --flavor sideload
if ($LASTEXITCODE -ne 0) { throw 'sideload build failed' }
$apkDir = 'build/app/outputs/flutter-apk'
# the updater picks the asset whose name contains "arm64" or "armv7"
Copy-Item "$apkDir/app-arm64-v8a-sideload-release.apk"   "$out/Pagemark-$version-arm64.apk" -Force
Copy-Item "$apkDir/app-armeabi-v7a-sideload-release.apk" "$out/Pagemark-$version-armv7.apk" -Force

flutter build appbundle --release --flavor play
if ($LASTEXITCODE -ne 0) { throw 'play bundle build failed' }
Copy-Item 'build/app/outputs/bundle/playRelease/app-play-release.aab' "$out/Pagemark-$version-play.aab" -Force

Get-ChildItem $out | ForEach-Object { '{0}  {1:N1} MB  {2}' -f $_.Name, ($_.Length / 1MB), (Get-FileHash $_.FullName -Algorithm SHA256).Hash }
'Attach the two .apk files to the GitHub release. Upload the .aab to Play Console (internal testing first).'
