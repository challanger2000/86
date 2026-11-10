# 86 — lokaler Retro-PC

Dieses Repository enthält ausschließlich frei verteilbare Start-, Einrichtungs- und Prüfscripte für einen **privaten** Windows-95-PC in 86Box.

**Status:** Grundgerüst. Noch **keine** fertig installierte Windows-95-/Creative-/Cakewalk-Maschine. `START.bat` startet erst, wenn eine geprüfte VM-Konfiguration mit Systemabbild lokal bereitliegt.

## Für Windows 11

1. Repository als ZIP herunterladen und entpacken.
2. `EINRICHTEN.bat` doppelklicken: lädt 86Box 6.0 von der offiziellen Projektfreigabe, prüft SHA-256, richtet Ordner ein.
3. Die eigene, rechtmäßig nutzbare Windows-95-Installation **oder** eine bereits funktionierende lokale 86Box-VM nach `VM` übernehmen. `VM\86box.cfg` und die referenzierten Plattenabbilder müssen dort gültig sein. ROM-Dateien und Creative-Treiber müssen lokal passend zur Maschine vorhanden sein.
4. `START.bat` doppelklicken.
5. `DATEIEN.bat` öffnet den Host-Austauschordner. In 86Box kann man ihn über das CD-ROM-Symbol als **Folder** einlegen (im Gast nur lesbar).
6. Nach dem ordnungsgemäßen Herunterfahren von Windows 95 und dem Schließen von 86Box erstellt `BACKUP.bat` eine Kopie.

## Zielkonfiguration

Windows 95 (identische Ausgabe wie die Entwicklungstests), passende original Creative AWE64 Gold Treiber, AWE64 Gold / EMU8000 mit abgestimmter Wave-ROM und Sample-RAM, SoundFont-Control-Panel und Cakewalk Pro Audio 9 **mit eigener Lizenz/Installationsquelle**. Diese Komponenten sind **nicht** Bestandteil des Pakets. Der ursprüngliche Entwicklungs-Test-PC wird nicht verändert.

## Lokale Ordner

- `86Box/` – Emulator (wird heruntergeladen)
- `VM/` – private VM-Konfiguration und Plattenabbilder
- `AUSTAUSCH/` – vom Gast als CD lesbare Dateien (SF2, MIDI, Installationsdateien)
- `BACKUPS/` – Sicherungen nach Ausschalten der VM

Alle vier Ordner sind in `.gitignore` ausgeschlossen. **Niemals** Windows-, ROM-, Cakewalk-, Treiber-, private SF2- oder VM-Abbilddateien committen oder in Actions-Artefakte hochladen.

## Grenzen

- Eine öffentlich lesbare GitHub-Actions-Ausführung ist kein privater Ort.
- Der Download des Emulators ist automatisiert; die Windows-Installation und die exakte AWE-Treiberkonfiguration noch nicht. Ein `START.bat` ohne vorhandene VM bricht mit verständlicher Meldung ab.
- Ein gemounteter Host-Ordner ist im Windows-95-Gast eine **schreibgeschützte CD**, kein bidirektionaler Netzwerkordner. Ein sicherer Rückweg für Gastdateien muss separat eingerichtet werden.
- Eine 86Box-VM kann nicht gleichzeitig von zwei 86Box-Prozessen oder Host-Datenträgerwerkzeugen schreibend verwendet werden.
- Audioidentität zu Entwicklungsläufen setzt identische Versionen und Konfiguration voraus und muss erst durch einen Vergleich bestätigt werden.

Offizielle Dokumentation: https://86box.readthedocs.io/en/latest/ | Download: https://github.com/86Box/86Box/releases/tag/v6.0
