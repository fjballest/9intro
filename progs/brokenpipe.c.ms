.P1
.ps -1
.ti -1i
.B
.BX brokenpipe.c
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
	close(fd[0]);
	write(fd[1], "Hello!\en", 7);
	print("could write\en");
	exits(nil);
}
.ps +2
.P2
