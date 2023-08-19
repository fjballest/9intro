.P1
.ps -1
.ti -1i
.B
.BX netecho.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	cfd, lfd, dfd;
	long	nr;
	char	adir[40];
	char	ldir[40];
	char	buf[1024];

	cfd = announce("tcp!*!9988", adir);
	if (cfd < 0)
		sysfatal("announce: %r");
	print("announced tcp!*!9988 in %s\en", adir);
.ps +2
.P2
.P1
.ps -2
.vs .15i
	for(;;){
		lfd = listen(adir, ldir);
		if (lfd < 0)
			sysfatal("listen: %r");
		dfd = accept(lfd, ldir);
		if (dfd < 0)
			sysfatal("can't accept: %r");
		close(lfd);
		print("accepted call at %s\en", ldir);
		for(;;){
			nr = read(dfd, buf, sizeof buf);
			if (nr <= 0)
				break;
			write(dfd, buf, nr);
		}
		print("terminated call at %s\en", ldir);
		close(dfd);
	}
}
.ps +2
.P2
