/* Win95-compatible synthetic 32-bit Windows GUI installer.
 * Never contains Cakewalk or Creative code. Only tests the /S guest execution path.
 */
#include <windows.h>
#include <string.h>
int WINAPI WinMain(HINSTANCE i,HINSTANCE prev,LPSTR command,int show) {
    HANDLE f;
    const char message[]="Wise fixture: 125A WIN95 EXECUTED WITH /S\r\n";
    if (strstr(command,"/S")==NULL && strstr(command,"/s")==NULL) return 41;
    f=CreateFileA("C:\\AWEINST\\CW9.PROOF",GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
    if (f==INVALID_HANDLE_VALUE) return 42;
    DWORD written=0;
    BOOL ok=WriteFile(f,message,sizeof(message)-1,&written,NULL);
    CloseHandle(f);
    return ok && written==sizeof(message)-1 ? 0 : 43;
}
