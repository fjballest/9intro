.P1
.ps -1
.ti -1i
.B
.BX cnt2.c
.ps +1
.CW
.ps -2
.vs .15i
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
			print("%d\en", cnt);
			unlock(&cntlck);
		}
	default:
		for(;;){
			lock(&cntlck);
			assert(cnt >= 0);
			if (cnt > 0)
				cnt--;
			print("%d\en", cnt);
			unlock(&cntlck);
		}
	}
}
.ps +2
.P2
