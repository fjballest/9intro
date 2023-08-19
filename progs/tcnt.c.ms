.P1
.ps -1
.ti -1i
.B
.BX tcnt.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <thread.h>
int	cnt;

void
incr(void* arg)
{
	int*	cp = arg;

	threadsetname("incrthread");
	for(;;){
		*cp = *cp + 1;
		print("cnt %d\en", *cp);
		yield();
	}
	threadexits(nil);
}
.ps +2
.P2
.P1
.ps -2
.vs .15i

void
decr(void* arg)
{
	int*	cp = arg;

	threadsetname("decrthread");
	for(;;){
		if (*cp > 0)
			*cp = *cp - 1;
		print("cnt %d\en", *cp);
		yield();
	}
	threadexits(nil);
}

void
threadmain(int, char*[])
{

	threadsetname("main");
	threadcreate(incr, &cnt, 8*1024);
	threadcreate(decr, &cnt, 8*1024);
	threadexits(nil);
}
.ps +2
.P2
