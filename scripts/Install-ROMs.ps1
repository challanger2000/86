# Install official 86Box ROM set locally. Never commit binaries.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $root '86Box\roms'
$bios = 'machines\p55t2p4\0207_j2.bin'
$awe = 'sound\creative\awe32.raw'
if ((Test-Path -LiteralPath (Join-Path $target $bios)) -and (Test-Path -LiteralPath (Join-Path $target $awe))) {
    Write-Host '86Box-ROMs sind bereits vorhanden (BIOS und AWE-ROM gefunden).'
    exit 0
}
if (Test-Path -LiteralPath $target) {
    throw 'ROM-Ordner ist bereits vorhanden, aber unvollstaendig. Es wird nichts ueberschrieben.'
}
$emulator = Join-Path $root '86Box\86Box.exe'
if (-not (Test-Path -LiteralPath $emulator)) { throw 'Zuerst 86Box installieren.' }
$revision = '26761b5ab25786b4405c6829236fa745436e5399' # official 86Box/roms v6.0 tag commit
$url = "https://github.com/86Box/roms/archive/$revision.zip"
$stage = Join-Path $env:TEMP ('86-ROM-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $stage -Force)
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host 'Lade offiziellen ROM-Satz aus 86Box/roms (festgelegter Git-Commit) ...'
    $archive = Join-Path $stage 'roms.zip'
    Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $archive
    $unpacked = Join-Path $stage 'unpacked'
    Expand-Archive -LiteralPath $archive -DestinationPath $unpacked
    $candidates = @(Get-ChildItem -LiteralPath $unpacked -Directory)
    if ($candidates.Count -ne 1) { throw 'ROM-Archiv: unerwartete Ordnerstruktur.' }
    $source = $candidates[0].FullName
    foreach ($required in @($bios,$awe)) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $required))) {
            throw "ROM-Archiv ohne erwartete Datei: $required"
        }
    }
    Move-Item -LiteralPath $source -Destination $target
    Set-Content -LiteralPath (Join-Path $target '86box-source.txt') -Value "86Box/roms $revision; official v6.0 tag" -Encoding Ascii
    Write-Host 'BIOS und AWE-ROMs installiert (nur lokal).'
} finally {
    Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
}
