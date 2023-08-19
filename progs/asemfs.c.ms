.P1
.ps -1
.ti -1i
.B
.BX asemfs.c
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

void
becomenone(void)
{
	int	fd;

	fd = open("#c/user", OWRITE);
	if (fd < 0)
		sysfatal("#c/user: %r");
	if (write(fd, "none", 4) < 0)
		sysfatal("can't become none");
	close(fd);
	newns("none", nil);
	rfork(RFNOMNT);
}

static void
fsattach(Req* r)
{
	becomenone();
	if (authattach(r) < 0)
		return;
	r->fid->qid = (Qid){0,0,QTDIR};
	r->ofcall.qid = r->fid->qid;
	respond(r, nil);
}

static void
fscreate(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;

	fid = r->fid;
	q = fid->qid;
	if (!(q.type&QTDIR)){
		respond(r, "not a directory");
		return;
	}
	s = newsem(r->ifcall.name);
	fid->qid = (Qid){s->id, 0, 0};
	fid->aux = s;
	incref(s);
	r->ofcall.qid = fid->qid;
	respond(r, nil);
}

static int
getdirent(int n, Dir* d, void*)
{
	d->atime= time(nil);
	d->mtime= d->atime;
	d->uid = estrdup9p(getuser());
	d->gid = estrdup9p(d->uid);
	d->muid= estrdup9p(d->uid);
	if (n == -1){
		d->qid = (Qid){0, 0, QTDIR};
		d->mode = 0775;
		d->name = estrdup9p("/");
		d->length = 0;
	} else if (n >= 0 && n < nsems && sems[n] != nil){
		d->qid = (Qid){n, 0, 0};
		d->mode = 0664;
		d->name = estrdup9p(sems[n]->name);
		d->length = sems[n]->tickets;
	} else
		return -1;
	return 0;
}

static void
fsread(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;
	char	nl[2] = "\en";

	fid = r->fid;
	q = fid->qid;
	if (q.type&QTAUTH){
		authread(r);
		return;
	}
	if (q.type&QTDIR){
		dirread9p(r, getdirent, nil);
		respond(r, nil);
		return;
	}
	s = fid->aux;
	if (s->tickets > 0){
		s->tickets--;
		readstr(r, nl);
		respond(r, nil);
	} else
		queuereq(s, r);
}

static void
fswrite(Req* r)
{
	Fid*	fid;
	Qid	q;
	Sem*	s;
	char	str[10];
	Req*	qr;
	char	nl[2] = "\en";

	fid = r->fid;
	q = fid->qid;
	if (q.type&QTAUTH){
		authwrite(r);
		return;
	}
	if (q.type&QTDIR){
		respond(r, "permission denied");
		return;
	}
	if (r->ifcall.count > sizeof(str) - 1){
		respond(r, "string too large");
		return;
	}
	memmove(str, r->ifcall.data, r->ifcall.count);
	str[r->ifcall.count] = 0;
	s = fid->aux;
	s->tickets += atoi(str);
	while(s->tickets > 0 && queuedreqs(s)){
		qr = dequeuereq(s);
		qr->ofcall.count = 1;
		s->tickets--;
		readstr(qr, nl);
		respond(qr, nil);
	}
	respond(r, nil);
}

static char*
fswalk1(Fid* fid, char* name, Qid* qid)
{
	Qid	q;
	int	i;
	Sem*	s;

	q = fid->qid;
	s = fid->aux;
	if (!(q.type&QTDIR)){
		if (!strcmp(name, "..")){
			fid->qid = (Qid){0,0,QTDIR};
			*qid = fid->qid;
			closesem(s);
			fid->aux = nil;
			return nil;
		}
	} else {
		for (i = 0; i < nsems; i++)
			if (sems[i] && !strcmp(name, sems[i]->name)){
				fid->qid = (Qid){i, 0, 0};
				incref(sems[i]);
				closesem(fid->aux);
				fid->aux = sems[i];
				*qid = fid->qid;
				return nil;
			}
	}
	return "no such file";
}

static char*
fsclone(Fid* fid, Fid* newfid)
{
	Sem*	s;

	s = fid->aux;
	if (s != nil)
		incref(s);
	newfid->aux = s;
	return nil;
}

static void
fsstat(Req* r)
{
	Fid*	fid;
	Qid	q;
	
	fid = r->fid;
	q = fid->qid;
	if (q.type&QTDIR)
		getdirent(-1, &r->d, nil);
	else
		getdirent(q.path, &r->d, nil);
	respond(r, nil);
}

static void
fsremove(Req* r)
{
	Sem*	s;

	s = r->fid->aux;
	closesem(s);
	r->fid->aux = nil;
	closesem(s);	// release reference from sems[]
	respond(r, nil);
}

static void
freefid(Fid* fid)
{
	Sem*	s;

	if (fid->qid.type&QTAUTH)
		authdestroy(fid);
	else {
		s = fid->aux;
		fid->aux = nil;
		closesem(s);
	}
}

static Srv sfs=
{
	.auth	=	auth9p,
	.attach =	fsattach,
	.create	=	fscreate,
	.remove =	fsremove,
	.read	=	fsread,
	.write	=	fswrite,
	.walk1	=	fswalk1,
	.clone	=	fsclone,
	.stat	=	fsstat,
	.destroyfid=	freefid,
	.keyspec	=	"proto=p9any role=server"
};

void
usage(void)
{
	fprint(2, "usage: %s [-D] [-s srv] [-m mnt]\en", argv0);
	threadexitsall("usage");
}


void
threadmain(int argc, char **argv)
{
	char*	mnt;
	char*	srv;

	srv = nil;
	mnt = nil;
	ARGBEGIN{
	case 'D':
		chatty9p++;
		break;
	case 's':
		srv = EARGF(usage());
		break;
	case 'm':
		mnt = EARGF(usage());
		break;
	default:
		usage();
	}ARGEND;

	if(argc!= 0)
		usage();
	if (srv == nil && mnt == nil)
		mnt = "/mnt/sem";
	threadpostmountsrv(&sfs, srv, mnt, MREPL|MCREATE);
	threadexits(nil);
}
.ps +2
.P2
