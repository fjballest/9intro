.P1
.ps -1
.ti -1i
.B
.BX alarm.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

int
handler(void*, char* msg)
{
	if (!strcmp(msg, "alarm")){
		fprint(2, "timed out\en");
		return 1;
	}
	return 0;
}

void
main(int, char*[])
{
	char	buf[1024];
	long	nr;

	atnotify(handler, 1);
	print("type something: ");
	alarm(30 * 1000);	// 30 secs.
	nr = read(0, buf, sizeof buf);
	alarm(0);
	if (nr >= 0)
		write(1, buf, nr);
	exits(nil);
}
.ps +2
.P2
