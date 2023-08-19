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
	int	nr;

	nr = read(0, buffer, sizeof buffer);
	write(1, buffer, nr);
	exits(nil);
}
.ps +2
.P2
