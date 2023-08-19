#include <u.h>
#include <libc.h>
#include <bio.h>
#include <thread.h>

enum { Npanels = 2 };
Channel*bcastc;		// of char*
Channel*panelc[Npanels];	// of char*


typedef struct PArg PArg;
struct PArg {
	Channel* c;	// to get new messages from
	int	fd;	// to the panel's file.
};

void
consreadthread(void*)
{
	Biobuf	bin;
	char*	ln;

	threadsetname("consread");
	Binit(&bin, 0, OREAD);
	while (ln = Brdstr(&bin, '\n', 0))
		sendp(bcastc, ln);
	sendp(bcastc, nil);
	Bterm(&bin);
	threadexits(nil);
}

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

void
threadmain(int, char*[])
{
	int	i;
	PArg*	arg;

	bcastc = chancreate(sizeof(char*), 0);
	proccreate(consreadthread, nil, 16*1024);
	for (i = 0; i < Npanels; i++){
		panelc[i] = chancreate(sizeof(char*), 0);
		arg = malloc(sizeof(*arg));
		arg->c = panelc[i];
		arg->fd = 1;		// to test the program.
		proccreate(panelthread, arg, 8*1024);
	}
	// The current thread used for bcast.
	bcastthread(nil);
}
