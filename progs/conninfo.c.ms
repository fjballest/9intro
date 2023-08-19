.P1
.ps -1
.ti -1i
.B
.BX conninfo.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	fd, srvfd;
	char*	addr;
	NetConnInfo*i;
	if (argc != 2){
		fprint(2, "usage: %s netaddr\en", argv[0]);
		exits("usage");
	}

	addr = netmkaddr(argv[1], "tcp", "9fs");
	fd = dial(addr, nil, nil, nil);
	if (fd < 0)
		sysfatal("dial: %s: %r", addr);
	i = getnetconninfo(nil, fd);
	if (i == nil)
		sysfatal("cannot get info: %r");
	print("dir:\et%s\en", i->dir);
	print("root:\et%s\en", i->root);
	print("spec:\et%s\en", i->spec);
	print("lsys:\et%s\en", i->lsys);
	print("lserv:\et%s\en", i->lserv);
	print("rsys:\et%s\en", i->rsys);
	print("rserv:\et%s\en", i->rserv);
	print("laddr:\et%s\en", i->laddr);
	print("raddr:\et%s\en", i->raddr);
	freenetconninfo(i);
	close(fd);
	exits(nil);
}
.ps +2
.P2
