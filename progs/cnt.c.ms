.P1
.ps -1
.ti -1i
.B
.BX cnt.c
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

.ps +2
.P2
.P1
.ps -2
.vs .15i
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
.ps +2
.P2
.P1
.ps -2
.vs .15i
			if (now - last >= 1){
				lock(&cntlck);
				print("cnt= %d\en", cnt);
				unlock(&cntlck);
				last = now;
			}
		}
.ps +2
.P2
.P1
.ps -2
.vs .15i
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
.ps +2
.P2
