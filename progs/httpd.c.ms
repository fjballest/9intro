.P1
.ps -1
.ti -1i
.B
.BX httpd.c
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

	switch(rfork(RFPROC|RFNOTEG)){
	case 0:
		for(i = 0; i < 5; i++){
			sleep(1000);
			print("%d ", i);
		}
		print("\en");
		exits(nil);
	case -1:
		sysfatal("rfork: %r");
	default:
		break;
	}
	exits(nil);
}
.ps +2
.P2
