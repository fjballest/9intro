#include <u.h>
#include <libc.h>

int	cnt;

void
main(int, char*[])
{
	int	i;
	int	loc;

	if (rfork(RFPROC|RFMEM|RFNOWAIT) < 0)
		sysfatal("fork: %r");
	for (i = 0; i < 2; i++){
		loc = cnt;
		sleep(1);
		loc++;
		cnt = loc;
	}
	print("cnt is %d\n", cnt);
	exits(nil);
}
