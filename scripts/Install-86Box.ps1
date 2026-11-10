# Download only the official emulator, never Windows, ROMs, drivers or Cakewalk.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root '86Box'
$exe = Join-Path $dest '86Box.exe'
$release = 'v6.0'
$url = 'https://github.com/86Box/86Box/releases/download/v6.0/86Box-Windows-64-b9001.zip'
$sha256 = 'b86722ed547089f095e8875805411f83c76aafd7d318f67286a5a69aecdd7644'
foreach ($folder in @('VM', 'AUSTAUSCH', 'BACKUPS')) {
    $p = Join-Path $root $folder
    if (-not (Test-Path -LiteralPath $p)) {
        [void](New-Item -ItemType Directory -Path $p -Force)
    }
}
if (Test-Path -LiteralPath $exe) {
    Write-Host '86Box.exe ist bereits vorhanden. Bestehende Installation bleibt unveraendert.'
    exit 0
}
if (Test-Path -LiteralPath $dest) {
    throw 'Ordner 86Box existiert, aber 86Box.exe fehlt. Bitte Ordner erst pruefen; es wird nichts ueberschrieben.'
}
$stage = Join-Path $env:TEMP ('86-Setup-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $stage -Force)
try {
    $archive = Join-Path $stage '86Box.zip'
    $unpacked = Join-Path $stage 'unpacked'
    Write-Host "Lade offizielle 86Box-Version $release ..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing
    $actual = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $sha256) {
        throw "Sicherheitsstopp: SHA256 stimmt nicht. Ist=$actual Soll=$sha256"
    }
    Expand-Archive -LiteralPath $archive -DestinationPath $unpacked -Force
    $found = @(Get-ChildItem -LiteralPath $unpacked -File -Recurse -Filter '86Box.exe')
    if ($found.Count -ne 1) {
        throw "Paketstruktur unerwartet: $($found.Count) x 86Box.exe gefunden."
    }
    [void](New-Item -ItemType Directory -Path $dest -Force)
    try {
        Get-ChildItem -LiteralPath $found[0].DirectoryName -Force | Copy-Item -Destination $dest -Recurse -Force
        if (-not (Test-Path -LiteralPath $exe)) {
            throw '86Box.exe nach Entpacken nicht gefunden.'
        }
    } catch {
        if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force -Recurse }
        throw
    }
    Write-Host 'Emulator erfolgreich geladen und SHA256-geprueft.'
    Write-Host 'Noch benoetigt: private VM mit Windows 95, Treibern, ROM und Cakewalk.'
} finally {
    if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Force -Recurse -ErrorAction SilentlyContinue
    }
}
