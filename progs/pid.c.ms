.P1
.ps -1
.ti -1i
.B
.BX pid.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	pid;

	pid = getpid();
	print("my pid is %d\en", pid);
	exits(nil);
}
.ps +2
.P2
