/* Deliberately 1995-compatible 32-bit PE smoke executable.
 * This does not include Cakewalk, vendor code or a CRT. Win95 import surface:
 * KERNEL32.CreateFileA, WriteFile, CloseHandle, GetCommandLineA, ExitProcess.
 */
#include <windows.h>
__attribute__((used)) void guest_entry(void) {
    static const char msg[]="Wise fixture: 125A WIN95 EXECUTED WITH /S\r\n";
    const char *cmd=GetCommandLineA();
    int haveSwitch=0;
    for(const char *c=cmd; *c; ++c)
        if(c[0]=='/' && (c[1]=='S'||c[1]=='s')) haveSwitch=1;
    HANDLE marker=CreateFileA("C:\\AWEINST\\CW9ENT.TXT",GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    DWORD n=0;
    DWORD cmdLen=0;
    while(cmd[cmdLen] && cmdLen<120) ++cmdLen;
    if(marker!=INVALID_HANDLE_VALUE) {
        WriteFile(marker,cmd,cmdLen,&n,0);
        CloseHandle(marker);
    }
    if(!haveSwitch) ExitProcess(41);
    HANDLE f=CreateFileA("C:\\AWEINST\\CW9PRF.TXT",GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    if(f==INVALID_HANDLE_VALUE) ExitProcess(42);
    BOOL ok=WriteFile(f,msg,sizeof(msg)-1,&n,0);
    CloseHandle(f);
    ExitProcess(ok&&n==sizeof(msg)-1?0:43);
}
