[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$disk=Join-Path $root 'VM\win95.img'
$verifier=Join-Path $root 'tools\AWE95-Guest-Verify.exe'
$report=Join-Path $root 'VM\PRUEFERGEBNIS.json'
if(!(Test-Path -LiteralPath $disk) -or !(Test-Path -LiteralPath $verifier)) {
  Write-Warning 'Nachpruefung nicht moeglich: Gastabbild oder Pruefprogramm fehlt.'
  exit 2
}
# Never inspect a writable 86Box guest disk while that emulator runs.
$running=Get-CimInstance Win32_Process -Filter "name='86Box.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.ExecutablePath -and [IO.Path]::GetFullPath($_.ExecutablePath).StartsWith((Join-Path $root '86Box'),[StringComparison]::OrdinalIgnoreCase) }
if($running) {
  Write-Warning '86Box laeuft noch. Kein paralleler Zugriff auf die virtuelle Festplatte.'
  exit 3
}
& $verifier --disk $disk --report $report
if($LASTEXITCODE -ne 0) { Write-Warning 'Dateipruefung fehlgeschlagen.'; exit 4 }
if(!(Test-Path -LiteralPath $report)) { throw 'Guest-Statusreport fehlt.' }
$s=Get-Content -LiteralPath $report -Raw | ConvertFrom-Json
if($s.cakewalk_program_files_present -eq $true) {
  Write-Host '[OK] Cakewalk-Programmdateien in der virtuellen Festplatte gefunden.'
  Write-Host 'ACHTUNG: Programmstart, MIDI, SoundFont und Audioausgabe sind noch nicht geprueft.'
} elseif($s.cakewalk_setup_attempted -eq $true) {
  Write-Warning 'Cakewalk-Setup wurde versucht, aber keine installierte CWPA.EXE gefunden.'
} elseif($s.cakewalk_installer_staged -eq $true) {
  Write-Host 'Cakewalk-Setup liegt bereit, wurde im Gast noch nicht als gestartet erkannt.'
} else {
  Write-Warning 'Noch keine Cakewalk-Installation erkennbar.'
}
Write-Host ('Pruefbericht: '+$report)
exit 0
