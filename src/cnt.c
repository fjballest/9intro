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
			unlock(&cntlck);
			now = time(nil);
			if (now - last >= 1){
				lock(&cntlck);
				print("cnt= %d\n", cnt);
				unlock(&cntlck);
				last = now;
			}
		}
	default:
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			if (cnt > 0)
				cnt--;
			unlock(&cntlck);
		}
	}
}
