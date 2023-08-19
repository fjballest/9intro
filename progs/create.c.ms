.P1
.ps -1
.ti -1i
.B
.BX create.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	fd, n;
	char	msg[] = "a new file\en";

	fd = create("afile", OWRITE, 0664);
	write(fd, msg, strlen(msg));
	close(fd);
	exits(nil);
}
.ps +2
.P2
