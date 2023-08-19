.P1
.ps -1
.ti -1i
.B
.BX iredir.c
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
		close(0);	// WRONG!
		open("/NOTICE", OREAD);
		execl("/bin/cat", "cat", nil);
		sysfatal("exec: %r");
	default:
		waitpid();
	}
	exits(nil);
}
.ps +2
.P2
