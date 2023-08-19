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
	char	buffer[10];
	int	nr;
	int	fd;

	fd = open("/NOTICE", OREAD);
	if (fd < 0)
		sysfatal("open: %r");
	for(;;){
		nr = read(fd, buffer, sizeof buffer);
		if (nr <= 0)
			break;
		if (write(1, buffer, nr) != nr)
			sysfatal("write: %r");
	}
	exits(nil);
}
.ps +2
.P2
