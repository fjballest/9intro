.P1
.ps -1
.ti -1i
.B
.BX chgrp.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
chgrp(char* gid, char* fname)
{
	Dir	d;

	nulldir(&d);
	d.gid = gid;
	if (dirwstat(fname, &d) < 0)
		fprint(2, "chgrp: wstat: %r\en");
}

void
main(int argc, char* argv[])
{
	int	i;

	if (argc < 3){
		fprint(2, "usage: %s gid file...\en", argv[0]);
		exits("usage");
	}
	for (i = 2; i < argc; i++)
		chgrp(argv[1], argv[i]);
	exits(nil);
}
.ps +2
.P2
