$ErrorActionPreference = 'Stop'

$packageName = 'pomodorot'
$url = 'https://github.com/mlm-games/pomodorot/releases/download/$version/pomodorot.exe'
$checksum = '$checksum'
$checksumType = 'sha256'

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'pomodorot.exe'

Get-ChocolateyWebFile -PackageName $packageName `
                      -FileFullPath $fileLocation `
                      -Url $url `
                      -Checksum $checksum `
                      -ChecksumType $checksumType

$guiFile = Join-Path $toolsDir 'pomodorot.exe.gui'
Set-Content -Path $guiFile -Value $null

Install-BinFile -Name 'pomodorot' -Path $fileLocation
