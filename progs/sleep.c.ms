.P1
.ps -1
.ti -1i
.B
.BX sleep.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
void
main(int, char*[])
{
	print("process pid is %d. have fun.\en", getpid());
	sleep(3600*1000); // one hour to play
	exits(nil);
}
.ps +2
.P2
