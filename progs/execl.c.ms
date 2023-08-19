.P1
.ps -1
.ti -1i
.B
.BX execl.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	print("running ls\en");
	execl("/bin/ls", "ls", "-l", "/usr/nemo", nil);
	print("exec failed: %r\en");
}
.ps +2
.P2
