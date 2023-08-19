#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(fork()){
	case -1:
		sysfatal("fork failed");
	case 0:
		close(0);	// WRONG!
		open("/NOTICE", OREAD);
		execl("/bin/cat", "cat", nil);
		sysfatal("exec: %r");
	default:
		waitpid();
	}
	exits(nil);
}
