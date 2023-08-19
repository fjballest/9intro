.P1
.ps -1
.ti -1i
.B
.BX srvecho.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	fd[2];
	int	srvfd;
	char	buf[128];
	int	nr;

	if (pipe(fd) < 0)
		sysfatal("pipe: %r");
	srvfd = create("/srv/echo", OWRITE, 0664);
	if (srvfd < 0)
		sysfatal("can't create at /srv: %r");
.ps +2
.P2
.P1
.ps -2
.vs .15i
	if (fprint(srvfd, "%d", fd[1]) < 0)
		sysfatal("can't post file descriptor: %r");
	close(fd[1]);
	for (;;){
		nr = read(fd[0], buf, sizeof buf);
		if (nr <= 0)
			break;
		write(1, buf, nr);
	}
	print("exiting\en");
	exits(nil);
}
.ps +2
.P2
