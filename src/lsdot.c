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
			print("%s\n", dents[i].name);
		free(dents);
	}
	exits(nil);
}
