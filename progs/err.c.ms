.P1
.ps -1
.ti -1i
.B
.BX err.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	if (chdir("magic") < 0){
		sysfatal("chdir failed: %r\en");
	}
	/* ... do other things ... */
	exits(nil);
}
.ps +2
.P2
