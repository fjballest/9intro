.P1
.ps -1
.ti -1i
.B
.BX pollb.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	Dir*	d;
	ulong	mtime, nmtime;

	if (argc != 2){
		fprint(2, "usage: %s file\en", argv[0]);
		exits("usage");
	}
	d = dirstat(argv[1]);
	if (d == nil)
		sysfatal("dirstat: %r");
	mtime = d->mtime;
	free(d);
	do {
		sleep(5 * 1000);
		d = dirstat(argv[1]);
		if (d == nil)
			break;
		nmtime = d->mtime;
		free(d);
	} while(nmtime == mtime);
	print("%s changed\en", argv[1]);
	exits(nil);
}
.ps +2
.P2
