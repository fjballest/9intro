#include <u.h>
#include <libc.h>

void
chgrp(char* gid, char* fname)
{
	Dir	d;

	nulldir(&d);
	d.gid = gid;
	if (dirwstat(fname, &d) < 0)
		fprint(2, "chgrp: wstat: %r\n");
}

void
main(int argc, char* argv[])
{
	int	i;

	if (argc < 3){
		fprint(2, "usage: %s gid file...\n", argv[0]);
		exits("usage");
	}
	for (i = 2; i < argc; i++)
		chgrp(argv[1], argv[i]);
	exits(nil);
}
