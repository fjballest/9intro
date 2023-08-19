.P1
.ps -1
.ti -1i
.B
.BX qcnt.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

int	cnt;
QLock	cntlck;

void
main(int, char*[])
{
	long	last, now;

	switch(rfork(RFPROC|RFMEM|RFNOWAIT)){
	case -1:
		sysfatal("fork: %r");
.ps +2
.P2
.P1
.ps -2
.vs .15i
	case 0:
		last = time(nil);
		for(;;){
			qlock(&cntlck);
			assert(cnt >= 0);
			cnt++;
			print("%d\en", cnt);
			qunlock(&cntlck);
		}
	default:
		for(;;){
			qlock(&cntlck);
			assert(cnt >= 0);
			if (cnt > 0)
				cnt--;
			print("%d\en", cnt);
			qunlock(&cntlck);
		}
	}
}
.ps +2
.P2
