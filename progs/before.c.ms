.P1
.ps -1
.ti -1i
.B
.BX before.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	fd;

	fd = create("afile", OWRITE, 0644);
	write(fd, "hello\en", 6);
	if (fork() == 0)
		write(fd, "child\en", 6);
	else
		write(fd, "dad\en", 4);
	close(fd);
	exits(nil);
}
.ps +2
.P2
