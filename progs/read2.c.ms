.P1
.ps -1
.ti -1i
.B
.BX read.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
void
main(int , char* [])
{
	char	buffer[1024];
	int	fd, nr;

	fd = open("/dev/cons", ORDWR);
	nr = read(fd, buffer, sizeof buffer);
	write(fd, buffer, nr);
	close(fd);
	exits(nil);
}
.ps +2
.P2
