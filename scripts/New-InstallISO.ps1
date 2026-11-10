[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$SourceDirectory,[Parameter(Mandatory=$true)][string]$Destination)
$ErrorActionPreference='Stop'
$SourceDirectory=[IO.Path]::GetFullPath($SourceDirectory)
$Destination=[IO.Path]::GetFullPath($Destination)
if(!(Test-Path -LiteralPath $SourceDirectory -PathType Container)){throw 'ISO-Quellverzeichnis fehlt.'}
if(Test-Path -LiteralPath $Destination){throw 'ISO existiert bereits und wird nicht ueberschrieben.'}
$targetDir=[IO.Path]::GetDirectoryName($Destination)
if(!(Test-Path -LiteralPath $targetDir)){[void][IO.Directory]::CreateDirectory($targetDir)}
$tmp=$Destination+'.partial'
if(Test-Path -LiteralPath $tmp){throw 'Unvollstaendige ISO-Zwischendatei vorhanden.'}
$out=$null
$pointer=[IntPtr]::Zero
try {
  $fsi=New-Object -ComObject IMAPI2FS.MsftFileSystemImage
  $fsi.FileSystemsToCreate=3
  $fsi.VolumeName='125A_INSTALL'
  $fsi.Root.AddTree($SourceDirectory,$false)
  $image=$fsi.CreateResultImage()
  $istream=[System.Runtime.InteropServices.ComTypes.IStream]$image.ImageStream
  $out=[IO.File]::Open($tmp,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
  $buf=New-Object byte[] (64*1024)
  $pointer=[Runtime.InteropServices.Marshal]::AllocCoTaskMem(4)
  while($true){
    [Runtime.InteropServices.Marshal]::WriteInt32($pointer,0)
    $istream.Read($buf,$buf.Length,$pointer)
    $count=[Runtime.InteropServices.Marshal]::ReadInt32($pointer)
    if($count -le 0){break}
    $out.Write($buf,0,$count)
  }
  $out.Dispose();$out=$null
  $f=[IO.File]::OpenRead($tmp)
  try {
    if($f.Length -lt 34816){throw 'ISO ist zu klein.'}
    $f.Position=32769
    $marker=New-Object byte[] 5
    [void]$f.Read($marker,0,5)
    if([Text.Encoding]::ASCII.GetString($marker) -ne 'CD001'){throw 'ISO9660-Praefix CD001 fehlt.'}
  } finally {$f.Dispose()}
  Move-Item -LiteralPath $tmp -Destination $Destination
  Write-Host "Installations-CD erstellt: $Destination"
} catch {
  if($out){$out.Dispose()}
  Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  throw
} finally {
  if($pointer -ne [IntPtr]::Zero){[Runtime.InteropServices.Marshal]::FreeCoTaskMem($pointer)}
}
