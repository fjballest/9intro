.P1
.ps -1
.ti -1i
.B
.BX fhello.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	char	msg[] = "hello\en";
	int	fd;

	fd = open("afile", OWRITE);
	write(fd, msg, strlen(msg));
	close(fd);
	exits(nil);
}
.ps +2
.P2
