@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo === 125A AWE64-PC Desktop-Symbol erstellen ===
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Desktop-Symbol.ps1"
set "RC=%ERRORLEVEL%"
echo.
pause
exit /b %RC%
