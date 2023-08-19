.P1
.ps -1
.ti -1i
.B
.BX srv.c
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
	char	fname[128];

	if (argc != 2){
		fprint(2, "usage: %s netaddr\en", argv[0]);
		exits("usage");
	}

	addr = netmkaddr(argv[1], "tcp", "9fs");
	fd = dial(addr, nil, nil, nil);
	if (fd < 0)
		sysfatal("dial: %s: %r", addr);
.ps +2
.P2
.P1
.ps -2
.vs .15i
	seprint(fname, fname+sizeof(fname), "/srv/%s", argv[1]);
	srvfd = create(fname, OWRITE, 0664);
	if (srvfd < 0)
		sysfatal("can't post %s: %r", fname);
	if (fprint(srvfd, "%d", fd) < 0)
		sysfatal("can't post file descriptor: %r");
	close(srvfd);
	close(fd);
	exits(nil);
}
.ps +2
.P2
