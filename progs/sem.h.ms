.P1
.ps -1
.ti -1i
.B
.BX sem.h
.ps +1
.CW
.ps -2
.vs .15i
typedef struct Sem Sem;
typedef struct QReq QReq;

struct Sem {
	Ref;
	int	id;
	char*	name;
	int	tickets;
	QReq*	reqs;
};

struct QReq {
	QReq*	next;
	Req*	r;
};

enum {
	Nsems = 255
};

Sem*		newsem(char* name);
Req*		dequeuereq(Sem* s);
int		queuedreqs(Sem* s);
void		closesem(Sem* s);
void		queuereq(Sem* s, Req* r);

extern Sem*	sems[Nsems];
extern int	nsems;
.ps +2
.P2
