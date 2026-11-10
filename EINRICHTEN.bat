@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === 86: Emulator UND ROMs einrichten ===
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-86Box.ps1"
if errorlevel 1 goto :failed
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-ROMs.ps1"
if errorlevel 1 goto :failed
echo.
echo Emulator und BIOS/AWE-ROMs sind vorbereitet.
echo Fehlt noch die lokale Windows-95-Festplatte? VM-EINRICHTEN.bat starten.
echo Nach der Einrichtung bitte PRUEFEN.bat starten.
echo.
pause
exit /b 0
:failed
echo.
echo Einrichtung nicht abgeschlossen. Bitte Fehlermeldung oben lesen.
echo.
pause
exit /b 1
