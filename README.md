# 86 – privater Windows-95-AWE64-PC

**Ziel:** Du klickst später nur auf \`START.bat\` und kannst eine historische Windows-95-Musikmaschine mit Creative AWE64 Gold und Cakewalk Pro Audio 9 benutzen.

**Ehrlicher Status:** Die Startumgebung, Emulator-/ROM-Downloads und ein Import-Assistent sind vorhanden. **Windows 95, der originale Creative-Treiber und Cakewalk sind noch nicht installiert**. Dafür braucht es deine eigene installierte Win95-Festplatte und passende, rechtmäßig nutzbare Software.

## Schritt für Schritt (Windows 11)

1. [Das aktuelle Actions-Paket herunterladen](https://github.com/challanger2000/86/actions) – im letzten erfolgreichen Lauf heißt das Artefakt \`86-Starter-ohne-Systemdateien\`. ZIP entpacken.
2. \`EINRICHTEN.bat\` doppelklicken. Das lädt den offiziellen 86Box-Emulator 6.0 sowie den zugehörigen ROM-Satz lokal herunter. Je nach ROM-Archiv kann das länger dauern.
3. \`VM-EINRICHTEN.bat\` doppelklicken. Dort deine **bereits installierte** private Windows-95-Festplatte im 512-MiB-Raw-Format \`.img\` auswählen. Eine Windows-95-CD/ISO allein genügt nicht: Dann muss Windows erst in einer virtuellen Maschine installiert werden.
4. \`PRUEFEN.bat\` zeigt, ob 86Box, BIOS, ROM und virtueller Datenträger vorhanden sind.
5. \`START.bat\` öffnet 86Box mit dem im AWE-Projekt nachgewiesenen Pentium-133-/AWE64-Gold-Profil.
6. \`DATEIEN.bat\` öffnet den Host-Ordner für SoundFonts, MIDI und Installationsprogramme. Um ihn im Gast sichtbar zu machen, in 86Box beim CD-ROM-Laufwerk eine **Folder**-CD mit dem Pfad \`AUSTAUSCH\` einlegen.
7. Nach dem Herunterfahren von Windows 95 und **Schließen** von 86Box kannst du mit \`BACKUP.bat\` eine Sicherheitskopie erstellen.

## Host und Gast

- Die Maus ist im P48-Referenzprofil eine PS/2-Maus. Eine tatsächlich funktionierende Maus im Windows-95-Gast muss beim ersten lokalen Start noch geprüft werden.
- AWE64 Gold: \`sbawe64_gold\` mit 28 MiB Sample-RAM. Das ist nur die emulierte Hardware. Der **passende Original-Creative-Treiber** und das **AWE Control Panel** müssen im Gast vorhanden sein bzw. installiert werden.
- Cakewalk Pro Audio 9: nur aus eigener vorhandener Installationsquelle; im Gast installieren und Creative AWE MIDI Synth auswählen.
- \`AUSTAUSCH\` ist als virtuelle CD **nur lesbar**. Ein bidirektionaler Austausch ohne Medienwechsel ist derzeit **noch nicht implementiert**. Die VM selbst sollte nicht als gleichzeitig benutzbarer Host-Ordner verwendet werden.
- Win95-Netzwerk ist zunächst **aus**, damit veraltete Netzwerkdienste nicht freigegeben werden.
- Für wirklich vergleichbare Messungen muss die gesamte Treiber-/ROM-/86Box-Konfiguration mit der aktuellen Entwicklungstest-Referenz abgeglichen werden.

## Lokal vorhandene Ordner

\`86Box/\` (Programm und ROMs), \`VM/\` (private virtuelle Maschine), \`AUSTAUSCH/\` (Host→Gast), \`BACKUPS/\` (Sicherungen). Alle sind vom Git-Upload ausgeschlossen.

## Nicht enthalten

Windows 95, Creative-Originaltreiber, Cakewalk Pro Audio 9 und private SF2-Bänke. Auch die GitHub-Action erzeugt **keine** fertig installierte Windows-95-Maschine und testet keine Audioausgabe. Sie prüft lediglich die Starter und das Konfigurationsprofil.

Die AWE-Entwicklungsumgebung unter \`challanger2000/125A-AWE-Synthesizer\` bleibt unverändert. Grundlage sind dort \`tools/p47_86box_emu8k_smoke.py\` und \`tools/p48_86box_boot_win95.py\` (Stand des P218-Zweiges).

Offizielle 86Box-Dokumentation: https://86box.readthedocs.io/ · ROMs: https://github.com/86Box/roms
