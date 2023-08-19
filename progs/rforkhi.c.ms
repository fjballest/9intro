.P1
.ps -1
.ti -1i
.B
.BX rforkhi.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>
 
void
main(int, char*argv[])
{
	print("hi\en");
	rfork(RFCFDG);
	print("there\en");
	exits(nil);
}
.ps +2
.P2
