#!/usr/bin/env python3
"""Read-only inspection of an existing Windows 95 FAT guest for startup automation.
Only prints metadata; never publishes guest media.
"""
from pathlib import Path
import argparse,json,struct
from pyfatfs.PyFatFS import PyFatFS

def partition_offset(disk:Path)->int:
    with disk.open('rb') as f: sector=f.read(512)
    if len(sector)!=512 or sector[-2:]!=b'\x55\xaa':raise RuntimeError('No valid MBR')
    for i in range(4):
        e=sector[446+i*16:462+i*16]
        first,length=struct.unpack_from('<II',e,8)
        if e[4] in (0x04,0x06,0x0b,0x0c,0x0e) and length:
            return first*512
    raise RuntimeError('No FAT partition')

def main():
 p=argparse.ArgumentParser();p.add_argument('--disk',type=Path,required=True);a=p.parse_args()
 r={"guest_disk_size":a.disk.stat().st_size,"partition_offset":partition_offset(a.disk),"candidates":{},"win_ini_windows_lines":[]}
 with PyFatFS(str(a.disk),offset=r['partition_offset'],read_only=True) as fs:
  for name in ['WINDOWS','WINDOWS/START MENU','WINDOWS/STARTM~1','WINDOWS/STARTM~1/PROGRAMS','WINDOWS/STARTM~1/PROGRAMS/STARTUP','WINDOWS/WIN.INI','WINDOWS/COMMAND.COM','WINDOWS/SYSTEM/SETUPX.DLL']:
   r['candidates'][name]=fs.exists(name)
  for path in ['WINDOWS','WINDOWS/START MENU','WINDOWS/STARTM~1','WINDOWS/STARTM~1/PROGRAMS']:
   if fs.exists(path) and fs.isdir(path):
    r.setdefault('listings',{})[path]=fs.listdir(path)[:80]
  if fs.exists('WINDOWS/WIN.INI'):
   raw=fs.readbytes('WINDOWS/WIN.INI')
   txt=raw.decode('cp1252','replace')
   r['win_ini_bytes']=len(raw)
   inwindows=False
   for line in txt.splitlines():
    l=line.strip()
    if l.startswith('['):inwindows=l.lower()=='[windows]'
    elif inwindows and l.lower().startswith(('run=','load=')):
     r['win_ini_windows_lines'].append(l[:200])
 print(json.dumps(r,indent=2,ensure_ascii=False))
if __name__=='__main__':main()
