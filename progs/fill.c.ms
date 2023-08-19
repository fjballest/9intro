.P1
.ps -1
.ti -1i
.B
.BX fill.c
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
	char	buf[1024];
	int	nw;

	if (pipe(fd) < 0)
		sysfatal("can't create a pipe: %r");
	for(;;){
		nw = write(fd[0], buf, sizeof(buf));
		print("wrote %d bytes\en", nw);
	}
	exits(nil);
}
.ps +2
.P2
