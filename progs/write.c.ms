.P1
.ps -1
.ti -1i
.B
.BX write.c
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
	int	l;

	l = strlen(msg);
	write(1, msg, l);
	exits(nil);
}
.ps +2
.P2
