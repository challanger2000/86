@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === 86: VM sichern ===
echo Windows 95 muss ordentlich heruntergefahren und 86Box beendet sein.
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Backup-VM.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo Sicherung fehlgeschlagen - bitte Meldung lesen.
pause
exit /b %RC%
