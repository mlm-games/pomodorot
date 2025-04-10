$ErrorActionPreference = 'Stop'

$packageName = 'pomodorot'
$softwareName = 'Pomodorot*'
$installDir = Join-Path $env:ProgramFiles $packageName

# Remove the application files
if (Test-Path $installDir) {
  Remove-Item -Path $installDir -Recurse -Force
  Write-Host "Removed application files from $installDir"
}

# Remove shortcut from Start Menu
$startMenu = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs"
$shortcutFile = Join-Path $startMenu "$packageName.lnk"
if (Test-Path $shortcutFile) {
  Remove-Item -Path $shortcutFile -Force
  Write-Host "Removed Start Menu shortcut"
}

Write-Host "Pomodorot has been uninstalled"