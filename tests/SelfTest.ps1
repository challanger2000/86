# Only checks starter script syntax & safety, not guest OS installation.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
foreach ($relative in @('scripts/Install-86Box.ps1', 'scripts/Backup-VM.ps1')) {
    $file = Join-Path $root $relative
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) { throw "PowerShell-Parserfehler in $relative : $($errors | Out-String)" }
}
foreach ($relative in @('README.md', '.gitignore', 'EINRICHTEN.bat', 'START.bat', 'DATEIEN.bat', 'BACKUP.bat')) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative))) {
        throw "Fehlende Datei: $relative"
    }
}
$start = Get-Content (Join-Path $root 'START.bat') -Raw
if (-not $start.Contains('--vmpath')) { throw 'START.bat verwendet keinen expliziten VM-Pfad.' }
if (-not $start.Contains('86box.cfg')) { throw 'START.bat prueft keine VM-Konfiguration.' }
$setup = Get-Content (Join-Path $root 'scripts/Install-86Box.ps1') -Raw
if ($setup -notmatch "sha256 = '[0-9a-f]{64}'") { throw 'Gepinnte SHA256-Summe fehlt.' }
$ignore = Get-Content (Join-Path $root '.gitignore') -Raw
foreach ($entry in @('/VM/', '/86Box/', '/AUSTAUSCH/', '/BACKUPS/')) {
    if (-not $ignore.Contains($entry)) { throw "Private Assets nicht ignoriert: $entry" }
}
Write-Host 'PASS: Starterdateien vorhanden, PowerShell-Syntax gueltig und Sicherheitsregeln gesetzt.'
Write-Host 'NOT TESTED: 86Box Runtime, BIOS, Windows 95, AWE64, Cakewalk, Audio, Dateiaustausch im Gast.'
