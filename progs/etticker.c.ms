.P1
.ps -1
.ti -1i
.B
.BX etticker.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <bio.h>
#include <thread.h>

enum { Npanels = 2 };
Channel*timerc;		// of char*
Channel*consc;		// of char*
Channel*tempc;		// of char*
Channel*bcastc;		// of char*
Channel*panelc[Npanels];	// of char*
.ps +2
.P2
.P1
.ps -2
.vs .15i


typedef struct PArg PArg;
struct PArg {
	Channel* c;	// to get new messages from
	int	fd;	// to the panel's file.
};

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
consreadthread(void*)
{
	Biobuf	bin;
	char*	ln;

	threadsetname("consread");
	Binit(&bin, 0, OREAD);
	while (ln = Brdstr(&bin, '\en', 1))
		sendp(consc, ln);
	sendp(consc, nil);
	Bterm(&bin);
	threadexits(nil);
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
bcastthread(void*)
{
	char*	msg;
	int	i;

	threadsetname("bcast");
	do {
		msg = recvp(bcastc);
		for (i = 0; i < Npanels; i++)
			if (msg != nil)
			  sendp(panelc[i], strdup(msg));
			else
			  sendp(panelc[i], nil);
		free(msg);
	} while(msg != nil);
	threadexits(nil);
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
panelthread(void* a)
{
	PArg*	arg = a;
	char*	msg;

	threadsetname("panel");
	while(msg = recvp(arg->c)){
		write(arg->fd, msg, strlen(msg));
		free(msg);
	}
	threadexits(nil);
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
timerthread(void* a)
{
	Channel* c = a;
	ulong	now;
	Tm*	tm;
	char	msg[10];
	for(;;){
		now = time(nil);
		tm = localtime(now);
		seprint(msg, msg+10, "%d:%d", tm->hour, tm->min);
		sendp(c, strdup(msg));
		sleep(60 * 1000);
	}
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
tempthread(void* a)
{
	Channel* c = a;
	char	temp[10];
	char	last[10];
	int	fd, nr;

	last[0] = 0;
	fd = open("/dev/temp", OREAD);
	if (fd < 0)
		sysfatal("/dev/temp: %r");
	for(;;){
		nr = read(fd, temp, sizeof(temp) - 1);
		if (nr <= 0)
			sysfatal("can't read temp");
		temp[nr] = 0;
		if (strcmp(last, temp) != 0){
			strcpy(last, temp);
			sendp(c, strdup(temp));
		}
		sleep(60 * 1000);
	}
}

.ps +2
.P2
.P1
.ps -2
.vs .15i
void
decoratorthread(void*)
{
	char*	lcons, *ltimer, * ltemp;
	char*	consmsg, *timermsg, *tempmsg;
	char*	msg;
	Alt	alts[] = {
		{ timerc,&timermsg, CHANRCV },
		{ consc, &consmsg, CHANRCV },
		{ tempc, &tempmsg, CHANRCV },
		{ nil,   nil, CHANEND } };

	lcons = strdup(""); ltimer = strdup(""); ltemp = strdup("");
	for(;;){
		msg = nil;
		switch(alt(alts)){
		case 0:	// operation in alts[0] made
			msg = smprint("%s (%s %s)\en",
				lcons, timermsg, ltemp);
			free(ltimer);
			ltimer = timermsg;
			break;
.ps +2
.P2
.P1
.ps -2
.vs .15i
		case 1:	// operation in alts[1] made
			msg = smprint("%s (%s %s)\en",
				consmsg, ltimer, ltemp);
			free(lcons);
			lcons = consmsg;
			break;
.ps +2
.P2
.P1
.ps -2
.vs .15i
		case 2:	// operation in alts[2] made
			msg = smprint("%s (%s %s)\en",
				lcons, ltimer, tempmsg);
			free(ltemp);
			ltemp = tempmsg;
			break;
		}
		sendp(bcastc, msg);
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
	int	i;
	PArg*	arg;

	timerc = chancreate(sizeof(char*), 0);
	consc = chancreate(sizeof(char*), 0);
	tempc = chancreate(sizeof(char*), 0);
	proccreate(timerthread, timerc, 8*1024);
	proccreate(consreadthread, consc, 16*1024);
	proccreate(tempthread, tempc, 8*1024);
	for (i = 0; i < Npanels; i++){
		panelc[i] = chancreate(sizeof(char*), 0);
		arg = malloc(sizeof(*arg));
		arg->c = panelc[i];
		arg->fd = 1;		// to test the program.
		proccreate(panelthread, arg, 8*1024);
	}
	bcastc = chancreate(sizeof(char*), 0);
	threadcreate(decoratorthread, nil, 8*1024);
	bcastthread(nil);
}
.ps +2
.P2
