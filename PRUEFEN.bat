@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === 86: Was ist schon eingerichtet? ===
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Pruefen.ps1"
set "RC=%ERRORLEVEL%"
echo.
pause
exit /b %RC%
