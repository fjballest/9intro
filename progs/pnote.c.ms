.P1
.ps -1
.ti -1i
.B
.BX pnote.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

int
handler(void*, char* msg)
{
	print("note: %s\en", msg);
	return 0;
}

void
main(int, char*[])
{
	atnotify(handler, 1);
	sleep(3600 * 1000);	// one hour to play
	print("done (%r)\en");
	exits(nil);
}
.ps +2
.P2
