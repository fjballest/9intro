.P1
.ps -1
.ti -1i
.B
.BX tid.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <thread.h>
void
threadfunc(void*)
{
	print("thread id= %d\etpid=%d\en", threadid(), getpid());
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	int	i, id;

	print("thread id= %d\etpid=%d\en", threadid(), getpid());
	for (i = 0; i < 2; i++){
		id = threadcreate(threadfunc, nil, 8*1024);
		print("\etcreated thread %d\en", id);
	}
	
}
.ps +2
.P2
