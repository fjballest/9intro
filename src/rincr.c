#include <u.h>
#include <libc.h>

int	cnt;

void
main(int, char*[])
{
	int	i;

	if (rfork(RFPROC|RFMEM|RFNOWAIT) < 0)
		sysfatal("fork: %r");
	for (i = 0; i < 2; i++)
		cnt++;
	print("cnt is %d\n", cnt);
	exits(nil);
}
