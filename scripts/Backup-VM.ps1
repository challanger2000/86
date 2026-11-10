[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$vm = Join-Path $root 'VM'
$config = Join-Path $vm '86box.cfg'
if (-not (Test-Path -LiteralPath $config)) {
    throw "Keine VM gefunden: $config"
}
$running = @(Get-Process -Name '86Box' -ErrorAction SilentlyContinue)
if ($running.Count -gt 0) {
    throw '86Box laeuft noch. Zuerst Windows 95 herunterfahren, dann 86Box schliessen.'
}
$base = Join-Path $root 'BACKUPS'
[void](New-Item -ItemType Directory -Path $base -Force)
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$dest = Join-Path $base ("VM-" + $stamp)
if (Test-Path -LiteralPath $dest) { throw "Backup-Ziel existiert bereits: $dest" }
[void](New-Item -ItemType Directory -Path $dest -Force)
try {
    Copy-Item -LiteralPath $vm -Destination (Join-Path $dest 'VM') -Recurse -Force
    if (-not (Test-Path -LiteralPath (Join-Path $dest 'VM\86box.cfg'))) {
        throw 'Sicherung enthaelt keine 86box.cfg.'
    }
    Write-Host "Backup erstellt: $dest"
} catch {
    Write-Warning 'Sicherung moeglicherweise unvollstaendig. Bitte Ziel kontrollieren.'
    throw
}
