#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	fd, srvfd;
	char*	addr;
	NetConnInfo*i;
	if (argc != 2){
		fprint(2, "usage: %s netaddr\n", argv[0]);
		exits("usage");
	}

	addr = netmkaddr(argv[1], "tcp", "9fs");
	fd = dial(addr, nil, nil, nil);
	if (fd < 0)
		sysfatal("dial: %s: %r", addr);
	i = getnetconninfo(nil, fd);
	if (i == nil)
		sysfatal("cannot get info: %r");
	print("dir:\t%s\n", i->dir);
	print("root:\t%s\n", i->root);
	print("spec:\t%s\n", i->spec);
	print("lsys:\t%s\n", i->lsys);
	print("lserv:\t%s\n", i->lserv);
	print("rsys:\t%s\n", i->rsys);
	print("rserv:\t%s\n", i->rserv);
	print("laddr:\t%s\n", i->laddr);
	print("raddr:\t%s\n", i->raddr);
	freenetconninfo(i);
	close(fd);
	exits(nil);
}
