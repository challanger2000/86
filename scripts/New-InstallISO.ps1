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
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
public static class AWE86_ImapiWriter {
  public static void Save(object comObject, string fileName) {
    IStream input=(IStream)comObject;
    using(FileStream output=new FileStream(fileName,FileMode.CreateNew,FileAccess.Write,FileShare.None)) {
      byte[] buffer=new byte[65536];
      IntPtr readCount=Marshal.AllocCoTaskMem(4);
      try {
        while(true) {
          Marshal.WriteInt32(readCount,0);
          input.Read(buffer,buffer.Length,readCount);
          int count=Marshal.ReadInt32(readCount);
          if(count<=0) break;
          output.Write(buffer,0,count);
        }
      } finally { Marshal.FreeCoTaskMem(readCount); }
    }
  }
}
'@
try {
  $fsi=New-Object -ComObject IMAPI2FS.MsftFileSystemImage
  $fsi.FileSystemsToCreate=3
  $fsi.VolumeName='125A_INSTALL'
  $fsi.Root.AddTree($SourceDirectory,$false)
  $image=$fsi.CreateResultImage()
  [AWE86_ImapiWriter]::Save($image.ImageStream,$tmp)
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
  Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  throw
} finally {
  if($pointer -ne [IntPtr]::Zero){[Runtime.InteropServices.Marshal]::FreeCoTaskMem($pointer)}
}
