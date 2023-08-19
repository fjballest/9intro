.P1
.ps -1
.ti -1i
.B
.BX tincr2.c
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
	int	loc;

	for (i = 0; i < 2; i++){
		loc = cnt;
		loc++;
		sleep(0);
		cnt = loc;
	}
	print("cnt is %d\en", cnt);
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	threadcreate(incrthread, nil, 8*1024);
	incrthread(nil);
}
.ps +2
.P2
