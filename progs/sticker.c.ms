.P1
.ps -1
.ti -1i
.B
.BX sticker.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>


typedef struct Msg Msg;
struct Msg {
	QLock	lck;	// to protect the other fields from races
	Rendez	newmsg;	// to sleep waiting for a new message.
	char*	text;	// for the message
};

void
wmsg(Msg* m, char* newtext)
{
	qlock(&m->lck);
	free(m->text);
	m->text = strdup(newtext);
	rwakeupall(&m->newmsg);
	qunlock(&m->lck);
}

char*
rmsg(Msg* m)
{
	char*	new;

	qlock(&m->lck);
	rsleep(&m->newmsg);
	new = strdup(m->text);
	qunlock(&m->lck);
	return new;
}

int	exiting;
Msg	msg;

void
reader(void)
{
	char	buf[512];
	int	nr;

	for(;;){
		nr = read(0, buf, sizeof(buf)-1);
		if (nr <= 0)
			break;
		buf[nr] = 0;
		wmsg(&msg, buf);
	}
	exiting = 1;
	exits(nil);
}

void
panelproc(int fd)
{
	ulong	lastvers = -1;
	char*	text;

	while(!exiting){
		text = rmsg(&msg);
		write(fd, text, strlen(text));
		free(text);
	}
	fprint(2, "panel exiting\en");
	exits(nil);
}

enum { Npanels = 3 };

void
main(int, char*[])
{
	int	i;

	msg.newmsg.l = &msg.lck;
	for (i = 0; i < Npanels; i++)
		if (rfork(RFPROC|RFMEM|RFNOWAIT) == 0)
			panelproc(1);
	reader();
	/* does not return */
}
.ps +2
.P2
