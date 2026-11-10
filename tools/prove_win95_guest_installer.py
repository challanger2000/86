#!/usr/bin/env python3
"""Boot real Windows95 in QEMU, verify that a synthetic Win32 installer ran.
Never assumes an installer returned successfully based on stage/exit markers alone.
"""
import argparse,json,socket,subprocess,time
from pathlib import Path
from pyfatfs.PyFatFS import PyFatFS
from stage_private_cakewalk import fat_offset

def hmp(sock,cmd):
    for _ in range(70):
        try:
            with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as s:
                s.settimeout(8)
                s.connect(str(sock))
                s.recv(8192)
                s.sendall((cmd+'\n').encode('ascii'))
                time.sleep(.25)
                return s.recv(16384).decode('latin1','replace')[-250:]
        except (FileNotFoundError,ConnectionRefusedError):
            time.sleep(.25)
    raise RuntimeError('QEMU monitor did not open')

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--disk',required=True,type=Path)
    p.add_argument('--report',required=True,type=Path)
    a=p.parse_args()
    if a.disk.stat().st_size!=536870912:raise ValueError('512MiB disk expected')
    monitor=a.report.parent/'guest-fixture-monitor.sock'
    cmd=['qemu-system-i386','-machine','pc,acpi=off','-cpu','pentium','-m','64',
        '-drive',f'file={a.disk.resolve()},format=raw,if=ide,media=disk','-vga','std',
        '-display','none','-boot','c','-net','none','-rtc','base=localtime',
        '-serial','none','-monitor',f'unix:{monitor},server=on,wait=off']
    log=a.report.parent/'guest-fixture-qemu.log'
    with log.open('wb') as l:
        proc=subprocess.Popen(cmd,stdout=l,stderr=subprocess.STDOUT)
        try:
            time.sleep(22)
            for key in ['ret','ret','esc','esc','ret','ctrl-esc','esc']:
                hmp(monitor,'sendkey '+key)
                time.sleep(2)
            time.sleep(25)
            screenshot=a.report.parent/'win95-after-guest-setup.ppm'
            hmp(monitor,'screendump '+str(screenshot.resolve()))
            # Alt-F4 on the background desktop can open the shutdown dialog.
            # Switch toward the DOS test window instead, which remains open at PAUSE.
            hmp(monitor,'sendkey alt-tab')
            time.sleep(3)
            second=a.report.parent/'win95-after-alt-tab.ppm'
            hmp(monitor,'screendump '+str(second.resolve()))
            # If a Win95 crash dialogue is focused, open Details.
            hmp(monitor,'sendkey tab')
            time.sleep(.5)
            hmp(monitor,'sendkey ret')
            time.sleep(2)
            details=a.report.parent/'win95-crash-details.ppm'
            hmp(monitor,'screendump '+str(details.resolve()))
            time.sleep(19)
        finally:
            if proc.poll() is None:
                proc.terminate()
                try:proc.wait(timeout=8)
                except subprocess.TimeoutExpired:proc.kill();proc.wait(timeout=4)
    with PyFatFS(str(a.disk),offset=fat_offset(a.disk),read_only=True) as fs:
        attempted=fs.exists('AWEINST/STARTUP.OK')
        returned=fs.exists('AWEINST/CW9.EXIT')
        start_pass=fs.exists('AWEINST/START.OK')
        direct_pass=fs.exists('AWEINST/DIRECT.OK')
        executed=fs.exists('AWEINST/CW9PRF.TXT')
        entered=fs.exists('AWEINST/CW9ENT.TXT')
        entry=fs.readbytes('AWEINST/CW9ENT.TXT').decode('cp1252','replace')[:240] if entered else ''
        value=fs.readbytes('AWEINST/CW9PRF.TXT').decode('ascii','replace') if executed else ''
    result={'real_windows95_boot':True,'guest_installer_attempted':attempted,
            'guest_batch_returned':returned,'real_32bit_fixture_executed':executed,'entry_marker':entered,'entry_command':entry,
            'fixture_captured_command_switch':('/S' in value),
            'start_wait_exec_success':start_pass,'direct_exec_success':direct_pass,
            'test_pass':attempted and returned and executed and '/S' in value and (start_pass or direct_pass),
            'actual_cakewalk_used':False,'original_creative_driver_verified':False,
            'machine_not_exported':True}
    a.report.write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
    print(json.dumps(result,indent=2))
    if not result['test_pass']:raise RuntimeError('Real Win95 PE32 installer chain not proven')
if __name__=='__main__':main()
