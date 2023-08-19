.P1
.ps -1
.ti -1i
.B
.BX rforkls.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(rfork(RFFDG|RFREND|RFPROC)){
	case -1:
		sysfatal("fork failed");
	case 0:
		execl("/bin/ls", "ls", nil);
		break;
	default:
		waitpid();
	}
	exits(nil);
}
.ps +2
.P2
