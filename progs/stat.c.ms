.P1
.ps -1
.ti -1i
.B
.BX stat.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	Dir*	d;

	d = dirstat("/NOTICE");
	if (d == nil)
		sysfatal("dirstat: %r");
	print("file name: %s\en", d->name);
	print("file mode: 0%o\en", d->mode);
	print("file size: %d bytes\en", d->length);
	free(d);
	exits(nil);
}
.ps +2
.P2
