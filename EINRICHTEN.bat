@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === 86: Emulator einrichten ===
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-86Box.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" (
  echo Einrichtung nicht abgeschlossen. Keine VM wurde veraendert.
) else (
  echo Vorbereitung abgeschlossen. Als Naechstes lokale VM-Dateien bereitstellen.
)
echo.
pause
exit /b %RC%
