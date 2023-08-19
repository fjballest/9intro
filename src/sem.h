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
