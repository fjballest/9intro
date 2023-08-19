#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(fork()){
	case -1:
		sysfatal("fork failed\n");
	case 0:
		print("I am the child\n");
		break;
	default:
		print("I am the parent\n");
	}
	exits(nil);
}
