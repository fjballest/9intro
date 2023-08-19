#include <u.h>
#include <libc.h>

typedef struct Msg Msg;
struct Msg {
	QLock	lck;	// to protect the other fields from races
	char*	text;	// for the message
	ulong	vers;	// for the message
};
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
		qlock(&msg.lck);
		free(msg.text);
		msg.text = strdup(buf);
		msg.vers++;
		qunlock(&msg.lck);
	}
	exiting = 1;
	exits(nil);
}

void
panelproc(int fd)
{
	ulong	lastvers = -1;

	while(!exiting){
		qlock(&msg.lck);
		if(msg.text != nil && lastvers != msg.vers){
			write(fd, msg.text, strlen(msg.text));
			lastvers = msg.vers;
		}
		qunlock(&msg.lck);
		sleep(5 * 1000);
	}
	fprint(2, "panel exiting\n");
	exits(nil);
}

enum { Npanels = 3 };

void
main(int, char*[])
{
	int	i;

	for (i = 0; i < Npanels; i++)
		if (rfork(RFPROC|RFMEM|RFNOWAIT) == 0)
			panelproc(1);
	reader();
	/* does not return */
}
