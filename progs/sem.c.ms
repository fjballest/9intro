.P1
.ps -1
.ti -1i
.B
.BX sem.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <auth.h>
#include <thread.h>
#include <fcall.h>
#include <9p.h>
#include "sem.h"



Sem*	sems[Nsems];
int	nsems;

Sem*
newsem(char* name)
{
	int	i;

	for (i = 0; i < Nsems; i++)
		if (sems[i] == nil)
			break;
	if (i == Nsems)
		return nil;
	if (i == nsems)
		nsems++;
	sems[i] = emalloc9p(sizeof(Sem));
	memset(sems[i], 0, sizeof(Sem));
	sems[i]->ref = 1;
	sems[i]->id = i;
	sems[i]->name = estrdup9p(name);
	return sems[i];
}

void
closesem(Sem* s)
{
	QReq*	q;

	if (s != nil && decref(s) == 0){
		free(s->name);
		while(s->reqs != nil){
			q = s->reqs;
			s->reqs = q->next;
			respond(q->r, "file has been removed");
			free(q);
		}
		assert(sems[s->id] == s);
		sems[s->id] = nil;
		free(s);
	}
}

void
queuereq(Sem* s, Req* r)
{
	QReq*	q;
	QReq**	l;

	q = emalloc9p(sizeof(QReq));
	q->r = r;
	q->next = nil;
	for (l = &s->reqs; *l != nil; l = &(*l)->next)
		;
	*l = q;
}

Req*
dequeuereq(Sem* s)
{
	QReq*	q;
	Req*	r;

	if (s->reqs == nil)
		return nil;
	q = s->reqs;
	s->reqs = q->next;
	r = q->r;
	free(q);
	return r;
}

int
queuedreqs(Sem* s)
{
	return s->reqs != nil;
}
.ps +2
.P2
