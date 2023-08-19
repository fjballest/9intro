.P1
.ps -1
.ti -1i
.B
.BX env.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	char*	home;

	home = getenv("home");
	if (home == nil)
		sysfatal("we are homeless");
	print("home is %s\en", home);
	exits(nil);
}
.ps +2
.P2
