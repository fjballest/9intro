.P1
.ps -1
.ti -1i
.B
.BX intfork.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	i;

	i = 1;
	fork();
	i++;
	print("i=%d\en", i);
	exits(nil);
}
.ps +2
.P2
