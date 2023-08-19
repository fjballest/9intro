#include <u.h>
#include <libc.h>
#include <thread.h>

void
pingpongthread(void*a)
{
	ulong	msg;
	Channel*c = a;

	for(;;){
		msg = recvul(c);	// i.e., recv(c, &msg);
		msg++;
		print("%d\n", msg);
		sendul(c, msg);		// i.e., send(c, &msg);
	}
}

void
threadmain(int, char*[])
{
	Channel* c;
	int	kickoff;

	c = chancreate(sizeof(int), 0);
	threadcreate(pingpongthread, c, 8*1024);
	threadcreate(pingpongthread, c, 8*1024);
	kickoff = 0;
	sendul(c, kickoff);
	threadexits(nil);
}
