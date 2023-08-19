.P1
.ps -1
.ti -1i
.B
.BX global.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

char global[1 * 1024 * 1024];

void
main(int, char*[])
{
	exits(nil);
}
.ps +2
.P2
