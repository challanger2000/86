@echo off
setlocal EnableExtensions
set "ROOT=%~dp0"
set "EMU=%ROOT%86Box\86Box.exe"
set "VM=%ROOT%VM"
if not exist "%EMU%" (
  echo.
  echo 86Box wurde noch nicht eingerichtet.
  echo Bitte zuerst EINRICHTEN.bat doppelklicken.
  echo.
  pause
  exit /b 2
)
if not exist "%VM%\86box.cfg" (
  echo.
  echo Die Windows-95-Maschine fehlt noch.
  echo Hier wird die gepruefte lokale VM erwartet:
  echo %VM%\86box.cfg
  echo Bitte zuerst die VM mit ihrer Festplatte einrichten bzw. uebernehmen.
  echo Ohne diese Dateien ist Windows 95 nicht installiert.
  echo.
  pause
  exit /b 3
)
cd /d "%ROOT%86Box"
start "" /D "%ROOT%86Box" "%EMU%" --vmpath "%VM%"
if errorlevel 1 (
  echo Start von 86Box fehlgeschlagen.
  pause
  exit /b 4
)
exit /b 0
