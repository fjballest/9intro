#include <u.h>
#include <libc.h>
#include <thread.h>
void
threadfunc(void*)
{
	print("thread id= %d\tpid=%d\n", threadid(), getpid());
	threadexits(nil);
}

void
threadmain(int, char*[])
{
	int	i, id;

	print("thread id= %d\tpid=%d\n", threadid(), getpid());
	for (i = 0; i < 2; i++){
		id = threadcreate(threadfunc, nil, 8*1024);
		print("\tcreated thread %d\n", id);
	}
	
}
