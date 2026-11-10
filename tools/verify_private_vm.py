#!/usr/bin/env python3
"""Read-only private Win95 VM state inspection.

Distinguish staged installation files from installed Cakewalk program files.
This is NOT an audio/MIDI or release test; Windows OS disk is read only.
"""
import argparse
import json
from pathlib import Path
from pyfatfs.PyFatFS import PyFatFS
from stage_private_cakewalk import fat_offset

INSTALLER_SEGMENTS=("SETUPCW9.EXE","SETUPCW9.W02","SETUPCW9.W03")
CREATIVE_FILES=("WINDOWS/SYSTEM/SBAWE.VXD","WINDOWS/SYSTEM/SBAWE32.DRV",
                "WINDOWS/SYSTEM/AWEMAN32.DLL","WINDOWS/INF/SB16AWE.INF")

def inspect(image:Path):
    if not image.is_file() or image.stat().st_size!=536870912:
        raise ValueError("Expected exactly one 512-MiB RAW Windows95 guest disk")
    report={"check":"Private Windows95/Cakewalk postboot file inspection",
            "guest_disk_bytes":image.stat().st_size,
            "cakewalk_installer_staged":False,
            "cakewalk_setup_attempted":False,
            "cakewalk_setup_batch_returned":False,
            "cakewalk_installed_binary_candidates":[],
            "cakewalk_program_files_present":False,
            "creative_driver_files_present":False,
            "creative_driver_bound_in_live_win95":False,
            "cakewalk_executed_successfully":False,
            "midi_output_verified":False,
            "sf2_loaded_verified":False,
            "audio_output_verified":False,
            "ready_to_release":False}
    with PyFatFS(str(image),offset=fat_offset(image),read_only=True) as fs:
        report["cakewalk_installer_staged"]=all(fs.exists("AWEINST/"+x) for x in INSTALLER_SEGMENTS)
        report["cakewalk_setup_attempted"]=fs.exists("AWEINST/CW9.TRIED")
        report["cakewalk_setup_batch_returned"]=fs.exists("AWEINST/CW9.EXIT")
        report["creative_driver_files_present"]=all(fs.exists(x) for x in CREATIVE_FILES)
        for path in fs.walk.files("/"):
            norm=path.replace("\\","/").upper().lstrip("/")
            if norm.rsplit("/",1)[-1]!="CWPA.EXE":
                continue
            if norm.startswith(("AWEINST/","AWE32/","WINDOWS/TEMP/")):
                continue
            try:
                size=fs.getsize(path)
                with fs.openbin(path,"r") as fh:signature=fh.read(2)
            except (OSError,ValueError):
                continue
            if size>=65536 and signature==b"MZ":
                report["cakewalk_installed_binary_candidates"].append(
                    {"guest_path":norm,"size_bytes":size})
        report["cakewalk_installed_binary_candidates"].sort(key=lambda x:x["guest_path"])
        report["cakewalk_program_files_present"]=bool(report["cakewalk_installed_binary_candidates"])
    report["inspection_pass"]=bool(report["cakewalk_program_files_present"])
    # No static file inventory can validate original Creative binding or actual
    # Cakewalk use, SF2 loading and audio playback.
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--disk",type=Path,required=True)
    p.add_argument("--report",type=Path)
    p.add_argument("--require-program-files",action="store_true")
    a=p.parse_args()
    report=inspect(a.disk)
    output=json.dumps(report,indent=2,ensure_ascii=False)+"\n"
    print(output)
    if a.report:
        a.report.parent.mkdir(parents=True,exist_ok=True)
        a.report.write_text(output,encoding="utf8")
    if a.require_program_files and not report["inspection_pass"]:
        raise SystemExit("Cakewalk installed binary not found in guest; NOT INSTALLED")

if __name__=="__main__":
    main()
