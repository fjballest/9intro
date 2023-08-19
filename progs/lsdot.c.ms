.P1
.ps -1
.ti -1i
.B
.BX lsdot.c
.ps +1
.CW
.ps -2
.vs .15i
#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	Dir*	dents;
	int	ndents, fd, i;

	fd = open(".", OREAD);
	if (fd < 0)
		sysfatal("open: %r");
	for(;;){
		ndents = dirread(fd, &dents);
		if (ndents == 0)
			break;
		for (i = 0; i < ndents; i++)
			print("%s\en", dents[i].name);
		free(dents);
	}
	exits(nil);
}
.ps +2
.P2
