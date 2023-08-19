.P1
.ps -1
.ti -1i
.B
.BX ann.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	cfd;
	char	dir[40];

	cfd = announce("tcp!*!9988", dir);
	if (cfd < 0)
		sysfatal("announce: %r");
	print("announced in %s\en", dir);
	for(;;)
		sleep(1000);
}
.ps +2
.P2
