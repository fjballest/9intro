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
	print("cnt is %d\n", cnt);
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	threadcreate(incrthread, nil, 8*1024);
	incrthread(nil);
}
