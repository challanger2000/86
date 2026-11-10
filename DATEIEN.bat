@echo off
setlocal
if not exist "%~dp0AUSTAUSCH" mkdir "%~dp0AUSTAUSCH"
echo Hier bitte MIDI-Dateien, SF2-Baenke und Programme hineinlegen.
echo.
echo Im laufenden 86Box am CD-ROM-Symbol "Folder" waehlen
echo und den gerade geoeffneten Windows-11-Ordner auswaehlen.
echo In Windows 95 erscheint er dann als CD (nur lesbar).
start "" explorer.exe "%~dp0AUSTAUSCH"
exit /b 0
