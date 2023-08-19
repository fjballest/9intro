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
	print("announced in %s (cfd=%d)\n", adir, cfd);
	lfd = listen(adir, dir);
	print("attending call in %s (lfd=%d)\n", dir, lfd);
	for(;;)
		sleep(1000);	// let us see
}
