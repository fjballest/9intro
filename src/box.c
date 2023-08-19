#include <u.h>
#include <libc.h>
#include <auth.h>	// for newns
void
main(int argc, char* argv[])
{
	char*	user;

	if (argc != 2){
		fprint(2, "usage: %s ns prog\n", argv0);
		sysfatal("usage");
	}
	switch(rfork(RFPROC|RFNAMEG)){
	case -1:
		sysfatal("fork: %r");
	default:
		waitpid();
		exits(nil);
	case 0:
		user = getuser();
		if (newns(user, argv[1]) < 0)
			sysfatal("newns: %r");
		rfork(RFNOMNT);
		execl(argv[1], argv[1], nil);
		sysfatal("exec: %r");
	}
}

