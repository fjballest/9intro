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
