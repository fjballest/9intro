.P1
.ps -1
.ti -1i
.B
.BX echo.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	int	i;

	for (i = 0; i < argc; i++)
		print("%d: %s\en ", i, argv[i]);
	exits(nil);
}
.ps +2
.P2
