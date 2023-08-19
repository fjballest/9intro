.P1
.ps -1
.ti -1i
.B
.BX after.c
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

	if (fork() == 0){
		fd = open("afile", OWRITE);
		write(fd, "child\en", 6);
	} else {
		fd = open("afile", OWRITE);
		write(fd, "dad\en", 4);
	}
	close(fd);
	exits(nil);
}
.ps +2
.P2
