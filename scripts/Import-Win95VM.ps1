# Create the lab-derived 86Box machine from an ALREADY INSTALLED, user-owned Windows 95 raw disk.
# Does not download or install Windows / Creative software / Cakewalk.
[CmdletBinding()]
param(
  [string]$DiskImage,
  [string]$DestinationRoot
)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($DestinationRoot)) {
    $DestinationRoot = Split-Path -Parent $PSScriptRoot
}
$DestinationRoot = [IO.Path]::GetFullPath($DestinationRoot)
if ([string]::IsNullOrWhiteSpace($DiskImage)) {
    Add-Type -AssemblyName System.Windows.Forms
    $picker = New-Object System.Windows.Forms.OpenFileDialog
    $picker.Title = 'Vorhandene Windows-95-Festplatte waehlen (512 MB IMG, KEIN ISO)'
    $picker.Filter = 'Raw-Festplatte (*.img;*.raw;*.hdd)|*.img;*.raw;*.hdd|Alle Dateien (*.*)|*.*'
    $picker.CheckFileExists = $true
    if ($picker.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host 'Abgebrochen - es wurde nichts eingerichtet.'
        exit 3
    }
    $DiskImage = $picker.FileName
}
$DiskImage = [IO.Path]::GetFullPath($DiskImage)
if (-not (Test-Path -LiteralPath $DiskImage -PathType Leaf)) {
    throw "Festplattenabbild nicht gefunden: $DiskImage"
}
$bytes = (Get-Item -LiteralPath $DiskImage).Length
if ($bytes -ne 536870912) {
    throw "Falsches Format/Groesse ($bytes Bytes). Der nachgewiesene P48-Laborstand verwendet genau 512 MiB Raw-IMG. Ein ISO oder ein anders grosses Plattenabbild kann hier nicht automatisch importiert werden."
}
if (@(Get-Process -Name '86Box' -ErrorAction SilentlyContinue).Count -gt 0) {
    throw '86Box laeuft noch. Bitte erst schliessen.'
}
$vm = Join-Path $DestinationRoot 'VM'
$config = Join-Path $vm '86box.cfg'
$disk = Join-Path $vm 'win95.img'
if ((Test-Path -LiteralPath $config) -or (Test-Path -LiteralPath $disk)) {
    throw 'Eine VM ist bereits vorhanden. Zur Sicherheit wird sie niemals automatisch ueberschrieben.'
}
if (-not (Test-Path -LiteralPath $vm)) { [void](New-Item -ItemType Directory -Path $vm -Force) }
if ([IO.Path]::GetFullPath($disk) -eq $DiskImage) {
    throw 'Quelle und Ziel duerfen nicht identisch sein.'
}
Write-Host 'Kopiere die private Windows-95-Festplatte in den VM-Ordner ...'
try {
    Copy-Item -LiteralPath $DiskImage -Destination $disk -ErrorAction Stop
    $copySize = (Get-Item -LiteralPath $disk).Length
    if ($copySize -ne $bytes) { throw 'Kopiertes Abbild hat eine andere Groesse.' }
    $cfg = @"
[General]
vid_renderer = sdl_software
confirm_exit = 0
[Machine]
machine = p55t2p4
cpu_family = pentium_p54c
cpu_speed = 133333333
cpu_multi = 2
cpu_use_dynarec = 1
fpu_type = internal
mem_size = 65536
time_sync = disabled
[Video]
gfxcard = vga
[Input devices]
keyboard_type = keyboard_at
mouse_type = ps2
[Sound]
sndcard = sbawe64_gold
[Network]
net_01_link = 0
[Storage controllers]
hdc = internal
[Hard disks]
hdd_01_fn = $disk
hdd_01_parameters = 63, 16, 1040, 0, ide
hdd_01_ide_channel = 0:0
hdd_01_speed = ramdisk
[Sound Blaster AWE64 Gold]
onboard_ram = 28672
[Floppy and CD-ROM drives]
fdd_01_type = 35_2hd
fdd_02_type = none
cdrom_01_parameters = 1, atapi
cdrom_01_ide_channel = 0:1
cdrom_01_speed = 24
cdrom_01_type = 86BOX_CD-ROM_1.00
"@
    [IO.File]::WriteAllText($config, $cfg, (New-Object System.Text.UTF8Encoding($false)))
} catch {
    if (Test-Path -LiteralPath $config) { Remove-Item -LiteralPath $config -Force }
    if (Test-Path -LiteralPath $disk) { Remove-Item -LiteralPath $disk -Force }
    throw
}
Write-Host ''
Write-Host 'VM-Konfiguration und private Plattenkopie erstellt.'
Write-Host 'ACHTUNG: Das prueft nur das Plattenformat, nicht ob Windows 95 bootet,'
Write-Host 'der Creative-Treiber installiert ist oder Cakewalk laeuft.'
Write-Host 'Wenn alles bereitliegt, START.bat verwenden.'
