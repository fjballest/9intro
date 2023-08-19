.P1
.ps -1
.ti -1i
.B
.BX noterfork.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int, char*[])
{
	int	i;

	rfork(RFNOTEG);
	for(i = 0; i < 5; i++){
		sleep(1000);
		print("%d ", i);
	}
	print("\en");
	exits(nil);
}
.ps +2
.P2
