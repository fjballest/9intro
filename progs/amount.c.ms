.P1
.ps -1
.ti -1i
.B
.BX amount.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <auth.h>
int
authmount(int fd, char *mntpt, int flags, char *aname, AuthInfo** aip)
{
	int afd, r;

	afd = fauth(fd, aname);
	if (afd < 0){
		*aip = nil;
		fprint(2, "fauth: %r\en");
		return mount(fd, afd, mntpt, flags, aname);
	}
	*aip = auth_proxy(afd, amount_getkey,
		"proto=p9any role=client");
	if (*aip == nil)
		return -1;
	r = mount(fd, afd, mntpt, flags, aname);
	close(afd);
	if (r < 0){
		auth_freeAI(*aip);
		*aip = nil;
	}
	return r;
}
.ps +2
.P2
.P1
.ps -2
.vs .15i
void
main(int argc, char*argv[])
{
	AuthInfo*ai;
	int	fd;

	if (argc != 4){
		fprint(2, "usage: %s file mnt aname\en", argv[0]);
		exits("usage");
	}
	fd = open(argv[1], ORDWR);
	if (fd < 0)
		sysfatal("open %s: %r", argv[1]);
	if (authmount(fd, argv[2], MREPL|MCREATE, argv[3], &ai) < 0)
		sysfatal("authmount: %r");
	if (ai == nil)
		print("no auth information obtained\en");
	if (ai != nil){
		print("client uid: %s\en", ai->cuid);
		print("server uid: %s\en", ai->suid);
		print("cap: %s\en", ai->cap);
		auth_freeAI(ai);
	}
	exits(nil);
}
.ps +2
.P2
