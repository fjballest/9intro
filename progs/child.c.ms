.P1
.ps -1
.ti -1i
.B
.BX child.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	switch(fork()){
	case -1:
		sysfatal("fork failed\en");
	case 0:
		print("I am the child\en");
		break;
	default:
		print("I am the parent\en");
	}
	exits(nil);
}
.ps +2
.P2
