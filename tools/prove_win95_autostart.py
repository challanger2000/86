#!/usr/bin/env python3
"""Verify actual execution of a BAT from Win95's Startup folder in QEMU.
Only touches a temporary private guest image; never publishes the OS.
"""
import argparse,json,socket,subprocess,struct,time
from pathlib import Path
from pyfatfs.PyFatFS import PyFatFS

STARTUP='WINDOWS/STARTM~1/PROGRAMS/STARTUP'
BODY=b'@ECHO OFF\r\nECHO 125A-AUTOSTART-EXECUTED> C:\\125ATEST.TXT\r\n'

def fs_offset(image):
    with image.open('rb') as f: s=f.read(512)
    if s[-2:]!=b'\x55\xaa':raise ValueError('Invalid MBR')
    for n in range(4):
        e=s[446+16*n:462+16*n]
        if e[4] in (4,6,11,12,14) and struct.unpack_from('<I',e,12)[0]:
            return struct.unpack_from('<I',e,8)[0]*512
    raise ValueError('Missing FAT partition')

def monitor(sock,cmd):
    with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as s:
        s.settimeout(5)
        for _ in range(100):
            try: s.connect(str(sock));break
            except (FileNotFoundError,ConnectionRefusedError):time.sleep(.2)
        else: raise RuntimeError('QEMU monitor unavailable')
        s.recv(8192)
        s.sendall((cmd+'\n').encode())
        time.sleep(.20)
        try: return s.recv(16384).decode('latin1','replace')[-250:]
        except socket.timeout:return 'timeout'

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--disk',required=True,type=Path)
    ap.add_argument('--report',required=True,type=Path)
    a=ap.parse_args()
    if a.disk.stat().st_size!=536870912:raise RuntimeError('Unexpected Windows disk size')
    off=fs_offset(a.disk)
    with PyFatFS(str(a.disk),offset=off,read_only=False,preserve_case=False) as fs:
        if not fs.isdir(STARTUP):raise RuntimeError('Original Win95 startup folder unavailable')
        if fs.exists('125ATEST.TXT'):raise RuntimeError('Marker pre-exists, invalid proof')
        with fs.openbin(STARTUP+'/125ABOOT.BAT','w') as f:f.write(BODY)
        if fs.readbytes(STARTUP+'/125ABOOT.BAT')!=BODY:raise RuntimeError('BAT staging did not roundtrip')
    monitor_socket=a.report.parent/'qemu-125a-monitor.sock'
    log=a.report.parent/'qemu.log'
    cmd=['qemu-system-i386','-machine','pc,acpi=off','-cpu','pentium','-m','64',
         '-drive',f'file={a.disk.resolve()},format=raw,if=ide,media=disk',
         '-vga','std','-display','none','-boot','c','-net','none','-rtc','base=localtime',
         '-serial','none','-monitor',f'unix:{monitor_socket},server=on,wait=off']
    events=[]
    with log.open('wb') as f:
        proc=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT)
        try:
            time.sleep(22)
            for key in ['ret','ret','esc','esc','ret','ctrl-esc','esc']:
                events.append({'key':key,'response':monitor(monitor_socket,'sendkey '+key)})
                time.sleep(2)
            time.sleep(45)
        finally:
            if proc.poll() is None:
                proc.terminate()
                try:proc.wait(timeout=8)
                except subprocess.TimeoutExpired:proc.kill();proc.wait(timeout=5)
    with PyFatFS(str(a.disk),offset=off,read_only=True) as fs:
        found=fs.exists('125ATEST.TXT')
        data=fs.readbytes('125ATEST.TXT').decode('cp1252','replace')[:100] if found else ''
    report={'test':'actual Windows95 guest execution of startup BAT','startup_folder_valid':True,
            'bat_staged':True,'marker_created_by_guest':found,'marker_content':data.strip(),
            'guest_scancode_events':len(events),'network_disabled':True,
            'test_pass':found and '125A-AUTOSTART-EXECUTED' in data,
            'cakewalk_installed':False,'creative_driver_bound_by_this_test':False}
    a.report.write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    print(json.dumps(report,indent=2))
    if not report['test_pass']:raise RuntimeError('Win95 guest did not produce execution marker')

if __name__=='__main__':main()
