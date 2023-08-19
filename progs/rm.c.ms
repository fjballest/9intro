.P1
.ps -1
.ti -1i
.B
.BX rm.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	i;
 
	for (i = 1; i < argc; i++)
		if (remove(argv[i]) < 0)
			fprint(2, "%s:  %r\en", argv[0]);
	exits(nil);
}
.ps +2
.P2
