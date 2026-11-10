# Windows 95 Gast-EXE-Start: echter Testnachweis (2026-11-10)

## Nachweis
Workflow `Real Win95 32-bit installer startup chain (synthetic)`:
https://github.com/challanger2000/86/actions/runs/42774991774

- Boot: bestehendes 512-MiB-Windows-95-OSR2-Festplattenabbild, QEMU mit Pentium-CPU, Gastnetz abgeschaltet.
- Host richtet einen **eigenen, synthetischen** Win32-Testinstaller mit den Namen `SETUPCW9.EXE/.W02/.W03` in einer **Kopie** der Gastfestplatte ein.
- Gast-Autostart: `WINDOWS/STARTM~1/PROGRAMS/STARTUP/125ACW9.BAT`.
- Der Gast führte die EXE mit `START /W` aus. Der frühere Direktaufruf wurde versucht, hatte aber keinen von der ersten Ausführung getrennten Marker; er war **nicht unabhängig nachgewiesen**.
- Von der EXE selbst erzeugter Gast-Marker `C:\AWEINST\CW9PRF.TXT` wurde nach dem Boot gelesen.
- Der aus `GetCommandLineA` gelesene Gast-Aufruf war `"C:\AWEINST\SETUPCW9.EXE" /S`.
- Ergebnis des Abschlusslaufs: `test_pass = true`.
- Frühere Gegenproben mit einer anderen PE32-Testausführung waren **FAIL** und zeigten eine Win95-Absturzmeldung. Die Korrekturen umfassten Pentium-kompatibles Kompilieren (`-march=i586`), kürzere 8.3-Dateinamen und einen begrenzten Speicherzugriff. Die Einzelursache wurde nicht isoliert.

## Ausdrücklich nicht nachgewiesen

- **Kein Cakewalk-Installer verwendet**. Der echte Installer aus dem privaten Nutzerarchiv wurde im Gast nicht gestartet.
- Kein Beleg, dass der Wise-Parameter `/S` bei **dieser** Cakewalk-Distribution unbeaufsichtigt funktioniert.
- Keine fertige Cakewalk-Installation, keine Audio-/MIDI-Abnahme und kein Nachweis einer ladbaren SF2-Bank.
- Dieser Test installiert/bindet den originalen Creative-AWE64-Treiber **nicht**.
- Keine fertige oder exportierte Windows-95-VM; das Testabbild wird nach dem CI-Lauf gelöscht.
- Microsoft-/Creative-/Cakewalk-Dateien sind nicht Bestandteil der öffentlichen Projektquellen oder der CI-Artefakte.

## Verbindliches Release-Gate

Erst `FULLY INSTALLED`, wenn die tatsächliche private Windows-95-Festplatte
1. nachweislich Creative AWE64 Gold als verwendeten MIDI-/Audioausgang besitzt,
2. Cakewalk Pro Audio 9.03 startet und MIDI über die AWE64 hörbar abspielt,
3. einen SF2-Lade- und Wiedergabetest besteht,
4. als dauerhaftes Abbild gesichert und mit `START.bat` unter Windows 11 erfolgreich wieder gestartet wurde.

Das synthetische `PASS` darf **niemals** als Cakewalk-/Treiber-/VM-Releasefreigabe ausgegeben werden.

## Adversarialer Folgetest (eingeführt nach dem ersten PASS)

Im Folgetest wird der ursprüngliche Erfolg nach `START /W /S` separat gesichert, der Erfolgsmelder gelöscht und dann derselbe PE32-Testinstaller absichtlich mit `/Z` aufgerufen. Dieser negative Kontrollfall darf keinen neuen Erfolgsmarker erzeugen. Das frühere `PASS` belegt nur den `/S`-Start, **nicht** die neu hinzugefügte Negativprüfung; deren eigener CI-Lauf ist separat zu betrachten.

## Abgeschlossene Negativkontrolle – 2026-11-10

[CI #42776084232](https://github.com/challanger2000/86/actions/runs/42776084232): **SUCCESS**.

Tatsächlich im Win95-Gast ausgeführt: `START /W SETUPCW9.EXE /S`, dessen Erfolg getrennt gesichert, Erfolgsmelder gelöscht, danach `START /W SETUPCW9.EXE /Z` als absichtlich ungültiger Parameter. Ergebnis aus dem Gast:

- `positive_process_verified = true`
- `positive_command_switch_verified = true`
- `start_wait_exec_success = true`
- `negative_command_switch_verified = true`
- `negative_proof_absent = true`
- `negative_gate_pass = true`
- `test_pass = true`

Das beweist die **generische Win95-PE32-Programmstartkette samt wirksamer Negativkontrolle**, nicht die Cakewalk-Installation oder den Creative-AWE64-Gold-Betrieb. Die privaten Binaries und OS-Platten bleiben außerhalb aller veröffentlichten Artefakte.
