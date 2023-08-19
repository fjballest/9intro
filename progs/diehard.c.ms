.P1
.ps -1
.ti -1i
.B
.BX diehard.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	while(fork() == 0)
		;	// catch me!
	exits(nil);
}
.ps +2
.P2
