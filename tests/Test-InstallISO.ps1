$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$stage=Join-Path $env:TEMP ('awe-cd-test-'+[guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($stage)
try {
  $source=Join-Path $stage 'src'
  [void][IO.Directory]::CreateDirectory($source)
  [IO.File]::WriteAllText((Join-Path $source 'TEST.TXT'),'86Box ISO smoke')
  $out=Join-Path $stage 'TEST.iso'
  & (Join-Path $root 'scripts\New-InstallISO.ps1') -SourceDirectory $source -Destination $out
  if(-not(Test-Path $out)){throw 'ISO fehlt'}
  $f=[IO.File]::OpenRead($out)
  try{
    $f.Position=32769
    $b=New-Object byte[] 5
    [void]$f.Read($b,0,5)
    if([Text.Encoding]::ASCII.GetString($b) -ne 'CD001'){throw 'CD001-Marker fehlt'}
  } finally {$f.Dispose()}
  Write-Host 'PASS: CD wurde mit IMAPI2 erstellt und ISO9660-Signatur gelesen.'
  Write-Host 'NOT TESTED: Windows 95 erkennt die CD im Gast.'
} finally {Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue}
