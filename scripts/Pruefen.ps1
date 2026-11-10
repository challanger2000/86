# Friendly diagnostics without touching the private guest image.
[CmdletBinding()]
param()
$root = Split-Path -Parent $PSScriptRoot
$emu = Join-Path $root '86Box\86Box.exe'
$rom = Join-Path $root '86Box\roms'
$bios = Join-Path $rom 'machines\p55t2p4\0207_j2.bin'
$awe = Join-Path $rom 'sound\creative\awe32.raw'
$cfg = Join-Path $root 'VM\86box.cfg'
$disk = Join-Path $root 'VM\win95.img'
$checks = @(
    @{ Name='86Box 6.0'; File=$emu },
    @{ Name='Pentium BIOS'; File=$bios },
    @{ Name='AWE ROM'; File=$awe },
    @{ Name='VM-Konfiguration'; File=$cfg },
    @{ Name='Windows 95-Plattenabbild'; File=$disk }
)
$missing = 0
foreach($x in $checks) {
    if (Test-Path -LiteralPath $x.File -PathType Leaf) {
        Write-Host "[OK]     $($x.Name)"
    } else {
        Write-Host "[FEHLT]  $($x.Name)"
        $missing++
    }
}
if (Test-Path -LiteralPath $cfg) {
    $configText = Get-Content -LiteralPath $cfg -Raw
    foreach($value in @('machine = p55t2p4','mouse_type = ps2','sndcard = sbawe64_gold','onboard_ram = 28672')) {
        if (-not $configText.Contains($value)) {
            Write-Host "[WARNUNG] VM-Einstellung fehlt: $value"
            $missing++
        }
    }
}
if ((Test-Path -LiteralPath $disk) -and (Get-Item -LiteralPath $disk).Length -ne 536870912) {
    Write-Host '[WARNUNG] Die Windows-Festplatte hat nicht die P48-Referenzgroesse von 512 MiB.'
    $missing++
}
Write-Host ''
if ($missing) {
    Write-Host "Nicht startbereit: $missing fehlende oder abweichende Grundvoraussetzungen."
    Write-Host 'EINRICHTEN.bat fuer Emulator und ROMs, VM-EINRICHTEN.bat fuer vorhandenes Windows 95-IMG.'
    exit 1
}
Write-Host 'Grunddateien vorhanden. Das ist KEIN Nachweis fuer einen Win95-/Treiber-/Cakewalk-Start.'
exit 0
