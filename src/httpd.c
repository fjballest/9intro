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
		print("\n");
		exits(nil);
	case -1:
		sysfatal("rfork: %r");
	default:
		break;
	}
	exits(nil);
}
