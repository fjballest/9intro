.P1
.ps -1
.ti -1i
.B
.BX pong.c
.ps +1
.CW
.ps -2
.vs .15i
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
		print("%d\en", msg);
		send(pongc, &msg);
	}
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
pongthread(void*)
{
	int	msg;

	for(;;){
		recv(pongc, &msg);
		msg++;
		print("\et%d\en", msg);
		send(pingc, &msg);
	}
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
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
.ps +2
.P2
