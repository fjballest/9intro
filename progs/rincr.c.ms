.P1
.ps -1
.ti -1i
.B
.BX rincr.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

int	cnt;

void
main(int, char*[])
{
	int	i;

	if (rfork(RFPROC|RFMEM|RFNOWAIT) < 0)
		sysfatal("fork: %r");
	for (i = 0; i < 2; i++)
		cnt++;
	print("cnt is %d\en", cnt);
	exits(nil);
}
.ps +2
.P2
