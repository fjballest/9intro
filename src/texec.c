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
	ln[nr-1] = 0;	// drop \n
	pidc = chancreate(sizeof(ulong), 1);
	waitc= threadwaitchan();
	proccreate(cmdproc, ln, 8*1024);
	pid = recvul(pidc);
	print("started new proc pid=%d\n", pid);
	if (pid >= 0){
		m = recvp(waitc);
		print("terminated pid=%d sts=%s\n", m->pid, m->msg);
		free(m);
	}
	threadexits(nil);
}
