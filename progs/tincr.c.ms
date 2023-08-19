.P1
.ps -1
.ti -1i
.B
.BX tincr.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <thread.h>

int	cnt;

void
incrthread(void*)
{
	int	i;

	for (i = 0; i < 2; i++)
		cnt++;
	print("cnt is %d\en", cnt);
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	int	i;

	threadcreate(incrthread, nil, 8*1024);
	for (i = 0; i < 2; i++)
		cnt++;
	print("cnt is %d\en", cnt);
	threadexits(nil);
}
.ps +2
.P2
