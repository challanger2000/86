# Creates a per-user desktop link, without admin privileges.
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root = Split-Path -Parent $PSScriptRoot
$launcher = Join-Path $root 'START.bat'
if (-not (Test-Path -LiteralPath $launcher)) { throw 'START.bat fehlt.' }
$desktop = [Environment]::GetFolderPath('Desktop')
if ([string]::IsNullOrWhiteSpace($desktop) -or -not (Test-Path -LiteralPath $desktop)) {
    throw 'Windows-Desktopordner konnte nicht gefunden werden.'
}
$shortcutPath = Join-Path $desktop '125A AWE64-PC.lnk'
$wshell = New-Object -ComObject WScript.Shell
$shortcut = $wshell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $launcher
$shortcut.WorkingDirectory = $root
$shortcut.Description = 'Privater 125A Windows-95/AWE64-Musik-PC'
$emulator = Join-Path $root '86Box\86Box.exe'
if (Test-Path -LiteralPath $emulator) {
    $shortcut.IconLocation = "$emulator,0"
}
$shortcut.Save()
Write-Host "Desktop-Symbol erstellt: $shortcutPath"
Write-Host 'Hinweis: Der eigentliche Win95-PC muss vorher eingerichtet sein.'
