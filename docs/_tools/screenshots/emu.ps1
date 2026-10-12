# Helpers for driving the Android emulator while taking documentation screenshots.
# Usage:  . .\emu.ps1   (dot-source), then Tap / Swipe / Txt / Back / Shot "name" / Relaunch
# Coordinates are in a 898x2000 preview space (the emulator is 1344x2992); x1.5 gives real pixels.
$global:adb = "$env:ANDROID_HOME\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { $global:adb = "C:\Android\sdk\platform-tools\adb.exe" }
$global:sp = Join-Path $PSScriptRoot "out"
New-Item -ItemType Directory -Force "$sp\shots" | Out-Null
$global:pkg = "com.axialforge.pagemark"
function Tap([double]$x, [double]$y) { & $adb shell input tap ([int]($x * 1.4965)) ([int]($y * 1.496)) | Out-Null; Start-Sleep -Milliseconds 900 }
function Swipe([double]$x1, [double]$y1, [double]$x2, [double]$y2, [int]$ms = 400) { & $adb shell input swipe ([int]($x1*1.4965)) ([int]($y1*1.496)) ([int]($x2*1.4965)) ([int]($y2*1.496)) $ms | Out-Null; Start-Sleep -Milliseconds 900 }
function Back() { & $adb shell input keyevent 4 | Out-Null; Start-Sleep -Milliseconds 800 }   # careful: Back on the library root leaves the app
function Txt([string]$t) { & $adb shell input text ($t -replace ' ', '%s') | Out-Null; Start-Sleep -Milliseconds 600 }   # not named Type: that is an alias for Get-Content
function Shot([string]$name) { cmd /c "`"$adb`" exec-out screencap -p > `"$sp\shots\$name.png`""; "$name " + (Get-Item "$sp\shots\$name.png").Length }
function Relaunch() { & $adb shell am force-stop $pkg; & $adb shell monkey -p $pkg -c android.intent.category.LAUNCHER 1 2>&1 | Out-Null; Start-Sleep -Seconds 6 }
