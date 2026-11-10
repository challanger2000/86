@echo off
setlocal EnableExtensions
set "ROOT=%~dp0"
if not exist "%ROOT%86Box\86Box.exe" goto :missing
if not exist "%ROOT%86Box\roms\machines\p55t2p4\0207_j2.bin" goto :missing
if not exist "%ROOT%86Box\roms\sound\creative\awe32.raw" goto :missing
if not exist "%ROOT%VM\86box.cfg" goto :missing
if not exist "%ROOT%VM\win95.img" goto :missing
cd /d "%ROOT%86Box"
start "" /D "%ROOT%86Box" "%ROOT%86Box\86Box.exe" --vmpath "%ROOT%VM" --rompath "%ROOT%86Box\roms"
if errorlevel 1 (
  echo 86Box konnte nicht gestartet werden.
  pause
  exit /b 4
)
exit /b 0
:missing
echo.
echo Noch nicht startbereit.
echo Bitte zuerst EINRICHTEN.bat und VM-EINRICHTEN.bat ausfuehren.
echo Danach zeigt PRUEFEN.bat, welche Datei fehlt.
echo.
pause
exit /b 3
