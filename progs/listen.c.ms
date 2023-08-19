.P1
.ps -1
.ti -1i
.B
.BX listen.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	cfd, lfd;
	char	adir[40];
	char	dir[40];

	cfd = announce("tcp!*!9988", adir);
	if (cfd < 0)
		sysfatal("announce: %r");
	print("announced in %s (cfd=%d)\en", adir, cfd);
	lfd = listen(adir, dir);
	print("attending call in %s (lfd=%d)\en", dir, lfd);
	for(;;)
		sleep(1000);	// let us see
}
.ps +2
.P2
