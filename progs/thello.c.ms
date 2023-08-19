.P1
.ps -1
.ti -1i
.B
.BX thello.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	fd;

	fd = open("afile", OWRITE|OTRUNC);
	write(fd, "hello\en", 6);
	close(fd);
	exits(nil);
}
.ps +2
.P2
