.P1
.ps -1
.ti -1i
.B
.BX rendez.c
.ps +1
.CW
.ps -2
.vs .15i
void
main(int, char*[])
{
	int	i;
	int	childsts;

	switch(rfork(RFPROC|RFNOTEG|RFNOWAIT)){
	case 0:
		if (httpinit() < 0)
			rendezvous(&main, (void*)-1);
		else
			rendezvous(&main, (void*)0);
		httpservice();	// do the job.
		exits(nil);
	case -1:
		sysfatal("rfork: %r");
	default:
		childsts = (int)rendezvous(&main, (void*)0);
		if (childsts == 0)
			exits(nil);
		else {
			fprint(2, "httpinit failed\en");
			exits("httpinit failed");
		}
	}
}
.ps +2
.P2
