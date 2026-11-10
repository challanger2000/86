#!/usr/bin/env python3
"""Stage private Cakewalk Wise setup for real Win95 Startup execution.
Does not execute guest installers on host, upload media, or claim install success.
"""
from __future__ import annotations
import argparse,hashlib,json,shutil,struct,zipfile
from pathlib import Path
from pyfatfs.PyFatFS import PyFatFS

FILES=('SETUPCW9.EXE','SETUPCW9.W02','SETUPCW9.W03')
STARTUP='WINDOWS/STARTM~1/PROGRAMS/STARTUP'
APPDIR='AWEINST'
GUEST_BOOT=(b'@ECHO OFF\r\n'
 b'IF EXIST C:\\AWEINST\\CW9.TRIED GOTO END\r\n'
 b'ECHO INSTALLER-LAUNCH> C:\\AWEINST\\STATUS.TXT\r\n'
 b'ECHO ATTEMPT> C:\\AWEINST\\CW9.TRIED\r\n'
 b'START /W C:\\AWEINST\\SETUPCW9.EXE /S\r\n'
 b'ECHO SETUP-RETURNED> C:\\AWEINST\\CW9.EXIT\r\n'
 b':END\r\n')

def fat_offset(image:Path)->int:
 with image.open('rb') as f: b=f.read(512)
 if len(b)!=512 or b[-2:]!=b'\x55\xaa':raise RuntimeError('Invalid disk MBR')
 for n in range(4):
  e=b[446+16*n:462+16*n];start,size=struct.unpack_from('<II',e,8)
  if e[4] in (4,6,11,12,14) and size>0:return start*512
 raise RuntimeError('FAT partition not found')

def segments_from_zip(src:Path):
 segments={}
 with zipfile.ZipFile(src) as z:
  for info in z.infolist():
   name=Path(info.filename.replace('\\','/')).name.upper()
   if name not in FILES:continue
   if name in segments:raise RuntimeError('Duplicate installer segment: '+name)
   if info.file_size<1024 or info.file_size>50_000_000:raise RuntimeError('Invalid size: '+name)
   raw=z.read(info)
   if len(raw)!=info.file_size:raise RuntimeError('Truncated segment: '+name)
   segments[name]=raw
 if set(segments)!=set(FILES):raise RuntimeError('Missing installer segment(s)')
 if not segments['SETUPCW9.EXE'].startswith(b'MZ'):raise RuntimeError('Installer is not a Windows EXE')
 if b'wise' not in segments['SETUPCW9.EXE'][:100_000].lower():raise RuntimeError('Wise signature absent')
 return segments

def stage(args):
 if args.disk.resolve()==args.output.resolve():raise RuntimeError('Refusing to modify original Windows disk')
 if args.output.exists():raise RuntimeError('Target exists. Refusing to overwrite.')
 if args.disk.stat().st_size!=536870912:raise RuntimeError('Expected 512MiB raw Win95 disk')
 segments=segments_from_zip(args.cakewalk)
 off=fat_offset(args.disk)
 partial=Path(str(args.output)+'.partial')
 if partial.exists():raise RuntimeError('Staging partial exists; refusing to overwrite')
 args.output.parent.mkdir(parents=True,exist_ok=True)
 try:
  shutil.copyfile(args.disk,partial)
  with PyFatFS(str(partial),offset=off,read_only=False,preserve_case=False) as fs:
   if not fs.isdir(STARTUP):raise RuntimeError('No Win95 Startup folder')
   if fs.exists(STARTUP+'/125ACW9.BAT') or fs.exists(APPDIR):raise RuntimeError('Existing installer staging detected')
   fs.makedirs(APPDIR)
   for name,data in segments.items():
    with fs.openbin(APPDIR+'/'+name,'w') as f:f.write(data)
    if fs.getsize(APPDIR+'/'+name)!=len(data):raise RuntimeError('Guest write incomplete '+name)
   if args.creative:
    if not args.creative.is_dir():raise RuntimeError('Creative directory missing')
    names=('SB16AWE.INF','SBAWE.VXD','SBAWE32.DRV','AWEMAN.DLL','AWEMAN32.DLL',
     'SYNTHGM.SBK','SB16.VXD','SB16SND.DRV','SBFM.DRV','CSPMAN.DLL','CIFMAN.DLL',
     'CIFMAN.CRL','UIDLL16.DLL','WFM0200.ACV','WFM0200A.CSP','WFM0201.ACV',
     'WFM0201A.CSP','WFM0202.ACV','WFM0202A.CSP','WFM0203.ACV','WFM0203A.CSP')
    fs.makedirs('AWE32',recreate=True)
    for name in names:
     path=args.creative/name
     if not path.is_file():raise RuntimeError('Missing Creative driver '+name)
     data=path.read_bytes()
     if len(data)<8 or len(data)>500_000:raise RuntimeError('Bad driver size '+name)
     if not fs.exists('AWE32/'+name):
      with fs.openbin('AWE32/'+name,'w') as f:f.write(data)
     # Make original Win95 PnP driver search resolve this file locally.
     # Mere file placement does not prove actual device binding.
     system_path=('WINDOWS/INF/' if name.endswith('.INF') else 'WINDOWS/SYSTEM/')+name
     if not fs.exists(system_path):
      with fs.openbin(system_path,'w') as f:f.write(data)
   with fs.openbin(STARTUP+'/125ACW9.BAT','w') as f:f.write(GUEST_BOOT)
   if fs.readbytes(STARTUP+'/125ACW9.BAT')!=GUEST_BOOT:raise RuntimeError('Startup batch did not roundtrip')
  partial.rename(args.output)
 except Exception:
  partial.unlink(missing_ok=True)
  raise
 report={'guest_installation_attempted':False,'guest_installation_verified':False,
         'windows_original_preserved':True,'network_required_in_guest':False,
         'installer_sha256':{name:hashlib.sha256(data).hexdigest() for name,data in segments.items()},
         'guest_command':'START /W C:\\AWEINST\\SETUPCW9.EXE /S',
         'guest_startup':'C:\\WINDOWS\\START MENU\\PROGRAMS\\STARTUP\\125ACW9.BAT',
         'new_guest_disk_size':args.output.stat().st_size}
 print(json.dumps(report,indent=2))
 if args.report:args.report.write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')

def inspect(args):
 with PyFatFS(str(args.disk),offset=fat_offset(args.disk),read_only=True) as fs:
  attempted=fs.exists(APPDIR+'/CW9.TRIED')
  returned=fs.exists(APPDIR+'/CW9.EXIT')
  programs=[]
  for name in fs.walk.files():
   if name.rsplit('/',1)[-1].upper() in ('CAKEWALK.EXE','CWPA.EXE'):programs.append(name)
 result={'guest_setup_launch_attempted':attempted,'guest_setup_returned':returned,
         'candidate_installed_programs':programs,'installation_files_detected':bool(programs),
         'guest_audio_and_midi_verified':False,'creative_driver_bound_verified':False}
 print(json.dumps(result,indent=2))
 if args.report:args.report.write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
 if not (returned and programs):raise RuntimeError('Cakewalk installation not confirmed')

def main():
 p=argparse.ArgumentParser();sp=p.add_subparsers(dest='action',required=True)
 a=sp.add_parser('stage');a.add_argument('--disk',type=Path,required=True)
 a.add_argument('--output',type=Path,required=True);a.add_argument('--cakewalk',type=Path,required=True)
 a.add_argument('--creative',type=Path);a.add_argument('--report',type=Path)
 b=sp.add_parser('inspect');b.add_argument('--disk',type=Path,required=True);b.add_argument('--report',type=Path)
 o=p.parse_args()
 if o.action=='stage':stage(o)
 else:inspect(o)
if __name__=='__main__':main()
