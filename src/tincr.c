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
	print("cnt is %d\n", cnt);
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	int	i;

	threadcreate(incrthread, nil, 8*1024);
	for (i = 0; i < 2; i++)
		cnt++;
	print("cnt is %d\n", cnt);
	threadexits(nil);
}
