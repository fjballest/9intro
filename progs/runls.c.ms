.P1
.ps -1
.ti -1i
.B
.BX runls.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(fork()){
	case -1:
		sysfatal("fork failed");
	case 0:
		execl("/bin/ls", "ls", nil);
		break;
	default:
		print("ls started\en");
	}
	exits(nil);
}
.ps +2
.P2
