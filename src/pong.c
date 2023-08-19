#include <u.h>
#include <libc.h>
#include <thread.h>

Channel* pingc;
Channel* pongc;

void
pingthread(void*)
{
	int	msg;

	for(;;){
		recv(pingc, &msg);
		msg++;
		print("%d\n", msg);
		send(pongc, &msg);
	}
}

void
pongthread(void*)
{
	int	msg;

	for(;;){
		recv(pongc, &msg);
		msg++;
		print("\t%d\n", msg);
		send(pingc, &msg);
	}
}

void
threadmain(int, char*[])
{
	int	kickoff;

	pingc = chancreate(sizeof(int), 0);
	pongc = chancreate(sizeof(int), 0);
	threadcreate(pingthread, nil, 8*1024);
	threadcreate(pongthread, nil, 8*1024);
	kickoff = 0;
	send(pingc, &kickoff);
	threadexits(nil);
}
