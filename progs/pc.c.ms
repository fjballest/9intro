.P1
.ps -1
.ti -1i
.B
.BX pc.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

enum {Nmsgs = 4 };

typedef struct Buffer Buffer;
struct Buffer {
	QLock	lck;
	char*	msgs[Nmsgs];	// messages in buffer
	int	hd;		// head of the queue
	int	tl;		// tail. First empty slot.
	int	nmsgs;		// number of messages in buffer.
	Rendez	isfull;		// to sleep because of no room for put
	Rendez	isempty;	// to sleep when nothing to get
};

/* b->lck must be held by caller
 */
void
dump(int fd, char* msg, Buffer* b)
{
	int	i;
	char	buf[512];
	char*	s;

	s = seprint(buf, buf+sizeof(buf), "%s [", msg);
	for (i = b->hd; i != b->tl; i = ++i%Nmsgs)
		s = seprint(s, buf+sizeof(buf),"%s ", b->msgs[i]);
	s = seprint(s, buf+sizeof(buf), "]\en");
	write(fd, buf, s-buf);
}

void
put(Buffer* b, char* msg)
{
	qlock(&b->lck);
	if (b->nmsgs == Nmsgs){
		print("<full>\en");
		rsleep(&b->isfull);
	}
	if (msg == nil)
		b->msgs[b->tl] = nil;
	else
		b->msgs[b->tl] = strdup(msg);
	b->tl = ++b->tl % Nmsgs;
	b->nmsgs++;
	if (b->nmsgs == 1)
		rwakeup(&b->isempty);
	dump(1, "put:", b);
	qunlock(&b->lck);
}

void
init(Buffer *b)
{
	// release all locks, set everything to null values.
	memset(b, 0, sizeof(*b));
	// set the locks used by the Rendezes
	b->isempty.l = &b->lck;
	b->isfull.l = &b->lck;
}

char*
get(Buffer* b)
{
	char*	msg;

	qlock(&b->lck);
	if (b->nmsgs == 0){
		print("<empty>\en");
		rsleep(&b->isempty);
	}
	msg = b->msgs[b->hd];
	b->hd = ++b->hd % Nmsgs;
	b->nmsgs--;
	if (b->nmsgs == Nmsgs - 1)
		rwakeup(&b->isfull);
	dump(1, "get:", b);
	qunlock(&b->lck);
	return msg;
}


void
producer(Buffer* b, char id)
{
	char	msg[20];
	int	i;

	for (i = 0; i < 5 ; i++){
		seprint(msg, msg+20, "%c%d", id, i);
		put(b, msg);
	}
	put(b, nil);
	exits(nil);
}

void
consumer(Buffer* b)
{
	char*	msg;
	while(msg = get(b)){
		// consume it
		free(msg);
	}
	exits(nil);
}

Buffer buf;

void
main(int, char*[])
{
	init(&buf);
	if (rfork(RFPROC|RFMEM|RFNOWAIT) == 0)
		producer(&buf, 'a');
	if (rfork(RFPROC|RFMEM|RFNOWAIT) == 0)
		producer(&buf, 'b');
	if (rfork(RFPROC|RFMEM|RFNOWAIT) == 0)
		consumer(&buf);
	else
		consumer(&buf);
}
.ps +2
.P2
