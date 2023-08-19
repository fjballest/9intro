.P1
.ps -1
.ti -1i
.B
.BX pipe.c
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
	char	buf[128];
	int	nr;

	if (pipe(fd) < 0)
		sysfatal("can't create a pipe: %r");
	write(fd[1], "Hello!\en", 7);
	nr = read(fd[0], buf, sizeof(buf));
	write(1, buf, nr);
	exits(nil);
}
.ps +2
.P2
