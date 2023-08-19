.P1
.ps -1
.ti -1i
.B
.BX texec.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
#include <thread.h>

Channel*waitc;
Channel*pidc;

void
cmdproc(void* arg)
{
	char*	cmd = arg;

	procexecl(pidc, cmd, cmd, nil);
	sysfatal("procexecl: %r");
}

.ps +2
.P2
.P1
.ps -2
void
threadmain(int, char*[])
{
	char	ln[512];
	int	pid, nr;
	Waitmsg	*m;

	write(1, "cmd? ", 5);
	nr = read(0, ln, sizeof(ln)-1);
	if (nr <= 1)
		threadexits(nil);
	ln[nr-1] = 0;	// drop \en
	pidc = chancreate(sizeof(ulong), 1);
	waitc= threadwaitchan();
	proccreate(cmdproc, ln, 8*1024);
	pid = recvul(pidc);
	print("started new proc pid=%d\en", pid);
	if (pid >= 0){
		m = recvp(waitc);
		print("terminated pid=%d sts=%s\en", m->pid, m->msg);
		free(m);
	}
	threadexits(nil);
}
.ps +2
.P2
