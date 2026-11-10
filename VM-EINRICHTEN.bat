@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === Eigene Windows-95-Festplatte einbinden ===
echo Bitte eine bereits installierte, eigene Win95-Festplatte (512 MiB RAW .img) bereithalten.
echo Ein Windows-95-ISO ist noch KEINE installierte Festplatte.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Import-Win95VM.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo Einbinden nicht abgeschlossen.
pause
exit /b %RC%
