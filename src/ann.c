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
	print("announced in %s\n", dir);
	for(;;)
		sleep(1000);
}
