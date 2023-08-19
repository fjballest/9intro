#include <u.h>
#include <libc.h>

int	cnt;
Lock	cntlck;

void
main(int, char*[])
{
	long	last, now;

	switch(rfork(RFPROC|RFMEM|RFNOWAIT)){
	case -1:
		sysfatal("fork: %r");
	case 0:
		last = time(nil);
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			cnt++;
			print("%d\n", cnt);
			unlock(&cntlck);
		}
	default:
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			if (cnt > 0)
				cnt--;
			print("%d\n", cnt);
			unlock(&cntlck);
		}
	}
}
