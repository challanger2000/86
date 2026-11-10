# 86 – START HERE

**Projektziel:** Eine separat nutzbare, private Windows-95/86Box/AWE64-Gold-Musikmaschine unter Windows 11, mit minimaler Bedienung per Doppelklick und optional Cakewalk Pro Audio 9.

- Eingangsreferenz: 125A-AWE-Synthesizer P47/P48, Konfiguration \`p55t2p4\`, Pentium P54C 133 MHz, 64 MiB, PS/2-Maus, AWE64 Gold, 28 MiB Onboard Sample RAM, interne IDE.
- Dieses Repository enthält **nur** Skripte, Tests und Dokumentation. Kein Windows 95, kein Cakewalk, keine Creative-Treiber, keine ROMs, keine privaten SoundFonts.
- Veröffentlichte Actions-Artefakte müssen frei von Gast-Systemdateien und privaten Datenträgern bleiben.
- Für Originaltreiber-Klangvergleiche sind **zusätzlich** Treiber-, Emulator-, ROM-, Bank- und Audioeinstellungen mit den P21x-Entwicklungsnachweisen abzugleichen. Ein BIOS-/ROM-Prüfresultat ersetzt das nicht.
- Windows 95 und Cakewalk können nur aus vorhandenen, rechtmäßig nutzbaren Medien oder einem vorhandenen eigenen VM-Abbild eingerichtet werden. Niemals angeben, diese Software sei bereits installiert, solange das lokale Gast-System nicht geprüft wurde.
- CI kann eine **kurzlebige, private Windows-95-OSR2-Testfestplatte** laden und über QEMU tatsächlich booten. Der Win95-Guest-Startup-Test ist nachgewiesen; ein synthetischer i586-Win32-Installer hat im Gast tatsächlich Code ausgeführt (siehe `QA/WIN95-GUEST-EXECUTION-VERIFIED.md`). Die CI exportiert **keine** Windows-Festplatten oder privaten Treiber und kann daraus keine fertig installierte Dauer-VM behaupten. Ein Win95-Boot-PASS ist ausdrücklich **kein Cakewalk-/Creative-PASS**.
- Kein Netzwerkzugang für Windows 95 ohne ausdrücklich abgesicherten Zweck; zum Dateieinlesen einen lokalen Ordner als CD verwenden.
- Nie die Entwicklungs-VM oder P21x-Testprojekte modifizieren, ohne expliziten Auftrag.

**Aktueller Stand (10.11.2026):** 86Box+ROM-Installer, VM-Import-Assistent, Win95-Boot mit tatsächlich ausgeführtem Gast-Autostart und synthetischem Windows-95-kompatiblem PE32-Testprogramm nachgewiesen. Echtes Cakewalk 9.03 ist im Gast **nicht installiert oder getestet**. Eine dauerhafte fertig konfigurierte AWE64-Gold-/Cakewalk-VM ist **nicht vorhanden**.

**Wichtige Unterscheidung:** Der P47/P48-Referenz-PC (P54C 133 MHz) dient historischen Entwickler-Messungen. Cakewalk Pro Audio 9 fordert mindestens einen Pentium 200 MHz und 64 MB RAM. Für ein privates Musikprofil sind deshalb ein kompatibler Pentium 200 MHz und ausreichend RAM anzustreben, getrennt vom unveränderten Klangreferenzprofil. Hardware-/VM-Konfiguration vor einer Releasezusage testen.

Siehe README.md für Benutzerschritte. Für 125A-Projekte sind außerdem die Regeln unter \`challanger2000/125A-Engineering/START-HERE.md\` maßgeblich.
