# 86 – START HERE

**Projektziel:** Eine separat nutzbare, private Windows-95/86Box/AWE64-Gold-Musikmaschine unter Windows 11, mit minimaler Bedienung per Doppelklick und optional Cakewalk Pro Audio 9.

- Eingangsreferenz: 125A-AWE-Synthesizer P47/P48, Konfiguration \`p55t2p4\`, Pentium P54C 133 MHz, 64 MiB, PS/2-Maus, AWE64 Gold, 28 MiB Onboard Sample RAM, interne IDE.
- Dieses Repository enthält **nur** Skripte, Tests und Dokumentation. Kein Windows 95, kein Cakewalk, keine Creative-Treiber, keine ROMs, keine privaten SoundFonts.
- Veröffentlichte Actions-Artefakte müssen frei von Gast-Systemdateien und privaten Datenträgern bleiben.
- Für Originaltreiber-Klangvergleiche sind **zusätzlich** Treiber-, Emulator-, ROM-, Bank- und Audioeinstellungen mit den P21x-Entwicklungsnachweisen abzugleichen. Ein BIOS-/ROM-Prüfresultat ersetzt das nicht.
- Windows 95 und Cakewalk können nur aus vorhandenen, rechtmäßig nutzbaren Medien oder einem vorhandenen eigenen VM-Abbild eingerichtet werden. Niemals angeben, diese Software sei bereits installiert, solange das lokale Gast-System nicht geprüft wurde.
- CI kann Installer, Syntax, Paketstruktur und Konfigurationsgenerator prüfen. CI hat keine private Windows-95-VM und darf niemals „Win95 boot PASS“ oder „Cakewalk PASS“ behaupten.
- Kein Netzwerkzugang für Windows 95 ohne ausdrücklich abgesicherten Zweck; zum Dateieinlesen einen lokalen Ordner als CD verwenden.
- Nie die Entwicklungs-VM oder P21x-Testprojekte modifizieren, ohne expliziten Auftrag.

**Aktueller Stand:** 86Box+ROM-Installer und VM-Import-Assistent implementiert; lokaler Win95-/Creative-/Cakewalk-Lauf **ausstehend**.

Siehe README.md für Benutzerschritte. Für 125A-Projekte sind außerdem die Regeln unter \`challanger2000/125A-Engineering/START-HERE.md\` maßgeblich.
