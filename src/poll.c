#include <u.h>
#include <libc.h>

void
main(int argc, char* argv[])
{
	Dir*	d;
	ulong	mtime, nmtime;

	if (argc != 2){
		fprint(2, "usage: %s file\n", argv[0]);
		exits("usage");
	}
	d = dirstat(argv[1]);
	if (d == nil)
		sysfatal("dirstat: %r");
	mtime = d->mtime;
	free(d);
	do {
		d = dirstat(argv[1]);
		if (d == nil)
			break;
		nmtime = d->mtime;
		free(d);
	} while(nmtime == mtime);
	print("%s changed\n", argv[1]);
	exits(nil);
}
