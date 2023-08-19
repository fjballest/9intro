#include <u.h>
#include <libc.h>
#include <auth.h>	// for amount
void
main(int, char*[])
{
	int	fd;

	fd = open("/srv/tcp!whale!9fs", ORDWR);
	if (fd < 0)
		sysfatal("can't open /srv/tcp!whale!9fs: %r");
	if (amount(fd, "/n/whale", MREPL|MCREATE, "") < 0)
		sysfatal("mount: %r");
	if (amount(fd, "/n/dump", MREPL, "main/archive") < 0)
		sysfatal("mount: %r");
	exits(nil);
}

