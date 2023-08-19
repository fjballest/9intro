#include <u.h>
#include <libc.h>

void
main(int , char* [])
{
	int	i;
 
	for (i = 1; i < argc; i++)
		if (remove(argv[i]) < 0)
			fprint(2, "%s:  %r\n", argv[0]);
	exits(nil);
}
