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
		print("cnt %d\n", *cp);
		yield();
	}
	threadexits(nil);
}

void
decr(void* arg)
{
	int*	cp = arg;

	threadsetname("decrthread");
	for(;;){
		if (*cp > 0)
			*cp = *cp - 1;
		print("cnt %d\n", *cp);
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
